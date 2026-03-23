import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart';

import 'desktop_tools.dart';

class LiveDictationProfile {
  const LiveDictationProfile({
    required this.stepDuration,
    required this.windowDuration,
    required this.language,
  });

  final Duration stepDuration;
  final Duration windowDuration;
  final String language;
}

class LiveTranscriber {
  LiveTranscriber(this._tools);

  final DesktopTools _tools;
  final AudioRecorder _recorder = AudioRecorder();

  final List<int> _pcmBuffer = <int>[];
  StreamSubscription<Uint8List>? _audioSubscription;
  List<int>? _pendingSnapshot;
  bool _isRunning = false;
  bool _isTranscribing = false;
  int _bytesSinceDispatch = 0;

  static const int _sampleRate = 16000;
  static const int _channels = 1;
  static const int _bytesPerSample = 2;

  Future<void> start({
    required String whisperPath,
    required String modelPath,
    required LiveDictationProfile profile,
    required void Function(String text) onSegment,
    required void Function(String status) onStatus,
  }) async {
    if (_isRunning) {
      return;
    }

    _isRunning = true;
    _bytesSinceDispatch = 0;
    _pcmBuffer.clear();
    _pendingSnapshot = null;
    onStatus('recording');

    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: _sampleRate,
        numChannels: _channels,
      ),
    );

    final stepBytes = _durationToBytes(profile.stepDuration);
    final windowBytes = _durationToBytes(profile.windowDuration);

    _audioSubscription = stream.listen((chunk) {
      if (!_isRunning) {
        return;
      }

      _pcmBuffer.addAll(chunk);
      _bytesSinceDispatch += chunk.length;

      if (_pcmBuffer.length > windowBytes) {
        _pcmBuffer.removeRange(0, _pcmBuffer.length - windowBytes);
      }

      if (_bytesSinceDispatch >= stepBytes) {
        _bytesSinceDispatch = 0;
        _enqueueSnapshot(
          List<int>.from(_pcmBuffer),
          whisperPath: whisperPath,
          modelPath: modelPath,
          language: profile.language,
          onSegment: onSegment,
          onStatus: onStatus,
        );
      }
    });
  }

  Future<void> stop({
    required String whisperPath,
    required String modelPath,
    required String language,
    required void Function(String text) onSegment,
    required void Function(String status) onStatus,
  }) async {
    if (!_isRunning) {
      return;
    }

    _isRunning = false;
    await _audioSubscription?.cancel();
    _audioSubscription = null;
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }

    final finalSnapshot = List<int>.from(_pcmBuffer);
    _pcmBuffer.clear();
    if (finalSnapshot.isNotEmpty) {
      await _transcribeSnapshot(
        finalSnapshot,
        whisperPath: whisperPath,
        modelPath: modelPath,
        language: language,
        onSegment: onSegment,
        onStatus: onStatus,
        restoreRecordingState: false,
      );
    } else {
      onStatus('idle');
    }
  }

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<void> dispose() async {
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    await _audioSubscription?.cancel();
    await _recorder.dispose();
  }

  void _enqueueSnapshot(
    List<int> snapshot, {
    required String whisperPath,
    required String modelPath,
    required String language,
    required void Function(String text) onSegment,
    required void Function(String status) onStatus,
  }) {
    if (snapshot.isEmpty) {
      return;
    }
    if (_isTranscribing) {
      _pendingSnapshot = snapshot;
      return;
    }
    unawaited(
      _transcribeSnapshot(
        snapshot,
        whisperPath: whisperPath,
        modelPath: modelPath,
        language: language,
        onSegment: onSegment,
        onStatus: onStatus,
      ),
    );
  }

  Future<void> _transcribeSnapshot(
    List<int> snapshot, {
    required String whisperPath,
    required String modelPath,
    required String language,
    required void Function(String text) onSegment,
    required void Function(String status) onStatus,
    bool restoreRecordingState = true,
  }) async {
    if (snapshot.length < _durationToBytes(const Duration(milliseconds: 500))) {
      return;
    }

    _isTranscribing = true;
    onStatus('transcribing');

    try {
      final wave = await _tools.createWaveFileFromPcm(
        pcmBytes: snapshot,
        sampleRate: _sampleRate,
        channels: _channels,
      );
      final text = await _tools.transcribeAudio(
        whisperPath: whisperPath,
        modelPath: modelPath,
        audioPath: wave.path,
        language: language,
      );
      final cleaned = text.trim();
      if (cleaned.isNotEmpty) {
        onSegment(cleaned);
      }
    } finally {
      _isTranscribing = false;
      final pending = _pendingSnapshot;
      _pendingSnapshot = null;
      if (pending != null) {
        unawaited(
          _transcribeSnapshot(
            pending,
            whisperPath: whisperPath,
            modelPath: modelPath,
            language: language,
            onSegment: onSegment,
            onStatus: onStatus,
            restoreRecordingState: restoreRecordingState,
          ),
        );
      } else {
        onStatus(restoreRecordingState && _isRunning ? 'recording' : 'idle');
      }
    }
  }

  int _durationToBytes(Duration duration) {
    return (duration.inMilliseconds *
            _sampleRate *
            _channels *
            _bytesPerSample) ~/
        1000;
  }
}
