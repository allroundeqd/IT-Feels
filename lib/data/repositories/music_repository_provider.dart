import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:it_feels_music/core/utils/service_locator.dart';
import 'package:it_feels_music/data/repositories/music_repository.dart';

/// Riverpod Provider exposing the IMusicRepository singleton
final musicRepositoryProvider = Provider<IMusicRepository>((ref) {
  return locator<IMusicRepository>();
});
