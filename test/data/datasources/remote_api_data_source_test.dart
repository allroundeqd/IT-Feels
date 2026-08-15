import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:it_feels_music/data/datasources/remote_api_data_source.dart';
import 'package:it_feels_music/data/models/song_model.dart';

void main() {
  group('RemoteApiDataSource Unit Tests', () {
    test('fetchRecommendations returns list of Songs on HTTP 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'recommendations': [
              {
                'id': 'rec_1',
                'title': 'Rec Song',
                'artist': 'Rec Artist',
                'album': 'Rec Album',
                'duration': 210,
                'coverArt': 'https://example.com/rec.jpg',
              }
            ]
          }),
          200,
        );
      });

      final dataSource = RemoteApiDataSource(httpClient: mockClient);
      final results = await dataSource.fetchRecommendations(artist: 'A.R. Rahman');

      expect(results.length, equals(1));
      expect(results.first.title, equals('Rec Song'));
      expect(results.first.artist, equals('Rec Artist'));
    });

    test('searchProxy returns list of Songs on HTTP 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'results': [
              {
                'id': 'proxy_1',
                'title': 'Proxy Title',
                'artist': 'Proxy Artist',
                'album': 'Proxy Album',
                'duration': 190,
                'coverArt': 'https://example.com/art.jpg',
              }
            ]
          }),
          200,
        );
      });

      final dataSource = RemoteApiDataSource(httpClient: mockClient);
      final results = await dataSource.searchProxy('Arijit Singh');

      expect(results, isNotNull);
      expect(results!.length, equals(1));
      expect(results.first.id, equals('proxy_1'));
    });

    test('getStreamUrl returns stream URL on success', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'streamUrl': 'https://proxy-cdn.com/audio.mp3',
          }),
          200,
        );
      });

      final dataSource = RemoteApiDataSource(httpClient: mockClient);
      final song = Song(
        id: 's1',
        saavnId: 's1',
        title: 'Song',
        artist: 'Artist',
        album: 'Album',
        duration: 120,
        coverArt: 'cover',
        addedAt: DateTime.now(),
      );

      final url = await dataSource.getStreamUrl(song);

      expect(url, equals('https://proxy-cdn.com/audio.mp3'));
    });

    test('getLyrics returns plain and synced lyrics', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'lyrics': {
              'plainLyrics': 'La la la',
              'syncedLyrics': '[00:10.00] La la la',
            }
          }),
          200,
        );
      });

      final dataSource = RemoteApiDataSource(httpClient: mockClient);
      final lyricsMap = await dataSource.getLyrics('Track', 'Artist');

      expect(lyricsMap, isNotNull);
      expect(lyricsMap!['plain'], equals('La la la'));
      expect(lyricsMap['synced'], equals('[00:10.00] La la la'));
    });

    test('songFromProxyJson correctly maps JSON to Song instance', () {
      final dataSource = RemoteApiDataSource();
      final json = {
        'id': 'saavn:xyz789',
        'title': 'Test Title',
        'artist': 'Test Artist',
        'album': 'Test Album',
        'coverArt': 'https://example.com/cover.jpg',
        'duration': 180,
      };

      final song = dataSource.songFromProxyJson(json);

      expect(song.id, equals('saavn:xyz789'));
      expect(song.saavnId, equals('xyz789'));
      expect(song.title, equals('Test Title'));
      expect(song.artist, equals('Test Artist'));
    });
  });
}
