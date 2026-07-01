import os
import re

lib_dir = '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib'

def fix_botched(match):
    original = match.group(0)
    
    # Check if it's already a valid screenutil number like 20.w or 1.5.h
    if re.fullmatch(r'\d+(?:\.\d+)?\.(?:w|h|r|sp)', original):
        return original
        
    # Extract all digits and periods
    digits_and_dots = re.sub(r'[whrsp]', '', original)
    cleaned_num = digits_and_dots.replace('..', '.').strip('.')
    if cleaned_num.count('.') > 1:
        parts = cleaned_num.split('.')
        cleaned_num = parts[0] + '.' + ''.join(parts[1:])
        
    # Determine suffix by looking at the last screenutil letter in the original string
    suffix = ''
    if 'sp' in original:
        suffix = '.sp'
    elif 'w' in original:
        suffix = '.w'
    elif 'h' in original:
        suffix = '.h'
    elif 'r' in original:
        suffix = '.r'
        
    if cleaned_num.endswith('.0'):
        cleaned_num = cleaned_num[:-2]
        
    return cleaned_num + suffix

pattern = re.compile(r'\b\d+(?:(?:\.(?:w|h|r|sp))+|\.\d+|(?:w|h|r|sp)+)+\b')

changed_files = 0
for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            filepath = os.path.join(root, f)
            with open(filepath, 'r') as file:
                content = file.read()
                
            new_content = pattern.sub(fix_botched, content)
            
            if new_content != content:
                with open(filepath, 'w') as file:
                    file.write(new_content)
                changed_files += 1

print(f"Fixed {changed_files} files.")
