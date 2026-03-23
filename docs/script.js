const translations = {
  zh: {
    navFeatures: '\u529f\u80fd',
    navDownloads: '\u4e0b\u8f7d',
    navFaq: '\u95ee\u7b54',
    viewSource: '\u67e5\u770b\u6e90\u7801',
    eyebrow: 'Local-first Whisper workflow',
    heroTitle:
      '\u8ba9\u672c\u5730 GPU \u542c\u5199\u3001\u8f6c\u5f55\u4e0e Markdown \u8bb0\u5f55\uff0c\u843d\u5728\u540c\u4e00\u4e2a\u684c\u9762\u7a7a\u95f4\u91cc\u3002',
    heroText:
      'FreeType Whisper Studio \u9762\u5411 Windows \u4e0e Linux\uff0c\u652f\u6301\u5b9e\u65f6\u542c\u5199\u3001\u6a21\u578b\u7ba1\u7406\u3001\u89c6\u9891\u8f6c\u6587\u672c\u3001\u53cc\u8bed\u754c\u9762\u4e0e\u6df1\u6d45\u8272\u5207\u6362\uff0c\u6574\u4e2a\u6d41\u7a0b\u4fdd\u6301\u672c\u5730\u4f18\u5148\u3002',
    primaryCta: '\u6253\u5f00 GitHub',
    secondaryCta: '\u67e5\u770b\u529f\u80fd',
    metricPlatform: '\u8de8\u5e73\u53f0\u684c\u9762',
    metricRuntime: '\u672c\u5730\u8fd0\u884c\u65f6\u94fe\u8def',
    metricExport: '\u8bb0\u5f55\u5bfc\u51fa',
    statusListening: '\u5b9e\u65f6\u542c\u5199\u4e2d',
    statusLocal: '\u672c\u5730\u5904\u7406',
    stackRealtime: 'Realtime',
    stackRealtimeText: '\u8fde\u7eed\u542c\u5199\u4e0e\u53e5\u672b\u63d0\u4ea4',
    stackModels: 'Models',
    stackModelsText: '\u6a21\u578b\u5927\u5c0f\u7b5b\u9009\u4e0e\u4fdd\u5b58\u76ee\u5f55',
    stackMedia: 'Media',
    stackMediaText: '\u89c6\u9891\u63d0\u97f3\u5e76\u5bfc\u51fa Markdown',
    featuresEyebrow: 'Capabilities',
    featuresTitle:
      '\u56f4\u7ed5\u771f\u5b9e\u684c\u9762\u5de5\u4f5c\u6d41\u8bbe\u8ba1\u7684\u672c\u5730\u8bed\u97f3\u5de5\u5177',
    feature1Title: '\u5b9e\u65f6\u8f93\u5165\u4f53\u9a8c',
    feature1Text:
      '\u652f\u6301\u8fde\u7eed\u542c\u5199\u3001\u589e\u91cf\u7c98\u8d34\u3001\u53e5\u672b\u63d0\u4ea4\u3001\u6574\u6bb5\u8986\u76d6\uff0c\u4ee5\u53ca\u5168\u5c40\u5feb\u6377\u952e\u63a7\u5236\u3002',
    feature2Title: '\u6a21\u578b\u4e0e\u8fd0\u884c\u65f6\u7ba1\u7406',
    feature2Text:
      '\u53ef\u914d\u7f6e Whisper \u53ef\u6267\u884c\u6587\u4ef6\u3001\u989d\u5916 GPU \u53c2\u6570\u3001\u6a21\u578b\u4e0b\u8f7d\u63d0\u9192\u3001\u6a21\u578b\u5927\u5c0f\u7b5b\u9009\u4e0e\u5b58\u50a8\u76ee\u5f55\u3002',
    feature3Title: '\u89c6\u9891\u5230\u7b14\u8bb0',
    feature3Text:
      '\u5bfc\u5165\u89c6\u9891\u540e\u81ea\u52a8\u63d0\u53d6\u97f3\u9891\u5e76\u8f6c\u5199\uff0c\u7ed3\u679c\u53ef\u6574\u7406\u4e3a Markdown \u8bb0\u5f55\u6587\u672c\u3002',
    feature4Title: '\u53cc\u8bed\u4e0e\u4e3b\u9898',
    feature4Text:
      '\u5e94\u7528\u4e0e Pages \u90fd\u63d0\u4f9b\u4e2d\u82f1\u6587\u5207\u6362\uff0c\u4ee5\u53ca\u660e\u4eae\u4e0e\u6697\u8272\u663e\u793a\u6a21\u5f0f\u3002',
    downloadsEyebrow: 'Downloads',
    downloadsTitle: '\u4ece\u6e90\u7801\u5230\u684c\u9762\u8fd0\u884c\uff0c\u5165\u53e3\u4fdd\u6301\u6e05\u695a\u76f4\u63a5',
    windowsBadge: 'Windows',
    windowsTitle: 'Windows \u684c\u9762\u6784\u5efa',
    windowsText:
      '\u5df2\u5728\u672c\u5730\u5b8c\u6210 `flutter build windows`\uff0c\u9002\u5408\u76f4\u63a5\u4f53\u9a8c\u5b9e\u65f6\u542c\u5199\u3001\u81ea\u52a8\u7c98\u8d34\u548c\u6a21\u578b\u7ba1\u7406\u3002',
    linuxBadge: 'Linux',
    linuxTitle: 'Linux \u684c\u9762\u6784\u5efa',
    linuxText:
      '\u5df2\u5728 WSL2 Ubuntu 24.04 \u9a8c\u8bc1 `flutter build linux`\uff0c\u9002\u5408\u90e8\u7f72\u5230\u672c\u5730 Linux \u684c\u9762\u73af\u5883\u3002',
    runtimeBadge: 'Runtime',
    runtimeGuideTitle: '\u672c\u5730\u8fd0\u884c\u65f6\u51c6\u5907',
    runtimeGuideText:
      '\u542f\u52a8\u524d\u9700\u8981\u914d\u7f6e Whisper \u517c\u5bb9\u53ef\u6267\u884c\u6587\u4ef6\u3001FFmpeg \u8def\u5f84\u548c\u6a21\u578b\u76ee\u5f55\uff0c\u6a21\u578b\u4e0b\u8f7d\u524d\u4f1a\u6709\u63d0\u9192\u3002',
    downloadSource: '\u67e5\u770b\u6e90\u7801\u4e0e\u4ea7\u7269',
    buildGuide: '\u67e5\u770b\u6784\u5efa\u8bf4\u660e',
    setupChecklist: '\u67e5\u770b\u51c6\u5907\u6e05\u5355',
    workflowEyebrow: 'Workflow',
    workflowTitle:
      '\u4ece\u6a21\u578b\u51c6\u5907\u5230\u6587\u7a3f\u5bfc\u51fa\uff0c\u94fe\u8def\u4fdd\u6301\u6e05\u6670',
    step1Title: '\u914d\u7f6e\u672c\u5730\u8fd0\u884c\u73af\u5883',
    step1Text:
      '\u6307\u5b9a Whisper \u517c\u5bb9\u53ef\u6267\u884c\u6587\u4ef6\u3001FFmpeg \u8def\u5f84\u548c\u6a21\u578b\u76ee\u5f55\u3002',
    step2Title: '\u9009\u62e9\u5408\u9002\u6a21\u578b',
    step2Text:
      '\u5728\u4e0b\u8f7d\u524d\u6536\u5230\u63d0\u9192\uff0c\u5e76\u6839\u636e\u5927\u5c0f\u7b5b\u9009\u6a21\u578b\u540e\u4fdd\u5b58\u5230\u81ea\u5b9a\u4e49\u4f4d\u7f6e\u3002',
    step3Title: '\u5f00\u59cb\u542c\u5199\u6216\u5bfc\u5165\u89c6\u9891',
    step3Text:
      '\u652f\u6301\u5b9e\u65f6\u9ea6\u514b\u98ce\u542c\u5199\uff0c\u4e5f\u652f\u6301\u4ece\u89c6\u9891\u4e2d\u63d0\u53d6\u97f3\u9891\u8fdb\u884c\u8f6c\u5f55\u3002',
    step4Title: '\u8f93\u51fa\u4e0e\u6574\u7406\u6587\u672c',
    step4Text:
      '\u53ef\u5c06\u7ed3\u679c\u81ea\u52a8\u7c98\u8d34\u5230\u5f53\u524d\u8f93\u5165\u6846\uff0c\u6216\u5bfc\u51fa\u4e3a Markdown \u7b14\u8bb0\u3002',
    previewEyebrow: 'Preview',
    previewTitle: '\u7528\u4e00\u7ec4\u573a\u666f\u5361\u7247\u5c55\u793a\u6838\u5fc3\u754c\u9762\u8282\u594f',
    previewCard1Title: '\u5b9e\u65f6\u542c\u5199\u9762\u677f',
    previewCard1Text:
      '\u5706\u89d2\u4fe1\u606f\u5361\u7247\u3001\u6eda\u52a8\u5f0f\u72b6\u6001\u53cd\u9988\u548c\u6301\u7eed\u8f6c\u5199\u7684\u89c6\u89c9\u8282\u594f\uff0c\u9002\u5408\u957f\u65f6\u95f4\u505c\u7559\u4f7f\u7528\u3002',
    previewCard2Title: '\u6a21\u578b\u4e0e\u4e0b\u8f7d\u7ba1\u7406',
    previewCard2Text:
      '\u63d0\u4f9b\u6a21\u578b\u5927\u5c0f\u7b5b\u9009\u3001\u4e0b\u8f7d\u524d\u786e\u8ba4\u3001\u4fdd\u5b58\u76ee\u5f55\u9009\u62e9\uff0c\u4ee5\u53ca\u989d\u5916 Whisper \u53c2\u6570\u914d\u7f6e\u3002',
    previewCard3Title: 'Markdown \u8f93\u51fa\u94fe\u8def',
    previewCard3Text:
      '\u4ece\u89c6\u9891\u97f3\u9891\u63d0\u53d6\u5230\u6587\u672c\u6574\u7406\uff0c\u518d\u5230\u5bfc\u51fa Markdown\uff0c\u6574\u4e2a\u6d41\u7a0b\u90fd\u5728\u672c\u5730\u5b8c\u6210\u3002',
    runtimeEyebrow: 'Runtime',
    runtimeTitle:
      '\u4f60\u63d0\u4f9b\u672c\u5730\u5f15\u64ce\uff0c\u5e94\u7528\u8d1f\u8d23\u4ea4\u4e92\u5c42',
    runtimeText:
      '\u5e94\u7528\u4e0d\u4f1a\u628a\u8bed\u97f3\u53d1\u9001\u5230\u4e91\u7aef\u3002\u5b83\u8c03\u7528\u4f60\u672c\u673a\u4e0a\u7684 Whisper \u517c\u5bb9\u53ef\u6267\u884c\u6587\u4ef6\u4e0e FFmpeg\uff0c\u5e76\u6cbf\u7528\u8fd9\u4e9b\u5de5\u5177\u81ea\u8eab\u7684 GPU \u80fd\u529b\u3002',
    licenseEyebrow: 'License',
    licenseTitle:
      '\u4e0e Whisper \u751f\u6001\u4fdd\u6301\u4e00\u81f4\u7684\u5f00\u6e90\u8bb8\u53ef',
    licenseText:
      '\u9879\u76ee\u5f53\u524d\u91c7\u7528 MIT License\uff0c\u4ee5\u4fdd\u6301\u548c Whisper \u9879\u76ee\u5bb6\u65cf\u53ca\u5e38\u89c1\u517c\u5bb9\u8fd0\u884c\u65f6\u7684\u4e00\u81f4\u6027\u3002',
    faqEyebrow: 'FAQ',
    faqTitle: '\u90e8\u7f72\u524d\u6700\u5e38\u89c1\u7684\u51e0\u4e2a\u95ee\u9898',
    faq1Title: '\u8fd9\u4e2a\u9879\u76ee\u4f1a\u628a\u8bed\u97f3\u4e0a\u4f20\u5230\u4e91\u7aef\u5417\uff1f',
    faq1Text:
      '\u4e0d\u4f1a\u3002\u5b83\u662f\u672c\u5730\u4f18\u5148\u7684\u684c\u9762\u5e94\u7528\uff0c\u8c03\u7528\u7684\u662f\u4f60\u673a\u5668\u4e0a\u7684 Whisper \u517c\u5bb9\u8fd0\u884c\u65f6\u548c FFmpeg\u3002',
    faq2Title: 'GitHub Pages \u8981\u600e\u4e48\u542f\u7528\uff1f',
    faq2Text:
      '\u5728\u4ed3\u5e93\u7684 Pages \u8bbe\u7f6e\u4e2d\u9009\u62e9 `Deploy from a branch`\uff0c\u518d\u628a\u6765\u6e90\u6307\u5411 `main / docs`\u3002',
    faq3Title: '\u6a21\u578b\u4e0b\u8f7d\u524d\u4e3a\u4ec0\u4e48\u8981\u63d0\u9192\uff1f',
    faq3Text:
      '\u56e0\u4e3a\u6a21\u578b\u6587\u4ef6\u901a\u5e38\u8f83\u5927\uff0c\u63d0\u9192\u53ef\u4ee5\u5e2e\u52a9\u4f60\u5728\u4e0b\u8f7d\u524d\u786e\u8ba4\u7f51\u7edc\u73af\u5883\u3001\u78c1\u76d8\u7a7a\u95f4\u548c\u4fdd\u5b58\u76ee\u5f55\u3002',
    faq4Title: '\u8fd9\u4e2a Pages \u80fd\u7ee7\u7eed\u6269\u5c55\u5417\uff1f',
    faq4Text:
      '\u53ef\u4ee5\u3002\u5f53\u524d\u7ed3\u6784\u5df2\u7ecf\u62c6\u6210 HTML\u3001CSS \u548c JS \u4e09\u4e2a\u6587\u4ef6\uff0c\u9002\u5408\u540e\u7eed\u7ee7\u7eed\u52a0\u622a\u56fe\u3001\u4e0b\u8f7d\u9875\u6216\u66f4\u65b0\u65e5\u5fd7\u3002',
    footerText:
      '\u672c\u5730\u4f18\u5148\u7684 Whisper \u684c\u9762\u5de5\u4f5c\u53f0\uff0c\u7528\u4e8e\u8fde\u7eed\u542c\u5199\u3001\u89c6\u9891\u8f6c\u5199\u4e0e Markdown \u8bb0\u5f55\u3002',
    footerGithub: 'GitHub \u4ed3\u5e93',
    footerPages: 'Pages \u8bbe\u7f6e',
    footerBackTop: '\u8fd4\u56de\u9876\u90e8'
  },
  en: {
    navFeatures: 'Features',
    navDownloads: 'Downloads',
    navFaq: 'FAQ',
    viewSource: 'View source',
    eyebrow: 'Local-first Whisper workflow',
    heroTitle: 'Bring local GPU dictation, transcription, and Markdown capture into one desktop space.',
    heroText:
      'FreeType Whisper Studio targets Windows and Linux with live dictation, model management, video-to-text workflows, bilingual UI, and light or dark themes, all in a local-first pipeline.',
    primaryCta: 'Open GitHub',
    secondaryCta: 'Explore features',
    metricPlatform: 'Cross-platform desktop',
    metricRuntime: 'Local runtime pipeline',
    metricExport: 'Markdown export',
    statusListening: 'Live dictation',
    statusLocal: 'Processed locally',
    stackRealtime: 'Realtime',
    stackRealtimeText: 'Continuous dictation with sentence-final commit',
    stackModels: 'Models',
    stackModelsText: 'Model size filtering and custom storage',
    stackMedia: 'Media',
    stackMediaText: 'Extract audio from video and export Markdown',
    featuresEyebrow: 'Capabilities',
    featuresTitle: 'A local speech tool built around real desktop workflows',
    feature1Title: 'Live input experience',
    feature1Text:
      'Supports continuous dictation, incremental paste, sentence-final commit, full replacement, and global hotkeys.',
    feature2Title: 'Model and runtime management',
    feature2Text:
      'Configure the Whisper executable, extra GPU flags, model download reminders, size filters, and storage directories.',
    feature3Title: 'Video to notes',
    feature3Text:
      'Import a video, extract its audio, transcribe it locally, and turn the result into Markdown notes.',
    feature4Title: 'Language and theme',
    feature4Text:
      'Both the app and the GitHub Pages site support Chinese and English, plus light and dark presentation modes.',
    downloadsEyebrow: 'Downloads',
    downloadsTitle: 'Clear entry points from source code to desktop builds',
    windowsBadge: 'Windows',
    windowsTitle: 'Windows desktop build',
    windowsText:
      'The project has already been verified locally with `flutter build windows`, ready for live dictation, auto paste, and model management workflows.',
    linuxBadge: 'Linux',
    linuxTitle: 'Linux desktop build',
    linuxText:
      'The project has already been validated in WSL2 Ubuntu 24.04 with `flutter build linux`, suitable for local Linux desktop deployment.',
    runtimeBadge: 'Runtime',
    runtimeGuideTitle: 'Local runtime setup',
    runtimeGuideText:
      'Before launch, configure a Whisper-compatible executable, the FFmpeg path, and a model directory. Model downloads are confirmed with reminders.',
    downloadSource: 'View source and artifacts',
    buildGuide: 'Read build notes',
    setupChecklist: 'Open setup checklist',
    workflowEyebrow: 'Workflow',
    workflowTitle: 'A clear path from model setup to exported writing',
    step1Title: 'Set up local tools',
    step1Text: 'Point the app at a Whisper-compatible executable, FFmpeg, and your model directory.',
    step2Title: 'Choose the right model',
    step2Text: 'Get a reminder before downloads, filter models by size, and store them wherever you prefer.',
    step3Title: 'Start dictation or import video',
    step3Text: 'Use live microphone dictation or extract audio from a video for local transcription.',
    step4Title: 'Export and organize text',
    step4Text: 'Paste directly into the active input or export the transcript as Markdown notes.',
    previewEyebrow: 'Preview',
    previewTitle: 'Show the core interface rhythm with scene-based cards',
    previewCard1Title: 'Live dictation panel',
    previewCard1Text:
      'Rounded status cards, flowing transcription feedback, and a layout designed for long sessions at the desktop.',
    previewCard2Title: 'Model and download management',
    previewCard2Text:
      'Includes model size filtering, download confirmations, storage selection, and extra Whisper runtime arguments.',
    previewCard3Title: 'Markdown output pipeline',
    previewCard3Text:
      'From extracting audio out of video to cleaning text and exporting Markdown, the whole flow stays local.',
    runtimeEyebrow: 'Runtime',
    runtimeTitle: 'You bring the local engine, the app handles the workflow layer',
    runtimeText:
      'The app does not send audio to the cloud. It calls your local Whisper-compatible executable and FFmpeg, and uses whatever GPU support those tools already provide.',
    licenseEyebrow: 'License',
    licenseTitle: 'An open-source license aligned with the Whisper ecosystem',
    licenseText:
      'The project currently uses the MIT License to stay aligned with the Whisper project family and common compatible runtimes.',
    faqEyebrow: 'FAQ',
    faqTitle: 'Common questions before deployment',
    faq1Title: 'Does this project upload audio to the cloud?',
    faq1Text:
      'No. It is a local-first desktop app and it calls the Whisper-compatible runtime and FFmpeg available on your own machine.',
    faq2Title: 'How do I enable GitHub Pages?',
    faq2Text:
      'Open the repository Pages settings, choose `Deploy from a branch`, and point the source to `main / docs`.',
    faq3Title: 'Why show a reminder before model downloads?',
    faq3Text:
      'Model files are often large, so the reminder helps you confirm network access, disk space, and the destination folder first.',
    faq4Title: 'Can this Pages site be extended later?',
    faq4Text:
      'Yes. The current structure is already separated into HTML, CSS, and JS files, making it easy to add screenshots, a download page, or a changelog later.',
    footerText:
      'A local-first Whisper desktop workspace for continuous dictation, video transcription, and Markdown capture.',
    footerGithub: 'GitHub repository',
    footerPages: 'Pages settings',
    footerBackTop: 'Back to top'
  }
};

const root = document.documentElement;
const langButton = document.getElementById('lang-toggle');
const themeButton = document.getElementById('theme-toggle');

const savedLanguage = localStorage.getItem('freetype-pages-lang') || 'zh';
const savedTheme = localStorage.getItem('freetype-pages-theme') || 'light';

function applyLanguage(language) {
  const locale = translations[language] ? language : 'zh';
  document.documentElement.lang = locale === 'zh' ? 'zh-CN' : 'en';
  document.querySelectorAll('[data-i18n]').forEach((node) => {
    const key = node.dataset.i18n;
    node.textContent = translations[locale][key] || '';
  });
  langButton.textContent = locale === 'zh' ? 'EN' : '\u4e2d\u6587';
  localStorage.setItem('freetype-pages-lang', locale);
}

function applyTheme(theme) {
  const nextTheme = theme === 'dark' ? 'dark' : 'light';
  root.setAttribute('data-theme', nextTheme);
  themeButton.textContent = nextTheme === 'dark' ? 'Light' : 'Dark';
  localStorage.setItem('freetype-pages-theme', nextTheme);
}

langButton.addEventListener('click', () => {
  const current = localStorage.getItem('freetype-pages-lang') || 'zh';
  applyLanguage(current === 'zh' ? 'en' : 'zh');
});

themeButton.addEventListener('click', () => {
  const current = root.getAttribute('data-theme') || 'light';
  applyTheme(current === 'light' ? 'dark' : 'light');
});

applyLanguage(savedLanguage);
applyTheme(savedTheme);
