import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:it_feels_music/data/models/song_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class AddonManager {
  static final AddonManager _instance = AddonManager._internal();
  factory AddonManager() => _instance;
  AddonManager._internal();

  final List<JavascriptRuntime> _activeRuntimes = [];

  bool get hasPlugins => _activeRuntimes.isNotEmpty;
  
  final ValueNotifier<bool> hasPluginsNotifier = ValueNotifier(false);

  Future<void> initialize() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final pluginsDir = Directory('${dir.path}/plugins');
      if (!await pluginsDir.exists()) {
        await pluginsDir.create();
      }

      final files = pluginsDir.listSync().where((f) => f.path.endsWith('.js')).toList();
      for (var file in files) {
        await _loadPlugin(file);
      }
      hasPluginsNotifier.value = _activeRuntimes.isNotEmpty;
    } catch (e) {
      debugPrint('[AddonManager] Init error: $e');
    }
  }

  Future<bool> installDefaultPlugin() async {
    final defaultPluginUrl = "https://raw.githubusercontent.com/Allrounder687/it-feels-provider-backend/main/backend_addon.js";
    return await installPluginFromUrl(defaultPluginUrl, "default_backend.js");
  }

  Future<bool> installPluginFromUrl(String url, String filename) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final pluginsDir = Directory('${dir.path}/plugins');
        if (!await pluginsDir.exists()) {
          await pluginsDir.create();
        }
        
        String safeName = filename.endsWith('.js') ? filename : '$filename.js';
        final file = File('${pluginsDir.path}/$safeName');
        await file.writeAsString(response.body);
        
        await _loadPlugin(file);
        hasPluginsNotifier.value = _activeRuntimes.isNotEmpty;
        return true;
      }
    } catch (e) {
      debugPrint('[AddonManager] Error installing plugin from URL: $e');
    }
    return false;
  }

  Future<void> _loadPlugin(FileSystemEntity file) async {
    try {
      final source = await File(file.path).readAsString();
      final JavascriptRuntime runtime = getJavascriptRuntime();
      
      runtime.evaluate(source);
      _activeRuntimes.add(runtime);
      debugPrint('[AddonManager] Loaded plugin: ${file.path}');
    } catch (e) {
      debugPrint('[AddonManager] Error loading plugin ${file.path}: $e');
    }
  }

  Future<List<Song>> search(String query) async {
    List<Song> allResults = [];
    for (var runtime in _activeRuntimes) {
      try {
        final jsResult = runtime.evaluate("typeof getSearchUrl === 'function' ? getSearchUrl('${query.replaceAll("'", "\\'")}') : null");
        final searchUrl = jsResult.stringResult;
        
        if (searchUrl != null && searchUrl != 'null' && searchUrl.isNotEmpty) {
          final response = await http.get(Uri.parse(searchUrl));
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['success'] == true && data['results'] != null) {
              for (var item in data['results']) {
                allResults.add(Song(
                  id: item['id']?.toString() ?? '',
                  saavnId: item['id']?.toString() ?? '',
                  title: item['title']?.toString() ?? '',
                  artist: item['artist']?.toString() ?? '',
                  album: item['album']?.toString() ?? 'Unknown',
                  coverArt: item['coverArt']?.toString() ?? item['albumArt']?.toString() ?? '',
                  duration: int.tryParse(item['duration']?.toString() ?? '0') ?? 0,
                  addedAt: DateTime.now(),
                ));
              }
            }
          }
        }
      } catch (e) {
        debugPrint('[AddonManager] Search error in plugin: $e');
      }
    }
    return allResults;
  }

  Future<String?> getStreamUrl(Song song) async {
    for (var runtime in _activeRuntimes) {
      try {
        final jsResult = runtime.evaluate("typeof getStreamUrl === 'function' ? getStreamUrl('${song.id.replaceAll("'", "\\'")}') : null");
        final streamApiUrl = jsResult.stringResult;
        
        if (streamApiUrl != null && streamApiUrl != 'null' && streamApiUrl.isNotEmpty) {
          final response = await http.get(Uri.parse(streamApiUrl));
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['success'] == true && data['audioUrl'] != null) {
              return data['audioUrl'];
            }
          }
        }
      } catch (e) {
        debugPrint('[AddonManager] getStreamUrl error in plugin: $e');
      }
    }
    return null;
  }
  
  Future<Map<String, dynamic>?> getHomeFeed() async {
    for (var runtime in _activeRuntimes) {
      try {
        final jsResult = runtime.evaluate("typeof getHomeFeedUrl === 'function' ? getHomeFeedUrl() : null");
        final homeUrl = jsResult.stringResult;
        
        if (homeUrl != null && homeUrl != 'null' && homeUrl.isNotEmpty) {
          final response = await http.get(Uri.parse(homeUrl));
          if (response.statusCode == 200) {
            return jsonDecode(response.body);
          }
        }
      } catch (e) {
        debugPrint('[AddonManager] getHomeFeed error in plugin: $e');
      }
    }
    return null;
  }
}
