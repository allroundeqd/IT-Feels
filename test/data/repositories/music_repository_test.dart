import 'package:flutter_test/flutter_test.dart';
import 'package:it_feels_music/data/models/song_model.dart';
import 'package:it_feels_music/data/datasources/remote_api_data_source.dart';
import 'package:it_feels_music/data/datasources/local_cache_data_source.dart';
import 'package:it_feels_music/data/services/streaming_service.dart';
import 'package:it_feels_music/data/services/music_api_service.dart';
import 'package:it_feels_music/data/repositories/music_repository.dart';

class FakeRemoteApiDataSource extends RemoteApiDataSource {
  bool shouldThrow = false;
  List<Song>? mockSearchCatalog;
  Map<String, dynamic>? mockHomeFeed;
  List<Song>? mockSearchProxy;
  String? mockStreamUrl;

  @override
  Future<List<Song>?> searchNativeCatalog(String query) async {
    if (shouldThrow) throw Exception('Network timeout');
    return mockSearchCatalog;
  }

  @override
  Future<Map<String, dynamic>?> fetchNativeHomeFeed() async {
    if (shouldThrow) throw Exception('Network timeout');
    return mockHomeFeed;
  }

  @override
  Future<List<Song>?> searchProxy(String query, {int page = 1, int limit = 20}) async {
    if (shouldThrow) throw Exception('Network timeout');
    return mockSearchProxy;
  }

  @override
  Future<String?> getStreamUrl(Song song) async {
    if (shouldThrow) throw Exception('Network timeout');
    return mockStreamUrl;
  }
}

class FakeLocalCacheDataSource extends LocalCacheDataSource {
  List<Song>? cachedSearch;
  Map<String, dynamic>? cachedFeed;

  @override
  Future<List<Song>?> getCachedSearchResults(String query) async {
    return cachedSearch;
  }

  @override
  Future<Map<String, dynamic>?> getCachedHomeFeed() async {
    return cachedFeed;
  }
}

class FakeStreamingService extends StreamingService {
  List<Map<String, dynamic>> mockInnerTubeSearch = [];
  Map<String, dynamic> mockStreams = {};

  @override
  Future<List<Map<String, dynamic>>> directInnerTubeVideoSearch(String query, {int limit = 20}) async {
    return mockInnerTubeSearch;
  }

  @override
  Future<Map<String, dynamic>> getVideoStreams(String videoId, {String? query, bool bypassCache = false}) async {
    return mockStreams;
  }
}

class FakeMusicApiService extends MusicApiService {
  List<Song> mockSaavnSearch = [];

  @override
  Future<List<Song>> searchSongs(String query, {int page = 1, int count = 20, Function(String message)? onError}) async {
    return mockSaavnSearch;
  }
}

void main() {
  late FakeRemoteApiDataSource fakeRemote;
  late FakeLocalCacheDataSource fakeCache;
  late FakeStreamingService fakeStreaming;
  late FakeMusicApiService fakeSaavn;
  late MusicRepository repository;

  final sampleSong = Song(
    id: 'test_123',
    saavnId: 'test_123',
    title: 'Test Title',
    artist: 'Test Artist',
    album: 'Test Album',
    duration: 180,
    coverArt: 'https://example.com/cover.jpg',
    addedAt: DateTime.now(),
  );

  setUp(() {
    fakeRemote = FakeRemoteApiDataSource();
    fakeCache = FakeLocalCacheDataSource();
    fakeStreaming = FakeStreamingService();
    fakeSaavn = FakeMusicApiService();

    repository = MusicRepository(
      remoteDataSource: fakeRemote,
      cacheDataSource: fakeCache,
      streamingService: fakeStreaming,
      saavnApiService: fakeSaavn,
    );
  });

  group('MusicRepository Fallback Unit Tests', () {
    test('searchNativeCatalog falls back to LocalCacheDataSource on Remote error/null', () async {
      fakeRemote.mockSearchCatalog = null;
      fakeCache.cachedSearch = [sampleSong];

      final results = await repository.searchNativeCatalog('A.R. Rahman');

      expect(results, equals([sampleSong]));
    });

    test('fetchNativeHomeFeed falls back to LocalCacheDataSource on Remote error/null', () async {
      fakeRemote.mockHomeFeed = null;
      fakeCache.cachedFeed = {'shelves': []};

      final feed = await repository.fetchNativeHomeFeed();

      expect(feed, equals({'shelves': []}));
    });

    test('search falls back to MusicApiService (Saavn) when Remote proxy fails', () async {
      fakeRemote.mockSearchProxy = null;
      fakeSaavn.mockSaavnSearch = [sampleSong];

      final results = await repository.search('Arijit Singh', page: 1, limit: 20);

      expect(results, equals([sampleSong]));
    });

    test('getStreamUrl falls back to StreamingService when Remote proxy fails', () async {
      fakeRemote.mockStreamUrl = null;
      fakeStreaming.mockInnerTubeSearch = [{'id': 'youtube:xyz123'}];
      fakeStreaming.mockStreams = {'audioUrl': 'https://googlevideo.com/audio.opus'};

      final streamUrl = await repository.getStreamUrl(sampleSong);

      expect(streamUrl, equals('https://googlevideo.com/audio.opus'));
    });
  });
}
