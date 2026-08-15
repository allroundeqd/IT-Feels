import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:it_feels_music/core/utils/service_locator.dart';
import 'package:it_feels_music/data/services/audio_engine_service.dart';
import 'dart:async';

class SystemTrayManager with TrayListener {
  static final SystemTrayManager instance = SystemTrayManager._internal();
  SystemTrayManager._internal();

  StreamSubscription? _playerStateSub;
  bool _isPlaying = false;

  Future<void> init() async {
    if (kIsWeb || !Platform.isWindows) return;

    trayManager.addListener(this);

    _playerStateSub = locator<AudioEngineService>().audioHandler.playbackState.listen((state) {
      final playing = state.playing;
      if (playing != _isPlaying) {
        _isPlaying = playing;
        _updateContextMenu();
      }
    });

    await _updateContextMenu();
  }

  Future<void> _updateContextMenu() async {
    Menu menu = Menu(
      items: [
        MenuItem(
          key: 'play_pause',
          label: _isPlaying ? 'Pause' : 'Play',
        ),
        MenuItem(
          key: 'next',
          label: 'Next Track',
        ),
        MenuItem(
          key: 'prev',
          label: 'Previous Track',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'show_app',
          label: 'Show App',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit_app',
          label: 'Exit IT-Feels',
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    windowManager.focus();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    final engine = locator<AudioEngineService>();

    switch (menuItem.key) {
      case 'play_pause':
        if (_isPlaying) {
          await engine.pause();
        } else {
          await engine.play();
        }
        break;
      case 'next':
        await engine.audioHandler.skipToNext();
        break;
      case 'prev':
        await engine.audioHandler.skipToPrevious();
        break;
      case 'show_app':
        windowManager.show();
        windowManager.focus();
        break;
      case 'exit_app':
        await windowManager.setPreventClose(false);
        await windowManager.destroy();
        exit(0);
    }
  }

  void dispose() {
    trayManager.removeListener(this);
    _playerStateSub?.cancel();
  }
}
