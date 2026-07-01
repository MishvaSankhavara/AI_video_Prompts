import os
import re

files_to_fix = [
    '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib/adsmanager/rewarded_ad_service.dart',
    '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib/adsmanager/interstitial_ad_service.dart'
]

for filepath in files_to_fix:
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Replace "// CommonUtils.printLog" with "CommonUtils.printLog"
    new_content = content.replace('// CommonUtils.printLog', 'CommonUtils.printLog')
    
    with open(filepath, 'w') as f:
        f.write(new_content)
    print(f"Uncommented logs in {os.path.basename(filepath)}")

