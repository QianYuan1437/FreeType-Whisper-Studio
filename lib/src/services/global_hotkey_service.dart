import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class GlobalHotkeyService {
  static final HotKey toggleDictationHotKey = HotKey(
    key: PhysicalKeyboardKey.keyR,
    modifiers: [HotKeyModifier.alt, HotKeyModifier.shift],
    scope: HotKeyScope.system,
  );

  static final HotKey pasteLatestHotKey = HotKey(
    key: PhysicalKeyboardKey.keyV,
    modifiers: [HotKeyModifier.alt, HotKeyModifier.shift],
    scope: HotKeyScope.system,
  );

  Future<void> register({
    required Future<void> Function() onToggleDictation,
    required Future<void> Function() onPasteLatest,
  }) async {
    await hotKeyManager.unregisterAll();
    await hotKeyManager.register(
      toggleDictationHotKey,
      keyDownHandler: (_) => onToggleDictation(),
    );
    await hotKeyManager.register(
      pasteLatestHotKey,
      keyDownHandler: (_) => onPasteLatest(),
    );
  }

  Future<void> unregisterAll() => hotKeyManager.unregisterAll();
}
