import os
import re

lib_dir = '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib'

files_to_modify = []
patterns = [
    r'width:\s*\d+(\.\d+)?',
    r'height:\s*\d+(\.\d+)?',
    r'padding:\s*EdgeInsets',
    r'margin:\s*EdgeInsets',
    r'fontSize:\s*\d+(\.\d+)?',
    r'radius:\s*\d+(\.\d+)?',
    r'Radius\.circular\(\d+(\.\d+)?\)'
]

for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            filepath = os.path.join(root, f)
            with open(filepath, 'r') as file:
                content = file.read()
                for p in patterns:
                    if re.search(p, content):
                        files_to_modify.append(filepath)
                        break

print(f"Total files needing responsive scaling: {len(files_to_modify)}")
