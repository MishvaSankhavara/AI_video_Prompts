import os
import re

filepath = '/Volumes/Work/pooja/projects/github_projects/AI_video_Prompts/lib/screens/category/prompt_details_screen.dart'
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace(
    '  final int categoryId;',
    '  final int categoryId;\n  final bool isFromSaved;'
)
content = content.replace(
    '    required this.categoryId,\n  });',
    '    required this.categoryId,\n    this.isFromSaved = false,\n  });'
)

def replacer(match):
    inner = match.group(1)
    res = f"                  if (!widget.isFromSaved) ...[\n{inner}\n                  ],"
    return res

content = re.sub(r'\/\*\s*(Row\(\s*mainAxisAlignment: MainAxisAlignment\.spaceBetween,.*?)\s*\*/', replacer, content, flags=re.DOTALL)

with open(filepath, 'w') as f:
    f.write(content)

