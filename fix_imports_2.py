import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content

    # Remove duplicated imports
    lines = content.split('\n')
    seen_imports = set()
    new_lines = []
    
    for line in lines:
        if line.startswith("import 'package:it_feels_music/data/repositories/music_repository.dart';") or \
           line.startswith("import 'package:it_feels_music/core/utils/service_locator.dart';") or \
           line.startswith("import 'data/services/music_api_service.dart';"):
            if line in seen_imports:
                continue
            seen_imports.add(line)
        new_lines.append(line)
        
    content = '\n'.join(new_lines)
    
    # Remove lingering bad imports in main.dart
    content = content.replace("import 'data/services/music_api_service.dart';", "")
    
    if original != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
