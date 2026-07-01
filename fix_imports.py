import os

lib_dir = '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib'

import_text = "import 'package:aivideoprompt/widgets/text_app.dart';"
import_string = "import 'package:aivideoprompt/utils/strings.dart';"

for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            filepath = os.path.join(root, f)
            with open(filepath, 'r') as file:
                content = file.read()
            
            needs_write = False
            
            if 'AppTextStyles' in content and 'text_app.dart' not in content:
                content = import_text + '\n' + content
                needs_write = True
                
            if 'AppStrings' in content and 'strings.dart' not in content:
                content = import_string + '\n' + content
                needs_write = True
                
            if needs_write:
                with open(filepath, 'w') as file:
                    file.write(content)
                print(f"Added imports to {filepath}")
