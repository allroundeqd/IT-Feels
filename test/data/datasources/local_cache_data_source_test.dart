import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:it_feels_music/data/datasources/local_cache_data_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalCacheDataSource Unit Tests', () {
    test('saveSearchResults and getCachedSearchResults store and retrieve search results', () async {
      SharedPreferences.setMockInitialValues({});
      final dataSource = LocalCacheDataSource();

      final jsonPayload = jsonEncode({
        'success': true,
        'results': [
          {
            'id': 'offline_1',
            'title': 'Offline Song',
            'artist': 'Offline Artist',
            'album': 'Offline Album',
            'duration': 200,
            'coverArt': 'https://example.com/cover.jpg',
          }
        ]
      });

      await dataSource.saveSearchResults('Rahman', jsonPayload);
      final cachedSongs = await dataSource.getCachedSearchResults('Rahman');

      expect(cachedSongs, isNotNull);
      expect(cachedSongs!.length, equals(1));
      expect(cachedSongs.first.title, equals('Offline Song'));
      expect(cachedSongs.first.artist, equals('Offline Artist'));
    });

    test('getCachedSearchResults handles corrupt JSON data safely by returning null', () async {
      SharedPreferences.setMockInitialValues({
        'offline_native_search_corrupt': 'NOT_A_JSON_STRING',
      });
      final dataSource = LocalCacheDataSource();

      final cachedSongs = await dataSource.getCachedSearchResults('corrupt');

      expect(cachedSongs, isNull);
    });

    test('saveHomeFeed and getCachedHomeFeed store and retrieve home feed', () async {
      SharedPreferences.setMockInitialValues({});
      final dataSource = LocalCacheDataSource();

      final feedJson = jsonEncode({
        'success': true,
        'shelves': [
          {'title': 'Top Hits', 'items': []}
        ]
      });

      await dataSource.saveHomeFeed(feedJson);
      final feed = await dataSource.getCachedHomeFeed();

      expect(feed, isNotNull);
      expect(feed!['success'], isTrue);
    });
  });
}
