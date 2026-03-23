class AppStrings {
  AppStrings(this.localeCode);

  final String localeCode;

  static const Map<String, Map<String, String>> _values = {
    'en': {
      'appTitle': 'FreeType Whisper Studio',
      'appSubtitle':
          'A rounded desktop workspace for low-latency dictation, model control, and Markdown transcripts.',
      'liveTitle': 'Live Dictation',
      'liveHint':
          'Capture microphone audio in short segments and transcribe them with your local Whisper runtime.',
      'start': 'Start',
      'stop': 'Stop',
      'listening': 'Listening',
      'idle': 'Idle',
      'transcript': 'Transcript',
      'notes': 'Markdown Notes',
      'importTitle': 'Video To Markdown',
      'importHint':
          'Extract audio with FFmpeg, run Whisper locally, and export a clean Markdown note.',
      'importButton': 'Import Video',
      'settings': 'Runtime Settings',
      'models': 'Model Library',
      'dark': 'Dark',
      'light': 'Light',
      'followSystem': 'System',
      'modelDir': 'Model directory',
      'whisperPath': 'Whisper executable',
      'ffmpegPath': 'FFmpeg executable',
      'selectedModel': 'Selected model',
      'download': 'Download',
      'downloadReminder':
          'This action will download a Whisper model to your device. Please confirm your network and available disk space first.',
      'missingConfig':
          'Please configure Whisper executable, FFmpeg executable, and model directory first.',
      'missingModel': 'Please select a downloaded model file first.',
      'status': 'Status',
      'videoDone': 'Video transcription completed.',
      'modelSaved': 'Model downloaded successfully.',
      'microphonePermission':
          'Microphone access is required before live dictation can start.',
      'gpuHint':
          'Use a GPU-enabled Whisper binary here. The app will call your local executable and keep all transcription on-device.',
      'refresh': 'Refresh',
      'small': 'Compact',
      'medium': 'Balanced',
      'large': 'High accuracy',
      'all': 'All',
      'emptyTranscript': 'Your live transcript will appear here.',
      'emptyNotes': 'Generated Markdown notes will appear here.',
      'runtimeHelp':
          'Tip: point Whisper to a whisper.cpp or similar local CLI build that already supports your GPU backend.',
    },
    'zh': {
      'appTitle': 'FreeType Whisper 工作台',
      'appSubtitle': '一个圆角风格的桌面转写工作台，支持低延迟听写、模型管理与 Markdown 记录。',
      'liveTitle': '实时听写',
      'liveHint': '按短片段采集麦克风音频，并调用本地 Whisper 运行时完成转写。',
      'start': '开始',
      'stop': '停止',
      'listening': '监听中',
      'idle': '空闲',
      'transcript': '转写文本',
      'notes': 'Markdown 记录',
      'importTitle': '视频转 Markdown',
      'importHint': '使用 FFmpeg 提取音频后，本地运行 Whisper，并导出干净的 Markdown 记录。',
      'importButton': '导入视频',
      'settings': '运行设置',
      'models': '模型库',
      'dark': '深色',
      'light': '浅色',
      'followSystem': '跟随系统',
      'modelDir': '模型目录',
      'whisperPath': 'Whisper 可执行文件',
      'ffmpegPath': 'FFmpeg 可执行文件',
      'selectedModel': '当前模型',
      'download': '下载',
      'downloadReminder': '该操作会把 Whisper 模型下载到本机。请先确认网络可用，并预留足够磁盘空间。',
      'missingConfig': '请先配置 Whisper 可执行文件、FFmpeg 可执行文件和模型目录。',
      'missingModel': '请先选择已下载的模型文件。',
      'status': '状态',
      'videoDone': '视频转写完成。',
      'modelSaved': '模型下载完成。',
      'microphonePermission': '开始实时听写前需要先授予麦克风权限。',
      'gpuHint': '这里应选择支持 GPU 的 Whisper 可执行程序。应用只会调用你本地的可执行文件，转写全程在本机完成。',
      'refresh': '刷新',
      'small': '轻量',
      'medium': '均衡',
      'large': '高精度',
      'all': '全部',
      'emptyTranscript': '实时转写结果会显示在这里。',
      'emptyNotes': '生成后的 Markdown 记录会显示在这里。',
      'runtimeHelp': '提示：建议将 Whisper 指向已启用 GPU 后端的 whisper.cpp 或同类本地 CLI 程序。',
    },
  };

  String t(String key) =>
      _values[localeCode]?[key] ?? _values['en']![key] ?? key;
}
