# Vanity ESP

> Modular ESP module Box, Name, Health Bar, Highlight/Cham, Visibility Colors.

## Quick Start
```lua
local Vanity = loadstring(game:HttpGet("https://github.com/BloodLetters/mono-ui/releases/latest/download/Vanity.luau"))()

-- Create ESP with desired features
local esp = Vanity.new({
    BoxEnabled = true,
    NameEnabled = true,
    HealthEnabled = true,
    HighlightEnabled = false,
    VisibilityColor = false,
    MaxDistance = 1000,
})

-- ESP runs automatically every RenderStepped
```

## API

### `Vanity.new(options)`

Creates and starts the ESP system. Accepts an optional options table.

| Option | Type | Default | Description |
|---|---|---|---|
| `BoxEnabled` | boolean | `false` | 2D box around players |
| `NameEnabled` | boolean | `false` | Player name + distance above box |
| `HealthEnabled` | boolean | `false` | Health bar on left side of box |
| `HighlightEnabled` | boolean | `false` | 3D highlight/cham on character |
| `MaxDistance` | number | `1000` | Max render distance (studs) |
| `VisibilityColor` | boolean | `false` | Green if visible, yellow if behind wall |
| `BoxColor` | Color3 | `(160,160,160)` | Box outline color |
| `BoxOutlineColor` | Color3 | `(60,60,60)` | Box outer outline color |
| `NameColor` | Color3 | `(255,255,255)` | Name text color |
| `NameSize` | number | `13` | Name text size |
| `HighlightColor` | Color3 | `(0,162,255)` | Highlight fill color |
| `VisibleColor` | Color3 | `(255,230,0)` | Highlight color when player is visible |
| `RootPart` | string/function | `"HumanoidRootPart"` | Part name or `function(char) => BasePart` for box anchor |
| `HeadPart` | string/function | `"Head"` | Part name or `function(char) => BasePart` for visibility raycast |
| `HealthClass` | string | `"Humanoid"` | Class name for health read (e.g. `"Humanoid"`, `"NpcHealth"`) |
| `BoxTopOffset` | Vector3 | `(0, 3, 0)` | Offset from RootPart for top of box |
| `BoxBottomOffset` | Vector3 | `(0, -3.5, 0)` | Offset from RootPart for bottom of box |
| `IsValid` | function | `nil` | Custom validity: `function(char) => bool` (overrides default alive check) |

### `esp:UpdateOptions(options)`

Update settings at runtime — ideal for GUI toggles/sliders.

```lua
-- Toggle box ESP off, highlight on
esp:UpdateOptions({
    BoxEnabled = false,
    HighlightEnabled = true,
    MaxDistance = 500,
})
```

Only pass the keys you want to change — the rest stay as-is.

### Custom Player Models (non-standard R6/R15)
```lua
local esp = Vanity.new({
    BoxEnabled = true,
    NameEnabled = true,

    -- Custom part lookup (string or function)
    RootPart = "Torso",               -- game pakai "Torso" bukan "HumanoidRootPart"
    HeadPart = function(char)         -- atau pakai function untuk lookup complex
        return char:FindFirstChild("Cabeza")
            or char:FindFirstChild("Head")
    end,

    -- Custom health class
    HealthClass = "MonsterHealth",

    -- Custom box size (game punya model double-size)
    BoxTopOffset = Vector3.new(0, 6, 0),
    BoxBottomOffset = Vector3.new(0, -7, 0),

    -- Custom validity check (game tidak pakai Humanoid sama sekali)
    IsValid = function(char)
        local tag = char:FindFirstChild("NPC_Tag")
        return tag ~= nil and tag.Value == true
    end,
})
```

### `esp:Destroy()`

Full cleanup: disconnects all events, removes all Drawing objects and Highlights, stops the render loop. Call this when unloading your script.

```lua
esp:Destroy()
```

## Integration with MonoUI (example)

```lua
local Vanity = require(path.to.modules.Vanity)
local esp = Vanity.new()

-- In your GUI tab:
tab:CreateToggle({
    text = "Box ESP",
    default = false,
    callback = function(state)
        esp:UpdateOptions({ BoxEnabled = state })
    end
})

tab:CreateToggle({
    text = "Name ESP",
    default = false,
    callback = function(state)
        esp:UpdateOptions({ NameEnabled = state })
    end
})

tab:CreateToggle({
    text = "Health ESP",
    default = false,
    callback = function(state)
        esp:UpdateOptions({ HealthEnabled = state })
    end
})

tab:CreateToggle({
    text = "Cham Highlight",
    default = false,
    callback = function(state)
        esp:UpdateOptions({ HighlightEnabled = state })
    end
})

tab:CreateToggle({
    text = "Visibility Colors",
    default = false,
    callback = function(state)
        esp:UpdateOptions({ VisibilityColor = state })
    end
})

tab:CreateSlider({
    text = "Max ESP Distance",
    min = 100,
    max = 5000,
    default = 1000,
    suffix = " studs",
    callback = function(value)
        esp:UpdateOptions({ MaxDistance = value })
    end
})
```

## Global Cleanup

If you use `getgenv()` for script-wide cleanup:
```lua
getgenv().VanityCleanUp = function()
    esp:Destroy()
end
```

## License
MIT - Part of the [MonoUI](https://github.com/BloodLetters/mono-ui) ecosystem.
