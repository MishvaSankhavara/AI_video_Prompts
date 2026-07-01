import os
import re

lib_dir = '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib'

pattern = re.compile(r"Text\(\s*['\"]([^'\"]+)['\"]")
pattern_named = re.compile(r"\b(?:title|subtitle|price|badgeText|label)\s*:\s*['\"]([^'\"]+)['\"]")
pattern_any = re.compile(r"['\"]([a-zA-Z][^'\"]{3,})['\"]")

for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            filepath = os.path.join(root, f)
            with open(filepath, 'r') as file:
                lines = file.readlines()
                for i, line in enumerate(lines):
                    # Ignore lines with AppStrings, import, assets, keys
                    if 'AppStrings' in line or 'import' in line or 'assets/' in line or 'ValueKey' in line or 'fontFamily' in line:
                        continue
                    if 'SharedPreferences' in line or 'Key' in line:
                        continue
                    # Check for simple text usages
                    matches = pattern.findall(line)
                    if not matches:
                        matches = pattern_named.findall(line)
                    
                    for m in matches:
                        if len(m.strip()) > 1:
                            print(f"{filepath}:{i+1}: {m.strip()}")

