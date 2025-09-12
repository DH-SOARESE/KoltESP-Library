-- KoltESP Library for Roblox ESP
-- Oriented to object references
-- Supports Tracer, Name, Distance, HighlightOutline, HighlightFill
-- Loaded via loadstring

local KoltESP = {}
KoltESP.__index = KoltESP

-- Internal tables
local targets = {}
local paused = false
local connection = nil

-- Default global config
KoltESP.Config = {
    Tracer = { Visible = true, Origin = "Bottom", Thickness = 1 },
    Name = { Visible = true },
    Distance = { Visible = true },
    Highlight = { Outline = true, Filled = true, Transparency = { Outline = 0.3, Filled = 0.5 } },
    DistanceMax = 300,
    DistanceMin = 5
}

-- Helper to get object from path or direct instance
local function getObject(pathOrObj)
    if typeof(pathOrObj) == "Instance" then
        return pathOrObj
    elseif type(pathOrObj) == "string" then
        local success, obj = pcall(function()
            return loadstring("return game." .. pathOrObj)()
        end)
        if success and typeof(obj) == "Instance" then
            return obj
        end
    end
    return nil
end

-- Helper to get color from table
local function toColor3(colorTable)
    return Color3.new(colorTable[1]/255, colorTable[2]/255, colorTable[3]/255)
end

-- Add a target
function KoltESP:Add(pathOrObj, config)
    local obj = getObject(pathOrObj)
    if not obj then
        warn("KoltESP: Invalid object or path")
        return nil
    end
    
    local target = {
        Object = obj,
        EspColor = config.EspColor or {255, 255, 255},
        EspName = config.EspName or { DisplayName = obj.Name, Container = "" },
        EspDistance = config.EspDistance or { Container = "%d", Suffix = "" },  -- Use %d for format
        Colors = config.Colors or {}
    }
    
    -- Create drawing objects
    target.Tracer = Drawing.new("Line")
    target.Tracer.Visible = false
    target.Tracer.Thickness = self.Config.Tracer.Thickness
    
    target.NameText = Drawing.new("Text")
    target.NameText.Visible = false
    target.NameText.Center = true
    target.NameText.Outline = true
    target.NameText.Size = 14
    
    target.DistanceText = Drawing.new("Text")
    target.DistanceText.Visible = false
    target.DistanceText.Center = true
    target.DistanceText.Outline = true
    target.DistanceText.Size = 14
    
    target.Highlight = Instance.new("Highlight")
    target.Highlight.Adornee = obj
    target.Highlight.Parent = game.CoreGui  -- To avoid parenting to object
    target.Highlight.Enabled = false
    
    table.insert(targets, target)
    
    -- Start rendering if not already
    if not connection then
        self:StartRendering()
    end
    
    return target
end

-- Start the rendering loop
function KoltESP:StartRendering()
    if connection then return end
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    
    connection = RunService.RenderStepped:Connect(function()
        if paused then return end
        
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("Head") then return end
        local playerPos = char.Head.Position
        
        for _, target in ipairs(targets) do
            local obj = target.Object
            if not obj or not obj.Parent then
                target.Tracer.Visible = false
                target.NameText.Visible = false
                target.DistanceText.Visible = false
                target.Highlight.Enabled = false
                continue
            end
            
            local pos = nil
            if obj:IsA("BasePart") then
                pos = obj.Position
            elseif obj:IsA("Model") and obj.PrimaryPart then
                pos = obj.PrimaryPart.Position
            end
            if not pos then continue end
            
            local distance = (playerPos - pos).Magnitude
            if distance > self.Config.DistanceMax or distance < self.Config.DistanceMin then
                target.Tracer.Visible = false
                target.NameText.Visible = false
                target.DistanceText.Visible = false
                target.Highlight.Enabled = false
                continue
            end
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
            if not onScreen then
                -- Optional: still draw if configured, but for now hide 2D if offscreen
                target.Tracer.Visible = false
                target.NameText.Visible = false
                target.DistanceText.Visible = false
            else
                -- Tracer
                if self.Config.Tracer.Visible then
                    local originPos
                    if self.Config.Tracer.Origin == "Top" then
                        originPos = Vector2.new(screenPos.X, 0)
                    elseif self.Config.Tracer.Origin == "Center" then
                        originPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    else  -- Bottom
                        originPos = Vector2.new(screenPos.X, Camera.ViewportSize.Y)
                    end
                    target.Tracer.From = originPos
                    target.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                    target.Tracer.Color = toColor3(target.Colors.EspTracer or target.EspColor)
                    target.Tracer.Visible = true
                    target.Tracer.Thickness = self.Config.Tracer.Thickness
                else
                    target.Tracer.Visible = false
                end
                
                -- Name
                if self.Config.Name.Visible then
                    local nameText = target.EspName.DisplayName .. target.EspName.Container
                    target.NameText.Text = nameText
                    target.NameText.Position = Vector2.new(screenPos.X, screenPos.Y - 20)  -- Above
                    target.NameText.Color = toColor3(target.Colors.EspNameColor or target.EspColor)
                    target.NameText.Visible = true
                else
                    target.NameText.Visible = false
                end
                
                -- Distance
                if self.Config.Distance.Visible then
                    local distStr = string.format(target.EspDistance.Container, math.floor(distance))
                    distStr = distStr .. target.EspDistance.Suffix
                    target.DistanceText.Text = distStr
                    target.DistanceText.Position = Vector2.new(screenPos.X, screenPos.Y + 5)  -- Below
                    target.DistanceText.Color = toColor3(target.Colors.EspDistanceColor or target.EspColor)
                    target.DistanceText.Visible = true
                else
                    target.DistanceText.Visible = false
                end
            end
            
            -- Highlight (3D, always if in distance)
            if self.Config.Highlight.Outline or self.Config.Highlight.Filled then
                target.Highlight.Enabled = true
                if self.Config.Highlight.Outline then
                    target.Highlight.OutlineColor = toColor3(target.Colors.EspHighlight and target.Colors.EspHighlight.Outline or target.EspColor)
                    target.Highlight.OutlineTransparency = self.Config.Highlight.Transparency.Outline
                else
                    target.Highlight.OutlineTransparency = 1
                end
                if self.Config.Highlight.Filled then
                    target.Highlight.FillColor = toColor3(target.Colors.EspHighlight and target.Colors.EspHighlight.Filled or target.EspColor)
                    target.Highlight.FillTransparency = self.Config.Highlight.Transparency.Filled
                else
                    target.Highlight.FillTransparency = 1
                end
            else
                target.Highlight.Enabled = false
            end
        end
    end)
end

-- Unload everything
function KoltESP.Unload()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    KoltESP.Clear()
end

-- Remove specific target
function KoltESP.Remove(target)
    for i, t in ipairs(targets) do
        if t == target then
            if t.Tracer then t.Tracer:Remove() end
            if t.NameText then t.NameText:Remove() end
            if t.DistanceText then t.DistanceText:Remove() end
            if t.Highlight then t.Highlight:Destroy() end
            table.remove(targets, i)
            break
        end
    end
end

-- Clear all targets
function KoltESP.Clear()
    for _, t in ipairs(targets) do
        if t.Tracer then t.Tracer:Remove() end
        if t.NameText then t.NameText:Remove() end
        if t.DistanceText then t.DistanceText:Remove() end
        if t.Highlight then t.Highlight:Destroy() end
    end
    targets = {}
end

-- Pause rendering
function KoltESP.Pause(bool)
    paused = bool
end

-- For compatibility, set metatable if needed
setmetatable(KoltESP, { __call = function(self, ...) return self:Add(...) end })

-- Return the library
return KoltESP
