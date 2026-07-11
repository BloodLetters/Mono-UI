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

# COMPONENT_DOCS_START
COMPONENT_DOCS = {
    'Button': {
        'description': 'An interactive button that runs a custom function when clicked.',
        'params': [
            {
                'default': 'nil',
                'desc': 'Fires when the button is clicked.',
                'name': 'callback',
                'type': 'function',
            },
            {
                'default': '"Button"',
                'desc': 'Text displayed on the button.',
                'name': 'text',
                'type': 'string',
            },
        ],
    },
    'ColorPicker': {
        'description': 'An advanced RGB/HSV color picker that supports hex input and saturation/brightness visual adjustments.',
        'params': [
            {
                'default': 'nil',
                'desc': 'Fires with the selected Color3 object.',
                'name': 'callback',
                'type': 'function',
            },
            {
                'default': 'Color3.fromRGB(100,100,110)',
                'desc': 'Initial Color3 value.',
                'name': 'default',
                'type': 'Color3',
            },
            {
                'default': 'nil',
                'desc': 'Unique key for config saving.',
                'name': 'flag',
                'type': 'string',
            },
            {
                'default': '"Color"',
                'desc': 'Label for the color picker.',
                'name': 'text',
                'type': 'string',
            },
        ],
    },
    'CreateSection': {
        'description': 'Inserts a visual section divider with a label to group related components.',
        'params': [
            {
                'default': 'nil',
                'desc': 'Section heading label.',
                'name': 'text',
                'type': 'string',
            },
        ],
    },
    'Dropdown': {
        'description': 'A selection menu for single or multi-value selections. Supports search filtering inside dropdown items.',
        'params': [
            {
                'default': 'nil',
                'desc': 'Fires with a table of selected options.',
                'name': 'callback',
                'type': 'function',
            },
            {
                'default': 'nil',
                'desc': 'Pre-selected option(s).',
                'name': 'default',
                'type': 'string | table',
            },
            {
                'default': 'nil',
                'desc': 'Unique key for config saving.',
                'name': 'flag',
                'type': 'string',
            },
            {
                'default': '{}',
                'desc': 'Array of string options to display.',
                'name': 'list',
                'type': 'table',
            },
            {
                'default': 'false',
                'desc': 'Allows selecting multiple items concurrently.',
                'name': 'multiple',
                'type': 'boolean',
            },
            {
                'default': '"Dropdown"',
                'desc': 'Label for the dropdown dropdown.',
                'name': 'text',
                'type': 'string',
            },
        ],
    },
    'Input': {
        'description': 'A single-line text input field for strings and custom configs.',
        'params': [
            {
                'default': 'nil',
                'desc': 'Fires with the updated text value.',
                'name': 'callback',
                'type': 'function',
            },
            {
                'default': '""',
                'desc': 'Initial text value.',
                'name': 'default',
                'type': 'string',
            },
            {
                'default': 'nil',
                'desc': 'Unique key for config saving.',
                'name': 'flag',
                'type': 'string',
            },
            {
                'default': '"type here..."',
                'desc': 'Ghost text shown when the input is empty.',
                'name': 'placeholder',
                'type': 'string',
            },
            {
                'default': '"Input"',
                'desc': 'Label of the input field.',
                'name': 'text',
                'type': 'string',
            },
        ],
    },
    'Keybind': {
        'description': 'Allows the user to bind a keybind shortcut to toggle/trigger functions. Click to rebind, press Escape to unbind.',
        'params': [
            {
                'default': 'nil',
                'desc': 'Fires with the new KeyCode when bound/triggered.',
                'name': 'callback',
                'type': 'function',
            },
            {
                'default': 'Enum.KeyCode.None',
                'desc': 'Initial bound KeyCode.',
                'name': 'default',
                'type': 'Enum.KeyCode',
            },
            {
                'default': 'nil',
                'desc': 'Unique key for config saving.',
                'name': 'flag',
                'type': 'string',
            },
            {
                'default': '"Keybind"',
                'desc': 'Label for the keybind.',
                'name': 'text',
                'type': 'string',
            },
        ],
    },
    'Logger': {
        'description': 'An in-app console widget that displays color-coded activity logs. Supports INFO, SUCCESS, WARNING, and ERROR levels.',
        'methods': [
            {
                'desc': 'Append a log entry.',
                'name': 'Log',
                'params': 'level: string (INFO|WARNING|SUCCESS|ERROR), message: string',
            },
        ],
        'params': [
            {
                'default': '180',
                'desc': 'Pixel height of the log area.',
                'name': 'height',
                'type': 'number',
            },
            {
                'default': '"Console Logs"',
                'desc': 'Console panel header label.',
                'name': 'text',
                'type': 'string',
            },
        ],
    },
    'PlayerList': {
        'description': 'Renders a scrolling player list widget showing active players on the server. Includes search bar.',
        'params': [
            {
                'default': '200',
                'desc': 'Pixel height of the scroll area.',
                'name': 'height',
                'type': 'number',
            },
            {
                'default': '"Player List"',
                'desc': 'Header title of the list widget.',
                'name': 'text',
                'type': 'string',
            },
        ],
    },
    'Slider': {
        'description': 'A draggable range input with min/max bounds and optional decimal precision.',
        'params': [
            {
                'default': 'nil',
                'desc': 'Fires with the current numeric value.',
                'name': 'callback',
                'type': 'function',
            },
            {
                'default': 'min',
                'desc': 'Initial value.',
                'name': 'default',
                'type': 'number',
            },
            {
                'default': 'nil',
                'desc': 'Unique key for config saving.',
                'name': 'flag',
                'type': 'string',
            },
            {
                'default': 'nil',
                'desc': 'Maximum value of the range.',
                'name': 'max',
                'type': 'number',
            },
            {
                'default': 'nil',
                'desc': 'Minimum value of the range.',
                'name': 'min',
                'type': 'number',
            },
            {
                'default': '"Slider"',
                'desc': 'Label for the slider row.',
                'name': 'text',
                'type': 'string',
            },
        ],
    },
    'TargetBody': {
        'description': 'A body hitbox selector showing a visual representation of a character body. Perfect for selective aimbot hitboxes.',
        'params': [
            {
                'default': 'nil',
                'desc': 'Fires with a table of currently active body parts.',
                'name': 'callback',
                'type': 'function',
            },
            {
                'default': 'nil',
                'desc': "Initially selected body part(s) (e.g. 'Head' or {'Head', 'Torso'}).",
                'name': 'default',
                'type': 'string | table',
            },
            {
                'default': '{}',
                'desc': "List of parts that cannot be selected (e.g. {'LeftArm', 'RightArm'}).",
                'name': 'disabledParts',
                'type': 'table',
            },
            {
                'default': 'nil',
                'desc': 'Unique key for config saving.',
                'name': 'flag',
                'type': 'string',
            },
            {
                'default': 'true',
                'desc': 'Allows selecting multiple body parts.',
                'name': 'multiple',
                'type': 'boolean',
            },
            {
                'default': '"Target Body Parts"',
                'desc': 'Label for the hitbox selector.',
                'name': 'text',
                'type': 'string',
            },
        ],
    },
    'Toggle': {
        'description': 'A checkbox-style switch for boolean values. State is persisted to config when a flag is provided.',
        'params': [
            {
                'default': 'nil',
                'desc': 'Fires with the new boolean state.',
                'name': 'callback',
                'type': 'function',
            },
            {
                'default': 'false',
                'desc': 'Initial state (true/false).',
                'name': 'default',
                'type': 'boolean',
            },
            {
                'default': 'nil',
                'desc': 'Unique key for config saving.',
                'name': 'flag',
                'type': 'string',
            },
            {
                'default': '"Toggle"',
                'desc': 'Label for the toggle.',
                'name': 'text',
                'type': 'string',
            },
        ],
    },
}
# COMPONENT_DOCS_END

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


def generate_loadstring(watermark: bool = False) -> str:
    """Generate the loadstring snippet to load MonoUI."""
    code = f"""-- Load MonoUI Library
local MonoUI = {LOADSTRING_URL}
"""
    if watermark:
        code += """
-- Set watermark
MonoUI.SetWatermark({
    visible = true,
    text = "MonoUI Premium",
})
"""
    return code


def generate_window(title: str, subtitle: str = "", icon: str = "shield",
                    width: int = 600, height: int = 400,
                    config_name: str = "mono_config", auto_save: bool = True,
                    auto_exec: bool = True, include_event_hooks: bool = False) -> str:
    """Generate a window creation snippet."""
    code = f"""local window = MonoUI.CreateWindow({{
    Title = \"{title}\",
    Subtitle = \"{subtitle}\",
    Size = UDim2.fromOffset({width}, {height}),
    Icon = \"{icon}\",
    ConfigName = \"{config_name}\",
    AutoSave = {_luau_value(auto_save)},
    AutoExec = {_luau_value(auto_exec)},
}})
"""
    if include_event_hooks:
        code += """
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
    return code


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


def generate_full_example(title: str = "Mono UI", config_name: str = "mono_config",
                          include_watermark: bool = False,
                          include_notifications: bool = False,
                          include_control_hud: bool = False,
                          include_logger: bool = False,
                          include_event_hooks: bool = False) -> str:
    """Generate a complete MonoUI example script."""
    watermark_section = ""
    if include_watermark:
        watermark_section = f"""

-- ═══ Watermark ═══
MonoUI.SetWatermark({{
    visible = true,
    text = "{title}",
}})"""

    notification_section = ""
    if include_notifications:
        notification_section = f"""

-- ═══ Notifications ═══
MonoUI.Notify({{
    title = "{title} Loaded",
    content = "All modules initialized successfully.",
    icon = "check-circle",
    duration = 5,
}})"""

    event_hooks_section = ""
    if include_event_hooks:
        event_hooks_section = """
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
"""

    logger_setup = ""
    logger_log = ""
    if include_logger:
        logger_setup = """

-- ═══ Logger ═══
local logger = mainTab:CreateLogger({
    text = "Console Output",
    height = 200,
})

logger:Log("SUCCESS", "MonoUI initialized!")"""
        logger_log = 'logger:Log("INFO", "Feature: " .. (state and "ON" or "OFF"))'
    else:
        logger_log = 'print("Feature: " .. (state and "ON" or "OFF"))'

    # Slider callback
    slider_callback = 'logger:Log("INFO", "Intensity: " .. math.floor(value))' if include_logger else 'print("Intensity: " .. math.floor(value))'
    # Dropdown callback
    dropdown_callback = 'logger:Log("INFO", "Mode: " .. tostring(value))' if include_logger else 'print("Mode: " .. tostring(value))'
    # Button callback
    button_callback = 'logger:Log("SUCCESS", "Action executed!")\n\t\t' if include_logger else 'print("Action executed!")\n\t\t'
    if include_notifications:
        button_callback += """MonoUI.Notify({
            title = "Success",
            content = "Action completed.",
            icon = "check-circle",
            duration = 3,
        })"""
    else:
        button_callback += '-- Put your action code here'

    # Input callback
    input_callback = 'logger:Log("INFO", "Input: " .. value)' if include_logger else 'print("Input: " .. value)'

    # Theme picker callback
    theme_callback = """MonoUI.SetThemeColor("AccentColor", color)"""
    if include_notifications:
        theme_callback += """\n\t\tMonoUI.Notify({
            title = "Theme Updated",
            content = "Accent color changed.",
            icon = "palette",
            duration = 2.5,
        })"""

    # Keybind callback
    keybind_callback = 'logger:Log("WARNING", "Toggled via: " .. key.Name)' if include_logger else 'print("Toggled via: " .. key.Name)'

    control_hud_section = ""
    if include_control_hud:
        control_hud_section = """

-- ═══ Control HUD ═══
MonoUI.CreateControlHUD({
    { icon = "swords", default = false, callback = function(active) print("Combat:", active) end },
    { icon = "eye",     default = true,  callback = function(active) print("ESP:", active) end },
    { icon = "gauge",   default = false, callback = function(active) print("Speed:", active) end },
})"""

    return f"""-- ╔══════════════════════════════════════════╗
-- ║     MonoUI - Complete Example Script    ║
-- ╚══════════════════════════════════════════╝

local MonoUI = {LOADSTRING_URL}{watermark_section}{notification_section}

-- ═══ Window ═══
local window = MonoUI.CreateWindow({{
    Title = "{title.lower()}",
    Subtitle = "premium modular library",
    Size = UDim2.fromOffset(600, 400),
    Icon = "shield",
    ConfigName = "{config_name}",
    AutoSave = true,
    AutoExec = true,
}}){event_hooks_section}
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
}}){logger_setup}

-- ═══ Toggle ═══
mainTab:CreateToggle({{
    text = "Enable Feature",
    default = false,
    flag = "feature_toggle",
    callback = function(state)
        {logger_log}
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
        {slider_callback}
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
        {dropdown_callback}
    end,
}})

-- ═══ Button ═══
mainTab:CreateButton({{
    text = "Execute Action",
    callback = function()
        {button_callback}
    end,
}})

-- ═══ Input ═══
mainTab:CreateInput({{
    text = "Custom Text",
    placeholder = "Type here...",
    default = "",
    flag = "custom_input",
    callback = function(value)
        {input_callback}
    end,
}})

settingsTab:CreateSection({{
    text = "Theme"
}})

-- ═══ Color Picker ═══
settingsTab:CreateColorPicker({{
    text = "Accent Color",
    default = Color3.fromRGB(0, 162, 255),
    flag = "accent_color",
    callback = function(color)
        {theme_callback}
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
        {keybind_callback}
    end,
}}){control_hud_section}

-- ═══ Cleanup Examples (Loops & Connections) ═══
-- Use window:AddCleanup to automatically stop loops and disconnect events when GUI closes

-- Safe background loop using MonoUI's built-in Timer (sleitnick/timer)
local myTimer = MonoUI.CreateTimer(1)
myTimer.Tick:Connect(function()
    -- Your background loop logic here (runs every 1 second)
end)
window:AddCleanup(myTimer)
myTimer:Start()

local myConnection = game.Players.PlayerAdded:Connect(function(player)
    -- Your event handler logic here
end)
window:AddCleanup(myConnection)
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
            description="Get the loadstring code to load the MonoUI library in Roblox. Optionally includes the watermark setup.",
            inputSchema={
                "type": "object",
                "properties": {
                    "watermark": {
                        "type": "boolean",
                        "description": "Whether to include the watermark initialization snippet.",
                        "default": False
                    }
                },
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
                    "include_event_hooks": {"type": "boolean", "description": "Whether to include window lifecycle event hooks (PreOpened, Closed, Minimized).", "default": False},
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
            description="Generate a complete, runnable MonoUI example script with window, tabs, and optional sections like watermark, notifications, control HUD, and logger.",
            inputSchema={
                "type": "object",
                "properties": {
                    "title": {"type": "string", "description": "Title/name for the example script.", "default": "Mono UI"},
                    "config_name": {"type": "string", "description": "Config file name.", "default": "mono_config"},
                    "include_watermark": {"type": "boolean", "description": "Include SetWatermark initialization.", "default": False},
                    "include_notifications": {"type": "boolean", "description": "Include load notification.", "default": False},
                    "include_control_hud": {"type": "boolean", "description": "Include ControlHUD setup.", "default": False},
                    "include_logger": {"type": "boolean", "description": "Include Logger widget and callback logs.", "default": False},
                    "include_event_hooks": {"type": "boolean", "description": "Include window event hooks (PreOpened, etc.).", "default": False},
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
        result = generate_loadstring(
            watermark=arguments.get("watermark", False)
        )

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
            include_event_hooks=arguments.get("include_event_hooks", False),
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
        result = generate_full_example(
            title=title,
            config_name=arguments.get("config_name", "mono_config"),
            include_watermark=arguments.get("include_watermark", False),
            include_notifications=arguments.get("include_notifications", False),
            include_control_hud=arguments.get("include_control_hud", False),
            include_logger=arguments.get("include_logger", False),
            include_event_hooks=arguments.get("include_event_hooks", False),
        )

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
