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
}
