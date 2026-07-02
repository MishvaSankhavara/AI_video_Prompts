import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # We need a robust parser for nested parentheses to replace Text( ... ) properly.
    # Since writing a full Dart parser in python is hard, let's use a bracket matching approach.
    
    out = []
    i = 0
    changed = False
    
    while i < len(content):
        # find "Text(" but make sure it's not a substring of another word like "RichText(" or "AppText("
        # Also could be preceded by "child: Text(" or "return Text("
        match = re.search(r'\bText\(', content[i:])
        if not match:
            out.append(content[i:])
            break
            
        start_idx = i + match.start()
        out.append(content[i:start_idx])
        
        # Now find the matching closing parenthesis for Text(
        p_count = 0
        in_string = False
        string_char = ''
        escape = False
        
        text_content_start = start_idx + 5 # length of "Text("
        j = text_content_start
        
        while j < len(content):
            char = content[j]
            if not in_string:
                if char in ("'", '"'):
                    in_string = True
                    string_char = char
                elif char == '(':
                    p_count += 1
                elif char == ')':
                    if p_count == 0:
                        break # Found the end of Text(...)
                    p_count -= 1
            else:
                if escape:
                    escape = False
                elif char == '\\':
                    escape = True
                elif char == string_char:
                    in_string = False
            j += 1
            
        if j < len(content) and content[j] == ')':
            text_args_str = content[text_content_start:j]
            
            # Now we need to see if there is a style: AppTextStyles.getStyle(...) or style: TextStyle(...)
            # inside text_args_str.
            # We can use the same bracket matching to extract style arguments.
            style_match = re.search(r'style\s*:\s*(AppTextStyles\.getStyle|TextStyle)\s*\(', text_args_str)
            if style_match:
                style_start = style_match.end()
                s_count = 0
                s_in_string = False
                s_string_char = ''
                s_escape = False
                k = style_start
                while k < len(text_args_str):
                    c = text_args_str[k]
                    if not s_in_string:
                        if c in ("'", '"'):
                            s_in_string = True
                            s_string_char = c
                        elif c == '(':
                            s_count += 1
                        elif c == ')':
                            if s_count == 0:
                                break
                            s_count -= 1
                    else:
                        if s_escape:
                            s_escape = False
                        elif c == '\\':
                            s_escape = True
                        elif c == s_string_char:
                            s_in_string = False
                    k += 1
                    
                if k < len(text_args_str) and text_args_str[k] == ')':
                    style_args = text_args_str[style_start:k]
                    # The rest of text args without the style part:
                    # from 0 to style_match.start() + from k+1 to end
                    # But wait, there might be a trailing comma or leading comma to clean up.
                    # Actually, we can just remove the "style: AppTextStyles.getStyle(...)" and insert style_args at the end.
                    
                    part1 = text_args_str[:style_match.start()]
                    part2 = text_args_str[k+1:]
                    
                    # Clean up dangling commas if needed, but in Dart extra commas are fine.
                    # We can just join them: part1 + part2 + "," + style_args
                    new_args = part1.strip()
                    if new_args and not new_args.endswith(','):
                        new_args += ','
                    new_args += part2.strip()
                    if new_args and not new_args.endswith(','):
                        new_args += ','
                    
                    # Add style args if any
                    style_args_stripped = style_args.strip()
                    if style_args_stripped:
                        new_args += '\n' + style_args_stripped
                        if not new_args.endswith(','):
                            new_args += ','
                            
                    out.append("AppText(" + new_args + ")")
                    changed = True
                else:
                    # parse failed for style, leave it
                    out.append("AppText(" + text_args_str + ")")
                    changed = True
            else:
                # No style attribute, just change Text to AppText
                out.append("AppText(" + text_args_str + ")")
                changed = True
                
            i = j + 1
        else:
            # parsing failed, just put Text(
            out.append("Text(")
            i = text_content_start

    if changed:
        with open(filepath, 'w') as f:
            f.write("".join(out))
            
        print(f"Updated {filepath}")

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
