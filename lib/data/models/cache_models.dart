import 'package:isar/isar.dart';

part 'cache_models.g.dart';

@collection
class CachedStream {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String videoId;

  late String resolvedVideoUrl;
  
  late String resolvedAudioUrl;
  
  late String quality;
  
  late DateTime expiryTime;
  
  late DateTime resolvedAt;
  
  late int resolverVersion; // e.g. 1
  
  late int failureCount; // Track retry counts

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}

@collection
class CachedPalette {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String artworkUrl;

  late int backgroundColorValue;
  late int surfaceColorValue;
  late int accentColorValue;

  late DateTime cachedAt;
}

@collection
class CachedLyrics {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String songId;

  String? staticLyrics;
  
  late String syncedLyricsJson; // Serialized list of LyricLine
  late String source;

  late DateTime cachedAt;
  late DateTime expiryTime;

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}

@collection
class CachedSearch {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String queryKey;

  late String responseJson; // Serialized list of Song or Playlist

  late DateTime cachedAt;
  late DateTime expiryTime;

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}
