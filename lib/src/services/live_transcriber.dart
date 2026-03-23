import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'desktop_tools.dart';

class LiveTranscriber {
  LiveTranscriber(this._tools);

  final DesktopTools _tools;
  final AudioRecorder _recorder = AudioRecorder();

  bool _running = false;

  Future<void> start({
    required String whisperPath,
    required String modelPath,
    required void Function(String text) onSegment,
    required void Function(String status) onStatus,
    Duration segmentLength = const Duration(seconds: 4),
  }) async {
    if (_running) {
      return;
    }
    _running = true;
    onStatus('recording');

    while (_running) {
      final tempDir = await getTemporaryDirectory();
      final segmentPath = p.join(
        tempDir.path,
        'segment_${DateTime.now().microsecondsSinceEpoch}.wav',
      );

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: segmentPath,
      );

      await Future.delayed(segmentLength);
      if (!await _recorder.isRecording()) {
        break;
      }

      final recordedPath = await _recorder.stop();
      if (!_running || recordedPath == null) {
        break;
      }

      onStatus('transcribing');
      final file = File(recordedPath);
      if (file.existsSync() && file.lengthSync() > 44) {
        final text = await _tools.transcribeAudio(
          whisperPath: whisperPath,
          modelPath: modelPath,
          audioPath: recordedPath,
        );
        final cleaned = text.trim();
        if (cleaned.isNotEmpty) {
          onSegment(cleaned);
        }
      }
      onStatus('recording');
    }
  }

  Future<void> stop() async {
    _running = false;
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
  }

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<void> dispose() async {
    await stop();
    await _recorder.dispose();
  }
}
