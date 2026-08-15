import 'dart:async';
import 'package:it_feels_music/data/models/song_model.dart';
import 'package:it_feels_music/data/datasources/local_cache_data_source.dart';
import 'package:it_feels_music/data/services/addon_manager.dart';

abstract class IMusicRepository {
  Future<List<Song>> fetchRecommendations({String? songId, String? artist});
  Future<List<Song>> fetchArtistTopTracks(String artistId);
  Future<List<Song>> searchNativeCatalog(String query);
  Future<Map<String, dynamic>?> fetchNativeHomeFeed();
  Future<List<Song>> search(String query, {int page = 1, int limit = 20});
  Future<String?> getStreamUrl(Song song);
  Future<Map<String, dynamic>?> getLyrics(
    String track,
    String artist, {
    String? album,
    int? duration,
  });
  Future<Map<String, dynamic>?> executeAiAction(String prompt);
  Future<Map<String, dynamic>> getVideoStreams(
    String videoId, {
    String? query,
    bool bypassCache = false,
  });
  Future<List<Map<String, dynamic>>> searchVideos(String query);
  Future<List<Map<String, dynamic>>> getTrendingVideos({int limit = 20});
  Future<List<Map<String, dynamic>>> directInnerTubeVideoSearch(
    String query, {
    int limit = 20,
  });
  Future<List<Map<String, dynamic>>> getRelatedVideos(
    String videoId, {
    String? query,
  });
  Future<String?> getChannelAvatar(String channelId);

  // Fallback UI Methods (to replace deleted services)
  Future<Map<String, dynamic>> getPlaylistDetails(String token, {int? page, int? count});
  Future<Map<String, dynamic>> fetchPlaylistDetails(String token, {int? page, int? count});
  Future<Map<String, dynamic>> getAlbumDetails(String token);
  Future<Map<String, dynamic>> fetchAlbumDetails(String token);
  Future<List<Song>> searchSongs(String query, {int page = 1, int count = 20});
  Future<List<Song>> getTrending();
  Future<List<dynamic>> getTopArtists();
  Future<List<Song>> getPlaylistTracks(String id);
  Future<List<Song>> searchPodcasts(String query, {int count = 10});
  Future<String?> resolveStream(Song song);
  Future<List<Song>> getRecommendedSongs(Song song);
  Future<void> preloadStreamUrl(Song song);
  Future<Map<String, dynamic>> searchAll(String query);
  Future<Map<String, dynamic>> fetchArtistDetails(String token, {int? page, int? count});
  Future<List<Playlist>> searchAlbums(String query, {int? page, int? count});
  Future<List<Playlist>> searchPlaylists(String query, {int? page, int? count});
  Future<Song?> fetchSongDetails(String token);
  Future<List<Song>> getTopStations();
  Future<List<Song>> searchStations(String query);
  Future<Map<String, dynamic>> getCharts();
  Future<Map<String, dynamic>> fetchHomepageData({Function(String)? onError});
}

class MusicRepository implements IMusicRepository {
  final LocalCacheDataSource cacheDataSource;

  MusicRepository({
    LocalCacheDataSource? cacheDataSource,
  })  : cacheDataSource = cacheDataSource ?? LocalCacheDataSource();

  @override
  Future<List<Song>> getTopStations() async => [];
  
  @override
  Future<List<Song>> searchStations(String query) async => [];

  @override
  Future<Map<String, dynamic>> getCharts() async => {'tracks': <Song>[], 'playlists': <Playlist>[]};

  @override
  Future<Map<String, dynamic>> fetchHomepageData({Function(String)? onError}) async {
    final addonData = await AddonManager().getHomeFeed();
    if (addonData != null) return addonData;
    
    final cached = await cacheDataSource.getCachedHomeFeed();
    return cached ?? {};
  }

  @override
  Future<Map<String, dynamic>> getPlaylistDetails(String token, {int? page, int? count}) async => {'songs': <Song>[]};
  @override
  Future<Map<String, dynamic>> fetchPlaylistDetails(String token, {int? page, int? count}) async => {'songs': <Song>[]};

  @override
  Future<Map<String, dynamic>> getAlbumDetails(String token) async => {'songs': <Song>[]};
  @override
  Future<Map<String, dynamic>> fetchAlbumDetails(String token) async => {'songs': <Song>[]};

  @override
  Future<List<Song>> searchSongs(String query, {int page = 1, int count = 20}) async {
    return search(query, page: page, limit: count);
  }

  @override
  Future<List<Song>> getTrending() async => [];

  @override
  Future<List<dynamic>> getTopArtists() async => [];

  @override
  Future<List<Song>> getPlaylistTracks(String id) async => [];

  @override
  Future<List<Song>> searchPodcasts(String query, {int count = 10}) async {
    final addonManager = AddonManager();
    final results = await addonManager.searchPodcasts(query);
    return results.take(count).toList();
  }

  @override
  Future<String?> resolveStream(Song song) async => null;

  @override
  Future<List<Song>> getRecommendedSongs(Song song) async => [];

  @override
  Future<void> preloadStreamUrl(Song song) async {}

  @override
  Future<Map<String, dynamic>> searchAll(String query) async => {'songs': <Song>[], 'albums': [], 'playlists': []};

  @override
  Future<Map<String, dynamic>> fetchArtistDetails(String token, {int? page, int? count}) async => {'topSongs': <Song>[]};

  @override
  Future<List<Playlist>> searchAlbums(String query, {int? page, int? count}) async => [];

  @override
  Future<List<Playlist>> searchPlaylists(String query, {int? page, int? count}) async {
    final addonManager = AddonManager();
    final results = await addonManager.searchPlaylists(query);
    if (count != null) {
      return results.take(count).toList();
    }
    return results;
  }

  @override
  Future<Song?> fetchSongDetails(String token) async => null;



  @override
  Future<List<Song>> fetchRecommendations({String? songId, String? artist}) async {
    return [];
  }

  @override
  Future<List<Song>> fetchArtistTopTracks(String artistId) async {
    return [];
  }

  @override
  Future<List<Song>> searchNativeCatalog(String query) async {
    final cached = await cacheDataSource.getCachedSearchResults(query);
    return cached ?? [];
  }

  @override
  Future<Map<String, dynamic>?> fetchNativeHomeFeed() async {
    return cacheDataSource.getCachedHomeFeed();
  }

  @override
  Future<List<Song>> search(String query, {int page = 1, int limit = 20}) async {
    final addonManager = AddonManager();
    final addonResults = await addonManager.search(query);
    if (addonResults.isNotEmpty) {
      return addonResults;
    }
    
    // Strict Legal Compliance: The app no longer falls back to any hardcoded
    // scraping logic. It relies exclusively on Addons.
    return [];
  }

  @override
  Future<String?> getStreamUrl(Song song) async {
    final addonManager = AddonManager();
    final addonStream = await addonManager.getStreamUrl(song);
    if (addonStream != null && addonStream.isNotEmpty) {
      return addonStream;
    }

    // Strict Legal Compliance: The app relies exclusively on Addons.
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getLyrics(
    String track,
    String artist, {
    String? album,
    int? duration,
  }) async {
    return null;
  }

  @override
  Future<Map<String, dynamic>?> executeAiAction(String prompt) async {
    return null;
  }

  @override
  Future<Map<String, dynamic>> getVideoStreams(
    String videoId, {
    String? query,
    bool bypassCache = false,
  }) async {
    return await addonManager.getVideoStreams(videoId, query);
  }

  @override
  Future<List<Map<String, dynamic>>> searchVideos(String query) async {
    return await addonManager.searchVideos(query);
  }

  @override
  Future<List<Map<String, dynamic>>> getTrendingVideos({int limit = 20}) async {
    return await addonManager.getTrendingVideos();
  }

  @override
  Future<List<Map<String, dynamic>>> directInnerTubeVideoSearch(
    String query, {
    int limit = 20,
  }) async {
    return await addonManager.searchVideos(query);
  }

  @override
  Future<List<Map<String, dynamic>>> getRelatedVideos(
    String videoId, {
    String? query,
  }) async {
    return [];
  }

  @override
  Future<String?> getChannelAvatar(String channelId) async {
    return null;
  }
}
