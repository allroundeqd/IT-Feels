import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:it_feels_music/core/utils/service_locator.dart';
import 'package:it_feels_music/data/models/song_model.dart';
import 'package:it_feels_music/data/repositories/music_repository.dart';
import 'package:it_feels_music/data/services/feedback_email_service.dart';

/// Legacy Static Facade for [IMusicRepository] & [FeedbackEmailService].
/// Delegates all calls to the injected clean architecture components in [locator].
class BackendApiService {
  static bool useProxyBackend = false;

  static http.Client httpClient = http.Client();

  static String baseUrl = '';

  static String ytDlpBackendUrl = '';

  static String cleanSearchQuery(String titleOrQuery, [String? artist]) {
    final combined = artist != null && artist.isNotEmpty ? '$titleOrQuery $artist' : titleOrQuery;
    return combined
        .replaceAll(RegExp(r'\s*\([^)]*\)'), '')
        .replaceAll(RegExp(r'\s*\[[^\]]*\]'), '')
        .replaceAll(RegExp(r'\s*ft\..*', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*feat\..*', caseSensitive: false), '')
        .trim();
  }

  static Future<List<Song>> fetchRecommendations({String? songId, String? artist}) {
    return locator<IMusicRepository>().fetchRecommendations(songId: songId, artist: artist);
  }

  static Future<List<Song>> fetchArtistTopTracks(String artistId) {
    return locator<IMusicRepository>().fetchArtistTopTracks(artistId);
  }

  static Future<List<Song>> searchNativeCatalog(String query) {
    return locator<IMusicRepository>().searchNativeCatalog(query);
  }

  static Future<Map<String, dynamic>?> fetchNativeHomeFeed() {
    return locator<IMusicRepository>().fetchNativeHomeFeed();
  }

  static Future<List<Song>> search(String query, {int page = 1, int limit = 20}) {
    return locator<IMusicRepository>().search(query, page: page, limit: limit);
  }

  static Future<String?> getStreamUrl(Song song) {
    return locator<IMusicRepository>().getStreamUrl(song);
  }

  static Future<Map<String, dynamic>?> getLyrics(
    String track,
    String artist, {
    String? album,
    int? duration,
  }) {
    return locator<IMusicRepository>().getLyrics(track, artist, album: album, duration: duration);
  }

  static Future<Map<String, dynamic>?> executeAiAction(String prompt) {
    return locator<IMusicRepository>().executeAiAction(prompt);
  }

  static Future<bool> logTelemetry(String eventName, Map<String, dynamic> metadata) {
    return locator<FeedbackEmailService>().logTelemetry(eventName, metadata);
  }

  static Future<bool> sendTelemetryPlay(dynamic songOrId, [String? title, String? artist]) {
    String songId = '';
    String songTitle = title ?? '';
    String songArtist = artist ?? '';

    if (songOrId is Song) {
      songId = songOrId.id;
      songTitle = songOrId.title;
      songArtist = songOrId.artist;
    } else {
      songId = songOrId.toString();
    }

    return locator<FeedbackEmailService>().logTelemetry('play_song', {
      'songId': songId,
      'title': songTitle,
      'artist': songArtist,
    });
  }

  static Future<bool> sendWelcomeEmail(String email, [String? name]) {
    return locator<FeedbackEmailService>().sendFeedbackEmail(
      subject: 'Welcome to It Feels Music',
      body: 'Welcome ${name ?? email}!',
      replyTo: email,
    );
  }

  static Future<bool> sendFeedbackEmail({
    required String subject,
    required String body,
    String? replyTo,
  }) {
    return locator<FeedbackEmailService>().sendFeedbackEmail(
      subject: subject,
      body: body,
      replyTo: replyTo,
    );
  }

  static Future<void> preloadVideoStreams(Song song) async {}
  static void clearVideoStreamCache(String videoId) {}

  static Future<Map<String, dynamic>> getVideoStreams(
    String videoId, {
    String? query,
    bool bypassCache = false,
  }) {
    return locator<IMusicRepository>().getVideoStreams(videoId, query: query, bypassCache: bypassCache);
  }

  static Future<List<Map<String, dynamic>>> searchVideos(String query) {
    return locator<IMusicRepository>().searchVideos(query);
  }

  static Future<List<Map<String, dynamic>>> getTrendingVideos({int limit = 20}) {
    return locator<IMusicRepository>().getTrendingVideos(limit: limit);
  }

  static Future<List<Map<String, dynamic>>> directInnerTubeVideoSearch(
    String query, {
    int limit = 20,
  }) {
    return locator<IMusicRepository>().directInnerTubeVideoSearch(query, limit: limit);
  }

  static Future<List<Map<String, dynamic>>> getRelatedVideos(
    String videoId, {
    String? query,
  }) {
    return locator<IMusicRepository>().getRelatedVideos(videoId, query: query);
  }

  static Future<String?> getChannelAvatar(String channelId) {
    return locator<IMusicRepository>().getChannelAvatar(channelId);
  }
}