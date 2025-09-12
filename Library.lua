-- KoltESP Library
-- Version: 1.0

local KoltESP = {}
local KoltESPConfig = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Internal storage
KoltESP.Targets = {}  -- { [path] = { obj = obj, config = { ... } } }
KoltESP.Drawings = {}  -- Global drawing objects per type
KoltESP.Connections = {}  -- Update connections

-- Default global config
KoltESPConfig = {
    ESPTypes = {
        Tracer = { Visible = true, Origin = "Bottom", Thickness = 1, Color = {0, 255, 0} },
        Name = { Visible = true, Color = {255, 255, 255} },
        Distance = { Visible = true, Color = {255, 255, 0}, Suffix = "m", Max = 300, Min = 5 },
        Highlight = { 
            Outline = { Visible = true, Color = {255, 255, 255}, Transparency = 0.3 },
            Filled = { Visible = true, Color = {255, 255, 0}, Transparency = 0.5 }
        }
    }
}

-- Helper to get 3D to 2D position
local function WorldToScreen(position)
    local screenPos, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

-- Helper to format distance
local function FormatDistance(distance)
    return math.floor(distance) .. KoltESPConfig.ESPTypes.Distance.Suffix
end

-- Update loop for all ESPs
local function UpdateESP()
    for path, target in pairs(KoltESP.Targets) do
        local obj = target.obj
        if not obj or not obj.Parent then continue end
        
        local humanoidRootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj.PrimaryPart
        if not humanoidRootPart then continue end
        
        local distance = (LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and (LocalPlayer.Character.PrimaryPart.Position - humanoidRootPart.Position).Magnitude) or math.huge
        if distance > KoltESPConfig.ESPTypes.Distance.Max or distance < KoltESPConfig.ESPTypes.Distance.Min then
            -- Hide all drawings for this target
            for _, drawing in pairs(target.drawings or {}) do
                if drawing then drawing.Visible = false end
            end
            continue
        end
        
        local headPos = obj:FindFirstChild("Head") and obj.Head.Position or humanoidRootPart.Position + Vector3.new(0, 5, 0)
        local bottomPos = humanoidRootPart.Position
        local screenPos, onScreen = WorldToScreen(headPos)
        
        if not onScreen then
            for _, drawing in pairs(target.drawings or {}) do
                if drawing then drawing.Visible = false end
            end
            continue
        end
        
        local targetConfig = target.config or {}
        local colors = targetConfig.Colors or { EspColor = targetConfig.EspColor or {255, 255, 255} }
        
        -- Name
        if KoltESPConfig.ESPTypes.Name.Visible then
            local nameDrawing = target.drawings.Name
            if nameDrawing then
                nameDrawing.Visible = true
                nameDrawing.Position = screenPos
                nameDrawing.Text = targetConfig.EspName and targetConfig.EspName.DisplayName or obj.Name
                nameDrawing.Color = Color3.fromRGB(colors.EspNameColor or colors.EspColor[1], colors.EspNameColor and colors.EspNameColor[2] or colors.EspColor[2], colors.EspNameColor and colors.EspNameColor[3] or colors.EspColor[3])
                nameDrawing.Size = 16
            end
        end
        
        -- Distance
        if KoltESPConfig.ESPTypes.Distance.Visible then
            local distDrawing = target.drawings.Distance
            if distDrawing then
                local distScreenPos, _ = WorldToScreen(bottomPos)
                distDrawing.Visible = true
                distDrawing.Position = distScreenPos
                distDrawing.Text = (targetConfig.EspDistance and targetConfig.EspDistance.Container or "(%d)") :format(FormatDistance(distance))
                distDrawing.Color = Color3.fromRGB(colors.EspDistanceColor or colors.EspColor[1], colors.EspDistanceColor and colors.EspDistanceColor[2] or colors.EspColor[2], colors.EspDistanceColor and colors.EspDistanceColor[3] or colors.EspColor[3])
                distDrawing.Size = 14
            end
        end
        
        -- Tracer
        if KoltESPConfig.ESPTypes.Tracer.Visible then
            local tracerDrawing = target.drawings.Tracer
            if tracerDrawing then
                local originScreen
                local origin = KoltESPConfig.ESPTypes.Tracer.Origin
                if origin == "Top" then
                    originScreen, _ = WorldToScreen(headPos + Vector3.new(0, 3, 0))
                elseif origin == "Center" then
                    originScreen, _ = WorldToScreen((headPos + bottomPos) / 2)
                else  -- Bottom
                    originScreen, _ = WorldToScreen(bottomPos - Vector3.new(0, 3, 0))
                end
                tracerDrawing.Visible = true
                tracerDrawing.From = originScreen
                tracerDrawing.To = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                tracerDrawing.Color = Color3.fromRGB(colors.EspTracer and colors.EspTracer[1] or colors.EspColor[1], colors.EspTracer and colors.EspTracer[2] or colors.EspColor[2], colors.EspTracer and colors.EspTracer[3] or colors.EspColor[3])
                tracerDrawing.Thickness = KoltESPConfig.ESPTypes.Tracer.Thickness
            end
        end
        
        -- Highlight (using SelectionBox or Highlight instance if available)
        local highlight = target.highlight
        if highlight and KoltESPConfig.ESPTypes.Highlight.Outline.Visible then
            highlight.OutlineColor = Color3.fromRGB(colors.EspHighlight and colors.EspHighlight.Outline[1] or 255, colors.EspHighlight and colors.EspHighlight.Outline[2] or 255, colors.EspHighlight and colors.EspHighlight.Outline[3] or 255)
            highlight.OutlineTransparency = KoltESPConfig.ESPTypes.Highlight.Outline.Transparency
        end
        if highlight and highlight.Fill and KoltESPConfig.ESPTypes.Highlight.Filled.Visible then
            highlight.FillColor = Color3.fromRGB(colors.EspHighlight and colors.EspHighlight.Filled[1] or 255, colors.EspHighlight and colors.EspHighlight.Filled[2] or 255, colors.EspHighlight and colors.EspHighlight.Filled[3] or 0)
            highlight.FillTransparency = KoltESPConfig.ESPTypes.Highlight.Filled.Transparency
        end
        
        -- Show all
        for _, drawing in pairs(target.drawings or {}) do
            if drawing then drawing.Visible = true end
        end
    end
end

-- Add a target ESP
function KoltESP:Add(path, obj)
    if not obj then return end
    
    local target = {
        obj = obj,
        config = {},
        drawings = {},
        highlight = nil
    }
    
    -- Parse arguments - assuming the second arg after obj is the config table
    -- Usage: KoltESP:Add("workspace.queijo", queijoObj, { EspColor = ..., EspName = ..., ... })
    local configTable = select(3, ...) or {}
    
    -- Set defaults
    target.config.EspColor = configTable.EspColor or {255, 255, 255}
    target.config.EspName = configTable.EspName or { DisplayName = obj.Name, Container = "[%s]" }
    target.config.EspDistance = configTable.EspDistance or { Container = "(%s)", Suffix = "m" }
    target.config.Colors = configTable.Colors or {}
    
    KoltESP.Targets[path] = target
    
    -- Create drawings
    if KoltESPConfig.ESPTypes.Name.Visible then
        target.drawings.Name = Drawing.new("Text")
        target.drawings.Name.Font = 2
        target.drawings.Name.Center = true
        target.drawings.Name.Outline = true
    end
    
    if KoltESPConfig.ESPTypes.Distance.Visible then
        target.drawings.Distance = Drawing.new("Text")
        target.drawings.Distance.Font = 2
        target.drawings.Distance.Center = true
        target.drawings.Distance.Outline = true
    end
    
    if KoltESPConfig.ESPTypes.Tracer.Visible then
        target.drawings.Tracer = Drawing.new("Line")
        target.drawings.Tracer.Transparency = 1
    end
    
    -- Highlight (use Highlight instance if available, fallback to SelectionBox)
    pcall(function()
        target.highlight = Instance.new("Highlight")
        target.highlight.Parent = obj
        target.highlight.Adornee = obj
        target.highlight.Enabled = true
        if KoltESPConfig.ESPTypes.Highlight.Filled.Visible then
            target.highlight.FillTransparency = KoltESPConfig.ESPTypes.Highlight.Filled.Transparency
        else
            target.highlight.FillTransparency = 1
        end
    end)
    
    if not target.highlight then
        target.highlight = Instance.new("SelectionBox")
        target.highlight.Parent = obj
        target.highlight.Adornee = obj
        target.highlight.Transparency = KoltESPConfig.ESPTypes.Highlight.Outline.Transparency
    end
    
    return target  -- Return for further chaining if needed
end

-- Set config
function KoltESP:SetConfig(key, value)
    if string.find(key, "ConfigESPType") then
        local espType = string.match(key, '"([^"]+)"')
        if espType then
            KoltESPConfig.ESPTypes[espType] = value
        end
    elseif key == "ConfigESPDistanceMax" then
        KoltESPConfig.ESPTypes.Distance.Max = value
    elseif key == "ConfigESPDistanceMin" then
        KoltESPConfig.ESPTypes.Distance.Min = value
    end
end

-- Toggle ESP type
function KoltESP:Toggle(typeName, enabled)
    if KoltESPConfig.ESPTypes[typeName] then
        KoltESPConfig.ESPTypes[typeName].Visible = enabled
        -- Optionally recreate drawings, but for simplicity, just set visible in update
    end
end

-- Init the library
function KoltESP:Init()
    if KoltESP.Connections.Update then return end  -- Already running
    
    KoltESP.Connections.Update = RunService.Heartbeat:Connect(UpdateESP)
    
    -- Clean up on player leaving or obj destroy
    LocalPlayer.AncestryChanged:Connect(function()
        if not LocalPlayer.Parent then
            KoltESP:Destroy()
        end
    end)
end

-- Destroy all
function KoltESP:Destroy()
    for _, conn in pairs(KoltESP.Connections) do
        if conn then conn:Disconnect() end
    end
    for _, target in pairs(KoltESP.Targets) do
        for _, drawing in pairs(target.drawings or {}) do
            if drawing then drawing:Remove() end
        end
        if target.highlight then target.highlight:Destroy() end
    end
    KoltESP.Targets = {}
    KoltESP.Connections = {}
end
return KoltESP
