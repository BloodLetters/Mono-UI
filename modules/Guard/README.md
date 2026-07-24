# Guard Key System

> Modular, executor-compatible Key System with a premium, dark-themed, Mono-styled GUI.

## Quick Start
```lua
local Guard = loadstring(game:HttpGet("https://github.com/BloodLetters/mono-ui/releases/latest/download/Guard.luau"))()

local guard = Guard.new({
    ConfigName = "my_premium_script", -- Used for file caching
    Key = "secret_pass_123",           -- The password (can also be a list or a function)
    GetKeyUrl = "https://linkvertise.com/123/get-key",
    DiscordUrl = "https://discord.gg/invite",
    OnSuccess = function()
        -- Put your main script here!
        print("Success! Loading library...")
        
        local MonoUI = loadstring(game:HttpGet("https://github.com/BloodLetters/mono-ui/releases/latest/download/mono-ui.luau"))()
        local window = MonoUI.CreateWindow({ Title = "My Script" })
    end
})
```

## API

### `Guard.new(options)`

Initializes and starts the Key System. It checks the local cache first. If a previously verified key is cached and still valid, it immediately fires the `OnSuccess` callback and bypasses the GUI. Otherwise, it displays the key verification screen.

| Option | Type | Default | Description |
|---|---|---|---|
| `Title` | string | `"guard key system"` | Header title. |
| `Subtitle` | string | `"please enter key to proceed"` | Header subtitle. |
| `Logo` | string | `"lock"` | The icon to show. Supports `"lock"`, `"key"`, `"shield"`, `"shield-check"`, `"shield-x"`, `"shield-alert"`. |
| `Key` | string / table / function | `""` | The expected key: can be a static string, an array/list of strings, or a custom verification function returning `true`/`false`. |
| `GetKeyUrl` | string | `""` | URL to get the key. If omitted, the "Get Key" button is hidden. |
| `DiscordUrl` | string | `""` | Discord invite link. If omitted, the "Join Discord" button is hidden. |
| `ConfigName` | string | `"guard_default"` | Unique configuration ID to name the cache file (`guard_key_<ConfigName>.txt`). |
| `AccentColor` | Color3 | `Color3.fromRGB(0, 162, 255)` | Color of the verify button and active input border. |
| `OnSuccess` | function | `nil` | Callback function fired immediately when the key is successfully verified. |

---

### Custom Key Verification Callback
If your keys are dynamic or verified through an API, pass a custom function to the `Key` option:

```lua
local guard = Guard.new({
    ConfigName = "api_key_system",
    GetKeyUrl = "https://linkvertise.com/...",
    Key = function(enteredKey)
        -- Fetch verification status from your server
        local response = game:HttpGet("https://api.myserver.com/verify?key=" .. enteredKey)
        return response == "VALID"
    end,
    OnSuccess = function()
        print("API validation succeeded!")
    end
})
```

### Multiple Valid Keys
You can also provide a list of valid keys:

```lua
local guard = Guard.new({
    ConfigName = "multi_key_system",
    Key = { "key_one", "key_two", "beta_tester_key" },
    OnSuccess = function()
        print("Verified via list!")
    end
})
```

---

### `guard:Show()`
Enables/displays the key system GUI.

### `guard:Hide()`
Disables/hides the key system GUI without deleting it.

### `guard:Destroy()`
Removes and cleans up all GUI elements, event connections, and UI instances.

---

## License
MIT - Part of the [MonoUI](https://github.com/BloodLetters/mono-ui) ecosystem.
