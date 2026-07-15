import os
import re
import json

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SRC_DIR = os.path.join(BASE_DIR, "src")
DOCS_DIR = os.path.join(BASE_DIR, "docs")
INDEX_HTML = os.path.join(DOCS_DIR, "index.html")
DUMP_FILE = os.path.join(DOCS_DIR, "dump.json")

METADATA = {
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
    "AddCleanup": {
        "group": "Core",
        "label": "Core API",
        "display_name": "AddCleanup",
        "id": "add-cleanup",
        "nav_id": "nav-cleanup",
        "icon": "fa-trash-can",
        "description": "Registers a thread, connection, instance, or custom callback to be automatically cleaned up/cancelled when the window is closed or destroyed.",
        "params": {
            "object": {"type": "any", "description": "The thread, RBXScriptConnection, Instance, or custom clean-up function to track."},
            "customCleanup": {"type": "function", "description": "Optional destructor function. For threads, pass <code>task.cancel</code>. For custom actions, pass a function."}
        },
        "example": """-- Auto-cancel a background loop when window closes
local myLoop = task.spawn(function()
    while true do
        task.wait(1)
        print("Looping...")
    end
end)
window:AddCleanup(myLoop, task.cancel)

-- Auto-disconnect a custom event connection
local connection = game.Players.PlayerAdded:Connect(function(player)
    print("Welcome", player.Name)
end)
window:AddCleanup(connection)"""
    },
    "CreateTimer": {
        "group": "Core",
        "label": "Core API",
        "display_name": "CreateTimer",
        "id": "create-timer",
        "nav_id": "nav-timer",
        "icon": "fa-clock",
        "description": "Creates a new Timer object from the built-in <code>sleitnick/timer</code> package. Provides a memory-safe, pauseable, and highly accurate alternative to <code>while true do</code> loops.",
        "params": {
            "interval": {"type": "number", "description": "Tick interval duration in seconds (defaults to 1)."}
        },
        "example": """-- Create a timer that ticks every 1 second
local myTimer = MonoUI.CreateTimer(1)

-- Connect logic to the Tick event
myTimer.Tick:Connect(function()
    print("Timer ticked!")
end)

-- Register the timer with the window to automatically stop it when the GUI closes
window:AddCleanup(myTimer)

-- Start the timer
myTimer:Start()

-- You can also use:
-- myTimer:Pause()
-- myTimer:Resume()
-- myTimer:Stop()"""
    },

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
    "CreateHBar": {
        "group": "Layout",
        "label": "Layout",
        "display_name": "HBar",
        "id": "hbar",
        "nav_id": "nav-hbar",
        "icon": "fa-grip",
        "description": "Creates a horizontal container block (HBar) that can hold multiple vertical column stacks (VBars) side-by-side.",
        "params": {},
        "example": "local hbar = tab:CreateHBar()"
    },
    "CreateVBar": {
        "group": "Layout",
        "label": "Layout",
        "display_name": "VBar",
        "id": "vbar",
        "nav_id": "nav-vbar",
        "icon": "fa-ellipsis-vertical",
        "description": "Creates a vertical column stack (VBar) inside an HBar layout container. Allows vertical stacking of any standard components.",
        "params": {},
        "example": """local vbar1 = hbar:CreateVBar()
vbar1:CreateToggle({ text = "Toggle in VBar" })"""
    },

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
            "default": {"type": "string | table", "description": "Initially selected body part(s). Valid parts: 'Head', 'Torso', 'LeftArm', 'RightArm', 'LeftLeg', 'RightLeg'."},
            "disabledParts": {"type": "table", "description": "List of parts that cannot be selected/clicked. Valid parts: 'Head', 'Torso', 'LeftArm', 'RightArm', 'LeftLeg', 'RightLeg'."},
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
        "description": "Renders a scrolling player list widget showing active players on the server. Supports up to 2 custom buttons per player.",
        "params": {
            "text": {"type": "string", "description": "Header title of the list widget."},
            "height": {"type": "number", "description": "Pixel height of the scroll area."},
            "buttons": {"type": "table", "description": "List of custom player actions (max 2). E.g. <code>{{text='TP', type='button', callback=function(p) ... end}}</code>"}
        },
        "example": """tab:CreatePlayerList({
    text   = "Active Server Players",
    height = 280,
    buttons = {
        {
            text = "TP",
            type = "button",
            callback = function(player)
                print("Teleporting to: " .. player.Name)
            end
        },
        {
            text = "ESP",
            type = "toggle",
            callback = function(player, active)
                print("ESP for " .. player.Name .. " set to " .. tostring(active))
            end
        }
    }
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
    },
    "CreateParagraph": {
        "group": "Components",
        "label": "Components",
        "display_name": "Paragraph",
        "id": "paragraph",
        "nav_id": "nav-paragraph",
        "icon": "fa-paragraph",
        "description": "Renders a beautifully formatted, auto-wrapping text block with rich text support.",
        "params": {
            "text": {"type": "string", "description": "The paragraph text to display. Supports RichText tags."},
            "size": {"type": "number", "description": "Font size (defaults to 12)."},
            "color": {"type": "Color3", "description": "Text color (defaults to light gray)."},
            "align": {"type": "Enum.TextXAlignment", "description": "Horizontal alignment (defaults to Left)."},
            "font": {"type": "Font", "description": "Custom FontFace to apply."}
        },
        "example": """tab:CreateParagraph({
    text  = "<b>MonoUI</b> is a premium, modular Roblox UI library. Supports <i>RichText</i> formatting out of the box!",
    size  = 13,
    color = Color3.fromRGB(242, 242, 242),
})"""
    },
    "CreateDivider": {
        "group": "Components",
        "label": "Components",
        "display_name": "Divider",
        "id": "divider",
        "nav_id": "nav-divider",
        "icon": "fa-minus",
        "description": "Creates a layout spacing buffer (spacer) or a horizontal separator line between components.",
        "params": {
            "height": {"type": "number", "description": "Spacing height in pixels (defaults to 12)."},
            "line": {"type": "boolean", "description": "Whether to render a subtle visible divider line (defaults to false)."}
        },
        "example": """tab:CreateDivider({
    height = 16,
    line   = true,
})"""
    }
}

def parse_lua_file(filepath):
    """
    Parses a Lua file to find properties accessed on 'args', 'options', etc.
    """
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    pattern = r"(?:args|options|tArgs|sArgs|cArgs|slArgs|tbArgs|kbArgs|lgArgs|plArgs|currentOptions)\.([a-zA-Z0-9_]+)"
    matches = re.findall(pattern, content)
    
    return sorted(list(set(matches)))

def extract_all_functions():
    """
    Scans the src/ components and core files to map actual arguments.
    """
    functions = {}

    components_path = os.path.join(SRC_DIR, "components")
    if os.path.exists(components_path):
        for filename in os.listdir(components_path):
            if filename.endswith(".lua"):
                filepath = os.path.join(components_path, filename)
                basename = filename[:-4]  # Remove .lua
                func_name = f"Create{basename}"
                
                if basename == "Section":
                    func_name = "CreateSection"

                args = parse_lua_file(filepath)
                stateful_components = ["Toggle", "Slider", "Dropdown", "Input", "Keybind", "ColorPicker", "TargetBody"]
                if basename in stateful_components and "flag" not in args:
                    args.append("flag")

                functions[func_name] = sorted(args)

    window_lua = os.path.join(SRC_DIR, "core", "window.lua")
    if os.path.exists(window_lua):
        with open(window_lua, "r", encoding="utf-8") as f:
            content = f.read()
        
        create_window_match = re.search(r"local function CreateWindow\(([^)]+)\)", content)
        if create_window_match:
            window_subcontent = content[:content.find("local function showTab")]
            window_args = re.findall(r"options\.([a-zA-Z0-9_]+)", window_subcontent)
            functions["CreateWindow"] = sorted(list(set(window_args)))

        create_tab_match = re.search(r"function windowObject:CreateTab\(([^)]+)\)", content)
        if create_tab_match:
            tab_block_start = content.find("function windowObject:CreateTab")
            tab_block_end = content.find("createContainerMethods(tab, page)", tab_block_start)
            tab_subcontent = content[tab_block_start:tab_block_end]
            tab_args = re.findall(r"args\.([a-zA-Z0-9_]+)", tab_subcontent)
            functions["CreateTab"] = sorted(list(set(tab_args)))

    notification_lua = os.path.join(SRC_DIR, "core", "notification.lua")
    if os.path.exists(notification_lua):
        notification_args = parse_lua_file(notification_lua)
        functions["Notify"] = notification_args

    watermark_lua = os.path.join(SRC_DIR, "core", "watermark.lua")
    if os.path.exists(watermark_lua):
        watermark_args = parse_lua_file(watermark_lua)
        functions["SetWatermark"] = watermark_args

    control_hud_lua = os.path.join(SRC_DIR, "core", "controlHUD.lua")
    if os.path.exists(control_hud_lua):
        functions["CreateControlHUD"] = ["icon", "default", "callback"]

    functions["AddCleanup"] = ["object", "customCleanup"]
    functions["CreateTimer"] = ["interval"]
    functions["CreateHBar"] = []
    functions["CreateVBar"] = []

    return functions

def generate_dump(extracted):
    """
    Generates a dump dictionary mapping each function to its parsed arguments with types and descriptions.
    """
    dump_data = {}
    for func_name, args in extracted.items():
        meta = METADATA.get(func_name, {})
        
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

def get_sort_key(name):
    order = {
        # Core Group Order
        "CreateWindow": 1,
        "Notify": 2,
        "SetWatermark": 3,
        "CreateControlHUD": 4,
        "AddCleanup": 5,
        "CreateTimer": 6,
        
        # Layout Group Order
        "CreateSection": 10,
        "CreateTab": 11,
        "CreateHBar": 12,
        "CreateVBar": 13,
    }
    if name in order:
        return (0, order[name])
    return (1, name)

FULL_SCRIPT_CONTENT = """            <!-- Full Example -->
            <section id="full-code" class="doc-section">
                <div class="breadcrumb">
                    <span class="current">Examples</span>
                    <span class="sep">›</span>
                    <span class="current">Full Script</span>
                </div>
                <div class="section-label">Examples</div>
                <h2>Full Script</h2>
                <p>A complete working example using all major MonoUI features.</p>
                <div class="code-container">
                    <div class="code-header">
                        <span class="code-lang">Lua</span>
                        <button class="copy-btn"><i class="fa-regular fa-copy"></i> Copy</button>
                    </div>
                    <pre><code class="language-lua">local MonoUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/mono-ui/main/dist/mono-ui.luau"))()

MonoUI.SetWatermark({ visible = true, text = "MonoUI Premium" })

local window = MonoUI.CreateWindow({
    Title      = "mono ui",
    Subtitle   = "premium modular library",
    Size       = UDim2.fromOffset(600, 400),
    Icon       = "shield",
    ConfigName = "my_config",
    AutoSave   = true,
    AutoExec   = true,
})

-- Console tab
local consoleTab = window:CreateTab({ text = "Console", icon = "terminal" })
consoleTab:CreateSection({ text = "System Logs" })
local logger = consoleTab:CreateLogger({ text = "Output", height = 280 })

-- Combat tab
local combatTab = window:CreateTab({ text = "Combat", icon = "swords" })
combatTab:CreateSection({ text = "Aimbot" })
combatTab:CreateToggle({
    text = "Silent Aim", default = false, flag = "silent_aim",
    callback = function(v) logger:Log("INFO", "Silent Aim: " .. tostring(v)) end,
})
combatTab:CreateSlider({
    text = "FOV", min = 10, max = 200, default = 90, flag = "fov",
    callback = function(v) logger:Log("INFO", "FOV: " .. v) end,
})

logger:Log("SUCCESS", "All tabs loaded.")</code></pre>
                </div>
            </section>
"""

def build_sidebar_html(dump_data, group_name):
    """
    Builds the sidebar HTML link tags for a specific group (Core, Layout, Components).
    """
    html_lines = []
    
    group_funcs = {k: v for k, v in dump_data.items() if v["type"] == group_name.lower()}
    
    for func_name in sorted(group_funcs.keys(), key=get_sort_key):
        meta = METADATA.get(func_name, {})
        nav_id = meta.get("nav_id", f"nav-{func_name.lower().replace('create', '')}")
        icon = meta.get("icon", "fa-cube")
        
        html_lines.append(f'                    <a href="{func_name}.html" class="nav-item" id="{nav_id}"><i\n'
                           f'                            class="fa-solid {icon}"></i> {func_name}</a>')
                           
    return "\n".join(html_lines)

def generate_full_context_example(func_name, basic_example):
    """
    Generates a complete, runnable boilerplate script for a given function.
    """
    loadstring_line = '-- Load the MonoUI Library\nlocal MonoUI = loadstring(game:HttpGet("https://github.com/BloodLetters/mono-ui/releases/latest/download/Release.luau"))()'
    
    if func_name == "CreateWindow":
        return f"{loadstring_line}\n\n{basic_example}"
        
    elif func_name in ["Notify", "SetWatermark", "CreateControlHUD"]:
        return f"{loadstring_line}\n\n{basic_example}"
        
    elif func_name in ["AddCleanup", "CreateTimer", "CreateTab"]:
        return (
            f"{loadstring_line}\n\n"
            f"-- Create the main Window\n"
            f"local window = MonoUI.CreateWindow({{\n"
            f"    Title      = \"mono ui\",\n"
            f"    ConfigName = \"mono_config\",\n"
            f"    AutoSave   = true,\n"
            f"}})\n\n"
            f"{basic_example}"
        )
        
    else:
        # Layout and components
        if "local MonoUI" in basic_example:
            return basic_example
        
        # Check if it needs hbar
        if func_name == "CreateVBar":
            return (
                f"{loadstring_line}\n\n"
                f"-- Create the main Window\n"
                f"local window = MonoUI.CreateWindow({{\n"
                f"    Title      = \"mono ui\",\n"
                f"    ConfigName = \"mono_config\",\n"
                f"    AutoSave   = true,\n"
                f"}})\n\n"
                f"-- Create a Tab\n"
                f"local tab = window:CreateTab({{ text = \"Main\", icon = \"home\" }})\n\n"
                f"-- Create a Horizontal Column stack (HBar)\n"
                f"local hbar = tab:CreateHBar()\n\n"
                f"-- Create the VBar\n"
                f"{basic_example}"
            )
        else:
            return (
                f"{loadstring_line}\n\n"
                f"-- Create the main Window\n"
                f"local window = MonoUI.CreateWindow({{\n"
                f"    Title      = \"mono ui\",\n"
                f"    ConfigName = \"mono_config\",\n"
                f"    AutoSave   = true,\n"
                f"}})\n\n"
                f"-- Create a Tab\n"
                f"local tab = window:CreateTab({{ text = \"Main\", icon = \"home\" }})\n\n"
                f"-- Create the component\n"
                f"{basic_example}"
            )

def build_single_content_html(func_name, func_data):
    """
    Builds the main content HTML section for a single function.
    """
    meta = METADATA.get(func_name, {})
    section_id = meta.get("id", func_name.lower().replace('create', ''))
    group = func_data["type"].capitalize()
    label = func_data["label"]
    desc = func_data["description"]
    example = func_data["example"]
    full_context = generate_full_context_example(func_name, example)
    
    breadcrumb = (
        f'                <div class="breadcrumb">\n'
        f'                    <a href="index.html#introduction">{group}</a>\n'
        f'                    <span class="sep">›</span>\n'
        f'                    <span class="current">{func_name}</span>\n'
        f'                </div>'
    )

    table_rows = []
    for arg in func_data["arguments"]:
        name = arg["name"]
        arg_type = arg["type"]
        arg_desc = arg["description"]
        
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

    table_html = ""
    if table_rows:
        table_html = (
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
        )

    section_html = (
        f'            <!-- {func_name} -->\n'
        f'            <section id="{section_id}" class="doc-section">\n'
        f'{breadcrumb}\n'
        f'                <div class="section-label">{label}</div>\n'
        f'                <h2>{func_name}</h2>\n'
        f'                <p>{desc}</p>\n'
        f'{table_html}'
        f'                <h3>Code Snippet</h3>\n'
        f'                <div class="code-container">\n'
        f'                    <div class="code-header">\n'
        f'                        <span class="code-lang">Lua</span>\n'
        f'                        <button class="copy-btn"><i class="fa-regular fa-copy"></i> Copy</button>\n'
        f'                    </div>\n'
        f'                    <pre><code class="language-lua">{example}</code></pre>\n'
        f'                </div>\n'
        f'                <h3>Complete Script Usage</h3>\n'
        f'                <div class="code-container">\n'
        f'                    <div class="code-header">\n'
        f'                        <span class="code-lang">Lua (Full Setup)</span>\n'
        f'                        <button class="copy-btn"><i class="fa-regular fa-copy"></i> Copy</button>\n'
        f'                    </div>\n'
        f'                    <pre><code class="language-lua">{full_context}</code></pre>\n'
        f'                </div>\n'
        f'            </section>\n'
    )
    return section_html

def get_latest_release():
    """
    Queries GitHub API to fetch the latest release tag.
    """
    import urllib.request
    import json
    url = "https://api.github.com/repos/BloodLetters/Mono-UI/releases/latest"
    req = urllib.request.Request(url, headers={"User-Agent": "MonoUI-Sync-Script"})
    try:
        with urllib.request.urlopen(req, timeout=5) as response:
            data = json.loads(response.read().decode())
            return data.get("tag_name", "v1.1.0")
    except Exception as e:
        print(f"[WARNING] Failed to fetch latest release version from GitHub: {e}")
        return "v1.1.0"

def update_index_html(sidebar_core, sidebar_layout, sidebar_components, version):
    """
    Replaces sections inside index.html using placeholders.
    """
    with open(INDEX_HTML, "r", encoding="utf-8") as f:
        content = f.read()

    version_pattern = r"(<!-- VERSION_START -->).*?(<!-- VERSION_END -->)"
    content = re.sub(version_pattern, rf'\1<span class="badge">{version}</span>\2', content, flags=re.DOTALL)

    core_pattern = r"(<!-- SIDEBAR_CORE_START -->).*?(<!-- SIDEBAR_CORE_END -->)"
    content = re.sub(core_pattern, rf"\1\n{sidebar_core}\n\2", content, flags=re.DOTALL)

    layout_pattern = r"(<!-- SIDEBAR_LAYOUT_START -->).*?(<!-- SIDEBAR_LAYOUT_END -->)"
    content = re.sub(layout_pattern, rf"\1\n{sidebar_layout}\n\2", content, flags=re.DOTALL)

    comp_pattern = r"(<!-- SIDEBAR_COMPONENTS_START -->).*?(<!-- SIDEBAR_COMPONENTS_END -->)"
    content = re.sub(comp_pattern, rf"\1\n{sidebar_components}\n\2", content, flags=re.DOTALL)

    with open(INDEX_HTML, "w", encoding="utf-8") as f:
        f.write(content)

def make_page(template_html, content_html, active_nav_id=None):
    """
    Constructs a separate HTML page by substituting content and sidebar highlights.
    """
    main_content_pattern = r"(<!-- MAIN_CONTENT_START -->).*?(<!-- MAIN_CONTENT_END -->)"
    page_html = re.sub(main_content_pattern, rf"\1\n{content_html}\n\2", template_html, flags=re.DOTALL)
    
    # Deactivate nav-intro
    page_html = page_html.replace('class="nav-item active" id="nav-intro"', 'class="nav-item" id="nav-intro"')
    page_html = page_html.replace('id="nav-intro" class="nav-item active"', 'id="nav-intro" class="nav-item"')
    
    # Activate correct link
    if active_nav_id:
        page_html = page_html.replace(f'class="nav-item" id="{active_nav_id}"', f'class="nav-item active" id="{active_nav_id}"')
        page_html = page_html.replace(f'id="{active_nav_id}" class="nav-item"', f'id="{active_nav_id}" class="nav-item active"')
        
    return page_html

def sync_mcp(dump_data):
    """
    Updates COMPONENT_DOCS in MCP/server.py and writes JSON schemas to App Data directory.
    """
    print("[SYNC] Synchronizing MCP server documents & schemas...")
    mcp_dir = os.path.join(BASE_DIR, "MCP")
    server_py_path = os.path.join(mcp_dir, "server.py")
    
    PARAM_DEFAULTS = {
        "text": {
            "Button": '"Button"', "Toggle": '"Toggle"', "Input": '"Input"', "Dropdown": '"Dropdown"',
            "Slider": '"Slider"', "ColorPicker": '"Color"', "Keybind": '"Keybind"', "Logger": '"Console Logs"',
            "PlayerList": '"Player List"', "TargetBody": '"Target Body Parts"', "Section": '"Section"'
        },
        "default": {
            "Toggle": "false", "Input": '""', "Dropdown": "nil", "Slider": "min",
            "ColorPicker": "Color3.fromRGB(100,100,110)", "Keybind": "Enum.KeyCode.None", "TargetBody": "nil"
        },
        "multiple": {
            "Dropdown": "false", "TargetBody": "true"
        },
        "list": "{}",
        "disabledParts": "{}",
        "flag": "nil",
        "callback": "nil",
        "placeholder": '"type here..."',
        "height": {
            "Logger": "180", "PlayerList": "200"
        }
    }

    def get_default_value(arg_name, comp_name):
        default_entry = PARAM_DEFAULTS.get(arg_name, "nil")
        if isinstance(default_entry, dict):
            return default_entry.get(comp_name, "nil")
        return default_entry

    mcp_components = {}
    for func_name, data in dump_data.items():
        if data["type"] == "components" or func_name in ["CreateSection", "CreateHBar", "CreateVBar"]:
            comp_name = data["display_name"]
            params = []
            for arg in data["arguments"]:
                params.append({
                    "name": arg["name"],
                    "type": arg["type"],
                    "default": get_default_value(arg["name"], comp_name),
                    "desc": arg["description"]
                })
            
            comp_entry = {
                "description": data["description"],
                "params": params
            }
            if comp_name == "Logger":
                comp_entry["methods"] = [
                    {"name": "Log", "params": "level: string (INFO|WARNING|SUCCESS|ERROR), message: string", "desc": "Append a log entry."}
                ]
            mcp_components[comp_name] = comp_entry

    def format_py(val, indent_level=0):
        indent = "    " * indent_level
        if isinstance(val, dict):
            if not val:
                return "{}"
            lines = ["{"]
            for k, v in sorted(val.items()):
                lines.append(f"{indent}    {repr(k)}: {format_py(v, indent_level + 1)},")
            lines.append(f"{indent}}}")
            return "\n".join(lines)
        elif isinstance(val, list):
            if not val:
                return "[]"
            lines = ["["]
            for item in val:
                lines.append(f"{indent}    {format_py(item, indent_level + 1)},")
            lines.append(f"{indent}]")
            return "\n".join(lines)
        else:
            return repr(val)

    component_docs_str = f"COMPONENT_DOCS = {format_py(mcp_components, 0)}"

    if os.path.exists(server_py_path):
        with open(server_py_path, "r", encoding="utf-8") as f:
            server_content = f.read()

        start_marker = "# COMPONENT_DOCS_START"
        end_marker = "# COMPONENT_DOCS_END"
        
        start_idx = server_content.find(start_marker)
        end_idx = server_content.find(end_marker)
        
        if start_idx != -1 and end_idx != -1:
            new_content = (
                server_content[:start_idx + len(start_marker)] +
                "\n" + component_docs_str + "\n" +
                server_content[end_idx:]
            )
            with open(server_py_path, "w", encoding="utf-8") as f:
                f.write(new_content)
            print("[SUCCESS] Updated 'COMPONENT_DOCS' in MCP/server.py")
        else:
            print("[WARNING] Could not find COMPONENT_DOCS markers in MCP/server.py")
    else:
        print(f"[WARNING] MCP/server.py not found at {server_py_path}")

    mcp_schema_dir = os.path.expanduser("~/.gemini/antigravity-ide/mcp/mono-ui-mcp")
    if os.path.exists(mcp_schema_dir):
        components_list = sorted(list(mcp_components.keys()))
        components_str = ", ".join(components_list)

        schemas = {
            "get-loadstring": {
                "name": "get-loadstring",
                "description": "Get the loadstring code to load the MonoUI library in Roblox. Optionally includes the watermark setup.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "watermark": {
                            "type": "boolean",
                            "description": "Whether to include the watermark initialization snippet.",
                            "default": False
                        }
                    },
                    "required": []
                }
            },
            "generate-window": {
                "name": "generate-window",
                "description": "Generate Luau code to create a MonoUI window with event hooks.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "title": {"type": "string", "description": "Window title (displayed in top bar)."},
                        "subtitle": {"type": "string", "description": "Window subtitle.", "default": ""},
                        "icon": {"type": "string", "description": "Lucide icon name for the window.", "default": "shield"},
                        "width": {"type": "integer", "description": "Window width in pixels.", "default": 600},
                        "height": {"type": "integer", "description": "Window height in pixels.", "default": 400},
                        "config_name": {"type": "string", "description": "Config file name for auto-save.", "default": "mono_config"},
                        "auto_save": {"type": "boolean", "description": "Enable auto-save of config.", "default": True},
                        "auto_exec": {"type": "boolean", "description": "Enable auto-reload on teleport.", "default": True},
                        "include_event_hooks": {"type": "boolean", "description": "Whether to include window lifecycle event hooks (PreOpened, Closed, Minimized).", "default": False}
                    },
                    "required": ["title"]
                }
            },
            "generate-tab": {
                "name": "generate-tab",
                "description": "Generate Luau code to create a tab inside a window.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "tab_var": {"type": "string", "description": "Variable name for the tab (e.g. 'mainTab')."},
                        "window_var": {"type": "string", "description": "Variable name of the window (e.g. 'window').", "default": "window"},
                        "text": {"type": "string", "description": "Tab display text."},
                        "icon": {"type": "string", "description": "Lucide icon name.", "default": ""}
                    },
                    "required": ["tab_var", "text"]
                }
            },
            "generate-component": {
                "name": "generate-component",
                "description": f"Generate Luau code to create a UI component ({components_str}) inside a tab.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "tab_var": {"type": "string", "description": "Variable name of the tab (e.g. 'mainTab').", "default": "tab"},
                        "comp_type": {"type": "string", "description": f"Component type: {components_str}."},
                        "var_name": {"type": "string", "description": "Variable name to assign result to (e.g. 'myLogger' for Logger)."},
                        "text": {"type": "string", "description": "Label/display text for the component."},
                        "placeholder": {"type": "string", "description": "(Input only) Placeholder text."},
                        "default": {"type": "string", "description": "Default value (boolean, number, string, Color3). For TargetBody, use single part ('Head') or comma-separated ('Head,Torso'). Valid parts: Head, Torso, LeftArm, RightArm, LeftLeg, RightLeg."},
                        "min": {"type": "number", "description": "(Slider only) Minimum value."},
                        "max": {"type": "number", "description": "(Slider only) Maximum value."},
                        "list": {"type": "string", "description": "(Dropdown only) Comma-separated option strings."},
                        "multiple": {"type": "boolean", "description": "(Dropdown/TargetBody) Allow multiple selections."},
                        "height": {"type": "number", "description": "(Logger/PlayerList) Height in pixels."},
                        "disabledParts": {"type": "string", "description": "(TargetBody only) Comma-separated parts that cannot be selected. Valid parts: Head, Torso, LeftArm, RightArm, LeftLeg, RightLeg."},
                        "flag": {"type": "string", "description": "Config save/load key for auto-save."},
                        "callback": {"type": "string", "description": "Luau callback code (e.g. 'function(value) print(value) end')."}
                    },
                    "required": ["comp_type"]
                }
            },
            "generate-notification": {
                "name": "generate-notification",
                "description": "Generate Luau code for a MonoUI sliding notification toast.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "title": {"type": "string", "description": "Notification title."},
                        "content": {"type": "string", "description": "Notification body text."},
                        "icon": {"type": "string", "description": "Lucide icon name.", "default": "check-circle"},
                        "duration": {"type": "integer", "description": "Display duration in seconds.", "default": 5}
                    },
                    "required": ["title", "content"]
                }
            },
            "generate-control-hud": {
                "name": "generate-control-hud",
                "description": "Generate Luau code for a ControlHUD quick-toggle bar with Lucide icons.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "buttons": {"type": "string", "description": "JSON array of buttons, each with: icon (string), default (boolean). Example: [{\"icon\":\"swords\",\"default\":false},{\"icon\":\"eye\",\"default\":true}]"}
                    },
                    "required": ["buttons"]
                }
            },
            "list-components": {
                "name": "list-components",
                "description": "List all available MonoUI components with brief descriptions.",
                "parameters": {
                    "type": "object",
                    "properties": {},
                    "required": []
                }
            },
            "get-component-docs": {
                "name": "get-component-docs",
                "description": "Get detailed documentation for a specific MonoUI component, including all parameters and methods.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "component": {"type": "string", "description": f"Component name: {components_str}."}
                    },
                    "required": ["component"]
                }
            },
            "generate-full-example": {
                "name": "generate-full-example",
                "description": "Generate a complete, runnable MonoUI example script with window, tabs, and optional sections like watermark, notifications, control HUD, and logger.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "title": {"type": "string", "description": "Title/name for the example script.", "default": "Mono UI"},
                        "config_name": {"type": "string", "description": "Config file name.", "default": "mono_config"},
                        "include_watermark": {"type": "boolean", "description": "Include SetWatermark initialization.", "default": False},
                        "include_notifications": {"type": "boolean", "description": "Include load notification.", "default": False},
                        "include_control_hud": {"type": "boolean", "description": "Include ControlHUD setup.", "default": False},
                        "include_logger": {"type": "boolean", "description": "Include Logger widget and callback logs.", "default": False},
                        "include_event_hooks": {"type": "boolean", "description": "Include window event hooks (PreOpened, etc.).", "default": False}
                    },
                    "required": []
                }
            },
            "list-icons": {
                "name": "list-icons",
                "description": "List available Lucide icon names that can be used with MonoUI.",
                "parameters": {
                    "type": "object",
                    "properties": {},
                    "required": []
                }
            }
        }

        for schema_name, schema_data in schemas.items():
            schema_file_path = os.path.join(mcp_schema_dir, f"{schema_name}.json")
            try:
                with open(schema_file_path, "w", encoding="utf-8") as sf:
                    json.dump(schema_data, sf)
                print(f"[SUCCESS] Updated lazy schema file: {schema_name}.json")
            except Exception as e:
                print(f"[WARNING] Failed to write lazy schema to {schema_file_path}: {e}")

        # Write instructions.md for the MCP server
        instructions_file_path = os.path.join(mcp_schema_dir, "instructions.md")
        instructions_content = """# mono-ui-mcp Best Practices & Guidelines

When generating Roblox scripts using MonoUI, you must follow these best practices for memory management and thread cleanup to prevent memory leaks in the player's client.

## Memory Leak Prevention (Janitor / Cleanup)

Roblox executors execute scripts inside persistent environments. When a user closes or destroys a GUI, any active event connections or running threads (loops) created by the script **will continue to run in the background** unless they are explicitly cleaned up.

MonoUI windows include a built-in clean-up tracking method: `window:AddCleanup(object, customCleanup)`.

### 1. Handling Loops (Never use raw `while` loops)
Never use raw `while true do` or `while task.wait() do` loops for background tasks, as they cause massive memory leaks when the GUI closes. Instead, always use MonoUI's built-in, memory-safe `CreateTimer` and register it with the window's cleanup list.

**Correct Pattern:**
```lua
local myTimer = MonoUI.CreateTimer(1) -- Ticks every 1 second
myTimer.Tick:Connect(function()
    -- Loop operations here
end)
window:AddCleanup(myTimer) -- Automatically stops and cleans up the timer on window close
myTimer:Start()
```

### 2. Handling Event Connections (`:Connect`)
When connecting to Roblox events outside of MonoUI's built-in callbacks (e.g. workspace events, user input, player joining/leaving), always register the connection with the window's cleanup list.

**Correct Pattern:**
```lua
local playerConnection = game.Players.PlayerAdded:Connect(function(player)
    print(player.Name .. " has joined the server!")
end)
window:AddCleanup(playerConnection) -- Automatically disconnects when window closes
```

### 3. Custom Cleanup Actions
If custom cleanup actions are needed (e.g. restoring game settings or destroying temp parts in workspace), pass a custom cleanup function.

**Correct Pattern:**
```lua
local tempPart = Instance.new("Part")
tempPart.Parent = workspace
window:AddCleanup(tempPart) -- Automatically calls :Destroy() on Instances

window:AddCleanup(function()
    -- Custom cleanup code (e.g. resetting gravity)
    workspace.Gravity = 196.2
end)
```
"""
        try:
            with open(instructions_file_path, "w", encoding="utf-8") as inf:
                inf.write(instructions_content)
            print("[SUCCESS] Updated MCP instructions.md")
        except Exception as e:
            print(f"[WARNING] Failed to write MCP instructions.md: {e}")
    else:
        print(f"[INFO] IDE Lazy schema directory not found at {mcp_schema_dir}. Skipping schema files sync.")


def main():
    print("[SYNC] Parsing source files in 'src/'...")
    extracted = extract_all_functions()
    
    print("[SYNC] Generating 'dump' file...")
    dump_data = generate_dump(extracted)
    with open(DUMP_FILE, "w", encoding="utf-8") as f:
        json.dump(dump_data, f, indent=4)
    print(f"[SUCCESS] Saved parsed API definitions to '{DUMP_FILE}'")

    sync_mcp(dump_data)

if __name__ == "__main__":
    main()
