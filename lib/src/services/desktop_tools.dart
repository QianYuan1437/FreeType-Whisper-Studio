import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/whisper_model.dart';

class DesktopTools {
  Future<String> defaultModelDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'FreeType', 'models'));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  Future<List<String>> availableModelFiles(String modelDirectory) async {
    final dir = Directory(modelDirectory);
    if (!dir.existsSync()) {
      return const [];
    }
    return dir
        .listSync()
        .whereType<File>()
        .map((file) => file.path)
        .where((path) => path.endsWith('.bin') || path.endsWith('.gguf'))
        .toList()
      ..sort();
  }

  Future<String?> autoLocateWhisperExecutable() {
    final names = Platform.isWindows
        ? ['whisper-cli.exe', 'whisper.exe', 'main.exe']
        : ['whisper-cli', 'whisper', 'main'];
    return _findExecutable(names, extraDirectories: _whisperCandidateDirectories());
  }

  Future<String?> autoLocateFFmpegExecutable() {
    final names = Platform.isWindows ? ['ffmpeg.exe'] : ['ffmpeg'];
    return _findExecutable(names, extraDirectories: _ffmpegCandidateDirectories());
  }

  Future<File> downloadModel({
    required WhisperModelInfo model,
    required String modelDirectory,
    required void Function(double progress) onProgress,
  }) async {
    final target = File(p.join(modelDirectory, model.fileName));
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(model.downloadUrl));
    final response = await request.close();
    if (response.statusCode >= 400) {
      throw HttpException('Failed to download model: ${response.statusCode}');
    }

    final sink = target.openWrite();
    final total = response.contentLength;
    var received = 0;
    await for (final chunk in response) {
      sink.add(chunk);
      received += chunk.length;
      if (total > 0) {
        onProgress(received / total);
      }
    }
    await sink.close();
    client.close(force: true);
    onProgress(1);
    return target;
  }

  Future<File> extractAudioFromVideo({
    required String ffmpegPath,
    required String videoPath,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final outFile = File(
      p.join(
        tempDir.path,
        'freetype_${DateTime.now().millisecondsSinceEpoch}.wav',
      ),
    );

    final result = await Process.run(ffmpegPath, [
      '-y',
      '-i',
      videoPath,
      '-vn',
      '-acodec',
      'pcm_s16le',
      '-ar',
      '16000',
      '-ac',
      '1',
      outFile.path,
    ]);

    if (result.exitCode != 0) {
      throw ProcessException(
        ffmpegPath,
        const [],
        '${result.stderr}',
        result.exitCode,
      );
    }
    return outFile;
  }

  Future<File> createWaveFileFromPcm({
    required List<int> pcmBytes,
    int sampleRate = 16000,
    int channels = 1,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final output = File(
      p.join(
        tempDir.path,
        'freetype_stream_${DateTime.now().microsecondsSinceEpoch}.wav',
      ),
    );
    final bytes = _buildWaveBytes(
      pcmBytes: pcmBytes,
      sampleRate: sampleRate,
      channels: channels,
    );
    await output.writeAsBytes(bytes, flush: true);
    return output;
  }

  Future<String> transcribeAudio({
    required String whisperPath,
    required String modelPath,
    required String audioPath,
    String language = 'auto',
    List<String> extraArgs = const [],
  }) async {
    final tempDir = await getTemporaryDirectory();
    final base = p.join(
      tempDir.path,
      'whisper_${DateTime.now().microsecondsSinceEpoch}',
    );
    final args = <String>[
      '-m',
      modelPath,
      '-f',
      audioPath,
      if (language != 'auto') ...['-l', language],
      ...extraArgs,
      '-otxt',
      '-of',
      base,
    ];
    final result = await Process.run(whisperPath, args);

    if (result.exitCode != 0) {
      throw ProcessException(
        whisperPath,
        args,
        '${result.stderr}',
        result.exitCode,
      );
    }

    final txtFile = File('$base.txt');
    if (txtFile.existsSync()) {
      return txtFile.readAsString();
    }

    if (result.stdout is List<int>) {
      return utf8.decode(result.stdout as List<int>);
    }
    return '${result.stdout}';
  }

  Future<String> testComputeRuntime({
    required String whisperPath,
    String? modelPath,
  }) async {
    final helpOutput = await _readWhisperHelp(whisperPath);
    final lower = helpOutput.toLowerCase();
    final backendHints = <String>[];
    for (final backend in ['cuda', 'vulkan', 'opencl', 'metal', 'coreml']) {
      if (lower.contains(backend)) {
        backendHints.add(backend.toUpperCase());
      }
    }

    final lines = <String>[
      'Whisper executable: ${p.basename(whisperPath)}',
      'CPU: available (${Platform.numberOfProcessors} logical processors detected)',
      if (modelPath != null && modelPath.isNotEmpty && File(modelPath).existsSync())
        'Model: ${p.basename(modelPath)}',
      backendHints.isEmpty
          ? 'Whisper runtime hints: no explicit GPU backend keywords were found in the help output.'
          : 'Whisper runtime hints: ${backendHints.join(', ')} support keywords detected.',
      await _platformHardwareSummary(),
    ];
    return lines.join('\n');
  }

  Future<File> saveMarkdown({
    required String outputPath,
    required String content,
  }) async {
    final file = File(outputPath);
    await file.writeAsString(content);
    return file;
  }

  List<int> _buildWaveBytes({
    required List<int> pcmBytes,
    required int sampleRate,
    required int channels,
  }) {
    const bitsPerSample = 16;
    final byteRate = sampleRate * channels * bitsPerSample ~/ 8;
    final blockAlign = channels * bitsPerSample ~/ 8;
    final totalSize = 44 + pcmBytes.length;
    final bytes = BytesBuilder(copy: false);

    void writeString(String value) {
      bytes.add(ascii.encode(value));
    }

    void writeUint32(int value) {
      final data = ByteData(4)..setUint32(0, value, Endian.little);
      bytes.add(data.buffer.asUint8List());
    }

    void writeUint16(int value) {
      final data = ByteData(2)..setUint16(0, value, Endian.little);
      bytes.add(data.buffer.asUint8List());
    }

    writeString('RIFF');
    writeUint32(totalSize - 8);
    writeString('WAVE');
    writeString('fmt ');
    writeUint32(16);
    writeUint16(1);
    writeUint16(channels);
    writeUint32(sampleRate);
    writeUint32(byteRate);
    writeUint16(blockAlign);
    writeUint16(bitsPerSample);
    writeString('data');
    writeUint32(pcmBytes.length);
    bytes.add(pcmBytes);
    return bytes.toBytes();
  }

  List<String> parseArguments(String rawArgs) {
    final args = <String>[];
    final buffer = StringBuffer();
    String? quote;
    var escaping = false;

    for (final char in rawArgs.split('')) {
      if (escaping) {
        buffer.write(char);
        escaping = false;
        continue;
      }
      if (char == r'\') {
        escaping = true;
        continue;
      }
      if (quote != null) {
        if (char == quote) {
          quote = null;
        } else {
          buffer.write(char);
        }
        continue;
      }
      if (char == '"' || char == "'") {
        quote = char;
        continue;
      }
      if (RegExp(r'\s').hasMatch(char)) {
        if (buffer.isNotEmpty) {
          args.add(buffer.toString());
          buffer.clear();
        }
        continue;
      }
      buffer.write(char);
    }

    if (buffer.isNotEmpty) {
      args.add(buffer.toString());
    }
    return args;
  }

  Future<String?> _findExecutable(
    List<String> names, {
    List<String> extraDirectories = const [],
  }) async {
    final pathSeparator = Platform.isWindows ? ';' : ':';
    final searchedDirs = <String>{
      ...extraDirectories.where((value) => value.isNotEmpty),
      ...(Platform.environment['PATH'] ?? '').split(pathSeparator).where((value) => value.isNotEmpty),
    };

    for (final dir in searchedDirs) {
      for (final name in names) {
        final candidate = File(p.join(dir, name));
        if (candidate.existsSync()) {
          return candidate.path;
        }
      }
    }

    final command = Platform.isWindows ? 'where' : 'which';
    for (final name in names) {
      try {
        final result = await Process.run(command, [name]);
        if (result.exitCode == 0) {
          final output = '${result.stdout}'.trim().split(RegExp(r'[\r\n]+')).firstWhere(
            (line) => line.trim().isNotEmpty,
            orElse: () => '',
          );
          if (output.isNotEmpty) {
            return output.trim();
          }
        }
      } catch (_) {}
    }
    return null;
  }

  List<String> _whisperCandidateDirectories() {
    if (Platform.isWindows) {
      return const [
        'C:\\whisper',
        'C:\\whisper.cpp',
        'D:\\whisper',
        'D:\\whisper.cpp',
      ];
    }
    return const ['/usr/local/bin', '/usr/bin', '/opt/homebrew/bin'];
  }

  List<String> _ffmpegCandidateDirectories() {
    if (Platform.isWindows) {
      return const [
        'C:\\ffmpeg\\bin',
        'D:\\ffmpeg\\bin',
        'D:\\ffmpeg-8.0.1\\bin',
        'C:\\Program Files\\ffmpeg\\bin',
      ];
    }
    return const ['/usr/local/bin', '/usr/bin', '/snap/bin'];
  }

  Future<String> _readWhisperHelp(String whisperPath) async {
    for (final args in const [
      ['-h'],
      ['--help'],
      ['-hh'],
    ]) {
      try {
        final result = await Process.run(whisperPath, args);
        final output = '${result.stdout}\n${result.stderr}'.trim();
        if (output.isNotEmpty) {
          return output;
        }
      } catch (_) {}
    }
    return 'Help output not available.';
  }

  Future<String> _platformHardwareSummary() async {
    if (Platform.isWindows) {
      return _windowsHardwareSummary();
    }
    if (Platform.isLinux) {
      return _linuxHardwareSummary();
    }
    return 'GPU detection: unsupported on this platform.';
  }

  Future<String> _windowsHardwareSummary() async {
    try {
      final result = await Process.run('powershell', [
        '-NoProfile',
        '-Command',
        'Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name'
      ]);
      final lines = '${result.stdout}'
          .split(RegExp(r'[\r\n]+'))
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      if (lines.isEmpty) {
        return 'GPU detection: no GPU adapter names were returned by Windows.';
      }
      return 'GPU detection: ${lines.join(', ')}';
    } catch (_) {
      return 'GPU detection: unable to query GPU adapters on Windows.';
    }
  }

  Future<String> _linuxHardwareSummary() async {
    try {
      final result = await Process.run('/bin/sh', [
        '-lc',
        'if command -v nvidia-smi >/dev/null 2>&1; then nvidia-smi --query-gpu=name --format=csv,noheader; '
            'elif command -v lspci >/dev/null 2>&1; then lspci | grep -i "vga\\|3d\\|display"; '
            'else echo "No GPU probe command found"; fi'
      ]);
      final lines = '${result.stdout}'
          .split(RegExp(r'[\r\n]+'))
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      if (lines.isEmpty) {
        return 'GPU detection: no GPU adapter names were returned by Linux tools.';
      }
      return 'GPU detection: ${lines.join(', ')}';
    } catch (_) {
      return 'GPU detection: unable to query GPU adapters on Linux.';
    }
  }
}
