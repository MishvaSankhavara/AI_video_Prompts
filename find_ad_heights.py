import os
import re

lib_dir = '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib'
for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            filepath = os.path.join(root, f)
            with open(filepath, 'r') as file:
                content = file.read()
                matches = re.finditer(r'buildNativeAdTile\([^;]+?\)', content, flags=re.DOTALL)
                for m in matches:
                    print(f"--- {filepath} ---")
                    # print just the height: line
                    call = m.group(0)
                    for line in call.split('\n'):
                        if 'height:' in line:
                            print(line.strip())
