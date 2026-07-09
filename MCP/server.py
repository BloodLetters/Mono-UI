"""
MonoUI MCP Server - Model Context Protocol server for MonoUI Roblox GUI library.

Provides tools to generate Luau code snippets for creating MonoUI interfaces,
including windows, tabs, components, notifications, watermarks, and control HUDs.
"""

import json
import sys
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent

# ──────────────────────────────────────────────
# Constants
# ──────────────────────────────────────────────

LOADSTRING_URL = (
    'loadstring(game:HttpGet('
    '"https://github.com/BloodLetters/mono-ui/releases/latest/download/Release.luau"'
    '))()'
)

COMPONENT_DOCS = {
    "Button": {
        "description": "A clickable action button with 'run' label.",
        "params": [
            {"name": "text", "type": "string", "default": '"Button"', "desc": "Label text for the button."},
            {"name": "callback", "type": "function", "default": "nil", "desc": "Function called when the button is clicked."},
        ],
    },
    "Toggle": {
        "description": "An on/off toggle switch.",
        "params": [
            {"name": "text", "type": "string", "default": '"Toggle"', "desc": "Label text."},
            {"name": "default", "type": "boolean", "default": "false", "desc": "Initial toggle state."},
            {"name": "flag", "type": "string", "default": "nil", "desc": "Config save/load key."},
            {"name": "callback", "type": "function", "default": "nil", "desc": "Called with (state: boolean) on toggle."},
        ],
    },
    "Input": {
        "description": "A text input field.",
        "params": [
            {"name": "text", "type": "string", "default": '"Input"', "desc": "Label text."},
            {"name": "placeholder", "type": "string", "default": '"type here..."', "desc": "Placeholder text."},
            {"name": "default", "type": "string", "default": '""', "desc": "Default input value."},
            {"name": "flag", "type": "string", "default": "nil", "desc": "Config save/load key."},
            {"name": "callback", "type": "function", "default": "nil", "desc": "Called with (value: string) on change."},
        ],
    },
    "Dropdown": {
        "description": "A dropdown selector (single or multi-select).",
        "params": [
            {"name": "text", "type": "string", "default": '"Dropdown"', "desc": "Label text."},
            {"name": "list", "type": "table", "default": "{}", "desc": "Array of option strings."},
            {"name": "default", "type": "string", "default": "nil", "desc": "Default selected option."},
            {"name": "multiple", "type": "boolean", "default": "false", "desc": "Allow multiple selections."},
            {"name": "flag", "type": "string", "default": "nil", "desc": "Config save/load key."},
            {"name": "callback", "type": "function", "default": "nil", "desc": "Called with (value) on selection change."},
        ],
    },
    "Slider": {
        "description": "A numeric slider with drag handle.",
        "params": [
            {"name": "text", "type": "string", "default": '"Slider"', "desc": "Label text."},
            {"name": "min", "type": "number", "default": "0", "desc": "Minimum value."},
            {"name": "max", "type": "number", "default": "100", "desc": "Maximum value."},
            {"name": "default", "type": "number", "default": "min", "desc": "Default slider value."},
            {"name": "flag", "type": "string", "default": "nil", "desc": "Config save/load key."},
            {"name": "callback", "type": "function", "default": "nil", "desc": "Called with (value: number) on change."},
        ],
    },
    "ColorPicker": {
        "description": "A color picker with hex input and interactive picker.",
        "params": [
            {"name": "text", "type": "string", "default": '"Color"', "desc": "Label text."},
            {"name": "default", "type": "Color3", "default": "Color3.fromRGB(100,100,110)", "desc": "Default color."},
            {"name": "flag", "type": "string", "default": "nil", "desc": "Config save/load key."},
            {"name": "callback", "type": "function", "default": "nil", "desc": "Called with (color: Color3) on change."},
        ],
    },
    "Keybind": {
        "description": "A keybind capture button.",
        "params": [
            {"name": "text", "type": "string", "default": '"Keybind"', "desc": "Label text."},
            {"name": "default", "type": "KeyCode", "default": "Enum.KeyCode.None", "desc": "Default keybind."},
            {"name": "flag", "type": "string", "default": "nil", "desc": "Config save/load key."},
            {"name": "callback", "type": "function", "default": "nil", "desc": "Called with (key: KeyCode) on bind."},
        ],
    },
    "Logger": {
        "description": "A scrollable console log display.",
        "params": [
            {"name": "text", "type": "string", "default": '"Console Logs"', "desc": "Title text."},
            {"name": "height", "type": "number", "default": "180", "desc": "Height of the logger in pixels."},
        ],
        "methods": [
            {"name": "Log", "params": "level: string (INFO|WARNING|SUCCESS|ERROR), message: string", "desc": "Append a log entry."},
        ],
    },
    "PlayerList": {
        "description": "A scrollable list of server players.",
        "params": [
            {"name": "text", "type": "string", "default": '"Player List"', "desc": "Title text."},
            {"name": "height", "type": "number", "default": "200", "desc": "Height in pixels."},
        ],
    },
    "TargetBody": {
        "description": "Interactive skeleton hitbox selector.",
        "params": [
            {"name": "text", "type": "string", "default": '"Target Body Parts"', "desc": "Title text."},
            {"name": "multiple", "type": "boolean", "default": "true", "desc": "Allow selecting multiple parts."},
            {"name": "default", "type": "string|table", "default": "nil", "desc": "Default selected part(s)."},
            {"name": "disabledParts", "type": "table", "default": "{}", "desc": "Parts to disable (e.g. {'LeftArm','RightArm'})."},
            {"name": "flag", "type": "string", "default": "nil", "desc": "Config save/load key."},
            {"name": "callback", "type": "function", "default": "nil", "desc": "Called with (parts: table) on change."},
        ],
    },
    "Section": {
        "description": "A section header with uppercase title and divider line.",
        "params": [
            {"name": "text", "type": "string", "default": '"Section"', "desc": "Section title (auto-uppercased)."},
        ],
    },
}

AVAILABLE_ICONS = [
    "shield", "terminal", "swords", "settings", "users", "user", "star",
    "check-circle", "zap", "eye", "palette", "gauge", "home", "search",
    "heart", "bell", "lock", "unlock", "sun", "moon", "cloud", "wifi",
    "bluetooth", "volume-2", "play", "pause", "skip-forward", "music",
    "camera", "video", "image", "file", "folder", "download", "upload",
    "trash-2", "edit", "plus", "minus", "x", "menu", "more-horizontal",
    "info", "alert-triangle", "help-circle", "external-link", "copy",
    "refresh-cw", "maximize-2", "minimize-2",
]

LOG_LEVELS = ["INFO", "WARNING", "SUCCESS", "ERROR"]

BODY_PARTS = ["Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"]


# ──────────────────────────────────────────────
# Code Generators
# ──────────────────────────────────────────────

def _luau_value(val):
    """Convert Python value to Luau literal."""
    if val is None:
        return "nil"
    if isinstance(val, bool):
        return "true" if val else "false"
    if isinstance(val, str):
        return val  # Already a Luau string like '"hello"'
    if isinstance(val, (int, float)):
        return str(val)
    if isinstance(val, list):
        items = ", ".join(_luau_value(v) for v in val)
        return "{" + items + "}"
    return str(val)


def _indent(code: str, level: int = 1) -> str:
    """Indent lines of code."""
    prefix = "\t" * level
    return "\n".join(prefix + line for line in code.split("\n"))


def generate_loadstring() -> str:
    """Generate the loadstring snippet to load MonoUI."""
    return f"""-- Load MonoUI Library
local MonoUI = {LOADSTRING_URL}

-- (Optional) Set watermark
MonoUI.SetWatermark({{
    visible = true,
    text = "MonoUI Premium",
}})
"""


def generate_window(title: str, subtitle: str = "", icon: str = "shield",
                    width: int = 600, height: int = 400,
                    config_name: str = "mono_config", auto_save: bool = True,
                    auto_exec: bool = True) -> str:
    """Generate a window creation snippet."""
    return f"""local window = MonoUI.CreateWindow({{
    Title = \"{title}\",
    Subtitle = \"{subtitle}\",
    Size = UDim2.fromOffset({width}, {height}),
    Icon = \"{icon}\",
    ConfigName = \"{config_name}\",
    AutoSave = {_luau_value(auto_save)},
    AutoExec = {_luau_value(auto_exec)},
}})

-- Window event hooks (optional)
window.event.PreOpened(function(event)
    -- Runs before the window opens
    event.message("Loading...")
    task.wait(1)
    event.done()
end)

window.event.Closed(function()
    print("Window closed!")
end)

window.event.Minimized(function()
    print("Window minimized!")
end)
"""


def generate_tab(tab_var: str, window_var: str, text: str, icon: str = "") -> str:
    """Generate a tab creation snippet."""
    icon_arg = f', icon = "{icon}"' if icon else ""
    return f'local {tab_var} = {window_var}:CreateTab({{\n\ttext = "{text}"{icon_arg}\n}})'

def generate_component(tab_var: str, comp_type: str, **kwargs) -> str:
    """Generate a component creation snippet."""
    type_map = {
        "Button": "CreateButton",
        "Toggle": "CreateToggle",
        "Input": "CreateInput",
        "Dropdown": "CreateDropdown",
        "Slider": "CreateSlider",
        "ColorPicker": "CreateColorPicker",
        "Keybind": "CreateKeybind",
        "Logger": "CreateLogger",
        "PlayerList": "CreatePlayerList",
        "TargetBody": "CreateTargetBody",
        "Section": "CreateSection",
    }
    method = type_map.get(comp_type)
    if not method:
        return f"-- Unknown component type: {comp_type}"

    lines = [f"{tab_var}:{method}({{"]
    for key, val in kwargs.items():
        if val is not None:
            luau_key = key[0].upper() + key[1:] if not key[0].isupper() else key
            lines.append(f"\t{luau_key} = {_luau_value(val)},")
    lines.append("})")
    return "\n".join(lines)


def generate_component_with_callback(tab_var: str, comp_type: str,
                                     var_name: str = None, **kwargs) -> str:
    """Generate a component with a callback and optional variable assignment."""
    type_map = {
        "Button": "CreateButton",
        "Toggle": "CreateToggle",
        "Input": "CreateInput",
        "Dropdown": "CreateDropdown",
        "Slider": "CreateSlider",
        "ColorPicker": "CreateColorPicker",
        "Keybind": "CreateKeybind",
        "Logger": "CreateLogger",
        "PlayerList": "CreatePlayerList",
        "TargetBody": "CreateTargetBody",
        "Section": "CreateSection",
    }
    method = type_map.get(comp_type)
    if not method:
        return f"-- Unknown component type: {comp_type}"

    prefix = f"local {var_name} = " if var_name else ""
    lines = [f"{prefix}{tab_var}:{method}({{"]
    for key, val in kwargs.items():
        if val is not None:
            lines.append(f"\t{key} = {_luau_value(val)},")
    lines.append("})")
    return "\n".join(lines)


def generate_notification(title: str, content: str, icon: str = "check-circle",
                          duration: int = 5) -> str:
    """Generate a notification snippet."""
    return f"""MonoUI.Notify({{
    title = "{title}",
    content = "{content}",
    icon = "{icon}",
    duration = {duration},
}})
"""


def generate_control_hud(buttons: list) -> str:
    """Generate a ControlHUD snippet."""
    lines = ["MonoUI.CreateControlHUD({"]
    for btn in buttons:
        icon = btn.get("icon", "settings")
        default = _luau_value(btn.get("default", False))
        lines.append("\t{")
        lines.append(f'\t\ticon = "{icon}",')
        lines.append(f"\t\tdefault = {default},")
        lines.append("\t\tcallback = function(active)")
        lines.append('\t\t\tprint("HUD button toggled:", active)')
        lines.append("\t\tend,")
        lines.append("\t},")
    lines.append("})")
    return "\n".join(lines)


def generate_full_example(title: str = "Mono UI", config_name: str = "mono_config") -> str:
    """Generate a complete MonoUI example script."""
    return f"""-- ╔══════════════════════════════════════════╗
-- ║     MonoUI - Complete Example Script    ║
-- ╚══════════════════════════════════════════╝

local MonoUI = {LOADSTRING_URL}

-- ═══ Watermark ═══
MonoUI.SetWatermark({{
    visible = true,
    text = "{title}",
}})

-- ═══ Notifications ═══
MonoUI.Notify({{
    title = "MonoUI Loaded",
    content = "All modules initialized successfully.",
    icon = "check-circle",
    duration = 5,
}})

-- ═══ Window ═══
local window = MonoUI.CreateWindow({{
    Title = \"{title.lower()}\",
    Subtitle = \"premium modular library\",
    Size = UDim2.fromOffset(600, 400),
    Icon = \"shield\",
    ConfigName = \"{config_name}\",
    AutoSave = true,
    AutoExec = true,
}})

-- ═══ Window Events ═══
window.event.PreOpened(function(event)
    event.message("Loading MonoUI...")
    task.wait(1.0)
    event.message("Configuring modules...")
    task.wait(0.8)
    event.done()
end)

window.event.Closed(function()
    print("Window closed!")
end)

-- ═══ Tabs ═══
local mainTab = window:CreateTab({{
    text = "Main",
    icon = "home",
}})

local settingsTab = window:CreateTab({{
    text = "Settings",
    icon = "settings",
}})

-- ═══ Sections ═══
mainTab:CreateSection({{
    text = "Core Features"
}})

-- ═══ Logger ═══
local logger = mainTab:CreateLogger({{
    text = "Console Output",
    height = 200,
}})

logger:Log("SUCCESS", "MonoUI initialized!")

-- ═══ Toggle ═══
mainTab:CreateToggle({{
    text = "Enable Feature",
    default = false,
    flag = "feature_toggle",
    callback = function(state)
        logger:Log("INFO", "Feature: " .. (state and "ON" or "OFF"))
    end,
}})

-- ═══ Slider ═══
mainTab:CreateSlider({{
    text = "Intensity",
    min = 0,
    max = 100,
    default = 50,
    flag = "intensity_slider",
    callback = function(value)
        logger:Log("INFO", "Intensity: " .. math.floor(value))
    end,
}})

-- ═══ Dropdown ═══
mainTab:CreateDropdown({{
    text = "Mode Select",
    list = {{"Option A", "Option B", "Option C"}},
    default = "Option A",
    multiple = false,
    flag = "mode_dropdown",
    callback = function(value)
        logger:Log("INFO", "Mode: " .. tostring(value))
    end,
}})

-- ═══ Button ═══
mainTab:CreateButton({{
    text = "Execute Action",
    callback = function()
        logger:Log("SUCCESS", "Action executed!")
        MonoUI.Notify({{
            title = "Success",
            content = "Action completed.",
            icon = "check-circle",
            duration = 3,
        }})
    end,
}})

-- ═══ Input ═══
mainTab:CreateInput({{
    text = "Custom Text",
    placeholder = "Type here...",
    default = "",
    flag = "custom_input",
    callback = function(value)
        logger:Log("INFO", "Input: " .. value)
    end,
}})

-- ═══ Color Picker ═══
settingsTab:CreateSection({{
    text = "Theme"
}})

settingsTab:CreateColorPicker({{
    text = "Accent Color",
    default = Color3.fromRGB(0, 162, 255),
    flag = "accent_color",
    callback = function(color)
        MonoUI.SetThemeColor("AccentColor", color)
        MonoUI.Notify({{
            title = "Theme Updated",
            content = "Accent color changed.",
            icon = "palette",
            duration = 2.5,
        }})
    end,
}})

-- ═══ Keybind ═══
local visibleState = true
settingsTab:CreateKeybind({{
    text = "Toggle Menu",
    default = Enum.KeyCode.RightControl,
    flag = "menu_keybind",
    callback = function(key)
        visibleState = not visibleState
        window:SetVisible(visibleState)
        logger:Log("WARNING", "Toggled via: " .. key.Name)
    end,
}})

-- ═══ Control HUD ═══
MonoUI.CreateControlHUD({{
    {{ icon = "swords", default = false, callback = function(active) print("Combat:", active) end }},
    {{ icon = "eye",     default = true,  callback = function(active) print("ESP:", active) end }},
    {{ icon = "gauge",   default = false, callback = function(active) print("Speed:", active) end }},
}})

logger:Log("SUCCESS", "Example script fully loaded!")
print("✅ MonoUI Example ready!")
"""


# ──────────────────────────────────────────────
# MCP Server
# ──────────────────────────────────────────────

server = Server("mono-ui-mcp")


@server.list_tools()
async def list_tools():
    return [
        Tool(
            name="get-loadstring",
            description="Get the loadstring code to load the MonoUI library in Roblox. Returns the full snippet including SetWatermark setup.",
            inputSchema={
                "type": "object",
                "properties": {},
                "required": [],
            },
        ),
        Tool(
            name="generate-window",
            description="Generate Luau code to create a MonoUI window with event hooks.",
            inputSchema={
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
                },
                "required": ["title"],
            },
        ),
        Tool(
            name="generate-tab",
            description="Generate Luau code to create a tab inside a window.",
            inputSchema={
                "type": "object",
                "properties": {
                    "tab_var": {"type": "string", "description": "Variable name for the tab (e.g. 'mainTab')."},
                    "window_var": {"type": "string", "description": "Variable name of the window (e.g. 'window').", "default": "window"},
                    "text": {"type": "string", "description": "Tab display text."},
                    "icon": {"type": "string", "description": "Lucide icon name.", "default": ""},
                },
                "required": ["tab_var", "text"],
            },
        ),
        Tool(
            name="generate-component",
            description="Generate Luau code to create a UI component (Button, Toggle, Input, Dropdown, Slider, ColorPicker, Keybind, Logger, PlayerList, TargetBody, Section) inside a tab.",
            inputSchema={
                "type": "object",
                "properties": {
                    "tab_var": {"type": "string", "description": "Variable name of the tab (e.g. 'mainTab').", "default": "tab"},
                    "comp_type": {"type": "string", "description": "Component type: Button, Toggle, Input, Dropdown, Slider, ColorPicker, Keybind, Logger, PlayerList, TargetBody, Section."},
                    "var_name": {"type": "string", "description": "Variable name to assign result to (e.g. 'myLogger' for Logger)."},
                    "text": {"type": "string", "description": "Label/display text for the component."},
                    "placeholder": {"type": "string", "description": "(Input only) Placeholder text."},
                    "default": {"type": "string", "description": "Default value (boolean, number, string, Color3)."},
                    "min": {"type": "number", "description": "(Slider only) Minimum value."},
                    "max": {"type": "number", "description": "(Slider only) Maximum value."},
                    "list": {"type": "string", "description": "(Dropdown only) Comma-separated option strings."},
                    "multiple": {"type": "boolean", "description": "(Dropdown/TargetBody) Allow multiple selections."},
                    "height": {"type": "number", "description": "(Logger/PlayerList) Height in pixels."},
                    "disabledParts": {"type": "string", "description": "(TargetBody only) Comma-separated parts to disable."},
                    "flag": {"type": "string", "description": "Config save/load key for auto-save."},
                    "callback": {"type": "string", "description": "Luau callback code (e.g. 'function(value) print(value) end')."},
                },
                "required": ["comp_type"],
            },
        ),
        Tool(
            name="generate-notification",
            description="Generate Luau code for a MonoUI sliding notification toast.",
            inputSchema={
                "type": "object",
                "properties": {
                    "title": {"type": "string", "description": "Notification title."},
                    "content": {"type": "string", "description": "Notification body text."},
                    "icon": {"type": "string", "description": "Lucide icon name.", "default": "check-circle"},
                    "duration": {"type": "integer", "description": "Display duration in seconds.", "default": 5},
                },
                "required": ["title", "content"],
            },
        ),
        Tool(
            name="generate-control-hud",
            description="Generate Luau code for a ControlHUD quick-toggle bar with Lucide icons.",
            inputSchema={
                "type": "object",
                "properties": {
                    "buttons": {"type": "string", "description": "JSON array of buttons, each with: icon (string), default (boolean). Example: [{\"icon\":\"swords\",\"default\":false},{\"icon\":\"eye\",\"default\":true}]"},
                },
                "required": ["buttons"],
            },
        ),
        Tool(
            name="list-components",
            description="List all available MonoUI components with brief descriptions.",
            inputSchema={
                "type": "object",
                "properties": {},
                "required": [],
            },
        ),
        Tool(
            name="get-component-docs",
            description="Get detailed documentation for a specific MonoUI component, including all parameters and methods.",
            inputSchema={
                "type": "object",
                "properties": {
                    "component": {"type": "string", "description": "Component name: Button, Toggle, Input, Dropdown, Slider, ColorPicker, Keybind, Logger, PlayerList, TargetBody, Section."},
                },
                "required": ["component"],
            },
        ),
        Tool(
            name="generate-full-example",
            description="Generate a complete, runnable MonoUI example script with window, tabs, multiple components, notifications, and control HUD.",
            inputSchema={
                "type": "object",
                "properties": {
                    "title": {"type": "string", "description": "Title/name for the example script.", "default": "Mono UI"},
                },
                "required": [],
            },
        ),
        Tool(
            name="list-icons",
            description="List available Lucide icon names that can be used with MonoUI.",
            inputSchema={
                "type": "object",
                "properties": {},
                "required": [],
            },
        ),
    ]


@server.call_tool()
async def call_tool(name: str, arguments: dict):
    if name == "get-loadstring":
        result = generate_loadstring()

    elif name == "generate-window":
        result = generate_window(
            title=arguments.get("title", "Mono UI"),
            subtitle=arguments.get("subtitle", ""),
            icon=arguments.get("icon", "shield"),
            width=arguments.get("width", 600),
            height=arguments.get("height", 400),
            config_name=arguments.get("config_name", "mono_config"),
            auto_save=arguments.get("auto_save", True),
            auto_exec=arguments.get("auto_exec", True),
        )

    elif name == "generate-tab":
        result = generate_tab(
            tab_var=arguments.get("tab_var", "tab"),
            window_var=arguments.get("window_var", "window"),
            text=arguments.get("text", "New Tab"),
            icon=arguments.get("icon", ""),
        )

    elif name == "generate-component":
        comp_type = arguments.get("comp_type", "Button")
        tab_var = arguments.get("tab_var", "tab")
        var_name = arguments.get("var_name")
        text = arguments.get("text")

        kwargs = {}
        if text:
            kwargs["text"] = f'"{text}"'

        if comp_type == "Input" and "placeholder" in arguments:
            kwargs["placeholder"] = f'"{arguments["placeholder"]}"'

        if "default" in arguments:
            kwargs["default"] = arguments["default"]

        if comp_type == "Slider":
            if "min" in arguments:
                kwargs["min"] = arguments["min"]
            if "max" in arguments:
                kwargs["max"] = arguments["max"]

        if comp_type == "Dropdown" and "list" in arguments:
            raw_list = arguments["list"]
            if isinstance(raw_list, str):
                items = [f'"{x.strip()}"' for x in raw_list.split(",")]
                kwargs["list"] = "{" + ", ".join(items) + "}"

        if "multiple" in arguments:
            kwargs["multiple"] = arguments["multiple"]

        if "height" in arguments:
            kwargs["height"] = arguments["height"]

        if comp_type == "TargetBody" and "disabledParts" in arguments:
            raw_parts = arguments["disabledParts"]
            if isinstance(raw_parts, str):
                parts = [f'"{x.strip()}"' for x in raw_parts.split(",")]
                kwargs["disabledParts"] = "{" + ", ".join(parts) + "}"

        if "flag" in arguments:
            kwargs["flag"] = f'"{arguments["flag"]}"'

        if "callback" in arguments:
            kwargs["callback"] = arguments["callback"]

        if var_name:
            result = generate_component_with_callback(
                tab_var=tab_var, comp_type=comp_type,
                var_name=var_name, **kwargs
            )
        else:
            result = generate_component(tab_var=tab_var, comp_type=comp_type, **kwargs)

    elif name == "generate-notification":
        result = generate_notification(
            title=arguments.get("title", "Notification"),
            content=arguments.get("content", ""),
            icon=arguments.get("icon", "check-circle"),
            duration=arguments.get("duration", 5),
        )

    elif name == "generate-control-hud":
        buttons_str = arguments.get("buttons", "[]")
        try:
            buttons = json.loads(buttons_str)
        except json.JSONDecodeError:
            buttons = []
        result = generate_control_hud(buttons)

    elif name == "list-components":
        lines = ["# MonoUI Components", ""]
        for cname, cinfo in COMPONENT_DOCS.items():
            lines.append(f"### {cname}")
            lines.append(f"**{cinfo['description']}**")
            lines.append("")
            lines.append("| Parameter | Type | Default | Description |")
            lines.append("|-----------|------|---------|-------------|")
            for p in cinfo["params"]:
                lines.append(f"| `{p['name']}` | `{p['type']}` | `{p['default']}` | {p['desc']} |")
            if "methods" in cinfo:
                lines.append("")
                lines.append("**Methods:**")
                for m in cinfo["methods"]:
                    lines.append(f"- `:{m['name']}({m['params']})` — {m['desc']}")
            lines.append("")
        result = "\n".join(lines)

    elif name == "get-component-docs":
        comp = arguments.get("component", "")
        if comp in COMPONENT_DOCS:
            cinfo = COMPONENT_DOCS[comp]
            lines = [f"# {comp}", "", f"**{cinfo['description']}**", ""]
            lines.append("## Parameters")
            lines.append("")
            lines.append("| Parameter | Type | Default | Description |")
            lines.append("|-----------|------|---------|-------------|")
            for p in cinfo["params"]:
                lines.append(f"| `{p['name']}` | `{p['type']}` | `{p['default']}` | {p['desc']} |")
            if "methods" in cinfo:
                lines.append("")
                lines.append("## Methods")
                for m in cinfo["methods"]:
                    lines.append(f"- `:{m['name']}({m['params']})` — {m['desc']}")
            lines.append("")
            lines.append("## Code Example")
            lines.append("```lua")
            lines.append(generate_component_with_callback(
                tab_var="tab", comp_type=comp,
                var_name=f"my{comp}",
                text=f'"My {comp}"',
                callback="function(value)\n\t\tprint(value)\n\tend" if comp != "Button" else "function()\n\t\tprint(\"clicked!\")\n\tend",
            ))
            lines.append("```")
            result = "\n".join(lines)
        else:
            available = ", ".join(COMPONENT_DOCS.keys())
            result = f"Component '{comp}' not found. Available: {available}"

    elif name == "generate-full-example":
        title = arguments.get("title", "Mono UI")
        result = generate_full_example(title)

    elif name == "list-icons":
        lines = ["# Available Lucide Icons", ""]
        lines.append("These icons can be used with windows, tabs, notifications, and the ControlHUD:")
        lines.append("")
        per_row = 6
        for i in range(0, len(AVAILABLE_ICONS), per_row):
            row = AVAILABLE_ICONS[i:i + per_row]
            lines.append("| " + " | ".join(f"`{icon}`" for icon in row) + " |")
        result = "\n".join(lines)

    else:
        result = f"Unknown tool: {name}"

    return [TextContent(type="text", text=result)]


async def main():
    async with stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream, server.create_initialization_options())


if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
