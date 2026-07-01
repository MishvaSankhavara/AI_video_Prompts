import re
import os

log_text = """
  error • Extension methods can't be used in constant expressions • lib/screens/category/prompt_details_screen.dart:788:23 • const_eval_extension_method
  error • Extension methods can't be used in constant expressions • lib/screens/settings/privacy_policy_screen.dart:111:31 • const_eval_extension_method
  error • Extension methods can't be used in constant expressions • lib/screens/settings/privacy_policy_screen.dart:160:29 • const_eval_extension_method
  error • Extension methods can't be used in constant expressions • lib/screens/settings/settings_screen.dart:339:23 • const_eval_extension_method
  error • Extension methods can't be used in constant expressions • lib/screens/settings/terms_of_use_screen.dart:108:31 • const_eval_extension_method
  error • Extension methods can't be used in constant expressions • lib/screens/settings/terms_of_use_screen.dart:157:29 • const_eval_extension_method
  error • Extension methods can't be used in constant expressions • lib/widgets/common_app_bar.dart:41:23 • const_eval_extension_method
  error • Extension methods can't be used in constant expressions • lib/widgets/common_video_player.dart:240:17 • const_eval_extension_method
  error • Extension methods can't be used in constant expressions • lib/widgets/common_video_player.dart:347:33 • const_eval_extension_method
  error • Extension methods can't be used in constant expressions • lib/widgets/dialog/custom_app_dialog.dart:88:29 • const_eval_extension_method
"""

# Extract filepath and line number
pattern = re.compile(r"lib/.*?\.dart:\d+")
matches = pattern.findall(log_text)

files_to_edit = {}
for m in matches:
    parts = m.split(':')
    filepath = '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/' + parts[0]
    line_num = int(parts[1]) - 1 # 0-indexed
    
    if filepath not in files_to_edit:
        files_to_edit[filepath] = []
    files_to_edit[filepath].append(line_num)

for filepath, lines_to_fix in files_to_edit.items():
    if os.path.exists(filepath):
        with open(filepath, 'r') as f:
            lines = f.readlines()
            
        for line_num in lines_to_fix:
            if line_num < len(lines):
                # Search backward for `const ` within the line or a few lines before if it's a multiline statement
                # Actually, flutter analyze points to the exact expression or line.
                # Just replace the first `const ` on this line
                if 'const ' in lines[line_num]:
                    lines[line_num] = lines[line_num].replace('const ', '', 1)
                else:
                    # Look up to 5 lines backwards for `const `
                    for i in range(line_num, max(-1, line_num - 5), -1):
                        if 'const ' in lines[i]:
                            lines[i] = lines[i].replace('const ', '', 1)
                            break
                            
        with open(filepath, 'w') as f:
            f.writelines(lines)
        print(f"Fixed const in {filepath}")

