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
            
            # Find buildNativeAdTile(...) using a better approach.
            # We know exactly the format of the height line within these files.
            # Let's just find "height: XX.h," that occurs after "factoryId:" or "buildNativeAdTile".
            
            # Actually, we can just replace specific known ad heights.
            # splash_screen.dart: 16.h -> 0.16.sh
            # category_details_screen.dart: 35.h -> 0.35.sh
            # prompt_details_screen.dart: 16.h -> 0.16.sh, 35.h -> 0.35.sh
            # start_screen.dart: 34.h -> 0.34.sh
            # onboarding_screen.dart: 100.h -> 1.0.sh, 34.h -> 0.34.sh
            
            # Let's match: height: XX.h, where the previous lines contain AppStrings.nativeAdFactory
            def replace_ad_height(match):
                pre = match.group(1)
                num = float(match.group(2))
                val = num / 100.0
                return f"{pre}height: {val:g}.sh,"

            # Match AppStrings.nativeAdFactory... followed by height: XX.h,
            new_content = re.sub(r'(AppStrings\.nativeAdFactory[^,]+,.*?)\bheight:\s*([\d\.]+)\.h,', replace_ad_height, content, flags=re.DOTALL)
            
            with open(filepath, 'w') as file:
                file.write(new_content)
            print(f"Fixed {f}")
