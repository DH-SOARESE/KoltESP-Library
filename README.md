# KoltESP Library

![Roblox ESP Example](https://via.placeholder.com/800x200?text=KoltESP+Demo) <!-- Placeholder for a demo image; replace if you have one -->

## Overview

KoltESP is a lightweight, object-oriented ESP (Extra Sensory Perception) library for Roblox. It allows you to add visual overlays (like tracers, names, distances, and highlights) to any game objects, such as parts, models, or characters. This is useful for cheats, debugging, or visualization in Roblox scripts.

Key features:
- **Supports**: Tracers (lines from screen origin to object), Names (text labels), Distances (calculated from local player), Highlights (3D outlines and fills using Roblox's Highlight instance).
- **Flexible**: Works with any Instance (e.g., BasePart or Model with PrimaryPart). You can pass objects directly or as string paths (e.g., "Players.LocalPlayer.Character").
- **Configurable**: Global settings for all ESP elements, with per-target overrides.
- **Performance**: Runs on RenderStepped for smooth updates, with distance culling to avoid unnecessary rendering.
- **Easy to Use**: Loaded via `loadstring` for quick integration into exploits or scripts.

**Version**: 1.0  
**Author**: DH-SOARESE (GitHub: [DH-SOARESE/KoltESP-Library](https://github.com/DH-SOARESE/KoltESP-Library))  
**License**: MIT (or specify if different)  
**Dependencies**: None (uses built-in Roblox APIs like Drawing and Highlight).

## Loading the Library

KoltESP is designed to be loaded dynamically using `loadstring`. Here's how:

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()
```

This returns the `KoltESP` table, which you can use to add targets and configure ESP.

## Global Configuration

Before adding targets, you can customize the global `KoltESP.Config` table. These settings apply to all targets unless overridden per-target.

```lua
KoltESP.Config = {
    Tracer = {
        Visible = true,      -- Show tracer lines?
        Origin = "Bottom",   -- Tracer start: "Top", "Center", or "Bottom" of screen
        Thickness = 1        -- Line thickness (pixels)
    },
    Name = {
        Visible = true       -- Show name labels?
    },
    Distance = {
        Visible = true       -- Show distance labels?
    },
    Highlight = {
        Outline = true,      -- Enable outline highlight?
        Filled = true,       -- Enable filled highlight?
        Transparency = {
            Outline = 0.3,   -- Outline transparency (0 = opaque, 1 = invisible)
            Filled = 0.5     -- Fill transparency (0 = opaque, 1 = invisible)
        }
    },
    DistanceMax = 300,       -- Max distance to render ESP (studs)
    DistanceMin = 5          -- Min distance to render ESP (studs; avoids rendering on self)
}
```

- **Colors**: Defaults to white ({255, 255, 255}). Override per-target (see below).
- **Notes**: Changes to config apply immediately. Highlights are 3D and visible even off-screen if within distance.

## Adding Targets

Use `KoltESP:Add(pathOrObj, config)` to add an ESP target. Returns the target table for later removal or modification.

- `pathOrObj`: Can be an Instance (e.g., `workspace.Part`) or a string path (e.g., `"Workspace.Part"` – resolved via `game.` prefix).
- `config`: A table for per-target settings (overrides global config).

Per-target config options:
```lua
{
    EspColor = {255, 0, 0},  -- Default RGB color for all ESP elements (array: {R, G, B})
    EspName = {
        DisplayName = "CustomName",  -- Text to show (defaults to object.Name)
        Container = " [Extra]"       -- Append extra text (e.g., for health: " [100 HP]")
    },
    EspDistance = {
        Container = "%d",            -- Format string for distance (e.g., "%d" for raw number)
        Suffix = " studs"            -- Append text (e.g., " studs")
    },
    Colors = {                       -- Override specific colors (RGB arrays)
        EspTracer = {0, 255, 0},     -- Tracer color
        EspNameColor = {255, 255, 0},-- Name text color
        EspDistanceColor = {0, 0, 255}, -- Distance text color
        EspHighlight = {
            Outline = {255, 0, 255}, -- Highlight outline color
            Filled = {0, 255, 255}   -- Highlight fill color
        }
    }
}
```

- **Shorthand**: You can call `KoltESP` like a function: `KoltESP(pathOrObj, config)` (same as `Add`).

The library auto-starts rendering when the first target is added.

## Examples

### Basic Usage: Add ESP to a Part

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Customize global config (optional)
KoltESP.Config.Tracer.Origin = "Center"
KoltESP.Config.Highlight.Filled = false

-- Add a target (string path)
local target1 = KoltESP:Add("Workspace.Baseplate", {
    EspColor = {255, 0, 0},  -- Red
    EspName = { DisplayName = "Floor" },
    EspDistance = { Suffix = "m" }
})

-- Add another (direct Instance)
local part = Instance.new("Part")
part.Parent = workspace
local target2 = KoltESP(part, {  -- Shorthand call
    EspColor = {0, 255, 0},  -- Green
    Colors = {
        EspHighlight = { Outline = {0, 0, 255} }  -- Blue outline
    }
})
```

This adds tracers, names, distances, and highlights to the objects. They update in real-time based on camera and player position.

### Advanced: Custom Colors and Formatting

```lua
local target = KoltESP:Add("Players.LocalPlayer.Character.HumanoidRootPart", {
    EspColor = {255, 255, 255},  -- White default
    EspName = { DisplayName = "Player", Container = " [VIP]" },
    EspDistance = { Container = "Dist: %d", Suffix = " units" },
    Colors = {
        EspTracer = {255, 165, 0},       -- Orange tracer
        EspNameColor = {255, 215, 0},    -- Gold name
        EspDistanceColor = {135, 206, 235}, -- Sky blue distance
        EspHighlight = {
            Outline = {255, 0, 0},       -- Red outline
            Filled = {0, 255, 0}         -- Green fill
        }
    }
})
```

### For All Players (Loop Example)

```lua
local Players = game:GetService("Players")

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer and player.Character then
        KoltESP:Add(player.Character, {
            EspColor = {255, 0, 0},  -- Red for enemies
            EspName = { DisplayName = player.Name }
        })
    end
end
```

### Pause/Resume Rendering

```lua
KoltESP.Pause(true)   -- Pause all ESP rendering
wait(5)
KoltESP.Pause(false)  -- Resume
```

### Remove a Specific Target

```lua
KoltESP.Remove(target1)  -- Removes drawings and highlight for that target
```

### Clear All Targets

```lua
KoltESP.Clear()  -- Removes all ESP elements
```

### Unload the Library

```lua
KoltESP.Unload()  -- Stops rendering loop and clears everything
```

## Methods

- **`Add(pathOrObj, config)` or `KoltESP(pathOrObj, config)`**: Adds a target and returns it. Starts rendering if not active.
- **`StartRendering()`**: Manually starts the render loop (auto-called on first add).
- **`Remove(target)`**: Removes a specific target (pass the returned table from Add).
- **`Clear()`**: Removes all targets and their visuals.
- **`Pause(bool)`**: Pauses (true) or resumes (false) rendering without removing targets.
- **`Unload()`**: Fully unloads the library (disconnects loop + clears targets).

## Properties and Offerings

- **Targets Table**: Internal, but each target has:
  - `Object`: The Instance being tracked.
  - `EspColor`, `EspName`, `EspDistance`, `Colors`: As set in config.
  - Drawing objects: `Tracer` (Line), `NameText` (Text), `DistanceText` (Text).
  - `Highlight`: Roblox Highlight instance (parented to CoreGui for persistence).

- **Rendering Logic**:
  - Updates every frame via `RenderStepped`.
  - Skips if paused, object invalid, or out of distance range.
  - Tracers/Texts only render if on-screen; Highlights render if in distance (3D).
  - Distance calculated from local player's Head to object's Position (or PrimaryPart).

- **Limitations**:
  - Requires a local player with Character and Head.
  - No bounding boxes (only point-based ESP).
  - Colors are RGB arrays (0-255); converted to Color3 internally.
  - Errors if invalid object/path; warns in console.

## Troubleshooting

- **No ESP Showing?**: Check distance (too far/close?), object validity, or if paused.
- **Performance Issues?**: Limit targets; distance culling helps.
- **Colors Not Applying?**: Ensure RGB arrays are {R, G, B} (0-255).
- **For Models**: Needs a PrimaryPart or tracks as point.

For issues, check Roblox console for warnings. Contributions welcome on GitHub!

## Changelog

- **v1.0**: Initial release with core ESP features.
