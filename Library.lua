-- KoltESP Library for Roblox ESP --
-- Oriented to object references
-- Supports Tracer, Name, Distance, HighlightOutline, HighlightFill
-- Safe + optimized rendering

local KoltESP = {}
KoltESP.__index = KoltESP

-- Internal tables
local targets = {}
local paused = false
local connection = nil

-- Default global config
KoltESP.Config = {
    Tracer = { Visible = true, Origin = "Bottom", Thickness = 1 },
    Name = { Visible = true, PositionOffset = Vector2.new(0, -20) },
    Distance = { Visible = true, PositionOffset = Vector2.new(0, 5), Precision = 0 },
    Highlight = { Outline = true, Filled = true, Transparency = { Outline = 0.3, Filled = 0.5 } },
    DistanceMax = 300,
    DistanceMin = 5,
    TextSize = 14,
    TextFont = Enum.Font.Code
}

-- Safe CoreGui (avoid crash)
local function getGuiParent()
    local suc, gui = pcall(gethui)
    if suc and gui then return gui end
    return game:GetService("CoreGui")
end

-- Helper: validate instance
local function getObject(pathOrObj)
    if typeof(pathOrObj) == "Instance" then
        return pathOrObj
    elseif type(pathOrObj) == "string" then
        local obj = game
        for part in string.gmatch(pathOrObj, "[^%.]+") do
            obj = obj:FindFirstChild(part)
            if not obj then return nil end
        end
        return obj
    end
    return nil
end

-- Helper: color table -> Color3
local function toColor3(tbl)
    return Color3.fromRGB(tbl[1], tbl[2], tbl[3])
end

-- Apply configs to drawing texts
local function setupText(textObj, cfg, size, font)
    textObj.Visible = false
    textObj.Center = true
    textObj.Outline = true
    textObj.Size = size
    textObj.Font = font
end

-- Add a target
function KoltESP:Add(pathOrObj, config)
    local obj = getObject(pathOrObj)
    if not obj then
        warn("KoltESP: Invalid object or path ->", tostring(pathOrObj))
        return nil
    end

    local target = {
        Object = obj,
        EspColor = config.EspColor or {255, 255, 255},
        EspName = config.EspName or { DisplayName = obj.Name, Container = "%s" },
        EspDistance = config.EspDistance or { Container = "%d", Suffix = "", Unit = "m" },
        Colors = config.Colors or {}
    }

    -- Drawing objects
    target.Tracer = Drawing.new("Line")
    target.Tracer.Visible = false
    target.Tracer.Thickness = self.Config.Tracer.Thickness

    target.NameText = Drawing.new("Text")
    setupText(target.NameText, config, self.Config.TextSize, self.Config.TextFont)

    target.DistanceText = Drawing.new("Text")
    setupText(target.DistanceText, config, self.Config.TextSize, self.Config.TextFont)

    -- Highlight
    target.Highlight = Instance.new("Highlight")
    target.Highlight.Adornee = obj
    target.Highlight.Parent = getGuiParent()
    target.Highlight.Enabled = false

    table.insert(targets, target)

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
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer

    connection = RunService.RenderStepped:Connect(function()
        if paused or not Camera then return end

        local char = LocalPlayer.Character
        local head = char and char:FindFirstChild("Head")
        if not head then return end
        local playerPos = head.Position

        for i = #targets, 1, -1 do
            local target = targets[i]
            local obj = target.Object

            if not obj or not obj.Parent then
                self.Remove(target) -- cleanup automatically
                continue
            end

            -- Object position
            local pos
            if obj:IsA("BasePart") then
                pos = obj.Position
            elseif obj:IsA("Model") and obj.PrimaryPart then
                pos = obj.PrimaryPart.Position
            end
            if not pos then continue end

            -- Distance
            local distance = (playerPos - pos).Magnitude
            if distance > self.Config.DistanceMax or distance < self.Config.DistanceMin then
                target.Tracer.Visible = false
                target.NameText.Visible = false
                target.DistanceText.Visible = false
                target.Highlight.Enabled = false
                continue
            end

            -- Viewport check
            local vp, onScreen = Camera:WorldToViewportPoint(pos)
            local screenPos = Vector2.new(vp.X, vp.Y)
            local visible = onScreen and vp.Z > 0

            if not visible then
                target.Tracer.Visible = false
                target.NameText.Visible = false
                target.DistanceText.Visible = false
            else
                -- Tracer
                if self.Config.Tracer.Visible then
                    local origin
                    local size = Camera.ViewportSize
                    if self.Config.Tracer.Origin == "Top" then
                        origin = Vector2.new(size.X/2, 0)
                    elseif self.Config.Tracer.Origin == "Center" then
                        origin = Vector2.new(size.X/2, size.Y/2)
                    else
                        origin = Vector2.new(size.X/2, size.Y)
                    end
                    target.Tracer.From = origin
                    target.Tracer.To = screenPos
                    target.Tracer.Color = toColor3(target.Colors.EspTracer or target.EspColor)
                    target.Tracer.Thickness = self.Config.Tracer.Thickness
                    target.Tracer.Visible = true
                end

                -- Name
                if self.Config.Name.Visible then
                    local nameText = string.format(target.EspName.Container, target.EspName.DisplayName)
                    target.NameText.Text = nameText
                    target.NameText.Position = screenPos + (target.Colors.EspNameOffset or self.Config.Name.PositionOffset)
                    target.NameText.Color = toColor3(target.Colors.EspNameColor or target.EspColor)
                    target.NameText.Visible = true
                end

                -- Distance
                if self.Config.Distance.Visible then
                    local precision = self.Config.Distance.Precision
                    local rounded = math.floor(distance * 10^precision) / 10^precision
                    local distStr = string.format(target.EspDistance.Container, rounded) ..
                                    target.EspDistance.Unit .. target.EspDistance.Suffix
                    target.DistanceText.Text = distStr
                    target.DistanceText.Position = screenPos + (target.Colors.EspDistanceOffset or self.Config.Distance.PositionOffset)
                    target.DistanceText.Color = toColor3(target.Colors.EspDistanceColor or target.EspColor)
                    target.DistanceText.Visible = true
                end
            end

            -- Highlight
            if self.Config.Highlight.Outline or self.Config.Highlight.Filled then
                target.Highlight.Adornee = obj
                target.Highlight.Enabled = true
                target.Highlight.OutlineColor = toColor3(target.Colors.EspHighlight and target.Colors.EspHighlight.Outline or target.EspColor)
                target.Highlight.FillColor = toColor3(target.Colors.EspHighlight and target.Colors.EspHighlight.Filled or target.EspColor)
                target.Highlight.OutlineTransparency = self.Config.Highlight.Outline and self.Config.Highlight.Transparency.Outline or 1
                target.Highlight.FillTransparency = self.Config.Highlight.Filled and self.Config.Highlight.Transparency.Filled or 1
            else
                target.Highlight.Enabled = false
            end
        end
    end)
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

-- Clear all
function KoltESP.Clear()
    for _, t in ipairs(targets) do
        if t.Tracer then t.Tracer:Remove() end
        if t.NameText then t.NameText:Remove() end
        if t.DistanceText then t.DistanceText:Remove() end
        if t.Highlight then t.Highlight:Destroy() end
    end
    targets = {}
end

-- Unload
function KoltESP.Unload()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    KoltESP.Clear()
end

-- Pause rendering
function KoltESP.Pause(bool)
    paused = bool
end

-- For syntactic sugar
setmetatable(KoltESP, { __call = function(self, ...) return self:Add(...) end })

return KoltESP
