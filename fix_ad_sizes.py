import os
import re

lib_dir = '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib'

# Files with known buildNativeAdTile height parameters that need converting to .sh
screens_to_fix = [
    'splash_screen.dart',
    'category_details_screen.dart',
    'prompt_details_screen.dart',
    'start_screen.dart',
    'onboarding_screen.dart'
]

# 1. Fix the buildNativeAdTile heights
for root, _, files in os.walk(os.path.join(lib_dir, 'screens')):
    for f in files:
        if f in screens_to_fix:
            filepath = os.path.join(root, f)
            with open(filepath, 'r') as file:
                content = file.read()
            
            # Replace height: XX.h, with height: 0.XX.sh,
            def replace_height(match):
                num = match.group(1)
                val = float(num) / 100.0
                # format without trailing zero if possible
                val_str = f"{val:g}"
                return f"height: {val_str}.sh,"
                
            new_content = re.sub(r'height:\s*([\d\.]+)\.h,', replace_height, content)
            
            if new_content != content:
                with open(filepath, 'w') as file:
                    file.write(new_content)
                print(f"Fixed ad heights in {f}")

# 2. Fix native_ad_shimmer.dart completely
shimmer_file = os.path.join(lib_dir, 'adsmanager', 'native ad', 'native_ad_shimmer.dart')
with open(shimmer_file, 'r') as file:
    shimmer_content = file.read()

def replace_shimmer_val(match):
    num = match.group(1)
    suffix = match.group(2)
    val = float(num) / 100.0
    val_str = f"{val:g}"
    new_suffix = '.sw' if suffix == '.w' else '.sh'
    return f"{val_str}{new_suffix}"

# Match any number followed by .w or .h
new_shimmer_content = re.sub(r'\b([\d\.]+)(\.w|\.h)\b', replace_shimmer_val, shimmer_content)

if new_shimmer_content != shimmer_content:
    with open(shimmer_file, 'w') as file:
        file.write(new_shimmer_content)
    print("Fixed native_ad_shimmer.dart")
