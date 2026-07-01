import os
import re

# 1. Remove from ad_ids.dart
ad_ids_path = '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib/adsmanager/ad_ids.dart'
with open(ad_ids_path, 'r') as f:
    content = f.read()
# Remove the comments and the variable
content = re.sub(r'/// Whether ads may be shown[^\n]*\n\s*///[^\n]*\n\s*///[^\n]*\n\s*static bool showAdsEnabled = true;\n', '', content)
# Just in case it's different
content = re.sub(r'static bool showAdsEnabled = true;\s*\n', '', content)
with open(ad_ids_path, 'w') as f:
    f.write(content)


# 2. Remove from remote_config_service.dart
rcs_path = '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib/services/remote_config_service.dart'
with open(rcs_path, 'r') as f:
    content = f.read()
content = re.sub(r"import '../adsmanager/ad_ids.dart';\n", '', content)
with open(rcs_path, 'w') as f:
    f.write(content)


# 3. Remove gating from app_open_ad_service.dart, interstitial_ad_service.dart, rewarded_ad_service.dart
services = ['app_open_ad_service.dart', 'interstitial_ad_service.dart', 'rewarded_ad_service.dart']
for s in services:
    path = os.path.join('/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib/adsmanager', s)
    with open(path, 'r') as f:
        content = f.read()
    
    # Remove:
    # // Ads disabled (e.g. via remote config) -> skip the ad, continue app flow.
    # if (!AdIds.showAdsEnabled) {
    #   onAdFailedToShow?.call();
    #   return;
    # }
    content = re.sub(r'\s*// Ads disabled.*?if \(!AdIds\.showAdsEnabled\) \{\s*onAdFailedToShow\?\.call\(\);\s*return;\s*\}', '', content, flags=re.DOTALL)
    
    with open(path, 'w') as f:
        f.write(content)


# 4. Remove gating from native_ad_service.dart
native_path = '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib/adsmanager/native ad/native_ad_service.dart'
with open(native_path, 'r') as f:
    content = f.read()
content = content.replace("bool get canShowAds => AdIds.showAdsEnabled;", "bool get canShowAds => true;")
with open(native_path, 'w') as f:
    f.write(content)

# 5. Remove gating from prompt_details_screen.dart
prompt_path = '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib/screens/category/prompt_details_screen.dart'
with open(prompt_path, 'r') as f:
    content = f.read()
# Replace `if (AdIds.showAdsEnabled) ...[` with just `...[` but since it's a spread we might just remove the if entirely.
# Actually let's look at what's there.
