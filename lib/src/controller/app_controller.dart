import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/whisper_model.dart';
import '../services/desktop_automation.dart';
import '../services/desktop_tools.dart';
import '../services/global_hotkey_service.dart';
import '../services/live_transcriber.dart';

class AppController extends ChangeNotifier {
  AppController();

  final DesktopTools _tools = DesktopTools();
  final DesktopAutomation _automation = DesktopAutomation();
  final GlobalHotkeyService _hotkeys = GlobalHotkeyService();
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
  String latestInsertedText = '';
  String whisperExecutable = '';
  String whisperExtraArgs = '';
  String ffmpegExecutable = '';
  String modelDirectory = '';
  String selectedModelPath = '';
  String modelFilter = 'all';
  String dictationLanguage = 'auto';
  String latencyPreset = 'steady';
  String pasteMode = 'incremental';
  bool autoPasteEnabled = false;
  bool copySnippetEnabled = false;
  bool globalHotkeysEnabled = true;
  double downloadProgress = 0;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];
    localeCode = prefs.getString('localeCode') ?? 'zh';
    whisperExecutable = prefs.getString('whisperExecutable') ?? '';
    whisperExtraArgs = prefs.getString('whisperExtraArgs') ?? '';
    ffmpegExecutable = prefs.getString('ffmpegExecutable') ?? '';
    modelDirectory =
        prefs.getString('modelDirectory') ?? await _tools.defaultModelDirectory();
    selectedModelPath = prefs.getString('selectedModelPath') ?? '';
    dictationLanguage = prefs.getString('dictationLanguage') ?? 'auto';
    latencyPreset = prefs.getString('latencyPreset') ?? 'steady';
    pasteMode = prefs.getString('pasteMode') ?? 'incremental';
    autoPasteEnabled = prefs.getBool('autoPasteEnabled') ?? false;
    copySnippetEnabled = prefs.getBool('copySnippetEnabled') ?? false;
    globalHotkeysEnabled = prefs.getBool('globalHotkeysEnabled') ?? true;
    status = 'ready';
    _liveTranscriber = LiveTranscriber(_tools);
    await _refreshHotkeys();
    isReady = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', themeMode.index);
    await prefs.setString('localeCode', localeCode);
    await prefs.setString('whisperExecutable', whisperExecutable);
    await prefs.setString('whisperExtraArgs', whisperExtraArgs);
    await prefs.setString('ffmpegExecutable', ffmpegExecutable);
    await prefs.setString('modelDirectory', modelDirectory);
    await prefs.setString('selectedModelPath', selectedModelPath);
    await prefs.setString('dictationLanguage', dictationLanguage);
    await prefs.setString('latencyPreset', latencyPreset);
    await prefs.setString('pasteMode', pasteMode);
    await prefs.setBool('autoPasteEnabled', autoPasteEnabled);
    await prefs.setBool('copySnippetEnabled', copySnippetEnabled);
    await prefs.setBool('globalHotkeysEnabled', globalHotkeysEnabled);
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    unawaited(_persist());
    notifyListeners();
  }

  void setLocaleCode(String code) {
    localeCode = code;
    unawaited(_persist());
    notifyListeners();
  }

  void setModelFilter(String value) {
    modelFilter = value;
    notifyListeners();
  }

  void setDictationLanguage(String value) {
    dictationLanguage = value;
    unawaited(_persist());
    notifyListeners();
  }

  void setLatencyPreset(String value) {
    latencyPreset = value;
    unawaited(_persist());
    notifyListeners();
  }

  void setPasteMode(String value) {
    pasteMode = value;
    unawaited(_persist());
    notifyListeners();
  }

  void setWhisperExtraArgs(String value) {
    whisperExtraArgs = value;
    unawaited(_persist());
    notifyListeners();
  }

  void setAutoPasteEnabled(bool value) {
    autoPasteEnabled = value;
    unawaited(_persist());
    notifyListeners();
  }

  void setCopySnippetEnabled(bool value) {
    copySnippetEnabled = value;
    unawaited(_persist());
    notifyListeners();
  }

  Future<void> setGlobalHotkeysEnabled(bool value) async {
    globalHotkeysEnabled = value;
    await _persist();
    await _refreshHotkeys();
    notifyListeners();
  }

  Future<void> _refreshHotkeys() async {
    if (!globalHotkeysEnabled) {
      await _hotkeys.unregisterAll();
      return;
    }
    await _hotkeys.register(
      onToggleDictation: _toggleDictationFromHotkey,
      onPasteLatest: pasteLatestText,
    );
  }

  Future<void> _toggleDictationFromHotkey() async {
    if (isListening) {
      await stopLiveTranscription();
    } else {
      await startLiveTranscription();
    }
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
    unawaited(_persist());
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
          extraArgs: _tools.parseArguments(whisperExtraArgs),
          profile: _profileForPreset(latencyPreset),
          onSegment: (text) {
            unawaited(_handleRecognizedSegment(text));
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
      extraArgs: _tools.parseArguments(whisperExtraArgs),
      onSegment: (text) {
        unawaited(_handleRecognizedSegment(text));
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

  Future<void> _handleRecognizedSegment(String text) async {
    latestSegment = text;
    final mergeResult = _mergeTranscript(transcript, text);
    transcript = mergeResult.mergedText;
    latestInsertedText = mergeResult.appendedText;
    markdown = _buildMarkdown();
    notifyListeners();

    if (latestInsertedText.isEmpty) {
      return;
    }

    if (copySnippetEnabled) {
      await _automation.copyText(latestInsertedText);
    }
    if (autoPasteEnabled) {
      final pasteText = pasteMode == 'whole' ? transcript : latestInsertedText;
      final error = await _automation.pasteTextIntoActiveInput(
        pasteText,
        replaceAll: pasteMode == 'whole',
      );
      if (error != null && error.isNotEmpty) {
        status = error;
        notifyListeners();
      }
    }
  }

  Future<String?> pasteLatestText() async {
    final text = pasteMode == 'whole'
        ? transcript
        : (latestInsertedText.isNotEmpty ? latestInsertedText : transcript);
    if (text.trim().isEmpty) {
      return 'no-transcript-yet';
    }
    final error = await _automation.pasteTextIntoActiveInput(
      text,
      replaceAll: pasteMode == 'whole',
    );
    if (error != null) {
      status = error;
      notifyListeners();
      return error;
    }
    return null;
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
        extraArgs: _tools.parseArguments(whisperExtraArgs),
      );
      transcript = text.trim();
      latestSegment = transcript;
      latestInsertedText = transcript;
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

  _MergeResult _mergeTranscript(String existing, String incoming) {
    final existingNormalized = _NormalizedText.fromOriginal(existing);
    final incomingNormalized = _NormalizedText.fromOriginal(incoming);
    if (incomingNormalized.normalized.isEmpty) {
      return _MergeResult(existing, '');
    }
    if (existingNormalized.normalized.isEmpty) {
      return _MergeResult(incoming.trim(), incoming.trim());
    }

    final overlap = _findCharOverlap(
      existingNormalized.normalized,
      incomingNormalized.normalized,
    );

    if (overlap == incomingNormalized.normalized.length) {
      return _MergeResult(existing.trim(), '');
    }

    final appendStart =
        overlap == 0 ? 0 : incomingNormalized.originalEndOffsets[overlap - 1];
    final suffix = incoming.substring(appendStart);
    if (suffix.trim().isEmpty) {
      return _MergeResult(existing.trim(), '');
    }

    final prefixSpace =
        overlap == 0 &&
            existing.trim().isNotEmpty &&
            !_shouldJoinWithoutSpace(existing, suffix)
        ? ' '
        : '';
    final appendedText = '$prefixSpace${suffix.trimLeft()}';
    return _MergeResult(
      '${existing.trimRight()}$appendedText'.trim(),
      appendedText,
    );
  }

  int _findCharOverlap(String existing, String incoming) {
    final maxOverlap = existing.length < incoming.length
        ? existing.length
        : incoming.length;
    for (var count = maxOverlap; count > 0; count--) {
      if (existing.substring(existing.length - count) ==
          incoming.substring(0, count)) {
        return count;
      }
    }
    return 0;
  }

  bool _shouldJoinWithoutSpace(String left, String right) {
    final trimmedRight = right.trimLeft();
    if (trimmedRight.isEmpty) {
      return true;
    }
    final first = String.fromCharCode(trimmedRight.runes.first);
    return RegExp(r'^[\p{Script=Han}\p{P}]$', unicode: true).hasMatch(first);
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
      '- Extra args: ${whisperExtraArgs.isEmpty ? '(none)' : whisperExtraArgs}',
      '',
      '## Transcript',
      '',
      transcript.trim(),
      '',
    ].join('\n');
  }
}

class _MergeResult {
  const _MergeResult(this.mergedText, this.appendedText);

  final String mergedText;
  final String appendedText;
}

class _NormalizedText {
  const _NormalizedText({
    required this.normalized,
    required this.originalEndOffsets,
  });

  final String normalized;
  final List<int> originalEndOffsets;

  factory _NormalizedText.fromOriginal(String original) {
    final buffer = StringBuffer();
    final offsets = <int>[];
    var codeUnitOffset = 0;
    var lastWasSpace = false;

    for (final rune in original.runes) {
      final char = String.fromCharCode(rune);
      codeUnitOffset += char.length;
      if (RegExp(r'\s', unicode: true).hasMatch(char)) {
        if (buffer.isEmpty || lastWasSpace) {
          continue;
        }
        buffer.write(' ');
        offsets.add(codeUnitOffset);
        lastWasSpace = true;
        continue;
      }
      if (RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(char)) {
        buffer.write(char.toLowerCase());
        offsets.add(codeUnitOffset);
        lastWasSpace = false;
      }
    }

    return _NormalizedText(
      normalized: buffer.toString().trim(),
      originalEndOffsets: offsets,
    );
  }
}
