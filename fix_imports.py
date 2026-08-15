import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content

    # Replace imports
    content = re.sub(r"import 'package:it_feels_music/data/services/music_api_service\.dart';", "import 'package:it_feels_music/core/utils/service_locator.dart';\nimport 'package:it_feels_music/data/repositories/music_repository.dart';", content)
    content = re.sub(r"import 'package:it_feels_music/data/services/deezer_api_service\.dart';", "", content)
    content = re.sub(r"import 'package:it_feels_music/data/services/youtube_podcast_provider\.dart';", "", content)
    content = re.sub(r"import 'package:it_feels_music/data/services/podcast_provider\.dart';", "", content)
    content = re.sub(r"import 'package:it_feels_music/data/services/radio_api_service\.dart';", "import 'package:it_feels_music/core/utils/service_locator.dart';\nimport 'package:it_feels_music/data/repositories/music_repository.dart';", content)
    content = re.sub(r"import 'package:it_feels_music/data/services/stream_resolver\.dart';", "", content)
    
    # In home_provider
    content = content.replace("late final MusicApiService saavnApi;", "late final IMusicRepository musicRepo;")
    content = content.replace("late final DeezerApiService deezerApi;", "")
    content = content.replace("saavnApi = locator.isRegistered<MusicApiService>() ? locator<MusicApiService>() : MusicApiService();", "musicRepo = locator<IMusicRepository>();")
    content = content.replace("deezerApi = locator.isRegistered<DeezerApiService>() ? locator<DeezerApiService>() : DeezerApiService();", "")
    content = content.replace("saavnApi.", "musicRepo.")
    
    content = content.replace("final ytPodcastProvider = YouTubePodcastProvider();", "final ytPodcastProvider = locator<IMusicRepository>();")
    
    content = content.replace("MusicApiService()", "locator<IMusicRepository>()")
    content = content.replace("MusicApiService", "IMusicRepository")
    
    content = content.replace("DeezerApiService", "IMusicRepository")
    content = content.replace("deezerApi.", "musicRepo.")
    
    content = content.replace("StreamResolver", "IMusicRepository")
    content = content.replace("_streamResolver = locator<IMusicRepository>();", "_streamResolver = locator<IMusicRepository>();")

    content = content.replace("PodcastProvider", "IMusicRepository")
    content = content.replace("RadioApiService", "IMusicRepository")
    
    if "locator<AudioEngineService>" in content and "import 'package:it_feels_music/core/utils/service_locator.dart';" not in content:
        content = "import 'package:it_feels_music/core/utils/service_locator.dart';\nimport 'package:it_feels_music/data/services/audio_engine_service.dart';\n" + content
    
    if original != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
