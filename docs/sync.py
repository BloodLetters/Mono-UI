import os
import re
import json

# Paths
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC_DIR = os.path.join(BASE_DIR, "src")
DOCS_DIR = os.path.join(BASE_DIR, "docs")
INDEX_HTML = os.path.join(DOCS_DIR, "index.html")
DUMP_FILE = os.path.join(DOCS_DIR, "dump.json")

# Predefined metadata database for functions and arguments
METADATA = {
    # Core API
    "CreateWindow": {
        "group": "Core",
        "label": "Core API",
        "display_name": "CreateWindow",
        "id": "create-window",
        "nav_id": "nav-window",
        "icon": "fa-window-maximize",
        "description": "Creates the main window container. Must be called before creating any tabs or components.",
        "params": {
            "Title": {"type": "string", "description": "Window title displayed in the top bar."},
            "Subtitle": {"type": "string", "description": "Subtitle text below the title."},
            "Size": {"type": "UDim2", "description": "Window dimensions."},
            "Icon": {"type": "string", "description": "Lucide icon name shown in the corner."},
            "ConfigName": {"type": "string", "description": "Filename key used for config persistence."},
            "AutoSave": {"type": "boolean", "description": "Auto-saves component state changes."},
            "AutoExec": {"type": "boolean", "description": "Re-executes script on teleport via <code>queue_on_teleport</code>."},
            "AutoExecUrl": {"type": "string", "description": "URL of the raw script to download and execute for AutoExec."},
            "DisplayOrder": {"type": "number", "description": "Render layering display order index of the ScreenGui."},
            "Name": {"type": "string", "description": "Name property of the ScreenGui instance."},
            "Position": {"type": "UDim2", "description": "Initial screen position coordinates of the window."}
        },
        "example": """local window = MonoUI.CreateWindow({
    Title      = "mono ui",
    Subtitle   = "premium modular library",
    Size       = UDim2.fromOffset(600, 400),
    Icon       = "shield",
    ConfigName = "my_config",
    AutoSave   = true,
    AutoExec   = true,
})"""
    },
    "Notify": {
        "group": "Core",
        "label": "Core API",
        "display_name": "Notify",
        "id": "notifications",
        "nav_id": "nav-notify",
        "icon": "fa-bell",
        "description": "Fires a toast notification at the bottom right corner of the screen.",
        "params": {
            "title": {"type": "string", "description": "Title of the notification header."},
            "content": {"type": "string", "description": "Description content of the notification."},
            "icon": {"type": "string", "description": "Lucide icon name displayed beside the text."},
            "duration": {"type": "number", "description": "Time in seconds before the notification disappears."}
        },
        "example": """MonoUI.Notify({
    title    = "Success",
    content  = "Cheat successfully loaded!",
    icon     = "check-circle",
    duration = 5,
})"""
    },
    "SetWatermark": {
        "group": "Core",
        "label": "Core API",
        "display_name": "SetWatermark",
        "id": "watermark",
        "nav_id": "nav-wm",
        "icon": "fa-chart-line",
        "description": "Creates or updates a small top-right HUD showing custom text, client FPS, ping, and character coordinates.",
        "params": {
            "visible": {"type": "boolean", "description": "Sets the visibility of the watermark HUD."},
            "text": {"type": "string", "description": "Custom prefix header text."},
            "position": {"type": "UDim2", "description": "Custom screen position offset."},
            "anchorPoint": {"type": "Vector2", "description": "Anchor point of the watermark frame."}
        },
        "example": """MonoUI.SetWatermark({
    visible = true,
    text    = "MonoUI Premium",
})"""
    },
    "CreateControlHUD": {
        "group": "Core",
        "label": "Core API",
        "display_name": "CreateControlHUD",
        "id": "control-hud",
        "nav_id": "nav-hud",
        "icon": "fa-sliders",
        "description": "Creates a floating, draggable, compact HUD with quick toggles (perfect for keeping essential scripts visible).",
        "params": {
            "icon": {"type": "string", "description": "Lucide icon name for this HUD shortcut."},
            "default": {"type": "boolean", "description": "Initial active state of the shortcut button."},
            "callback": {"type": "function", "description": "Fires with <code>active: boolean</code> on toggle."}
        },
        "example": """MonoUI.CreateControlHUD({
    { icon = "swords", default = false, callback = function(v) print("Aim:", v) end },
    { icon = "eye",    default = true,  callback = function(v) print("ESP:", v) end },
})"""
    },

    # Layout API
    "CreateTab": {
        "group": "Layout",
        "label": "Layout",
        "display_name": "CreateTab",
        "id": "create-tab",
        "nav_id": "nav-tab",
        "icon": "fa-folder-open",
        "description": "Appends a navigation tab to the window sidebar. Returns a tab object used to add components.",
        "params": {
            "text": {"type": "string", "description": "Label displayed in the sidebar."},
            "icon": {"type": "string", "description": "Lucide icon shown next to the label."}
        },
        "example": """local tab = window:CreateTab({
    text = "Combat",
    icon = "swords",
})"""
    },
    "CreateSection": {
        "group": "Layout",
        "label": "Layout",
        "display_name": "CreateSection",
        "id": "create-section",
        "nav_id": "nav-section",
        "icon": "fa-grip-lines",
        "description": "Inserts a visual section divider with a label to group related components.",
        "params": {
            "text": {"type": "string", "description": "Section heading label."}
        },
        "example": 'tab:CreateSection({ text = "Combat Hacks" })'
    },

    # Components API
    "CreateToggle": {
        "group": "Components",
        "label": "Components",
        "display_name": "Toggle",
        "id": "toggle",
        "nav_id": "nav-toggle",
        "icon": "fa-toggle-on",
        "description": "A checkbox-style switch for boolean values. State is persisted to config when a flag is provided.",
        "params": {
            "text": {"type": "string", "description": "Label for the toggle."},
            "default": {"type": "boolean", "description": "Initial state (true/false)."},
            "flag": {"type": "string", "description": "Unique key for config saving."},
            "callback": {"type": "function", "description": "Fires with the new boolean state."}
        },
        "example": """tab:CreateToggle({
    text     = "Silent Aim",
    default  = false,
    flag     = "silent_aim",
    callback = function(state)
        print("Silent Aim:", state)
    end,
})"""
    },
    "CreateSlider": {
        "group": "Components",
        "label": "Components",
        "display_name": "Slider",
        "id": "slider",
        "nav_id": "nav-slider",
        "icon": "fa-sliders",
        "description": "A draggable range input with min/max bounds and optional decimal precision.",
        "params": {
            "text": {"type": "string", "description": "Label for the slider row."},
            "min": {"type": "number", "description": "Minimum value of the range."},
            "max": {"type": "number", "description": "Maximum value of the range."},
            "default": {"type": "number", "description": "Initial value."},
            "flag": {"type": "string", "description": "Unique key for config saving."},
            "callback": {"type": "function", "description": "Fires with the current numeric value."}
        },
        "example": """tab:CreateSlider({
    text     = "FOV Range",
    min      = 10,
    max      = 200,
    default  = 90,
    flag     = "aimbot_fov",
    callback = function(value)
        print("FOV:", value)
    end,
})"""
    },
    "CreateDropdown": {
        "group": "Components",
        "label": "Components",
        "display_name": "Dropdown",
        "id": "dropdown",
        "nav_id": "nav-dropdown",
        "icon": "fa-caret-down",
        "description": "A selection menu for single or multi-value selections. Supports search filtering inside dropdown items.",
        "params": {
            "text": {"type": "string", "description": "Label for the dropdown dropdown."},
            "list": {"type": "table", "description": "Array of string options to display."},
            "default": {"type": "string | table", "description": "Pre-selected option(s)."},
            "multiple": {"type": "boolean", "description": "Allows selecting multiple items concurrently."},
            "flag": {"type": "string", "description": "Unique key for config saving."},
            "callback": {"type": "function", "description": "Fires with a table of selected options."}
        },
        "example": """tab:CreateDropdown({
    text     = "Target Part",
    list     = {"Head", "Torso", "LeftArm", "RightArm"},
    default  = "Head",
    multiple = false,
    flag     = "target_part",
    callback = function(selected)
        print("Selected:", selected[1])
    end,
})"""
    },
    "CreateInput": {
        "group": "Components",
        "label": "Components",
        "display_name": "Input",
        "id": "input",
        "nav_id": "nav-input",
        "icon": "fa-keyboard",
        "description": "A single-line text input field for strings and custom configs.",
        "params": {
            "text": {"type": "string", "description": "Label of the input field."},
            "placeholder": {"type": "string", "description": "Ghost text shown when the input is empty."},
            "default": {"type": "string", "description": "Initial text value."},
            "flag": {"type": "string", "description": "Unique key for config saving."},
            "callback": {"type": "function", "description": "Fires with the updated text value."}
        },
        "example": """tab:CreateInput({
    text        = "Webhook URL",
    placeholder = "https://discord.com/api/webhooks/...",
    default     = "",
    flag        = "webhook_url",
    callback    = function(url)
        print("Webhook:", url)
    end,
})"""
    },
    "CreateButton": {
        "group": "Components",
        "label": "Components",
        "display_name": "Button",
        "id": "button",
        "nav_id": "nav-button",
        "icon": "fa-square-check",
        "description": "An interactive button that runs a custom function when clicked.",
        "params": {
            "text": {"type": "string", "description": "Text displayed on the button."},
            "callback": {"type": "function", "description": "Fires when the button is clicked."}
        },
        "example": """tab:CreateButton({
    text     = "Force Teleport",
    callback = function()
        print("Teleport button pressed.")
    end,
})"""
    },
    "CreateColorPicker": {
        "group": "Components",
        "label": "Components",
        "display_name": "ColorPicker",
        "id": "colorpicker",
        "nav_id": "nav-color",
        "icon": "fa-palette",
        "description": "An advanced RGB/HSV color picker that supports hex input and saturation/brightness visual adjustments.",
        "params": {
            "text": {"type": "string", "description": "Label for the color picker."},
            "default": {"type": "Color3", "description": "Initial Color3 value."},
            "flag": {"type": "string", "description": "Unique key for config saving."},
            "callback": {"type": "function", "description": "Fires with the selected Color3 object."}
        },
        "example": """tab:CreateColorPicker({
    text     = "ESP Color",
    default  = Color3.fromRGB(255, 0, 0),
    flag     = "esp_color",
    callback = function(color)
        print("Color changed:", color)
    end,
})"""
    },
    "CreateKeybind": {
        "group": "Components",
        "label": "Components",
        "display_name": "Keybind",
        "id": "keybind",
        "nav_id": "nav-keybind",
        "icon": "fa-keyboard",
        "description": "Allows the user to bind a keybind shortcut to toggle/trigger functions. Click to rebind, press Escape to unbind.",
        "params": {
            "text": {"type": "string", "description": "Label for the keybind."},
            "default": {"type": "Enum.KeyCode", "description": "Initial bound KeyCode."},
            "flag": {"type": "string", "description": "Unique key for config saving."},
            "callback": {"type": "function", "description": "Fires with the new KeyCode when bound/triggered."}
        },
        "example": """tab:CreateKeybind({
    text     = "Toggle GUI",
    default  = Enum.KeyCode.RightControl,
    flag     = "gui_toggle",
    callback = function(key)
        print("Keybind triggered:", key.Name)
    end,
})"""
    },
    "CreateTargetBody": {
        "group": "Components",
        "label": "Components",
        "display_name": "TargetBody",
        "id": "targetbody",
        "nav_id": "nav-body",
        "icon": "fa-child",
        "description": "A body hitbox selector showing a visual representation of a character body. Perfect for selective aimbot hitboxes.",
        "params": {
            "text": {"type": "string", "description": "Label for the hitbox selector."},
            "multiple": {"type": "boolean", "description": "Allows selecting multiple body parts."},
            "default": {"type": "string | table", "description": "Initially selected body part(s) (e.g. 'Head' or {'Head', 'Torso'})."},
            "disabledParts": {"type": "table", "description": "List of parts that cannot be selected (e.g. {'LeftArm', 'RightArm'})."},
            "flag": {"type": "string", "description": "Unique key for config saving."},
            "callback": {"type": "function", "description": "Fires with a table of currently active body parts."}
        },
        "example": """tab:CreateTargetBody({
    text          = "Selective Hitboxes",
    multiple      = true,
    default       = {"Head", "Torso"},
    disabledParts = {"LeftArm", "RightArm"},
    flag          = "target_hitboxes",
    callback      = function(parts)
        print("Active hitboxes:", table.concat(parts, ", "))
    end,
})"""
    },
    "CreatePlayerList": {
        "group": "Components",
        "label": "Components",
        "display_name": "PlayerList",
        "id": "playerlist",
        "nav_id": "nav-players",
        "icon": "fa-users",
        "description": "Renders a scrolling player list widget showing active players on the server. Includes search bar.",
        "params": {
            "text": {"type": "string", "description": "Header title of the list widget."},
            "height": {"type": "number", "description": "Pixel height of the scroll area."}
        },
        "example": """tab:CreatePlayerList({
    text   = "Active Server Players",
    height = 280,
})"""
    },
    "CreateLogger": {
        "group": "Components",
        "label": "Components",
        "display_name": "Logger",
        "id": "logger",
        "nav_id": "nav-logger",
        "icon": "fa-terminal",
        "description": "An in-app console widget that displays color-coded activity logs. Supports INFO, SUCCESS, WARNING, and ERROR levels.",
        "params": {
            "text": {"type": "string", "description": "Console panel header label."},
            "height": {"type": "number", "description": "Pixel height of the log area."}
        },
        "example": """local log = tab:CreateLogger({ text = "Console", height = 280 })

log:Log("INFO",    "Script loaded.")
log:Log("SUCCESS", "ESP enabled.")
log:Log("WARNING", "High ping detected.")
log:Log("ERROR",   "Target not found.")"""
    }
}

def parse_lua_file(filepath):
    """
    Parses a Lua file to find properties accessed on 'args', 'options', etc.
    """
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    # Find matches of args.something or options.something
    pattern = r"(?:args|options|tArgs|sArgs|cArgs|slArgs|tbArgs|kbArgs|lgArgs|plArgs|currentOptions)\.([a-zA-Z0-9_]+)"
    matches = re.findall(pattern, content)
    
    # Return unique sorted list
    return sorted(list(set(matches)))

def extract_all_functions():
    """
    Scans the src/ components and core files to map actual arguments.
    """
    functions = {}

    # 1. Parse src/components/
    components_path = os.path.join(SRC_DIR, "components")
    if os.path.exists(components_path):
        for filename in os.listdir(components_path):
            if filename.endswith(".lua"):
                filepath = os.path.join(components_path, filename)
                basename = filename[:-4]  # Remove .lua
                func_name = f"Create{basename}"
                
                # Exception for Section
                if basename == "Section":
                    func_name = "CreateSection"

                args = parse_lua_file(filepath)
                # Guarantee 'flag' is included for stateful components (if not already found)
                stateful_components = ["Toggle", "Slider", "Dropdown", "Input", "Keybind", "ColorPicker", "TargetBody"]
                if basename in stateful_components and "flag" not in args:
                    args.append("flag")

                functions[func_name] = sorted(args)

    # 2. Parse core files for CreateWindow, CreateTab, Notify, SetWatermark, CreateControlHUD
    window_lua = os.path.join(SRC_DIR, "core", "window.lua")
    if os.path.exists(window_lua):
        with open(window_lua, "r", encoding="utf-8") as f:
            content = f.read()
        
        # CreateWindow options
        create_window_match = re.search(r"local function CreateWindow\(([^)]+)\)", content)
        if create_window_match:
            # Parse all options.something inside window.lua before showTab
            window_subcontent = content[:content.find("local function showTab")]
            window_args = re.findall(r"options\.([a-zA-Z0-9_]+)", window_subcontent)
            functions["CreateWindow"] = sorted(list(set(window_args)))

        # CreateTab args
        create_tab_match = re.search(r"function windowObject:CreateTab\(([^)]+)\)", content)
        if create_tab_match:
            tab_block_start = content.find("function windowObject:CreateTab")
            tab_block_end = content.find("function tab:CreateToggle", tab_block_start)
            tab_subcontent = content[tab_block_start:tab_block_end]
            tab_args = re.findall(r"args\.([a-zA-Z0-9_]+)", tab_subcontent)
            functions["CreateTab"] = sorted(list(set(tab_args)))

    # Notify in notification.lua
    notification_lua = os.path.join(SRC_DIR, "core", "notification.lua")
    if os.path.exists(notification_lua):
        notification_args = parse_lua_file(notification_lua)
        functions["Notify"] = notification_args

    # SetWatermark in watermark.lua
    watermark_lua = os.path.join(SRC_DIR, "core", "watermark.lua")
    if os.path.exists(watermark_lua):
        watermark_args = parse_lua_file(watermark_lua)
        functions["SetWatermark"] = watermark_args

    # CreateControlHUD in controlHUD.lua
    control_hud_lua = os.path.join(SRC_DIR, "core", "controlHUD.lua")
    if os.path.exists(control_hud_lua):
        # We manually structure controlHUD arguments because it processes a list of tables
        functions["CreateControlHUD"] = ["icon", "default", "callback"]

    return functions

def generate_dump(extracted):
    """
    Generates a dump dictionary mapping each function to its parsed arguments with types and descriptions.
    """
    dump_data = {}
    for func_name, args in extracted.items():
        meta = METADATA.get(func_name, {})
        
        # Extract metadata details or fall back to defaults
        group = meta.get("group", "Components")
        label = meta.get("label", "Components")
        display_name = meta.get("display_name", func_name.replace("Create", ""))
        desc = meta.get("description", f"Dynamic {display_name} component.")
        params_meta = meta.get("params", {})
        example = meta.get("example", f"-- Example for {func_name}\nlocal comp = tab:{func_name}({{}})")

        arguments_list = []
        for arg in args:
            arg_meta = params_meta.get(arg, {})
            arg_type = arg_meta.get("type", "any")
            arg_desc = arg_meta.get("description", "Undocumented argument.")
            arguments_list.append({
                "name": arg,
                "type": arg_type,
                "description": arg_desc
            })

        dump_data[func_name] = {
            "type": group.lower(),
            "label": label,
            "display_name": display_name,
            "description": desc,
            "arguments": arguments_list,
            "example": example
        }

    return dump_data

def build_sidebar_html(dump_data, group_name):
    """
    Builds the sidebar HTML link tags for a specific group (Core, Layout, Components).
    """
    html_lines = []
    
    # Sort functions in this group to maintain consistency
    group_funcs = {k: v for k, v in dump_data.items() if v["type"] == group_name.lower()}
    
    for func_name in sorted(group_funcs.keys()):
        meta = METADATA.get(func_name, {})
        nav_id = meta.get("nav_id", f"nav-{func_name.lower().replace('create', '')}")
        section_id = meta.get("id", func_name.lower().replace('create', ''))
        icon = meta.get("icon", "fa-cube")
        display_name = group_funcs[func_name]["display_name"]
        
        # Clean formatting matching standard index.html sidebar nav-items
        html_lines.append(f'                    <a href="#{section_id}" class="nav-item" id="{nav_id}"><i\n'
                           f'                            class="fa-solid {icon}"></i> {func_name}</a>')
                           
    return "\n".join(html_lines)

def build_content_html(dump_data):
    """
    Builds the main content HTML sections.
    """
    sections = []
    
    # Group and order functions logically: Core, then Layout, then Components
    ordered_funcs = []
    for group in ["Core", "Layout", "Components"]:
        group_funcs = {k: v for k, v in dump_data.items() if v["type"] == group.lower()}
        for k in sorted(group_funcs.keys()):
            ordered_funcs.append((k, group_funcs[k]))

    for func_name, func_data in ordered_funcs:
        meta = METADATA.get(func_name, {})
        section_id = meta.get("id", func_name.lower().replace('create', ''))
        group = func_data["type"].capitalize()
        display_name = func_data["display_name"]
        label = func_data["label"]
        desc = func_data["description"]
        example = func_data["example"]
        
        # Breadcrumb HTML
        breadcrumb = (
            f'                <div class="breadcrumb">\n'
            f'                    <span class="current">{group}</span>\n'
            f'                    <span class="sep">›</span>\n'
            f'                    <span class="current">{func_name}</span>\n'
            f'                </div>'
        )

        # Arguments Table rows
        table_rows = []
        for arg in func_data["arguments"]:
            name = arg["name"]
            arg_type = arg["type"]
            arg_desc = arg["description"]
            
            # Formatted type class mapping
            type_class = "type-string"
            if "boolean" in arg_type:
                type_class = "type-boolean"
            elif "number" in arg_type:
                type_class = "type-number"
            elif "function" in arg_type:
                type_class = "type-function"
            elif "table" in arg_type or "array" in arg_type:
                type_class = "type-table"

            table_rows.append(
                f'                        <tr>\n'
                f'                            <td>{name}</td>\n'
                f'                            <td><span class="type {type_class}">{arg_type}</span></td>\n'
                f'                            <td>{arg_desc}</td>\n'
                f'                        </tr>'
            )

        rows_html = "\n".join(table_rows)

        section_html = (
            f'            <!-- {func_name} -->\n'
            f'            <section id="{section_id}" class="doc-section">\n'
            f'{breadcrumb}\n'
            f'                <div class="section-label">{label}</div>\n'
            f'                <h2>{func_name}</h2>\n'
            f'                <p>{desc}</p>\n'
            f'                <table class="params-table">\n'
            f'                    <thead>\n'
            f'                        <tr>\n'
            f'                            <th>Argument</th>\n'
            f'                            <th>Type</th>\n'
            f'                            <th>Description</th>\n'
            f'                        </tr>\n'
            f'                    </thead>\n'
            f'                    <tbody>\n'
            f'{rows_html}\n'
            f'                    </tbody>\n'
            f'                </table>\n'
            f'                <div class="code-container">\n'
            f'                    <div class="code-header">\n'
            f'                        <span class="code-lang">Lua</span>\n'
            f'                        <button class="copy-btn"><i class="fa-regular fa-copy"></i> Copy</button>\n'
            f'                    </div>\n'
            f'                    <pre><code class="language-lua">{example}</code></pre>\n'
            f'                </div>\n'
            f'            </section>\n'
        )
        sections.append(section_html)

    return "\n".join(sections)

def get_latest_release():
    """
    Queries GitHub API to fetch the latest release tag.
    """
    import urllib.request
    url = "https://api.github.com/repos/BloodLetters/Mono-UI/releases/latest"
    req = urllib.request.Request(url, headers={"User-Agent": "MonoUI-Sync-Script"})
    try:
        with urllib.request.urlopen(req, timeout=5) as response:
            data = json.loads(response.read().decode())
            return data.get("tag_name", "v1.1.0")
    except Exception as e:
        print(f"[WARNING] Failed to fetch latest release version from GitHub: {e}")
        return "v1.1.0"

def update_index_html(sidebar_core, sidebar_layout, sidebar_components, main_content, version):
    """
    Replaces sections inside index.html using placeholders.
    """
    with open(INDEX_HTML, "r", encoding="utf-8") as f:
        content = f.read()

    # Replace Version Badge
    version_pattern = r"(<!-- VERSION_START -->).*?(<!-- VERSION_END -->)"
    content = re.sub(version_pattern, rf'\1<span class="badge">{version}</span>\2', content, flags=re.DOTALL)

    # Replace Sidebar Core
    core_pattern = r"(<!-- SIDEBAR_CORE_START -->\n).*?(\n\s*<!-- SIDEBAR_CORE_END -->)"
    content = re.sub(core_pattern, rf"\1{sidebar_core}\2", content, flags=re.DOTALL)

    # Replace Sidebar Layout
    layout_pattern = r"(<!-- SIDEBAR_LAYOUT_START -->\n).*?(\n\s*<!-- SIDEBAR_LAYOUT_END -->)"
    content = re.sub(layout_pattern, rf"\1{sidebar_layout}\2", content, flags=re.DOTALL)

    # Replace Sidebar Components
    comp_pattern = r"(<!-- SIDEBAR_COMPONENTS_START -->\n).*?(\n\s*<!-- SIDEBAR_COMPONENTS_END -->)"
    content = re.sub(comp_pattern, rf"\1{sidebar_components}\2", content, flags=re.DOTALL)

    # Replace Dynamic Content
    content_pattern = r"(<!-- DYNAMIC_API_START -->\n).*?(\n\s*<!-- DYNAMIC_API_END -->)"
    content = re.sub(content_pattern, rf"\1{main_content}\2", content, flags=re.DOTALL)

    with open(INDEX_HTML, "w", encoding="utf-8") as f:
        f.write(content)

def main():
    print("[SYNC] Parsing source files in 'src/'...")
    extracted = extract_all_functions()
    
    print("[SYNC] Generating 'dump' file...")
    dump_data = generate_dump(extracted)
    with open(DUMP_FILE, "w", encoding="utf-8") as f:
        json.dump(dump_data, f, indent=4)
    print(f"[SUCCESS] Saved parsed API definitions to '{DUMP_FILE}'")

    print("[SYNC] Preparing HTML components...")
    sidebar_core = build_sidebar_html(dump_data, "Core")
    sidebar_layout = build_sidebar_html(dump_data, "Layout")
    sidebar_components = build_sidebar_html(dump_data, "Components")
    main_content = build_content_html(dump_data)

    print("[SYNC] Fetching latest release version from GitHub...")
    version = get_latest_release()
    print(f"[SYNC] Latest release version is: {version}")

    print("[SYNC] Injecting documentation into 'index.html'...")
    update_index_html(sidebar_core, sidebar_layout, sidebar_components, main_content, version)
    print("[SUCCESS] HTML documentation has been synchronized!")

if __name__ == "__main__":
    main()
