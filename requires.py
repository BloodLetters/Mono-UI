import os
import re
import json
import sys

ROOT_DIR = "Packages"

def get_project_path(abs_target):
    proj_json = os.path.join(abs_target, "default.project.json")
    if os.path.exists(proj_json):
        try:
            with open(proj_json, "r", encoding="utf-8") as f:
                data = json.load(f)
            path_val = data.get("tree", {}).get("$path")
            if path_val:
                return path_val
        except Exception as e:
            print(f"Error reading {proj_json}: {e}")
    return None

def process_file(filepath):
    filename = os.path.basename(filepath)
    is_init_file = filename.lower() in ("init.luau", "init.lua")
    base_name, _ = os.path.splitext(filename)
    
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    modified = False

    package_match = re.search(r"local\s+(Packages?)\s+=\s+script((?:\.Parent)+)", content)
    if package_match:
        parents_str = package_match.group(2)
        package_parents = parents_str.count(".Parent")
        var_name = package_match.group(1)
    else:
        package_parents = 0
        var_name = "Package"

    pattern = r"require\(\s*(Packages?|script)([^)]*)\)"

    def replace_require(match):
        nonlocal modified
        base_expr = match.group(1)
        suffix = match.group(2).strip()
        
        part_pattern = r"\.([a-zA-Z0-9_-]+)|\[\"([^\"]+)\"\]|\['([^']+)'\]"
        matches = re.findall(part_pattern, suffix)
        
        path_parts = []
        for m in matches:
            part = m[0] or m[1] or m[2]
            path_parts.append(part)
            
        p_count = 0
        while path_parts and path_parts[0] == "Parent":
            p_count += 1
            path_parts.pop(0)
            
        if base_expr in ("Package", "Packages"):
            total_parents = package_parents + p_count
        else:
            total_parents = p_count
            
        if is_init_file:
            up_steps = total_parents
        else:
            up_steps = total_parents - 1
            
        if up_steps < 0:
            prefix = "./" + base_name + "/"
        elif up_steps == 0:
            prefix = "./"
        else:
            prefix = "../" * up_steps
            
        rel_path = prefix + "/".join(path_parts)
        rel_path = re.sub(r"/+", "/", rel_path)
        if rel_path.endswith("/") and rel_path != "./":
            rel_path = rel_path[:-1]
            
        abs_target = os.path.normpath(os.path.join(os.path.dirname(filepath), rel_path))
        target_subpath = get_project_path(abs_target)
        if target_subpath:
            rel_path = rel_path + "/" + target_subpath
            rel_path = re.sub(r"/+", "/", rel_path)
            
        if not rel_path.startswith(".") and not rel_path.startswith("/"):
            rel_path = "./" + rel_path
            
        modified = True
        return f'require("{rel_path}")'

    new_content = re.sub(pattern, replace_require, content)

    if package_parents > 0:
        new_content, count = re.subn(
            r"local\s+(Packages?)\s+=\s+script((?:\.Parent)+)",
            r"-- local \1 = script\2",
            new_content
        )
        if count > 0:
            modified = True

    if modified and new_content != content:
        new_content = new_content.replace('Packages:FindFirstChild("Promise")', 'false')
        
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(new_content)
        print(f"Processed: {os.path.relpath(filepath, ROOT_DIR)}")

def main():
    if not os.path.exists(ROOT_DIR):
        print(f"Skipping fix_requires: {ROOT_DIR} does not exist.")
        return
    for root, dirs, files in os.walk(ROOT_DIR):
        for file in files:
            if file.endswith(".luau") or file.endswith(".lua"):
                process_file(os.path.join(root, file))

if __name__ == "__main__":
    main()
