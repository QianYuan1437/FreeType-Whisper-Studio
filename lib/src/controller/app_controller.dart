import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/whisper_model.dart';
import '../services/desktop_tools.dart';
import '../services/live_transcriber.dart';

class AppController extends ChangeNotifier {
  final DesktopTools _tools = DesktopTools();
  LiveTranscriber? _liveTranscriber;

  ThemeMode themeMode = ThemeMode.system;
  String localeCode = 'zh';
  bool isReady = false;
  bool isBusy = false;
  bool isListening = false;
  String status = '';
  String transcript = '';
  String markdown = '';
  String whisperExecutable = '';
  String ffmpegExecutable = '';
  String modelDirectory = '';
  String selectedModelPath = '';
  String modelFilter = 'all';
  double downloadProgress = 0;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];
    localeCode = prefs.getString('localeCode') ?? 'zh';
    whisperExecutable = prefs.getString('whisperExecutable') ?? '';
    ffmpegExecutable = prefs.getString('ffmpegExecutable') ?? '';
    modelDirectory =
        prefs.getString('modelDirectory') ??
        await _tools.defaultModelDirectory();
    selectedModelPath = prefs.getString('selectedModelPath') ?? '';
    status = 'Ready';
    _liveTranscriber = LiveTranscriber(_tools);
    isReady = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', themeMode.index);
    await prefs.setString('localeCode', localeCode);
    await prefs.setString('whisperExecutable', whisperExecutable);
    await prefs.setString('ffmpegExecutable', ffmpegExecutable);
    await prefs.setString('modelDirectory', modelDirectory);
    await prefs.setString('selectedModelPath', selectedModelPath);
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    _persist();
    notifyListeners();
  }

  void setLocaleCode(String code) {
    localeCode = code;
    _persist();
    notifyListeners();
  }

  void setModelFilter(String value) {
    modelFilter = value;
    notifyListeners();
  }

  Future<List<String>> refreshAvailableModels() {
    return _tools.availableModelFiles(modelDirectory);
  }

  Future<void> pickModelDirectory() async {
    final dir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose model directory',
      initialDirectory: modelDirectory.isEmpty ? null : modelDirectory,
    );
    if (dir == null) {
      return;
    }
    modelDirectory = dir;
    if (selectedModelPath.isNotEmpty &&
        p.dirname(selectedModelPath) != modelDirectory) {
      selectedModelPath = '';
    }
    await _persist();
    notifyListeners();
  }

  Future<void> pickWhisperExecutable() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Choose Whisper executable',
      allowMultiple: false,
      type: FileType.any,
    );
    final path = result?.files.single.path;
    if (path == null) {
      return;
    }
    whisperExecutable = path;
    await _persist();
    notifyListeners();
  }

  Future<void> pickFFmpegExecutable() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Choose FFmpeg executable',
      allowMultiple: false,
      type: FileType.any,
    );
    final path = result?.files.single.path;
    if (path == null) {
      return;
    }
    ffmpegExecutable = path;
    await _persist();
    notifyListeners();
  }

  void selectModelPath(String value) {
    selectedModelPath = value;
    _persist();
    notifyListeners();
  }

  Future<String?> downloadModel(WhisperModelInfo model) async {
    if (modelDirectory.isEmpty) {
      return 'Please configure the model directory first.';
    }
    isBusy = true;
    downloadProgress = 0;
    status = 'Downloading ${model.label}';
    notifyListeners();
    try {
      final file = await _tools.downloadModel(
        model: model,
        modelDirectory: modelDirectory,
        onProgress: (progress) {
          downloadProgress = progress;
          notifyListeners();
        },
      );
      selectedModelPath = file.path;
      status = 'Model ready';
      await _persist();
      return null;
    } catch (error) {
      status = '$error';
      return '$error';
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<String?> startLiveTranscription() async {
    if (whisperExecutable.isEmpty ||
        ffmpegExecutable.isEmpty ||
        modelDirectory.isEmpty) {
      return 'missing-config';
    }
    if (selectedModelPath.isEmpty || !File(selectedModelPath).existsSync()) {
      return 'missing-model';
    }
    if (!await _liveTranscriber!.hasPermission()) {
      return 'missing-microphone-permission';
    }

    isListening = true;
    status = 'Listening';
    notifyListeners();

    _liveTranscriber!
        .start(
          whisperPath: whisperExecutable,
          modelPath: selectedModelPath,
          onSegment: (text) {
            transcript = transcript.isEmpty ? text : '$transcript $text';
            markdown = _buildMarkdown();
            notifyListeners();
          },
          onStatus: (value) {
            status = value;
            notifyListeners();
          },
        )
        .whenComplete(() {
          isListening = false;
          status = 'Idle';
          notifyListeners();
        });

    return null;
  }

  Future<void> stopLiveTranscription() async {
    await _liveTranscriber?.stop();
    isListening = false;
    status = 'Idle';
    notifyListeners();
  }

  Future<String?> importVideoAndTranscribe() async {
    if (whisperExecutable.isEmpty ||
        ffmpegExecutable.isEmpty ||
        selectedModelPath.isEmpty) {
      return 'missing-config';
    }
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Pick a video file',
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['mp4', 'mov', 'mkv', 'avi', 'webm'],
    );
    final videoPath = result?.files.single.path;
    if (videoPath == null) {
      return null;
    }

    isBusy = true;
    status = 'Importing video';
    notifyListeners();
    try {
      final audio = await _tools.extractAudioFromVideo(
        ffmpegPath: ffmpegExecutable,
        videoPath: videoPath,
      );
      final text = await _tools.transcribeAudio(
        whisperPath: whisperExecutable,
        modelPath: selectedModelPath,
        audioPath: audio.path,
      );
      transcript = text.trim();
      markdown = _buildMarkdown(source: p.basename(videoPath));
      final outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Markdown',
        fileName: '${p.basenameWithoutExtension(videoPath)}.md',
        type: FileType.custom,
        allowedExtensions: const ['md'],
      );
      if (outputPath != null) {
        await _tools.saveMarkdown(outputPath: outputPath, content: markdown);
      } else {
        final docs = await getApplicationDocumentsDirectory();
        await _tools.saveMarkdown(
          outputPath: p.join(
            docs.path,
            '${p.basenameWithoutExtension(videoPath)}.md',
          ),
          content: markdown,
        );
      }
      status = 'Video transcription completed';
      return null;
    } catch (error) {
      status = '$error';
      return '$error';
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  String _buildMarkdown({String? source}) {
    final stamp = DateTime.now().toLocal().toIso8601String();
    final heading = source ?? 'Live dictation';
    return [
      '# $heading',
      '',
      '- Generated: $stamp',
      '- Model: ${selectedModelPath.isEmpty ? 'Unselected' : p.basename(selectedModelPath)}',
      '',
      '## Transcript',
      '',
      transcript.trim(),
      '',
    ].join('\n');
  }
}
