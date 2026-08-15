import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run test/yt_tester.dart <VIDEO_ID>');
    print('Example: dart run test/yt_tester.dart dQw4w9WgXcQ');
    return;
  }

  String videoId = args.first;
  if (videoId.contains(':')) {
    videoId = videoId.split(':').last;
  }

  final yt = YoutubeExplode();

  print('🔍 Fetching YouTube manifest for: $videoId...\n');

  try {
    final manifest = await yt.videos.streamsClient.getManifest(
      videoId,
      ytClients: [YoutubeApiClient.android, YoutubeApiClient.ios],
    );

    final video = await yt.videos.get(videoId);
    print('🎵 Title: "${video.title}"');
    print('👤 Channel: ${video.author}');
    print('⏱️ Duration: ${video.duration}\n');

    print('=== 📹 Adaptive Video-Only Streams (DASH) ===');
    final sortedVideo = manifest.videoOnly.sortByVideoQuality();
    if (sortedVideo.isEmpty) {
      print('❌ No video-only streams found.');
    } else {
      for (final stream in sortedVideo) {
        final codec = stream.videoCodec;
        final res = stream.videoResolution;
        final container = stream.container.name;
        final isH264 = codec.toLowerCase().contains('avc1') || codec.toLowerCase().contains('h264');
        final tag = isH264 ? '✅ (H.264 - 100% HW Accelerated)' : '⚠️ (${codec})';

        print('$tag | Res: ${res.width}x${res.height} (${stream.qualityLabel}) | Container: $container');
        print('    URL: ${stream.url}\n');
      }
    }

    print('=== 📦 Muxed Audio+Video Fallback Streams ===');
    if (manifest.muxed.isEmpty) {
      print('❌ No muxed streams found.');
    } else {
      for (final stream in manifest.muxed) {
        print('ℹ️ Quality: ${stream.videoQualityLabel} | Container: ${stream.container.name}');
        print('   URL: ${stream.url}\n');
      }
    }

    print('=== 🔊 Audio-Only Streams ===');
    if (manifest.audioOnly.isEmpty) {
      print('❌ No audio streams found.');
    } else {
      final bestAudio = manifest.audioOnly.withHighestBitrate();
      print('🔊 Best Audio: Bitrate: ${bestAudio.bitrate} | Container: ${bestAudio.container.name}');
      print('   URL: ${bestAudio.url}\n');
    }

    print('✅ Stream extraction diagnostic completed successfully.');
  } catch (e) {
    print('❌ Failed to extract YouTube streams: $e');
  } finally {
    yt.close();
  }
}
