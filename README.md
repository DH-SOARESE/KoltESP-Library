# KoltESP Library

![KoltESP Banner](https://via.placeholder.com/800x200?text=KoltESP+V1.3) <!-- You can replace this with an actual banner image if available -->

**Version: 1.3 Enhanced**  
**Author: DH_SOARES**  
**Description:** KoltESP is a lightweight, efficient, and responsive ESP (Extra Sensory Perception) library for Roblox. It provides visual enhancements like tracers, highlights, boxes, skeletons, health bars, and more for models or parts in the game world. Designed with performance in mind, it includes caching, validation, and customizable settings. Ideal for game development, cheats, or visual debugging in Roblox experiences.

This library is minimalist yet powerful, supporting features like rainbow mode, team checks, occlusion detection (optional), and auto-removal of invalid targets. It runs at a configurable update rate to balance performance and smoothness.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage Examples](#usage-examples)
- [API Reference](#api-reference)
  - [Global Settings](#global-settings)
  - [Methods](#methods)
  - [Configuration per ESP Object](#configuration-per-esp-object)
  - [Statistics](#statistics)
- [Shortcuts and Tips](#shortcuts-and-tips)
- [Performance Considerations](#performance-considerations)
- [Changelog](#changelog)
- [License](#license)

## Features

- **ESP Types Supported:**
  - Tracers (from various origins: Top, Center, Bottom, Left, Right, Mouse)
  - 3D Highlights (fill and outline, with transparency control)
  - 2D Boxes (around screen position)
  - Skeletons (for humanoid models, connecting body parts)
  - Health Bars (for humanoids, with color gradient based on health)
  - Name and Distance Text Overlays

- **Customization:**
  - Global settings for all ESPs (e.g., opacity, thickness, rainbow mode)
  - Per-object overrides (e.g., custom colors, custom update functions)
  - Rainbow color mode for dynamic visuals
  - Distance-based visibility (min/max distance)
  - Team check for players (ignores same-team targets)
  - Auto-remove invalid targets (e.g., destroyed models)
  - Occlusion detection (optional, checks if target is behind obstacles)

- **Performance Optimizations:**
  - Caching for model centers to reduce computations
  - Throttled updates based on configurable FPS rate (default: 60)
  - Stats tracking (total/visible objects, frame time)
  - Stateful unload function to clean up all resources

- **Error Handling:**
  - Validation for targets (models or base parts)
  - Protected calls (pcall) for drawing creation and removal
  - Warnings for invalid operations

- **Themes:**
  - Default theme with primary, secondary, outline, and error colors
  - Easily modifiable via `ModelESP.Theme`

Everything is toggleable globally or per-object, making it flexible for various use cases.

## Installation

The library is loaded via Roblox's `loadstring` function. Fetch the raw Lua code from the GitHub repository and execute it.

```lua
local libraryCode = game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua")
local ModelESP = loadstring(libraryCode)()
```

- **Global Access:** After loading, the library is available as `ModelESP`. It's also set to `getgenv().KoltESP` and `_G.KoltESP` for easy access.
- **Initialization:** The library auto-initializes on load, connecting to `RunService.RenderStepped` for updates.

**Note:** Ensure you're running this in a Roblox environment with access to services like `RunService`, `Players`, and `Workspace`.

## Quick Start

Add ESP to a player's character:

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Add ESP to local player's character
ModelESP:Add(game.Players.LocalPlayer.Character, {
    Name = "My Character",
    Color = Color3.fromRGB(0, 255, 0)
})

-- Enable rainbow mode globally
ModelESP:SetGlobalRainbow(true)
```

This will add a tracer, name, distance, and highlight to your character.

## Usage Examples

### Basic ESP Addition

Add ESP to a model or part:

```lua
local targetModel = workspace:FindFirstChild("SomeModel") -- Replace with your target
ModelESP:Add(targetModel, {
    Name = "Enemy",
    Color = Color3.fromRGB(255, 0, 0),
    ShowHealthBar = true  -- If it's a humanoid
})
```

### Custom Per-Object Configuration

Override global settings for a specific ESP:

```lua
ModelESP:Add(workspace.Part, {
    Name = "Important Part",
    TracerColor = Color3.fromRGB(255, 255, 0),
    BoxColor = Color3.fromRGB(0, 0, 255),
    CustomUpdate = function(esp, screenPos, distance, color, visible)
        -- Custom logic, e.g., change text based on distance
        if distance > 50 then
            esp.nameText.Text = "Far Away"
        end
    end
})
```

### Global Settings Changes

Toggle features globally:

```lua
ModelESP:SetGlobalTracerOrigin("Mouse")  -- Tracer from mouse position
ModelESP:SetGlobalESPType("ShowSkeleton", true)  -- Enable skeletons for all
ModelESP:SetGlobalOpacity(0.5)  -- Half opacity
ModelESP:SetMaxDistance(1000)  -- Only show ESP within 1000 studs
ModelESP:SetTeamCheck(true)  -- Ignore same-team players
```

### Adding ESP to All Players

Loop through players and add ESP:

```lua
for _, player in ipairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer and player.Character then
        ModelESP:Add(player.Character, {
            Name = player.Name,
            Color = Color3.fromRGB(255, 100, 100)
        })
    end
end
```

### Removing ESP

Remove from a specific target:

```lua
ModelESP:Remove(workspace.SomeModel)
```

Clear all ESPs:

```lua
ModelESP:Clear()
```

### Unloading the Library

Fully unload and clean up:

```lua
ModelESP:Unload()
```

### Monitoring Stats

Get performance stats:

```lua
local stats = ModelESP:GetStats()
print("Total Objects:", stats.totalObjects)
print("Visible Objects:", stats.visibleObjects)
print("Frame Time (ms):", stats.frameTime)
```

## API Reference

### Global Settings

Access and modify via `ModelESP.GlobalSettings` table. Use setter methods for updates that propagate to all ESPs.

- `TracerOrigin` (string): "Bottom" (default), "Top", "Center", "Left", "Right", "Mouse"
- `ShowTracer` (bool): true
- `ShowHighlightFill` (bool): true
- `ShowHighlightOutline` (bool): true
- `ShowName` (bool): true
- `ShowDistance` (bool): true
- `ShowBox` (bool): true
- `ShowSkeleton` (bool): false
- `ShowHealthBar` (bool): false
- `RainbowMode` (bool): false
- `MaxDistance` (number): math.huge
- `MinDistance` (number): 0
- `Opacity` (number): 0.8 (0-1)
- `LineThickness` (number): 1.5
- `BoxThickness` (number): 1.5
- `SkeletonThickness` (number): 1.2
- `BoxTransparency` (number): 0.5 (0-1)
- `HighlightOutlineTransparency` (number): 0.65 (0-1)
- `HighlightFillTransparency` (number): 0.85 (0-1)
- `FontSize` (number): 14
- `AutoRemoveInvalid` (bool): true
- `UpdateRate` (number): 60 (FPS)
- `UseOcclusion` (bool): false (not fully implemented in code, but placeholder)
- `TeamCheck` (bool): false

Setter Methods:
- `SetGlobalTracerOrigin(origin: string)`
- `SetGlobalESPType(typeName: string, enabled: bool)` (e.g., "ShowTracer")
- `SetGlobalRainbow(enable: bool)`
- `SetGlobalOpacity(value: number)`
- `SetGlobalFontSize(size: number)`
- `SetGlobalLineThickness(thick: number)`
- `SetGlobalBoxThickness(thick: number)`
- `SetGlobalSkeletonThickness(thick: number)`
- `SetGlobalBoxTransparency(value: number)`
- `SetGlobalHighlightOutlineTransparency(value: number)`
- `SetGlobalHighlightFillTransparency(value: number)`
- `SetMaxDistance(distance: number)`
- `SetMinDistance(distance: number)`
- `SetUpdateRate(fps: number)`
- `SetTeamCheck(enabled: bool)`

### Methods

- `Add(target: Model|BasePart, config: table) -> bool`: Adds ESP to a target. Config options below.
- `Remove(target: Model|BasePart)`: Removes ESP from a target.
- `Clear()`: Removes all ESPs.
- `Unload()`: Fully unloads the library, disconnects connections, clears everything.
- `UpdateGlobalSettings()`: Propagates global changes to all ESPs (called internally by setters).
- `Initialize()`: Sets up the render loop (auto-called on load).
- `GetStats() -> table`: Returns stats like totalObjects, visibleObjects, frameTime, etc.

### Configuration per ESP Object

Passed as a table to `Add()`. Overrides globals where applicable.

- `Name` (string): Display name (default: target.Name)
- `Color` (Color3): Main color (default: Theme.PrimaryColor)
- `HighlightOutlineColor` (Color3): Outline color
- `HighlightOutlineTransparency` (number): 0-1
- `FilledTransparency` (number): Fill transparency (for highlight)
- `BoxColor` (Color3): Box color override
- `TracerColor` (Color3): Tracer color override
- `ShowHealthBar` (bool): Per-object health bar toggle
- `CustomUpdate` (function(esp, screenPos, distance, color, visible)): Custom update callback

### Statistics

Returned by `GetStats()`:

- `totalObjects` (int)
- `visibleObjects` (int)
- `frameTime` (number): Milliseconds per frame
- `lastUpdate` (number): Timestamp of last update
- `cacheSize` (int): Size of internal cache
- `enabled` (bool): If ESP is enabled

## Shortcuts and Tips

- **Quick Toggle:** `ModelESP.Enabled = false` to disable all rendering without unloading.
- **Global Access:** Use `getgenv().KoltESP` or `_G.KoltESP` after loading.
- **Rainbow Speed:** Modify `getRainbowColor` function's `speed` param for faster/slower rainbows.
- **Humanoid-Only:** Check for `Humanoid` before adding skeleton or health bar.
- **Performance Tip:** Set `UpdateRate` to 30 for low-end devices.
- **Debug:** Print stats every second with a loop: `while wait(1) do print(ModelESP:GetStats()) end`
- **Atalhos (Shortcuts in Portuguese):** 
  - Adicionar ESP: `ModelESP:Add(target, {})`
  - Remover: `ModelESP:Remove(target)`
  - Arco-íris: `ModelESP:SetGlobalRainbow(true)`
  - Descarregar: `ModelESP:Unload()`

## Performance Considerations

- Uses `RenderStepped` with throttling to target FPS.
- Caches model centers every 0.1 seconds.
- Avoid adding thousands of objects; test with `GetStats()` for bottlenecks.
- Skeletons and health bars are resource-intensive; toggle off if not needed.

## Changelog

- **V1.3 Enhanced:** Added unload, performance throttling, caching, validation, stats, team check, more setters.
- **Previous:** Basic ESP features.
