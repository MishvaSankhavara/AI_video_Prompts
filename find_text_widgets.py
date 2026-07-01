import os
import re

lib_dir = '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib'

# Regex to match Text('...') or Text("...") possibly with newlines
pattern = re.compile(r"Text\s*\(\s*['\"]([^'\"]+)['\"]", re.MULTILINE)

for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            filepath = os.path.join(root, f)
            with open(filepath, 'r') as file:
                content = file.read()
                matches = pattern.findall(content)
                for m in matches:
                    if 'AppStrings' not in m and len(m.strip()) > 1:
                        print(f"{filepath}: {m}")

