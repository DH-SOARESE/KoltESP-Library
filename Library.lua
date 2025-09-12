-- ==============================
-- KoltESP Library
-- Author: Adapted for your request
-- Load via: loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()
-- ==============================

local KoltESP = {}
KoltESP.__index = KoltESP

-- ==============================
-- Internal Tables
-- ==============================
KoltESP.Targets = {}
KoltESP.Configs = {
    Name = {Visible = true},
    Distance = {Visible = true},
    Tracer = {Visible = true},
    Highlight = {Filled = true, Outline = true},
}
KoltESP.Rainbow = false
KoltESP.ConfigTransparency = {
    Highlight = {Filled = 0.5, Outline = 0.3}
}
KoltESP.ConfigDistanceMax = 400
KoltESP.ConfigDistanceMin = 5

-- ==============================
-- Utility Functions
-- ==============================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function CreateDrawing(type)
    local success, drawing = pcall(function()
        return Drawing.new(type)
    end)
    return success and drawing or nil
end

local function DistanceBetween(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

local function RGBToHex(r,g,b)
    return Color3.fromRGB(r,g,b)
end

local function GetObjectPosition(obj)
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") and obj.PrimaryPart then
        return obj.PrimaryPart.Position
    else
        return obj:FindFirstChildWhichIsA("BasePart") and obj:FindFirstChildWhichIsA("BasePart").Position or nil
    end
end

local function WorldToViewport(position)
    local screenPos, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

-- ==============================
-- Core Target Function
-- ==============================
function KoltESP:Target(path, espName, options)
    if not path or not espName then return end
    options = options or {}

    local Target = {
        Path = path,
        Name = espName,
        Paused = false,
        Options = options,
        Components = {
            Name = CreateDrawing("Text"),
            Distance = CreateDrawing("Text"),
            Tracer = CreateDrawing("Line"),
            Highlight = Instance.new("Highlight")
        }
    }

    -- Setup Highlight
    if Target.Components.Highlight then
        Target.Components.Highlight.Parent = workspace
        Target.Components.Highlight.FillTransparency = options.Color and options.Color.Highlight and options.Color.Highlight.Filled or KoltESP.ConfigTransparency.Highlight.Filled
        Target.Components.Highlight.OutlineTransparency = options.Color and options.Color.Highlight and options.Color.Highlight.Outline or KoltESP.ConfigTransparency.Highlight.Outline
        Target.Components.Highlight.Enabled = true
        Target.Components.Highlight.FillColor = options.Color and options.Color.Highlight and RGBToHex(unpack(options.Color.Highlight.Filled or {0,40,144})) or Color3.fromRGB(0,40,144)
        Target.Components.Highlight.OutlineColor = options.Color and options.Color.Highlight and RGBToHex(unpack(options.Color.Highlight.Outline or {255,255,255})) or Color3.fromRGB(255,255,255)
        if path:IsA("Instance") then
            Target.Components.Highlight.Adornee = path
        end
    end

    KoltESP.Targets[espName] = Target
end

-- ==============================
-- Update ESP Each Frame
-- ==============================
RunService.RenderStepped:Connect(function()
    for _, target in pairs(KoltESP.Targets) do
        if target.Paused then
            -- Hide components
            for _, comp in pairs(target.Components) do
                if comp:IsA("Drawing") then comp.Visible = false end
            end
        else
            local objPos = GetObjectPosition(target.Path)
            if objPos then
                local screenPos, onScreen = WorldToViewport(objPos)
                local dist = math.clamp(DistanceBetween(Camera.CFrame.Position, objPos), KoltESP.ConfigDistanceMin, KoltESP.ConfigDistanceMax)
                local nameText = target.Options.Name and target.Options.Name.Name or target.Path.Name
                local distText = string.format("%.1f%s", dist, target.Options.Distance and target.Options.Distance.Suffix or "m")

                -- Update Text
                if KoltESP.Configs.Name.Visible then
                    target.Components.Name.Text = (target.Options.Name and target.Options.Name.Container and (target.Options.Name.Container.Start or "") or "") .. nameText .. (target.Options.Name and target.Options.Name.Container and (target.Options.Name.Container.End or "") or "")
                    target.Components.Name.Position = screenPos
                    target.Components.Name.Color = RGBToHex(unpack(target.Options.Color and target.Options.Color.Name or {255,255,255}))
                    target.Components.Name.Visible = onScreen
                    target.Components.Name.Center = true
                end

                if KoltESP.Configs.Distance.Visible then
                    target.Components.Distance.Text = (target.Options.Distance and target.Options.Distance.Container and (target.Options.Distance.Container.Start or "") or "") .. distText .. (target.Options.Distance and target.Options.Distance.Container and (target.Options.Distance.Container.End or "") or "")
                    target.Components.Distance.Position = screenPos + Vector2.new(0, 15)
                    target.Components.Distance.Color = RGBToHex(unpack(target.Options.Color and target.Options.Color.Distancia or {0,255,0}))
                    target.Components.Distance.Visible = onScreen
                    target.Components.Distance.Center = true
                end

                if KoltESP.Configs.Tracer.Visible then
                    local tracer = target.Components.Tracer
                    tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    tracer.To = screenPos
                    tracer.Color = RGBToHex(unpack(target.Options.Color and target.Options.Color.Tracer or {255,255,0}))
                    tracer.Visible = onScreen
                end

                if target.Components.Highlight and target.Path:IsA("Instance") then
                    target.Components.Highlight.Adornee = target.Path
                end
            end
        end
    end
end)

-- ==============================
-- API Functions
-- ==============================
function KoltESP:NewTarget(path, oldName, newName)
    if KoltESP.Targets[oldName] then
        KoltESP.Targets[newName] = KoltESP.Targets[oldName]
        KoltESP.Targets[oldName] = nil
    end
end

function KoltESP:Clear(name)
    if name then
        local target = KoltESP.Targets[name]
        if target then
            for _, comp in pairs(target.Components) do
                if comp:IsA("Drawing") then
                    comp:Remove()
                elseif comp:IsA("Highlight") then
                    comp:Destroy()
                end
            end
            KoltESP.Targets[name] = nil
        end
    else
        for name, _ in pairs(KoltESP.Targets) do
            KoltESP:Clear(name)
        end
    end
end

function KoltESP:Pause(name, state)
    if name then
        if KoltESP.Targets[name] then
            KoltESP.Targets[name].Paused = state
        end
    else
        for _, target in pairs(KoltESP.Targets) do
            target.Paused = state
        end
    end
end

function KoltESP:Unload()
    KoltESP:Clear()
    KoltESP.Targets = {}
end

function KoltESP:Config(component, settings)
    KoltESP.Configs[component] = settings
end

function KoltESP:ConfigTransparency(component, settings)
    KoltESP.ConfigTransparency[component] = settings
end

function KoltESP:RainbowMode(state)
    KoltESP.Rainbow = state
end

return KoltESP
