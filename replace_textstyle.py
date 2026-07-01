import os

lib_dir = '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib'

import_statement = "import 'package:ai_video_prompt/widgets/text_app.dart';"
# wait, what is the package name? Let's check pubspec.yaml

for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            filepath = os.path.join(root, f)
            with open(filepath, 'r') as file:
                content = file.read()
            
            if 'TextStyle(' in content:
                new_content = content.replace('const TextStyle(', 'AppTextStyles.getStyle(')
                new_content = new_content.replace('TextStyle(', 'AppTextStyles.getStyle(')
                
                if new_content != content:
                    with open(filepath, 'w') as file:
                        file.write(new_content)
                    print(f"Updated {filepath}")
