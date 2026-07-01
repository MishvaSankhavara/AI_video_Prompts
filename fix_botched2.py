import os
import re

lib_dir = '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib'

# This script finds ANY token that contains a digit and a screenutil letter (w, h, r, sp)
# but is NOT exactly \d+(?:\.\d+)?\.[whrsp]
# It will print them out.
def print_botched():
    for root, _, files in os.walk(lib_dir):
        for f in files:
            if f.endswith('.dart'):
                filepath = os.path.join(root, f)
                with open(filepath, 'r') as file:
                    lines = file.readlines()
                    for i, line in enumerate(lines):
                        # Find tokens mixing digits, dots, w, h, r, sp
                        # but that are not purely digits/dots, and not purely letters
                        # A quick regex to find anything with numbers and at least one of w,h,r,sp
                        # specifically looking for bad ones:
                        tokens = re.findall(r'\b\d+[whrsp0-9\.]+[whrsp0-9]*\b', line)
                        for t in tokens:
                            if not re.fullmatch(r'\d+(?:\.\d+)?\.(?:w|h|r|sp)', t):
                                # Also exclude pure digits + dot (if caught by accident, though regex needs letters)
                                if re.search(r'[whrsp]', t):
                                    print(f"{filepath}:{i+1}: {t}")

print_botched()
