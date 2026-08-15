import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:it_feels_music/core/utils/service_locator.dart';
import 'package:it_feels_music/services/backend_api_service.dart';
import 'package:it_feels_music/data/repositories/music_repository.dart';
import 'package:it_feels_music/data/datasources/remote_api_data_source.dart';
import 'package:it_feels_music/data/services/feedback_email_service.dart';
import '../data/repositories/music_repository_test.dart';

void main() {
  late FakeRemoteApiDataSource fakeRemote;
  late FakeLocalCacheDataSource fakeCache;
  late FakeStreamingService fakeStreaming;
  late FakeMusicApiService fakeSaavn;
  late MusicRepository repository;

  setUp(() async {
    await locator.reset();

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

    locator.registerLazySingleton<RemoteApiDataSource>(() => fakeRemote);
    locator.registerLazySingleton<IMusicRepository>(() => repository);
    locator.registerLazySingleton<FeedbackEmailService>(() => FeedbackEmailService(
          httpClient: MockClient((req) async => http.Response('{"success":true}', 200)),
        ));
  });

  group('BackendApiService Static Facade Unit Tests', () {
    test('search delegates call to locator<IMusicRepository>()', () async {
      fakeRemote.mockSearchProxy = [];

      final results = await BackendApiService.search('Rahman');

      expect(results, equals([]));
    });

    test('cleanSearchQuery formats query removing brackets and feature tags', () {
      final cleaned = BackendApiService.cleanSearchQuery('Song Title (Official Video) ft. Artist');
      expect(cleaned, equals('Song Title'));
    });
  });
}
