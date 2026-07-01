import os
import re

lib_dir = '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib'

# Patterns that indicate a botched screenutil replace:
# e.g. 2.h0.h, 1.w.0.w, 3.r0.r, 2.sp8.sp
pattern = re.compile(r'\d+(?:\.[a-zA-Z]+)+[\d\.]*[a-zA-Z]*')

for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            filepath = os.path.join(root, f)
            with open(filepath, 'r') as file:
                lines = file.readlines()
                for i, line in enumerate(lines):
                    # Find all numbers with letters mixed in incorrectly
                    # e.g., 20.w.0.w, 1.sp8.sp
                    matches = re.findall(r'\b\d+\.[whr]|sp\d*\.[whr]|sp\b', line)
                    # A better way is to just look for things like .w., .h., .r., .sp., or .w\d, .h\d, .r\d, .sp\d
                    botched = re.findall(r'\d+\.[whrsp]+\.?\d*\.?[whrsp]*', line)
                    for b in botched:
                        # Only print if it looks botched (more than one period or letter followed by number)
                        if re.search(r'[whrsp]\d', b) or b.count('.') > 1:
                            print(f"{filepath}:{i+1}: {b}")
