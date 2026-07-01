import os
import re

lib_dir = 'lib'
colors_file = 'lib/utils/colors.dart'

# Step 1: Read existing AppColors
with open(colors_file, 'r') as f:
    colors_dart = f.read()

existing_colors = {}
for match in re.finditer(r'static\s+const\s+Color\s+([a-zA-Z0-9_]+)\s*=\s*(Color\([^)]+\));', colors_dart):
    name = match.group(1)
    val = match.group(2)
    existing_colors[val] = name
    
print("Existing colors:", existing_colors)

# Step 2: Find all raw colors and Colors.* usages
all_raw_colors = set()
all_material_colors = set()

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart') and not file.endswith('colors.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()
                
            raw_matches = re.findall(r'\bColor\(0x[0-9a-fA-F]{8}\)', content)
            all_raw_colors.update(raw_matches)
            
            material_matches = re.findall(r'\bColors\.[a-zA-Z0-9_]+', content)
            all_material_colors.update(material_matches)

print("Raw colors found:", all_raw_colors)
print("Material colors found:", all_material_colors)

# Step 3: Create mappings
new_colors_to_add = {}
replacements = {} # { original_string: AppColors.name }

# Map Colors.* to AppColors.*
for mc in all_material_colors:
    name = mc.split('.')[1]
    if f"Color(0xFFFFFFFF)" not in existing_colors and name == 'white': pass # Example, we know it's there
    if name not in [n for v, n in existing_colors.items()] and name not in new_colors_to_add:
        # We just declare static const Color {name} = Colors.{name};
        # Wait, Colors.black is a MaterialColor, it's better to use actual color values or just Colors.black.
        # But AppColors is using Color(0xFF...), let's just use Colors.{name} for simplicity
        new_colors_to_add[name] = mc
    replacements[mc] = f"AppColors.{name}"

# Map Color(0x...) to AppColors.*
color_index = 1
for rc in all_raw_colors:
    if rc in existing_colors:
        replacements[rc] = f"AppColors.{existing_colors[rc]}"
    else:
        # Check if another name is mapped to this value in new_colors_to_add?
        # Let's generate a name
        hex_val = re.search(r'0x([0-9a-fA-F]{8})', rc).group(1)
        # Try to find a good name or just colorHex
        name = f"color{hex_val}"
        new_colors_to_add[name] = rc
        replacements[rc] = f"AppColors.{name}"

print("New colors to add:", new_colors_to_add)

# Write updated colors.dart
new_declarations = []
for name, val in new_colors_to_add.items():
    new_declarations.append(f"  static const Color {name} = {val};")

if new_declarations:
    # Insert before the last closing brace
    last_brace = colors_dart.rfind('}')
    updated_colors_dart = colors_dart[:last_brace] + "\n  // Auto-generated colors\n" + "\n".join(new_declarations) + "\n" + colors_dart[last_brace:]
    with open(colors_file, 'w') as f:
        f.write(updated_colors_dart)

# Update all files
for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart') and not file.endswith('colors.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()
            
            new_content = content
            for orig, new_val in replacements.items():
                if orig.startswith('Color('):
                    # Replace exactly
                    new_content = new_content.replace(orig, new_val)
                else:
                    # For Colors.black, use word boundary so we don't replace Colors.black38 with AppColors.black38
                    new_content = re.sub(rf'\b{orig}\b', new_val, new_content)
            
            # Make sure to import colors.dart if we replaced something
            if new_content != content:
                # Basic check for import
                if 'import \'package:ai_video_prompts/utils/colors.dart\';' not in new_content and 'import \'../../utils/colors.dart\';' not in new_content and 'import \'../utils/colors.dart\';' not in new_content and 'import \'../../../utils/colors.dart\';' not in new_content and 'import \'colors.dart\'' not in new_content:
                    # we should use an absolute import for the package
                    import_statement = "import 'package:ai_video_prompts/utils/colors.dart';\n"
                    # Just add it at the top after other imports or at line 1
                    # A better way is to just put it at the beginning of the file
                    new_content = import_statement + new_content
                
                with open(filepath, 'w') as f:
                    f.write(new_content)

print("Done replacing.")
