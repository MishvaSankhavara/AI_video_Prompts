import os
import re

lib_dir = '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib'

const_widgets = ['SizedBox', 'EdgeInsets', 'BorderRadius', 'Radius', 'Offset', 'Padding', 'Text', 'Icon', 'Positioned', 'Center', 'Align', 'Container', 'Row', 'Column', 'Expanded', 'Flexible', 'Spacer', 'BoxDecoration']

def process_file(filepath):
    with open(filepath, 'r') as f:
        original_content = f.read()

    content = original_content

    # Fix broken replacements like 2.h4.h -> 24.h
    content = re.sub(r'(\d+)\.(h|w|r|sp)(\d+)\.\2', r'\1\3.\2', content)
    
    # Fix import
    content = content.replace("import 'package:responsive_sizer/responsive_sizer.dart';", "import 'package:flutter_screenutil/flutter_screenutil.dart';")

    # Remove invalid consts
    for w in const_widgets:
        content = re.sub(r'const\s+' + w + r'\b', w, content)
        
    # Edge cases from flutter analyze:
    # Some consts might be like `const _PlanCard` or `const CustomAppDialog` but wait, custom widgets aren't in `const_widgets`.
    # Let's also catch things like `const [ ... ]` where list items use extension methods?
    # Actually, we can remove `const ` from lines that use `.h`, `.w`, `.sp`, `.r`.
    
    lines = content.split('\n')
    for i in range(len(lines)):
        # If line contains .h, .w, .sp, .r and has `const `, we might need to remove `const `
        # But `const ` could be at the beginning of a multiline widget.
        pass

    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Fixed {filepath}")

for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            process_file(os.path.join(root, f))
