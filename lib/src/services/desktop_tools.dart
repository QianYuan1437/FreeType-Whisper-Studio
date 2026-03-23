import 'dart:convert';
import 'dart:io';

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

  Future<String> transcribeAudio({
    required String whisperPath,
    required String modelPath,
    required String audioPath,
    String language = 'auto',
  }) async {
    final tempDir = await getTemporaryDirectory();
    final base = p.join(
      tempDir.path,
      'whisper_${DateTime.now().microsecondsSinceEpoch}',
    );
    final result = await Process.run(whisperPath, [
      '-m',
      modelPath,
      '-f',
      audioPath,
      '-l',
      language,
      '-otxt',
      '-of',
      base,
    ]);

    if (result.exitCode != 0) {
      throw ProcessException(
        whisperPath,
        const [],
        '${result.stderr}',
        result.exitCode,
      );
    }

    final txtFile = File('$base.txt');
    if (txtFile.existsSync()) {
      return txtFile.readAsString();
    }

    return utf8.decode(result.stdout is List<int> ? result.stdout : const []);
  }

  Future<File> saveMarkdown({
    required String outputPath,
    required String content,
  }) async {
    final file = File(outputPath);
    await file.writeAsString(content);
    return file;
  }
}
