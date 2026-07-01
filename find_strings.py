import os
import re

lib_dir = '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib'

pattern = re.compile(r"Text\(\s*['\"]([^'\"]+)['\"]")
pattern_named = re.compile(r"\b(?:title|subtitle|price|badgeText|label)\s*:\s*['\"]([^'\"]+)['\"]")

for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            filepath = os.path.join(root, f)
            with open(filepath, 'r') as file:
                lines = file.readlines()
                for i, line in enumerate(lines):
                    # Ignore lines with AppStrings
                    if 'AppStrings' in line:
                        continue
                    # Ignore empty strings or single chars if not meaningful
                    matches = pattern.findall(line)
                    matches += pattern_named.findall(line)
                    for m in matches:
                        if len(m.strip()) > 1 and not m.startswith('assets/'):
                            print(f"{filepath}:{i+1}: {m}")

