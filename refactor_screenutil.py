import os
import re

lib_dir = '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib'

def process_file(filepath):
    with open(filepath, 'r') as f:
        original_content = f.read()

    content = original_content

    # Regex patterns
    # Look for parameter: number (ignoring numbers already having .h, .w, .sp, .r)
    # E.g. height: 20, width: 30.5
    
    # 1. Height
    content = re.sub(r'height:\s*(\d+(?:\.\d+)?)(?![\.a-zA-Z])', r'height: \1.h', content)
    # 2. Width
    content = re.sub(r'width:\s*(\d+(?:\.\d+)?)(?![\.a-zA-Z])', r'width: \1.w', content)
    # 3. fontSize
    content = re.sub(r'fontSize:\s*(\d+(?:\.\d+)?)(?![\.a-zA-Z])', r'fontSize: \1.sp', content)
    # 4. EdgeInsets.all(X)
    content = re.sub(r'EdgeInsets\.all\(\s*(\d+(?:\.\d+)?)\s*\)', r'EdgeInsets.all(\1.r)', content)
    # 5. BorderRadius.circular(X)
    content = re.sub(r'BorderRadius\.circular\(\s*(\d+(?:\.\d+)?)\s*\)', r'BorderRadius.circular(\1.r)', content)
    # 6. Radius.circular(X)
    content = re.sub(r'Radius\.circular\(\s*(\d+(?:\.\d+)?)\s*\)', r'Radius.circular(\1.r)', content)
    
    # 7. EdgeInsets.symmetric(horizontal: X, vertical: Y)
    # This is trickier because order might change or only one is present
    content = re.sub(r'horizontal:\s*(\d+(?:\.\d+)?)(?![\.a-zA-Z])', r'horizontal: \1.w', content)
    content = re.sub(r'vertical:\s*(\d+(?:\.\d+)?)(?![\.a-zA-Z])', r'vertical: \1.h', content)
    
    # 8. EdgeInsets.only(left: X, top: Y, right: Z, bottom: W)
    content = re.sub(r'left:\s*(\d+(?:\.\d+)?)(?![\.a-zA-Z])', r'left: \1.w', content)
    content = re.sub(r'right:\s*(\d+(?:\.\d+)?)(?![\.a-zA-Z])', r'right: \1.w', content)
    content = re.sub(r'top:\s*(\d+(?:\.\d+)?)(?![\.a-zA-Z])', r'top: \1.h', content)
    content = re.sub(r'bottom:\s*(\d+(?:\.\d+)?)(?![\.a-zA-Z])', r'bottom: \1.h', content)

    # 9. blurRadius, spreadRadius, size
    content = re.sub(r'blurRadius:\s*(\d+(?:\.\d+)?)(?![\.a-zA-Z])', r'blurRadius: \1.r', content)
    content = re.sub(r'spreadRadius:\s*(\d+(?:\.\d+)?)(?![\.a-zA-Z])', r'spreadRadius: \1.r', content)
    content = re.sub(r'size:\s*(\d+(?:\.\d+)?)(?![\.a-zA-Z])', r'size: \1.sp', content)
    
    # 10. Offset(X, Y)
    content = re.sub(r'Offset\(\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*\)', r'Offset(\1.w, \2.h)', content)

    # Note: the negative lookahead (?![\.a-zA-Z]) ensures we don't match 20.0 to 20.0.h.
    # Oh wait, if it's 20.0, the `(?:\.\d+)?` absorbs the `.0`.
    # Let's test negative lookahead. If it's `20.h`, the number is 20, lookahead sees `.h`, so it won't match. Correct.
    # If it's `20.0`, the number is 20.0, lookahead sees `)`, `,`, or whitespace, so it matches! Correct.
    # If it's `20`, lookahead sees `,` or `)`, matches!
    # Let's check `double.infinity`. It's not matched because it starts with letters.

    # Special case: SizedBox(height: X) without parameter name? No, SizedBox uses named params.
    # SizedBox(width: X, height: Y) is caught by the first two rules.
    
    if content != original_content:
        # Check if flutter_screenutil is imported
        if 'package:flutter_screenutil/flutter_screenutil.dart' not in content:
            # Find the first import statement and insert after it
            lines = content.split('\n')
            first_import_idx = next((i for i, line in enumerate(lines) if line.startswith('import ')), -1)
            if first_import_idx != -1:
                lines.insert(first_import_idx + 1, "import 'package:flutter_screenutil/flutter_screenutil.dart';")
            else:
                lines.insert(0, "import 'package:flutter_screenutil/flutter_screenutil.dart';")
            content = '\n'.join(lines)
            
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            process_file(os.path.join(root, f))
