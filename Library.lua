-- KoltESP Library for Roblox ESP --
-- Name + Distance in single container (2 lines, centered)
-- Highlight with slight saturation
-- Oriented to object references
-- Loaded via loadstring

local KoltESP = {}
KoltESP.__index = KoltESP

local targets = {}
local paused = false
local connection = nil

KoltESP.Config = {
    Tracer = { Visible = true, Origin = "Bottom", Thickness = 1 },
    NameDistance = { Visible = true }, -- unified name + distance
    Highlight = { Outline = true, Filled = true, Saturation = 0.8, Transparency = { Outline = 0.3, Filled = 0.5 } },
    DistanceMax = 300,
    DistanceMin = 5
}

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

local function toColor3(colorTable)
    return Color3.new(colorTable[1]/255, colorTable[2]/255, colorTable[3]/255)
end

local function saturateColor(color3, saturation)
    local h, s, v = Color3.toHSV(color3)
    return Color3.fromHSV(h, math.clamp(s*saturation,0,1), v)
end

function KoltESP:Add(pathOrObj, config)
    local obj = getObject(pathOrObj)
    if not obj then
        warn("KoltESP: Invalid object or path")
        return nil
    end

    local target = {
        Object = obj,
        EspColor = config.EspColor or {255, 255, 255},
        EspName = config.EspName or {DisplayName = obj.Name, Container = ""},
        EspDistance = config.EspDistance or {Format = "%d", Suffix = "m", Container = ""},
        Colors = config.Colors or {}
    }

    target.Tracer = Drawing.new("Line")
    target.Tracer.Visible = false
    target.Tracer.Thickness = KoltESP.Config.Tracer.Thickness

    target.NameDistanceText = Drawing.new("Text")
    target.NameDistanceText.Visible = false
    target.NameDistanceText.Center = true
    target.NameDistanceText.Outline = true
    target.NameDistanceText.Size = 14

    target.Highlight = Instance.new("Highlight")
    target.Highlight.Adornee = obj
    target.Highlight.Parent = game.CoreGui
    target.Highlight.Enabled = false

    table.insert(targets, target)

    if not connection then
        self:StartRendering()
    end

    return target
end

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
                target.NameDistanceText.Visible = false
                target.Highlight.Enabled = false
                continue
            end

            local pos
            if obj:IsA("BasePart") then pos = obj.Position
            elseif obj:IsA("Model") and obj.PrimaryPart then pos = obj.PrimaryPart.Position end
            if not pos then continue end

            local distance = (playerPos - pos).Magnitude
            if distance > self.Config.DistanceMax or distance < self.Config.DistanceMin then
                target.Tracer.Visible = false
                target.NameDistanceText.Visible = false
                target.Highlight.Enabled = false
                continue
            end

            local viewportPoint, inFront = Camera:WorldToViewportPoint(pos)
            local screenPos = Vector2.new(viewportPoint.X, viewportPoint.Y)
            local onScreen = inFront and viewportPoint.X >= 0 and viewportPoint.X <= Camera.ViewportSize.X and viewportPoint.Y >= 0 and viewportPoint.Y <= Camera.ViewportSize.Y

            if not onScreen then
                target.Tracer.Visible = false
                target.NameDistanceText.Visible = false
            else
                -- Tracer
                if KoltESP.Config.Tracer.Visible then
                    local originPos
                    local vs = Camera.ViewportSize
                    if KoltESP.Config.Tracer.Origin == "Top" then
                        originPos = Vector2.new(vs.X/2,0)
                    elseif KoltESP.Config.Tracer.Origin == "Center" then
                        originPos = Vector2.new(vs.X/2, vs.Y/2)
                    else
                        originPos = Vector2.new(vs.X/2, vs.Y)
                    end
                    target.Tracer.From = originPos
                    target.Tracer.To = screenPos
                    target.Tracer.Color = toColor3(target.Colors.EspTracer or target.EspColor)
                    target.Tracer.Visible = true
                    target.Tracer.Thickness = KoltESP.Config.Tracer.Thickness
                else
                    target.Tracer.Visible = false
                end

                -- Name + Distance
                if KoltESP.Config.NameDistance.Visible then
                    local nameStr = target.EspName.DisplayName .. (target.EspName.Container or "")
                    local distStr = (target.EspDistance.Container or "") .. string.format(target.EspDistance.Format, math.floor(distance)) .. target.EspDistance.Suffix
                    target.NameDistanceText.Text = nameStr .. "\n(" .. distStr .. ")"
                    target.NameDistanceText.Position = screenPos
                    target.NameDistanceText.Color = toColor3(target.Colors.EspNameColor or target.EspColor)
                    target.NameDistanceText.Visible = true
                else
                    target.NameDistanceText.Visible = false
                end
            end

            -- Highlight
            if KoltESP.Config.Highlight.Outline or KoltESP.Config.Highlight.Filled then
                target.Highlight.Enabled = true
                local baseColor = toColor3(target.Colors.EspHighlight and target.Colors.EspHighlight.Filled or target.EspColor)
                local finalColor = saturateColor(baseColor, KoltESP.Config.Highlight.Saturation)
                if KoltESP.Config.Highlight.Outline then
                    target.Highlight.OutlineColor = finalColor
                    target.Highlight.OutlineTransparency = KoltESP.Config.Highlight.Transparency.Outline
                else
                    target.Highlight.OutlineTransparency = 1
                end
                if KoltESP.Config.Highlight.Filled then
                    target.Highlight.FillColor = finalColor
                    target.Highlight.FillTransparency = KoltESP.Config.Highlight.Transparency.Filled
                else
                    target.Highlight.FillTransparency = 1
                end
            else
                target.Highlight.Enabled = false
            end
        end
    end)
end

function KoltESP.Unload()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    KoltESP.Clear()
end

function KoltESP.Remove(target)
    for i, t in ipairs(targets) do
        if t == target then
            if t.Tracer then t.Tracer:Remove() end
            if t.NameDistanceText then t.NameDistanceText:Remove() end
            if t.Highlight then t.Highlight:Destroy() end
            table.remove(targets, i)
            break
        end
    end
end

function KoltESP.Clear()
    for _, t in ipairs(targets) do
        if t.Tracer then t.Tracer:Remove() end
        if t.NameDistanceText then t.NameDistanceText:Remove() end
        if t.Highlight then t.Highlight:Destroy() end
    end
    targets = {}
end

function KoltESP.Pause(bool)
    paused = bool
end

setmetatable(KoltESP, { __call = function(self, ...) return self:Add(...) end })

return KoltESP
