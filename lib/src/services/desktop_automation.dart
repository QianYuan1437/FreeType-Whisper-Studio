import 'dart:io';

import 'package:flutter/services.dart';

class DesktopAutomation {
  Future<void> copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  Future<String?> pasteTextIntoActiveInput(String text) async {
    if (text.trim().isEmpty) {
      return null;
    }

    await copyText(text);
    if (Platform.isWindows) {
      return _sendWindowsPaste();
    }
    if (Platform.isLinux) {
      return _sendLinuxPaste();
    }
    return 'Auto paste is only available on Windows and Linux.';
  }

  Future<String?> _sendWindowsPaste() async {
    final result = await Process.run('powershell', [
      '-NoProfile',
      '-Command',
      r'''
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class NativeKeyboard {
  [DllImport("user32.dll")]
  public static extern void keybd_event(byte bVk, byte bScan, int dwFlags, int dwExtraInfo);
}
"@;
$VK_CONTROL = 0x11;
$VK_V = 0x56;
$KEYEVENTF_KEYUP = 0x0002;
[NativeKeyboard]::keybd_event($VK_CONTROL, 0, 0, 0);
[NativeKeyboard]::keybd_event($VK_V, 0, 0, 0);
Start-Sleep -Milliseconds 40;
[NativeKeyboard]::keybd_event($VK_V, 0, $KEYEVENTF_KEYUP, 0);
[NativeKeyboard]::keybd_event($VK_CONTROL, 0, $KEYEVENTF_KEYUP, 0);
''',
    ]);

    if (result.exitCode != 0) {
      return '${result.stderr}'.trim();
    }
    return null;
  }

  Future<String?> _sendLinuxPaste() async {
    final result = await Process.run('bash', [
      '-lc',
      'if command -v xdotool >/dev/null 2>&1; then xdotool key --clearmodifiers ctrl+v; else exit 127; fi',
    ]);

    if (result.exitCode == 127) {
      return 'Auto paste on Linux requires xdotool.';
    }
    if (result.exitCode != 0) {
      return '${result.stderr}'.trim();
    }
    return null;
  }
}
