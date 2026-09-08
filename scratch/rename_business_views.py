import os
import re

def camel_to_snake(name):
    name = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', name).lower()

base_dir = 'lib/views/business'
renames = {}

# Handle dir rename first
for root, dirs, files in os.walk(base_dir):
    if 'Activities' in dirs:
        old_dir = os.path.join(root, 'Activities')
        new_dir = os.path.join(root, 'activities')
        os.rename(old_dir, new_dir)
        dirs[dirs.index('Activities')] = 'activities'

for root, dirs, files in os.walk(base_dir):
    for f in files:
        if f.endswith('.dart'):
            old_path = os.path.join(root, f)
            new_name = camel_to_snake(f.replace('.dart', '')) + '.dart'
            new_path = os.path.join(root, new_name)
            
            if old_path != new_path:
                print(f'Renaming {old_path} -> {new_path}')
                os.rename(old_path, new_path)
                
                old_rel = old_path.replace('lib/', '')
                new_rel = new_path.replace('lib/', '')
                
                # Careful not to replace substrings indiscriminately
                renames[f"'{f}'"] = f"'{new_name}'"
                renames[f'"{f}"'] = f'"{new_name}"'
                renames[f"'{old_rel}'"] = f"'{new_rel}'"
                renames[f'"{old_rel}"'] = f'"{new_rel}"'
                renames[f"middle_ware/{old_rel}"] = f"middle_ware/{new_rel}"

# Now fix all imports in lib folder
for root, dirs, files in os.walk('lib'):
    for f in files:
        if f.endswith('.dart'):
            file_path = os.path.join(root, f)
            with open(file_path, 'r') as file:
                content = file.read()
                
            new_content = content
            
            # Replace dir 'Activities' to 'activities' in imports
            new_content = new_content.replace('views/business/Activities', 'views/business/activities')
            
            for old_str, new_str in renames.items():
                if old_str in new_content:
                    new_content = new_content.replace(old_str, new_str)
                    
            if content != new_content:
                with open(file_path, 'w') as file:
                    file.write(new_content)

print("Done renaming and fixing imports.")
