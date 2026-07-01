import os
import re

lib_dir = '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib'

def fix_token(token):
    # Find all screenutil suffixes used in this token
    suffixes_used = re.findall(r'\.(?:sp|w|h|r)', token)
    if not suffixes_used:
        return token
        
    # We will pick the last suffix as the intended one
    intended_suffix = suffixes_used[-1]
    
    # Strip all screenutil suffixes
    cleaned = re.sub(r'\.(?:sp|w|h|r)', '', token)
    
    # If the cleaned string is just a valid number (int or float)
    if re.fullmatch(r'\d+(?:\.\d+)?', cleaned):
        # We might have trailing .0 which we can remove to keep it clean
        if cleaned.endswith('.0'):
            cleaned = cleaned[:-2]
        return cleaned + intended_suffix
        
    # If something weird happened, just return the token
    return token

# We need to find words that look like mangled screenutil values
# E.g., 2.h4.h, 1.sp8.sp, 35.r.0.r, 0.w.5.w
# A sequence of digits, dots, w, h, r, sp
# Regex: \b\d+(?:[\.whrsp0-9]*[whrsp])\b
# Let's test this
pattern = re.compile(r'\b\d+(?:[\.whrsp0-9]*[whrsp])\b')

changed_files = 0
for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            filepath = os.path.join(root, f)
            with open(filepath, 'r') as file:
                content = file.read()
                
            def replacer(match):
                original = match.group(0)
                return fix_token(original)
                
            new_content = pattern.sub(replacer, content)
            
            if new_content != content:
                with open(filepath, 'w') as file:
                    file.write(new_content)
                changed_files += 1

print(f"Fixed {changed_files} files.")
