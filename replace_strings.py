import os

replacements = {
    "lib/screens/settings/feedback_screen.dart": {
        "'What can we improve?'": "AppStrings.feedbackWhatToImprove"
    },
    "lib/screens/home/favorite_screen.dart": {
        "'No Favorites Yet'": "AppStrings.favoriteNoFavoritesTitle",
        "'Saved templates will appear here.'": "AppStrings.favoriteNoFavoritesSubtitle"
    },
    "lib/screens/home/home_screen.dart": {
        "'No categories available.'": "AppStrings.homeNoCategories"
    },
    "lib/screens/category/category_details_screen.dart": {
        "'No templates found in this category.'": "AppStrings.categoryNoTemplates"
    },
    "lib/screens/start/start_screen.dart": {
        "'Ready to create amazing videos with AI? Dive right back into the prompts.'": "AppStrings.startScreenSubtitle",
        "'Start Exploring'": "AppStrings.startScreenButton"
    },
    "lib/screens/pro/pro_screen.dart": {
        "'Terms of Service'": "AppStrings.proTermsOfService",
        "'Restore'": "AppStrings.proRestore",
        "'Privacy Policy'": "AppStrings.proPrivacyPolicy"
    },
    "lib/widgets/shimmer_loading.dart": {
        "'AI Video Prompts'": "AppStrings.appName"
    }
}

for filepath, reps in replacements.items():
    if os.path.exists(filepath):
        with open(filepath, 'r') as f:
            content = f.read()
        
        # Add import for AppStrings if not present and we made a replacement
        made_replacements = False
        for old, new in reps.items():
            if old in content:
                content = content.replace(old, new)
                made_replacements = True
        
        if made_replacements:
            if "import '../../utils/strings.dart';" not in content and "import 'package:aivideoprompt/utils/strings.dart';" not in content:
                # Naive import insertion at top
                if 'import' in content:
                    # Calculate depth to utils/strings.dart based on filepath
                    depth = filepath.count('/') - 1
                    rel_path = '../' * depth + 'utils/strings.dart'
                    # if it's in lib/widgets, depth is 1. lib/screens/home is 2
                    import_statement = f"import '{rel_path}';\n"
                    # Just find last import and insert after
                    lines = content.split('\n')
                    last_import = max((i for i, line in enumerate(lines) if line.startswith('import ')), default=-1)
                    if last_import != -1:
                        lines.insert(last_import + 1, import_statement)
                        content = '\n'.join(lines)
            
            with open(filepath, 'w') as f:
                f.write(content)
        print(f"Updated {filepath}")
