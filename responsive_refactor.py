import os
import re

lib_dir = '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib'
import_statement = "import 'package:flutter_screenutil/flutter_screenutil.dart';\n"

# Only process .dart files inside lib/screens, lib/widgets, lib/utils
dirs_to_process = [
    os.path.join(lib_dir, 'screens'),
    os.path.join(lib_dir, 'widgets'),
    os.path.join(lib_dir, 'utils')
]

# Patterns for appending .w, .h, .sp, .r
# We use negative lookbehind/lookahead to prevent replacing already scaled values or non-numbers
def replace_dimensions(content):
    # fontSize: 20 -> fontSize: 20.sp
    content = re.sub(r'(fontSize:\s*)(\d+(\.\d+)?)((?!\.[a-zA-Z]))', r'\1\2.sp', content)
    
    # width: 20 -> width: 20.w
    # left: 20 -> left: 20.w
    # right: 20 -> right: 20.w
    # horizontal: 20 -> horizontal: 20.w
    content = re.sub(r'(\b(?:width|left|right|horizontal):\s*)(\d+(\.\d+)?)((?!\.[a-zA-Z]))', r'\1\2.w', content)
    
    # height: 20 -> height: 20.h
    # top: 20 -> top: 20.h
    # bottom: 20 -> bottom: 20.h
    # vertical: 20 -> vertical: 20.h
    content = re.sub(r'(\b(?:height|top|bottom|vertical):\s*)(\d+(\.\d+)?)((?!\.[a-zA-Z]))', r'\1\2.h', content)
    
    # Radius.circular(20) -> Radius.circular(20.r)
    # radius: 20 -> radius: 20.r
    # EdgeInsets.all(20) -> EdgeInsets.all(20.w) (Using .w for all is common)
    content = re.sub(r'(Radius\.circular\(\s*)(\d+(\.\d+)?)((?!\.[a-zA-Z]))', r'\1\2.r', content)
    content = re.sub(r'(radius:\s*)(\d+(\.\d+)?)((?!\.[a-zA-Z]))', r'\1\2.r', content)
    content = re.sub(r'(EdgeInsets\.all\(\s*)(\d+(\.\d+)?)((?!\.[a-zA-Z]))', r'\1\2.w', content)
    
    # SizedBox(width: 20, height: 20) -> handled by above rules
    
    return content

for d in dirs_to_process:
    if not os.path.exists(d): continue
    for root, _, files in os.walk(d):
        for f in files:
            if f.endswith('.dart'):
                filepath = os.path.join(root, f)
                with open(filepath, 'r') as file:
                    original_content = file.read()
                
                new_content = replace_dimensions(original_content)
                
                # Check if we made changes
                if new_content != original_content:
                    # Add import if needed
                    if 'flutter_screenutil' not in new_content:
                        lines = new_content.split('\n')
                        # Find last import
                        last_import = max((i for i, line in enumerate(lines) if line.startswith('import ')), default=-1)
                        if last_import != -1:
                            lines.insert(last_import + 1, import_statement.strip())
                        else:
                            lines.insert(0, import_statement.strip())
                        new_content = '\n'.join(lines)
                    
                    with open(filepath, 'w') as file:
                        file.write(new_content)
                    print(f"Updated {filepath}")

