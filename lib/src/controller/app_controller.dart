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
  AppController();

  final DesktopTools _tools = DesktopTools();
  LiveTranscriber? _liveTranscriber;

  ThemeMode themeMode = ThemeMode.system;
  String localeCode = 'zh';
  bool isReady = false;
  bool isBusy = false;
  bool isListening = false;
  String status = 'ready';
  String transcript = '';
  String markdown = '';
  String latestSegment = '';
  String whisperExecutable = '';
  String ffmpegExecutable = '';
  String modelDirectory = '';
  String selectedModelPath = '';
  String modelFilter = 'all';
  String dictationLanguage = 'auto';
  String latencyPreset = 'steady';
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
    dictationLanguage = prefs.getString('dictationLanguage') ?? 'auto';
    latencyPreset = prefs.getString('latencyPreset') ?? 'steady';
    status = 'ready';
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
    await prefs.setString('dictationLanguage', dictationLanguage);
    await prefs.setString('latencyPreset', latencyPreset);
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

  void setDictationLanguage(String value) {
    dictationLanguage = value;
    _persist();
    notifyListeners();
  }

  void setLatencyPreset(String value) {
    latencyPreset = value;
    _persist();
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
    status = 'downloading';
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
      status = 'ready';
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
    if (whisperExecutable.isEmpty || modelDirectory.isEmpty) {
      return 'missing-config';
    }
    if (selectedModelPath.isEmpty || !File(selectedModelPath).existsSync()) {
      return 'missing-model';
    }
    if (!await _liveTranscriber!.hasPermission()) {
      return 'missing-microphone-permission';
    }

    isListening = true;
    status = 'recording';
    notifyListeners();

    _liveTranscriber!
        .start(
          whisperPath: whisperExecutable,
          modelPath: selectedModelPath,
          profile: _profileForPreset(latencyPreset),
          onSegment: (text) {
            latestSegment = text;
            transcript = _mergeTranscript(transcript, text);
            markdown = _buildMarkdown();
            notifyListeners();
          },
          onStatus: (value) {
            status = value;
            notifyListeners();
          },
        )
        .catchError((Object error) {
          status = '$error';
          isListening = false;
          notifyListeners();
        })
        .whenComplete(() {
          if (!isListening) {
            status = 'idle';
            notifyListeners();
          }
        });

    return null;
  }

  Future<void> stopLiveTranscription() async {
    await _liveTranscriber?.stop(
      whisperPath: whisperExecutable,
      modelPath: selectedModelPath,
      language: dictationLanguage,
      onSegment: (text) {
        latestSegment = text;
        transcript = _mergeTranscript(transcript, text);
        markdown = _buildMarkdown();
        notifyListeners();
      },
      onStatus: (value) {
        status = value;
        notifyListeners();
      },
    );
    isListening = false;
    status = 'idle';
    notifyListeners();
  }

  Future<String?> importVideoAndTranscribe() async {
    if (whisperExecutable.isEmpty ||
        ffmpegExecutable.isEmpty ||
        modelDirectory.isEmpty) {
      return 'missing-import-config';
    }
    if (selectedModelPath.isEmpty || !File(selectedModelPath).existsSync()) {
      return 'missing-model';
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
    status = 'transcribing';
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
        language: dictationLanguage,
      );
      transcript = text.trim();
      latestSegment = transcript;
      markdown = _buildMarkdown(source: p.basename(videoPath));
      await saveMarkdown(
        defaultFileName: '${p.basenameWithoutExtension(videoPath)}.md',
      );
      status = 'ready';
      return null;
    } catch (error) {
      status = '$error';
      return '$error';
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<String?> saveMarkdown({
    String defaultFileName = 'freetype-notes.md',
  }) async {
    if (markdown.trim().isEmpty) {
      return 'no-transcript-yet';
    }
    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Markdown',
      fileName: defaultFileName,
      type: FileType.custom,
      allowedExtensions: const ['md'],
    );
    final target = outputPath ?? await _fallbackMarkdownPath(defaultFileName);
    try {
      await _tools.saveMarkdown(outputPath: target, content: markdown);
      return null;
    } catch (error) {
      return '$error';
    }
  }

  Future<String> _fallbackMarkdownPath(String defaultFileName) async {
    final docs = await getApplicationDocumentsDirectory();
    return p.join(docs.path, defaultFileName);
  }

  LiveDictationProfile _profileForPreset(String preset) {
    switch (preset) {
      case 'fast':
        return LiveDictationProfile(
          stepDuration: const Duration(seconds: 2),
          windowDuration: const Duration(seconds: 4),
          language: dictationLanguage,
        );
      case 'precise':
        return LiveDictationProfile(
          stepDuration: const Duration(seconds: 4),
          windowDuration: const Duration(seconds: 8),
          language: dictationLanguage,
        );
      default:
        return LiveDictationProfile(
          stepDuration: const Duration(seconds: 3),
          windowDuration: const Duration(seconds: 6),
          language: dictationLanguage,
        );
    }
  }

  String _mergeTranscript(String existing, String incoming) {
    final normalizedExisting = _normalizeForMerge(existing);
    final normalizedIncoming = _normalizeForMerge(incoming);
    if (normalizedIncoming.isEmpty) {
      return existing;
    }
    if (normalizedExisting.isEmpty) {
      return incoming.trim();
    }
    if (normalizedExisting.endsWith(normalizedIncoming)) {
      return existing.trim();
    }

    final existingWords = normalizedExisting.split(' ');
    final incomingWords = normalizedIncoming.split(' ');
    var overlap = 0;
    final maxOverlap = existingWords.length < incomingWords.length
        ? existingWords.length
        : incomingWords.length;

    for (var count = maxOverlap; count > 0; count--) {
      final existingTail = existingWords
          .sublist(existingWords.length - count)
          .join(' ');
      final incomingHead = incomingWords.sublist(0, count).join(' ');
      if (existingTail == incomingHead) {
        overlap = count;
        break;
      }
    }

    if (overlap == incomingWords.length) {
      return existing.trim();
    }

    final suffix = incomingWords.sublist(overlap).join(' ');
    if (suffix.isEmpty) {
      return existing.trim();
    }
    return '${existing.trim()} $suffix'.trim();
  }

  String _normalizeForMerge(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[\r\n]+'), ' ')
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _buildMarkdown({String? source}) {
    final stamp = DateTime.now().toLocal().toIso8601String();
    final heading = source ?? 'Live dictation';
    return [
      '# $heading',
      '',
      '- Generated: $stamp',
      '- Model: ${selectedModelPath.isEmpty ? 'Unselected' : p.basename(selectedModelPath)}',
      '- Language: $dictationLanguage',
      '- Latency: $latencyPreset',
      '',
      '## Transcript',
      '',
      transcript.trim(),
      '',
    ].join('\n');
  }
}
