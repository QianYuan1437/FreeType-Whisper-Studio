class WhisperModelInfo {
  const WhisperModelInfo({
    required this.id,
    required this.label,
    required this.fileName,
    required this.sizeMb,
    required this.downloadUrl,
    required this.category,
    required this.multilingual,
  });

  final String id;
  final String label;
  final String fileName;
  final int sizeMb;
  final String downloadUrl;
  final String category;
  final bool multilingual;
}

const whisperModels = <WhisperModelInfo>[
  WhisperModelInfo(
    id: 'tiny',
    label: 'Tiny',
    fileName: 'ggml-tiny.bin',
    sizeMb: 75,
    downloadUrl:
        'https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin',
    category: 'small',
    multilingual: true,
  ),
  WhisperModelInfo(
    id: 'base',
    label: 'Base',
    fileName: 'ggml-base.bin',
    sizeMb: 142,
    downloadUrl:
        'https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin',
    category: 'medium',
    multilingual: true,
  ),
  WhisperModelInfo(
    id: 'small',
    label: 'Small',
    fileName: 'ggml-small.bin',
    sizeMb: 466,
    downloadUrl:
        'https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.bin',
    category: 'medium',
    multilingual: true,
  ),
  WhisperModelInfo(
    id: 'medium',
    label: 'Medium',
    fileName: 'ggml-medium.bin',
    sizeMb: 1530,
    downloadUrl:
        'https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.bin',
    category: 'large',
    multilingual: true,
  ),
  WhisperModelInfo(
    id: 'small-en',
    label: 'Small.en',
    fileName: 'ggml-small.en.bin',
    sizeMb: 244,
    downloadUrl:
        'https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en.bin',
    category: 'medium',
    multilingual: false,
  ),
];
