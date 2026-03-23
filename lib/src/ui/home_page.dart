import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../controller/app_controller.dart';
import '../localization/app_strings.dart';
import '../models/whisper_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.controller, required this.strings});

  final AppController controller;
  final AppStrings strings;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _availableModels = const [];

  @override
  void initState() {
    super.initState();
    _refreshModels();
  }

  Future<void> _refreshModels() async {
    final items = await widget.controller.refreshAvailableModels();
    if (mounted) {
      setState(() => _availableModels = items);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final strings = widget.strings;
    final theme = Theme.of(context);

    if (!controller.isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.scaffoldBackgroundColor,
              theme.colorScheme.primary.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(strings: strings, controller: controller),
                const SizedBox(height: 20),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 1180;
                      final leftPane = Column(
                        children: [
                          _HeroCard(controller: controller, strings: strings),
                          const SizedBox(height: 20),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _TextCard(
                                    title: strings.t('transcript'),
                                    content: controller.transcript,
                                    emptyText: strings.t('emptyTranscript'),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _TextCard(
                                    title: strings.t('notes'),
                                    content: controller.markdown,
                                    emptyText: strings.t('emptyNotes'),
                                    actionLabel: strings.t('saveMarkdown'),
                                    onAction: () async {
                                      final message = await controller
                                          .saveMarkdown();
                                      if (!context.mounted) {
                                        return;
                                      }
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            message == null
                                                ? strings.t('markdownSaved')
                                                : _mapError(strings, message),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                      final rightPane = ListView(
                        children: [
                          _DictationSettingsCard(
                            controller: controller,
                            strings: strings,
                          ),
                          const SizedBox(height: 20),
                          _AutomationCard(
                            controller: controller,
                            strings: strings,
                          ),
                          const SizedBox(height: 20),
                          _SettingsCard(
                            controller: controller,
                            strings: strings,
                          ),
                          const SizedBox(height: 20),
                          _ModelsCard(
                            controller: controller,
                            strings: strings,
                            availableModels: _availableModels,
                            onRefresh: _refreshModels,
                          ),
                          const SizedBox(height: 20),
                          _ImportCard(controller: controller, strings: strings),
                        ],
                      );

                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 6, child: leftPane),
                            const SizedBox(width: 20),
                            Expanded(flex: 4, child: rightPane),
                          ],
                        );
                      }

                      return ListView(
                        children: [
                          _HeroCard(controller: controller, strings: strings),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 230,
                            child: _DictationSettingsCard(
                              controller: controller,
                              strings: strings,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _AutomationCard(
                            controller: controller,
                            strings: strings,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 300,
                            child: _TextCard(
                              title: strings.t('transcript'),
                              content: controller.transcript,
                              emptyText: strings.t('emptyTranscript'),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 300,
                            child: _TextCard(
                              title: strings.t('notes'),
                              content: controller.markdown,
                              emptyText: strings.t('emptyNotes'),
                              actionLabel: strings.t('saveMarkdown'),
                              onAction: () async {
                                final message = await controller.saveMarkdown();
                                if (!context.mounted) {
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      message == null
                                          ? strings.t('markdownSaved')
                                          : _mapError(strings, message),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          _SettingsCard(
                            controller: controller,
                            strings: strings,
                          ),
                          const SizedBox(height: 20),
                          _ModelsCard(
                            controller: controller,
                            strings: strings,
                            availableModels: _availableModels,
                            onRefresh: _refreshModels,
                          ),
                          const SizedBox(height: 20),
                          _ImportCard(controller: controller, strings: strings),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.strings, required this.controller});

  final AppStrings strings;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF19A67E), Color(0xFF53C3D1)],
            ),
          ),
          child: const Icon(Icons.graphic_eq_rounded, color: Colors.white),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.t('appTitle'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                strings.t('appSubtitle'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor?.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
        SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(
              value: ThemeMode.light,
              label: Text(strings.t('light')),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text(strings.t('dark')),
            ),
            ButtonSegment(
              value: ThemeMode.system,
              label: Text(strings.t('followSystem')),
            ),
          ],
          selected: {controller.themeMode},
          onSelectionChanged: (selection) {
            controller.setThemeMode(selection.first);
          },
        ),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'zh', label: Text('中文')),
            ButtonSegment(value: 'en', label: Text('EN')),
          ],
          selected: {controller.localeCode},
          onSelectionChanged: (selection) {
            controller.setLocaleCode(selection.first);
          },
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.controller, required this.strings});

  final AppController controller;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusLabel = _statusLabel(strings, controller.status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                Chip(
                  avatar: Icon(
                    controller.isListening
                        ? Icons.mic_rounded
                        : Icons.pause_circle_rounded,
                    size: 18,
                  ),
                  label: Text(
                    controller.isListening
                        ? strings.t('listening')
                        : strings.t('idle'),
                  ),
                ),
                Chip(label: Text('${strings.t('status')}: $statusLabel')),
                if (controller.selectedModelPath.isNotEmpty)
                  Chip(label: Text(p.basename(controller.selectedModelPath))),
              ],
            ),
            const SizedBox(height: 18),
            Text(strings.t('liveTitle'), style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(strings.t('liveHint')),
            const SizedBox(height: 12),
            Text(
              strings.t('gpuHint'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.74,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: theme.colorScheme.surfaceContainerLow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.t('segmentPreview'),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.latestSegment.isEmpty
                        ? strings.t('emptyTranscript')
                        : controller.latestSegment,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: controller.isListening
                      ? null
                      : () async {
                          final error = await controller
                              .startLiveTranscription();
                          if (error != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_mapError(strings, error)),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(strings.t('start')),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: controller.isListening
                      ? () => controller.stopLiveTranscription()
                      : null,
                  icon: const Icon(Icons.stop_rounded),
                  label: Text(strings.t('stop')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DictationSettingsCard extends StatelessWidget {
  const _DictationSettingsCard({
    required this.controller,
    required this.strings,
  });

  final AppController controller;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.t('dictationSettings'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(strings.t('dictationLanguage')),
            const SizedBox(height: 10),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'auto',
                  label: Text(strings.t('autoDetect')),
                ),
                ButtonSegment(value: 'zh', label: Text(strings.t('chinese'))),
                ButtonSegment(value: 'en', label: Text(strings.t('english'))),
              ],
              selected: {controller.dictationLanguage},
              onSelectionChanged: (selection) {
                controller.setDictationLanguage(selection.first);
              },
            ),
            const SizedBox(height: 16),
            Text(strings.t('latency')),
            const SizedBox(height: 10),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'fast', label: Text(strings.t('fast'))),
                ButtonSegment(
                  value: 'steady',
                  label: Text(strings.t('steady')),
                ),
                ButtonSegment(
                  value: 'precise',
                  label: Text(strings.t('precise')),
                ),
              ],
              selected: {controller.latencyPreset},
              onSelectionChanged: (selection) {
                controller.setLatencyPreset(selection.first);
              },
            ),
            const SizedBox(height: 14),
            Text(strings.t('liveModeHint')),
          ],
        ),
      ),
    );
  }
}

class _AutomationCard extends StatelessWidget {
  const _AutomationCard({
    required this.controller,
    required this.strings,
  });

  final AppController controller;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.t('automationSettings'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(strings.t('copySnippet')),
              value: controller.copySnippetEnabled,
              onChanged: controller.setCopySnippetEnabled,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(strings.t('autoPaste')),
              value: controller.autoPasteEnabled,
              onChanged: controller.setAutoPasteEnabled,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(strings.t('globalHotkeys')),
              value: controller.globalHotkeysEnabled,
              onChanged: (value) {
                controller.setGlobalHotkeysEnabled(value);
              },
            ),
            const SizedBox(height: 10),
            Text(strings.t('pasteMode')),
            const SizedBox(height: 10),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'incremental',
                  label: Text(strings.t('pasteIncremental')),
                ),
                ButtonSegment(
                  value: 'whole',
                  label: Text(strings.t('pasteWhole')),
                ),
              ],
              selected: {controller.pasteMode},
              onSelectionChanged: (selection) {
                controller.setPasteMode(selection.first);
              },
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: strings.t('toggleHotkey'),
              value: strings.t('hotkeyToggleValue'),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: strings.t('pasteHotkey'),
              value: strings.t('hotkeyPasteValue'),
            ),
            const SizedBox(height: 12),
            Text(strings.t('pasteModeHint')),
            const SizedBox(height: 8),
            Text(strings.t('automationHint')),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.controller, required this.strings});

  final AppController controller;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.t('settings'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 18),
            _PathRow(
              label: strings.t('whisperPath'),
              value: controller.whisperExecutable,
              buttonLabel: 'File',
              onTap: controller.pickWhisperExecutable,
            ),
            const SizedBox(height: 12),
            _EditableField(
              label: strings.t('whisperArgs'),
              initialValue: controller.whisperExtraArgs,
              hintText: strings.t('whisperArgsHint'),
              onChanged: controller.setWhisperExtraArgs,
            ),
            const SizedBox(height: 12),
            _PathRow(
              label: strings.t('ffmpegPath'),
              value: controller.ffmpegExecutable,
              buttonLabel: 'File',
              onTap: controller.pickFFmpegExecutable,
            ),
            const SizedBox(height: 12),
            _PathRow(
              label: strings.t('modelDir'),
              value: controller.modelDirectory,
              buttonLabel: 'Folder',
              onTap: controller.pickModelDirectory,
            ),
            const SizedBox(height: 16),
            Text(strings.t('runtimeHelp')),
          ],
        ),
      ),
    );
  }
}

class _ModelsCard extends StatelessWidget {
  const _ModelsCard({
    required this.controller,
    required this.strings,
    required this.availableModels,
    required this.onRefresh,
  });

  final AppController controller;
  final AppStrings strings;
  final List<String> availableModels;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final filtered = whisperModels.where((model) {
      return controller.modelFilter == 'all' ||
          controller.modelFilter == model.category;
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    strings.t('models'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'all', label: Text(strings.t('all'))),
                ButtonSegment(value: 'small', label: Text(strings.t('small'))),
                ButtonSegment(
                  value: 'medium',
                  label: Text(strings.t('medium')),
                ),
                ButtonSegment(value: 'large', label: Text(strings.t('large'))),
              ],
              selected: {controller.modelFilter},
              onSelectionChanged: (selection) {
                controller.setModelFilter(selection.first);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue:
                  availableModels.contains(controller.selectedModelPath)
                  ? controller.selectedModelPath
                  : null,
              decoration: InputDecoration(
                labelText: strings.t('selectedModel'),
              ),
              items: availableModels
                  .map(
                    (path) => DropdownMenuItem(
                      value: path,
                      child: Text(p.basename(path)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectModelPath(value);
                }
              },
            ),
            const SizedBox(height: 16),
            for (final model in filtered) ...[
              _ModelRow(
                model: model,
                controller: controller,
                strings: strings,
                onRefresh: onRefresh,
              ),
              const SizedBox(height: 10),
            ],
            if (controller.downloadProgress > 0 &&
                controller.downloadProgress < 1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(
                  value: controller.downloadProgress,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ModelRow extends StatelessWidget {
  const _ModelRow({
    required this.model,
    required this.controller,
    required this.strings,
    required this.onRefresh,
  });

  final WhisperModelInfo model;
  final AppController controller;
  final AppStrings strings;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${model.label} · ${model.sizeMb} MB',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              FilledButton.tonal(
                onPressed: controller.isBusy
                    ? null
                    : () async {
                        final confirmed =
                            await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(strings.t('download')),
                                content: Text(strings.t('downloadReminder')),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text(
                                      MaterialLocalizations.of(
                                        context,
                                      ).cancelButtonLabel,
                                    ),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text(strings.t('download')),
                                  ),
                                ],
                              ),
                            ) ??
                            false;
                        if (!confirmed) {
                          return;
                        }
                        final message = await controller.downloadModel(model);
                        await onRefresh();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message ?? strings.t('modelSaved')),
                            ),
                          );
                        }
                      },
                child: Text(strings.t('download')),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(model.multilingual ? 'Multilingual' : 'English only'),
        ],
      ),
    );
  }
}

class _ImportCard extends StatelessWidget {
  const _ImportCard({required this.controller, required this.strings});

  final AppController controller;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.t('importTitle'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(strings.t('importHint')),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: controller.isBusy
                  ? null
                  : () async {
                      final message = await controller
                          .importVideoAndTranscribe();
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            message == null
                                ? strings.t('videoDone')
                                : _mapError(strings, message),
                          ),
                        ),
                      );
                    },
              icon: const Icon(Icons.video_library_rounded),
              label: Text(strings.t('importButton')),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextCard extends StatelessWidget {
  const _TextCard({
    required this.title,
    required this.content,
    required this.emptyText,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String content;
  final String emptyText;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (actionLabel != null && onAction != null)
                  FilledButton.tonal(
                    onPressed: () => onAction!.call(),
                    child: Text(actionLabel!),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(content.isEmpty ? emptyText : content),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  const _EditableField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.hintText,
  });

  final String label;
  final String initialValue;
  final void Function(String value) onChanged;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextFormField(
          key: ValueKey('$label-$initialValue'),
          initialValue: initialValue,
          minLines: 1,
          maxLines: 2,
          onChanged: onChanged,
          decoration: InputDecoration(hintText: hintText),
        ),
      ],
    );
  }
}

class _PathRow extends StatelessWidget {
  const _PathRow({
    required this.label,
    required this.value,
    required this.buttonLabel,
    required this.onTap,
  });

  final String label;
  final String value;
  final String buttonLabel;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                key: ValueKey('$label-$value'),
                initialValue: value,
                readOnly: true,
                maxLines: 2,
              ),
            ),
            const SizedBox(width: 10),
            FilledButton.tonal(onPressed: onTap, child: Text(buttonLabel)),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        SelectableText(value),
      ],
    );
  }
}

String _mapError(AppStrings strings, String error) {
  switch (error) {
    case 'missing-config':
      return strings.t('missingConfig');
    case 'missing-import-config':
      return strings.t('missingImportConfig');
    case 'missing-model':
      return strings.t('missingModel');
    case 'missing-microphone-permission':
      return strings.t('microphonePermission');
    case 'no-transcript-yet':
      return strings.t('noTranscriptYet');
    default:
      return error;
  }
}

String _statusLabel(AppStrings strings, String status) {
  switch (status) {
    case 'recording':
      return strings.t('recording');
    case 'transcribing':
      return strings.t('transcribing');
    case 'ready':
      return strings.t('ready');
    case 'idle':
      return strings.t('idle');
    case 'downloading':
      return strings.t('download');
    default:
      return status;
  }
}
