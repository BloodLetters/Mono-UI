# Lead — Flexible Combat Module for MonoUI

**Lead** (`ashesh/lead`) is a combat module. Supports **aimbot**, **trigger bot**, and **silent aim** — designed to be flexible for custom character models, custom health classes, and custom weapon systems.

## Quick Start

```lua
local Lead = loadstring(game:HttpGet(
    "https://github.com/BloodLetters/mono-ui/releases/latest/download/Lead.luau"
))()

local lead = Lead.new({
    AimEnabled = true,
    AimKey = Enum.UserInputType.MouseButton2,
    TargetPart = "Head",
    FovRadius = 120,
    Smoothness = 2.5,
    WallCheck = true,
    StickyTarget = true,

    TriggerEnabled = true,
    TriggerFovRadius = 30,
    Delay = 80,
})

lead:Start()

-- Update via MonoUI toggles
visualsTab:CreateToggle({
    text = "Aimbot",
    callback = function(state)
        lead:UpdateOptions({ AimEnabled = state })
    end
})
```

## Flexibility Features

### Custom Character Models

All part lookups, health checks, and validation support **function callbacks**:

| Option | Default | Description |
|---|---|---|
| `TargetPart` | `"Head"` | `string` or `function(character) => BasePart` |
| `HealthClass` | `"Humanoid"` | Class name custom health system |
| `IsTargetValid` | `nil` | `function(player, character) => bool` |
| `PredictionFn` | `nil` | `function(character, targetPart, localChar) => Vector3` |
| `FovMethod` | `nil` | `function(camPos, partPos, screenCenter, screenPos, fovRadius) => bool` |
| `AimMethod` | `"Camera"` | `"Camera"`, `"Mouse"`, or `function(camera, predictedPos, aimCFrame)` |
| `TargetOffset` | `nil` | `Vector3` static or `function(dt, predictedPos, targetPart) => Vector3` |
| `AimKey` | `MouseButton2` | `EnumItem`, `"always"`, or `function() => bool` |
| `SilentAimHook` | `nil` | `function(worldPosition)` — redirect bullet |
| `Fire` | `nil` | `function()` — custom fire (e.g. remotes) |
| `BeforeFire` | `nil` | `function(player, character, targetPart) => bool` |
| `AfterFire` | `nil` | `function(player, character, targetPart)` |
| `TriggerKey` | `nil` | `nil`, `EnumItem`, or `function() => bool` |

### Example: Custom NPC / Monster

```lua
lead:UpdateOptions({
    TargetPart = function(character)
        -- Custom model: target part is named "Chest" instead of "Head"
        return character:FindFirstChild("Chest") or character:FindFirstChild("Head")
    end,
    HealthClass = "MonsterHealth",
    IsTargetValid = function(player, character)
        return character:FindFirstChild("IsNPC") ~= nil
    end,
    PredictionFn = function(character, targetPart, localChar)
        -- NPCs don't have velocity, predict based on LookVector
        local root = character:FindFirstChild("HumanoidRootPart")
        return targetPart.Position + (root and root.CFrame.LookVector * 4 or Vector3.zero)
    end,
})
```

### Example: Silent Aim

```lua
lead:UpdateOptions({
    SilentAim = true,
    AimKey = "always",  -- always active
    SilentAimHook = function(worldPos)
        -- Your weapon's fire to use this world position
        -- e.g. remote:FireServer(worldPos)
    end,
})

-- Get position externally
local silentPos = lead:GetSilentAimPosition()
```

### Example: Custom Fire (Remote weapons)

```lua
lead:UpdateOptions({
    TriggerEnabled = true,
    Fire = function()
        -- Fire via game remote instead of mouse1click()
        local args = { [1] = "FireBullet" }
        game:GetService("ReplicatedStorage").WeaponRemote:FireServer(unpack(args))
    end,
})
```

## API Reference

### `Lead.new(options?) → Lead`

Creates a combat instance. All options are optional, defaults are in `DEFAULT_OPTIONS`.

### `Lead:Start()`

Starts the aimbot and trigger bot loops (RenderStepped).

### `Lead:Stop()`

Stops all loops.

### `Lead:UpdateOptions(newOptions)`

Partial update — only pass the keys you want to change.

### `Lead:GetSilentAimPosition() → Vector3?`

Returns current silent aim world position.

### `Lead:Destroy()`

Full cleanup — disconnects all events, stops loops.

## Default Options

| Option | Default | Type |
|---|---|---|
| `AimEnabled` | `false` | `boolean` |
| `AimKey` | `MouseButton2` | `EnumItem` / `"always"` / `function` |
| `AimMethod` | `"Camera"` | `"Camera"` / `"Mouse"` / `function` |
| `TargetPart` | `"Head"` | `string` / `function` |
| `HealthClass` | `"Humanoid"` | `string` |
| `IsTargetValid` | `nil` | `function` / `nil` |
| `FovRadius` | `150` | `number` |
| `FovMethod` | `nil` | `function` / `nil` |
| `Smoothness` | `1` | `number` |
| `StickyTarget` | `false` | `boolean` |
| `WallCheck` | `false` | `boolean` |
| `WallCheckIgnoreList` | `nil` | `table` |
| `MaxDistance` | `nil` | `number` / `nil` |
| `PredictionFn` | `nil` | `function` / `nil` |
| `TargetOffset` | `nil` | `Vector3` / `function` / `nil` |
| `SilentAim` | `false` | `boolean` |
| `SilentAimHook` | `nil` | `function` / `nil` |
| `TriggerEnabled` | `false` | `boolean` |
| `TriggerKey` | `nil` | `nil` / `EnumItem` / `function` |
| `TriggerTargetPart` | `nil` | `string` / `function` / `nil` |
| `TriggerFovRadius` | `50` | `number` |
| `TriggerMaxDistance` | `1000` | `number` |
| `TriggerWallCheck` | `false` | `boolean` |
| `Delay` | `50` | `number` (ms) |
| `Fire` | `nil` | `function` / `nil` |
| `BeforeFire` | `nil` | `function` / `nil` |
| `AfterFire` | `nil` | `function` / `nil` |

## License
MIT - Part of the [MonoUI](https://github.com/BloodLetters/mono-ui) ecosystem.
