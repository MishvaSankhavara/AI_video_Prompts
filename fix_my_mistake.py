import os
import re

lib_dir = '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib/screens'

screens_to_fix = [
    'splash_screen.dart',
    'category_details_screen.dart',
    'prompt_details_screen.dart',
    'start_screen.dart',
    'onboarding_screen.dart'
]

for root, _, files in os.walk(lib_dir):
    for f in files:
        if f in screens_to_fix:
            filepath = os.path.join(root, f)
            with open(filepath, 'r') as file:
                content = file.read()
            
            # Step 1: Revert all .sh back to .h (multiplying by 100)
            def revert_sh(match):
                num_str = match.group(1)
                val = float(num_str) * 100
                # Round to nearest integer if close to it, or keep 1 decimal
                val = round(val, 2)
                if val.is_integer():
                    val = int(val)
                return f"{val}.h"
                
            content = re.sub(r'([\d\.]+)\.sh', revert_sh, content)
            
            # Step 2: Now specifically target buildNativeAdTile and change its height to .sh
            # We can find buildNativeAdTile and the height argument inside it.
            def fix_ad_height(match):
                # match.group(0) is the entire buildNativeAdTile(...) call
                call_body = match.group(0)
                # find height: XX.h, and convert it to 0.XX.sh
                def replace_h(h_match):
                    val = float(h_match.group(1)) / 100.0
                    return f"height: {val:g}.sh,"
                new_call_body = re.sub(r'height:\s*([\d\.]+)\.h,', replace_h, call_body)
                return new_call_body
                
            new_content = re.sub(r'buildNativeAdTile\s*\([^;]+?\)', fix_ad_height, content, flags=re.DOTALL)
            
            with open(filepath, 'w') as file:
                file.write(new_content)
            print(f"Fixed {f}")
