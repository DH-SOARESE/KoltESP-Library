local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local Kolt = {}
Kolt.ESPs = {}
Kolt.config = {
    ["Tracer"] = {
        Origin = "Top",
        Visible = true,
    },
    ["Highlight"] = {
        Outline = true,
        Filled = true,
        Visible = true,
    },
    ["Name"] = {
        Text = "",
        Visible = true,
        Container = "[%s]",
    },
    ["Distance"] = {
        Visible = true,
        Container = "(%s)",
    },
    EspMaxDistance = 300,
    EspMinDistance = 5,
    EspHighlightTransparency = {
        Outline = 0.3,
        Filled = 0.5,
    },
}

local updateConnection

local function resolvePath(path)
    if not path then return nil end
    local parts = string.split(path, ".")
    local obj = game
    for _, part in ipairs(parts) do
        obj = obj:FindFirstChild(part)
        if not obj then
            return nil
        end
    end
    return obj
end

local function createDrawings(esp)
    esp.drawings = {}

    -- Tracer
    if Kolt.config.Tracer.Visible then
        local line = Drawing.new("Line")
        line.Thickness = 2
        line.Transparency = 0
        line.Visible = false
        esp.drawings.tracer = line
    end

    -- Name
    if Kolt.config.Name.Visible then
        local text = Drawing.new("Text")
        text.Size = 16
        text.Center = true
        text.Outline = true
        text.Font = 2
        text.Transparency = 1
        text.Visible = false
        esp.drawings.name = text
    end

    -- Distance
    if Kolt.config.Distance.Visible then
        local text = Drawing.new("Text")
        text.Size = 16
        text.Center = true
        text.Outline = true
        text.Font = 2
        text.Transparency = 1
        text.Visible = false
        esp.drawings.distance = text
    end

    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Parent = nil
    highlight.Adornee = esp.target
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 1
    esp.highlight = highlight
end

local function updateESP()
    local viewportSize = Camera.ViewportSize

    for target, esp in pairs(Kolt.ESPs) do
        if not esp.target or not esp.target.Parent then
            Kolt.Remove(target)
            continue
        end

        local rootPart = esp.target:IsA("BasePart") and esp.target or esp.target:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            continue
        end

        local worldPos = rootPart.Position
        local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
        local distance = (worldPos - Camera.CFrame.Position).Magnitude

        if distance > Kolt.config.EspMaxDistance or distance < Kolt.config.EspMinDistance then
            -- Hide drawings
            for _, drawing in pairs(esp.drawings) do
                drawing.Visible = false
            end
            -- Hide highlight
            esp.highlight.FillTransparency = 1
            esp.highlight.OutlineTransparency = 1
            continue
        end

        local sPos = Vector2.new(screenPos.X, screenPos.Y)

        -- Tracer
        local tracer = esp.drawings.tracer
        if tracer and Kolt.config.Tracer.Visible then
            local originPos
            local origin = esp.Tracer and esp.Tracer.Origin or Kolt.config.Tracer.Origin
            if origin == "Top" then
                originPos = Vector2.new(viewportSize.X / 2, 0)
            elseif origin == "Center" then
                originPos = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
            else
                originPos = Vector2.new(viewportSize.X / 2, viewportSize.Y)
            end
            tracer.From = originPos
            tracer.To = sPos
            tracer.Color = esp.Color
            tracer.Visible = onScreen
            tracer.Transparency = tracer.Visible and 0.5 or 0
        end

        -- Name
        local nameDrawing = esp.drawings.name
        if nameDrawing and Kolt.config.Name.Visible then
            local nameText = esp.Name and esp.Name.Text or esp.target.Name
            local container = esp.Name and esp.Name.Container or Kolt.config.Name.Container
            nameDrawing.Text = string.format(container, nameText)
            nameDrawing.Position = sPos - Vector2.new(0, 30)
            nameDrawing.Color = esp.Color
            nameDrawing.Visible = onScreen
            nameDrawing.Transparency = nameDrawing.Visible and 1 or 0
        end

        -- Distance
        local distanceDrawing = esp.drawings.distance
        if distanceDrawing and Kolt.config.Distance.Visible then
            local distText = tostring(math.floor(distance))
            local container = esp.DistanceContainer or Kolt.config.Distance.Container
            distanceDrawing.Text = string.format(container, distText)
            distanceDrawing.Position = sPos + Vector2.new(0, 10)
            distanceDrawing.Color = esp.Color
            distanceDrawing.Visible = onScreen
            distanceDrawing.Transparency = distanceDrawing.Visible and 1 or 0
        end

        -- Highlight
        if Kolt.config.Highlight.Visible then
            esp.highlight.FillColor = esp.Color
            esp.highlight.OutlineColor = esp.Color
            if (esp.Highlight and esp.Highlight.Filled ~= nil) or Kolt.config.Highlight.Filled then
                esp.highlight.FillTransparency = Kolt.config.EspHighlightTransparency.Filled
            else
                esp.highlight.FillTransparency = 1
            end
            if (esp.Highlight and esp.Highlight.Outline ~= nil) or Kolt.config.Highlight.Outline then
                esp.highlight.OutlineTransparency = Kolt.config.EspHighlightTransparency.Outline
            else
                esp.highlight.OutlineTransparency = 1
            end
        else
            esp.highlight.FillTransparency = 1
            esp.highlight.OutlineTransparency = 1
        end
    end
end

function Kolt.Add(path, reference, localConfig)
    local target = reference or resolvePath(path)
    if not target or not target.Parent then
        return nil
    end

    local esp = {}
    esp.target = target
    createDrawings(esp)

    -- Apply local config
    if localConfig then
        esp.Color = localConfig.Color or Color3.fromRGB(255, 0, 0)
        esp.Name = localConfig.Name or {Text = "", Container = "[]"}
        esp.DistanceContainer = localConfig.DistanceContainer or "()"
        esp.Tracer = localConfig.Tracer or {Origin = Kolt.config.Tracer.Origin}
        esp.Highlight = localConfig.Highlight or {Outline = true, Filled = true}
    else
        esp.Color = Color3.fromRGB(255, 0, 0)
        esp.Name = {Text = "", Container = "[]"}
        esp.DistanceContainer = "()"
        esp.Tracer = {Origin = Kolt.config.Tracer.Origin}
        esp.Highlight = {Outline = true, Filled = true}
    end

    Kolt.ESPs[target] = esp

    -- Initial update for highlight
    updateESP()

    return esp
end

function Kolt.Remove(target)
    local esp = Kolt.ESPs[target]
    if esp then
        for _, drawing in pairs(esp.drawings) do
            if drawing then
                drawing:Remove()
            end
        end
        if esp.highlight then
            esp.highlight:Destroy()
        end
        Kolt.ESPs[target] = nil
    end
end

function Kolt.Clear()
    for target, _ in pairs(Kolt.ESPs) do
        Kolt.Remove(target)
    end
end

function Kolt.Unload()
    if updateConnection then
        updateConnection:Disconnect()
        updateConnection = nil
    end
    Kolt.Clear()
end

updateConnection = RunService.Heartbeat:Connect(updateESP)

return Kolt
