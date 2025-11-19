--[[  
    KoltESP Library v1.8
    • Biblioteca de ESP voltada para endereços de objetos (Model e BasePart).  
    • Oferece diversas APIs úteis para seus projetos, incluindo a visualização de todas as colisões de um alvo.  
    • O ponto central do alvo é definido com base na parte mais visível — se houver colisões invisíveis, a prioridade será dada à parte com maior visibilidade, e não ao centro exato do modelo.
]]

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local HighlightFolderName = "Highlight Folder" 
local highlightFolder = nil 

local function getHighlightFolder()
    if not highlightFolder then
        highlightFolder = ReplicatedStorage:FindFirstChild(HighlightFolderName)
        if not highlightFolder then
            highlightFolder = Instance.new("Folder")
            highlightFolder.Name = HighlightFolderName
            highlightFolder.Parent = ReplicatedStorage
        end
    end
    return highlightFolder
end

local KoltESP = {
    Objects = {},
    Theme = {
        PrimaryColor = Color3.fromRGB(130, 200, 255),
        SecondaryColor = Color3.fromRGB(255, 255, 255),
        OutlineColor = Color3.fromRGB(0, 0, 0),
    },
    EspSettings = {
        TracerOrigin = "Bottom",
        ShowTracer = true,
        ShowHighlightFill = true,
        ShowHighlightOutline = true,
        ShowName = true,
        ShowDistance = true,
        RainbowMode = false,
        MaxDistance = math.huge,
        MinDistance = 0,
        Opacity = 0.8,
        LineThickness = 4,
        FontSize = 14,
        Font = 3,
        AutoRemoveInvalid = true,
        HighlightTransparency = {
            Filled = 0.5,
            Outline = 0.3
        },
        TextOutlineEnabled = true,
        TextOutlineColor = Color3.fromRGB(0, 0, 0),
        TextOutlineThickness = 1,
        Enabled = true,
    }
}

local ColorRegistry = {}

function KoltESP:AddToRegistry(target, config)
    if not target or not config then return end
    if not (target:IsA("Model") or target:IsA("BasePart")) then return end

    ColorRegistry[target] = {
        TextColor       = config.TextColor,
        DistanceColor   = config.DistanceColor,
        TracerColor     = config.TracerColor,
        HighlightColor  = config.HighlightColor,
    }

    local esp = self:GetESP(target)
    if esp then
        local reg = ColorRegistry[target]
        if reg.TextColor      then esp.Colors.Name      = reg.TextColor end
        if reg.DistanceColor  then esp.Colors.Distance  = reg.DistanceColor end
        if reg.TracerColor    then esp.Colors.Tracer    = reg.TracerColor end
        if reg.HighlightColor then 
            esp.Colors.Highlight.Filled  = reg.HighlightColor
            esp.Colors.Highlight.Outline = reg.HighlightColor
        end
    end
end

function KoltESP:GetESP(target)
    for _, esp in ipairs(self.Objects) do
        if esp.Target == target then return esp end
    end
    return nil
end

function KoltESP:SetHighlightFolderName(name)
    if typeof(name) == "string" and name ~= "" then
        HighlightFolderName = name
        highlightFolder = nil
    end
end

function KoltESP:SetGlobalHighlightTransparency(trans)
    if typeof(trans) == "table" then
        if trans.Filled and typeof(trans.Filled) == "number" then
            self.EspSettings.HighlightTransparency.Filled = math.clamp(trans.Filled, 0, 1)
        end
        if trans.Outline and typeof(trans.Outline) == "number" then
            self.EspSettings.HighlightTransparency.Outline = math.clamp(trans.Outline, 0, 1)
        end
    end
end

local function createDrawing(class, props)
    local obj = Drawing.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

local function getRainbowColor(t)
    local f = 2
    return Color3.fromRGB(
        math.sin(f*t + 0)*127 + 128,
        math.sin(f*t + 2)*127 + 128,
        math.sin(f*t + 4)*127 + 128
    )
end

local tracerOrigins = {
    Top    = function(vs) return Vector2.new(vs.X/2, 0) end,
    Center = function(vs) return Vector2.new(vs.X/2, vs.Y/2) end,
    Bottom = function(vs) return Vector2.new(vs.X/2, vs.Y) end,
    Left   = function(vs) return Vector2.new(0, vs.Y/2) end,
    Right  = function(vs) return Vector2.new(vs.X, vs.Y/2) end,
}

local function getBoundingBox(target)
    if target:IsA("Model") then
        return target:GetBoundingBox()
    elseif target:IsA("BasePart") then
        return target.CFrame, target.Size
    end
    return nil, nil
end

local function collectBaseParts(target)
    local parts = {}
    for _, v in ipairs(target:GetDescendants()) do
        if v:IsA("BasePart") then table.insert(parts, v) end
    end
    if target:IsA("BasePart") then table.insert(parts, target) end
    return parts
end

local function setupCollision(esp, target, collision, allParts)
    if collision then
        local hum = target:FindFirstChild("Esp") or Instance.new("Humanoid")
        hum.Name = "Esp"
        hum.Parent = target
        esp.humanoid = hum

        for _, part in ipairs(allParts) do
            if part.Transparency >= 1 then
                table.insert(esp.ModifiedParts, {Part = part, Original = part.Transparency})
                part.Transparency = 0.99
            end
        end
    else
        esp.visibleParts = {}
        for _, part in ipairs(allParts) do
            if part.Transparency < 0.99 then
                table.insert(esp.visibleParts, part)
            end
        end
    end
end

local function setupHighlight(esp, target)
    local showFill = KoltESP.EspSettings.ShowHighlightFill and esp.Types.HighlightFill
    local showOutline = KoltESP.EspSettings.ShowHighlightOutline and esp.Types.HighlightOutline

    if showFill or showOutline then
        if not esp.highlight then
            esp.highlight = Instance.new("Highlight")
            esp.highlight.Name = "ESPHighlight"
            esp.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            esp.highlight.Parent = getHighlightFolder()
        end
        esp.highlight.Adornee = target
        esp.highlight.FillTransparency = showFill and KoltESP.EspSettings.HighlightTransparency.Filled or 1
        esp.highlight.OutlineTransparency = showOutline and KoltESP.EspSettings.HighlightTransparency.Outline or 1

        local col = KoltESP.EspSettings.RainbowMode and getRainbowColor(tick()) or esp.Colors.Highlight.Filled
        esp.highlight.FillColor = col
        esp.highlight.OutlineColor = KoltESP.EspSettings.RainbowMode and col or esp.Colors.Highlight.Outline
    elseif esp.highlight then
        esp.highlight:Destroy()
        esp.highlight = nil
    end
end

local function applyColors(cfg, config)
    cfg.Colors = {
        Name = KoltESP.Theme.PrimaryColor,
        Distance = KoltESP.Theme.PrimaryColor,
        Tracer = KoltESP.Theme.PrimaryColor,
        Highlight = {
            Filled = KoltESP.Theme.PrimaryColor,
            Outline = KoltESP.Theme.SecondaryColor
        }
    }

    if config and config.Color then
        if typeof(config.Color) == "Color3" then
            cfg.Colors.Name = config.Color
            cfg.Colors.Distance = config.Color
            cfg.Colors.Tracer = config.Color
            cfg.Colors.Highlight.Filled = config.Color
            cfg.Colors.Highlight.Outline = config.Color
        end
    end

    local reg = ColorRegistry[cfg.Target]
    if reg then
        if reg.TextColor      then cfg.Colors.Name = reg.TextColor end
        if reg.DistanceColor  then cfg.Colors.Distance = reg.DistanceColor end
        if reg.TracerColor    then cfg.Colors.Tracer = reg.TracerColor end
        if reg.HighlightColor then
            cfg.Colors.Highlight.Filled = reg.HighlightColor
            cfg.Colors.Highlight.Outline = reg.HighlightColor
        end
    end
end

local function CleanupESP(esp)
    if esp.tracerLine then pcall(esp.tracerLine.Remove, esp.tracerLine) end
    if esp.nameText then pcall(esp.nameText.Remove, esp.nameText) end
    if esp.distanceText then pcall(esp.distanceText.Remove, esp.distanceText) end
    if esp.highlight then pcall(esp.highlight.Destroy, esp.highlight) end
    if esp.humanoid then pcall(esp.humanoid.Destroy, esp.humanoid) end

    for _, mod in ipairs(esp.ModifiedParts) do
        if mod.Part and mod.Part.Parent then
            mod.Part.Transparency = mod.Original
        end
    end

    esp.tracerLine = nil
    esp.nameText = nil
    esp.distanceText = nil
    esp.highlight = nil
    esp.humanoid = nil
    esp.ModifiedParts = {}
    esp.visibleParts = nil
end

local function CreateDrawings(esp)
    local allParts = collectBaseParts(esp.Target)
    setupCollision(esp, esp.Target, esp.Collision, allParts)

    esp.tracerLine = createDrawing("Line", {Thickness = esp.LineThickness, Transparency = esp.Opacity, Visible = false})
    esp.nameText   = createDrawing("Text", {Size = esp.FontSize, Center = true, Outline = esp.TextOutlineEnabled, OutlineColor = esp.TextOutlineColor, Font = esp.Font, Transparency = esp.Opacity, Visible = false})
    esp.distanceText = createDrawing("Text", {Size = esp.FontSize - 2, Center = true, Outline = esp.TextOutlineEnabled, OutlineColor = esp.TextOutlineColor, Font = esp.Font, Transparency = esp.Opacity, Visible = false})

    setupHighlight(esp, esp.Target)
end

function KoltESP:Add(target, config)
    if not target or not target:IsA("Instance") or not (target:IsA("Model") or target:IsA("BasePart")) then return end

    self:Remove(target)

    local cfg = {
        Target = target,
        Name = (config and config.Name) or target.Name,
        DistancePrefix = (config and config.DistancePrefix) or "",
        DistanceSuffix = (config and config.DistanceSuffix) or "",
        DisplayOrder = (config and config.DisplayOrder) or 0,
        Types = {
            Tracer = (config and config.Types and config.Types.Tracer == false) and false or true,
            Name = (config and config.Types and config.Types.Name == false) and false or true,
            Distance = (config and config.Types and config.Types.Distance == false) and false or true,
            HighlightFill = (config and config.Types and config.Types.HighlightFill == false) and false or true,
            HighlightOutline = (config and config.Types and config.Types.HighlightOutline == false) and false or true,
        },
        TextOutlineEnabled = (config and config.TextOutlineEnabled ~= nil) and config.TextOutlineEnabled or self.EspSettings.TextOutlineEnabled,
        TextOutlineColor = config and config.TextOutlineColor or self.EspSettings.TextOutlineColor,
        Opacity = config and config.Opacity or self.EspSettings.Opacity,
        LineThickness = config and config.LineThickness or self.EspSettings.LineThickness,
        FontSize = config and config.FontSize or self.EspSettings.FontSize,
        Font = config and config.Font or self.EspSettings.Font,
        MaxDistance = config and config.MaxDistance or self.EspSettings.MaxDistance,
        MinDistance = config and config.MinDistance or self.EspSettings.MinDistance,
        Collision = config and config.Collision or false,
        ModifiedParts = {},
    }

    applyColors(cfg, config)
    CreateDrawings(cfg)
    table.insert(self.Objects, cfg)
end

function KoltESP:Remove(target)
    for i = #self.Objects, 1, -1 do
        if self.Objects[i].Target == target then
            CleanupESP(self.Objects[i])
            table.remove(self.Objects, i)
            break
        end
    end
end

function KoltESP:Clear()
    for i = #self.Objects, 1, -1 do
        CleanupESP(self.Objects[i])
        table.remove(self.Objects, i)
    end
end

KoltESP.connection = RunService.RenderStepped:Connect(function()
    if not KoltESP.EspSettings.Enabled then
        for _, esp in ipairs(KoltESP.Objects) do
            if esp.tracerLine then esp.tracerLine.Visible = false end
            if esp.nameText then esp.nameText.Visible = false end
            if esp.distanceText then esp.distanceText.Visible = false end
            if esp.highlight then esp.highlight.Enabled = false end
        end
        return
    end

    local camera = workspace.CurrentCamera
    local vs = camera.ViewportSize
    local rainbow = KoltESP.EspSettings.RainbowMode
    local rainbowCol = getRainbowColor(tick())

    for i = #KoltESP.Objects, 1, -1 do
        local esp = KoltESP.Objects[i]
        local target = esp.Target

        if not target or not target.Parent then
            if KoltESP.EspSettings.AutoRemoveInvalid then KoltESP:Remove(target) end
            continue
        end

        local cf, size = getBoundingBox(target)
        if not cf then continue end

        local pos3D = cf.Position
        if esp.visibleParts and #esp.visibleParts > 0 then
            local total = Vector3.zero
            local volTotal = 0
            for _, part in ipairs(esp.visibleParts) do
                if part and part.Parent then
                    local vol = part.Size.Magnitude
                    total += part.Position * vol
                    volTotal += vol
                end
            end
            if volTotal > 0 then pos3D = total / volTotal end
        end

        local screenPos, onScreen = camera:WorldToViewportPoint(pos3D)
        if not onScreen or screenPos.Z <= 0 then
            esp.tracerLine.Visible = false
            esp.nameText.Visible = false
            esp.distanceText.Visible = false
            if esp.highlight then esp.highlight.Enabled = false end
            continue
        end

        local distance = (camera.CFrame.Position - pos3D).Magnitude
        if distance < esp.MinDistance or distance > esp.MaxDistance then
            esp.tracerLine.Visible = false
            esp.nameText.Visible = false
            esp.distanceText.Visible = false
            if esp.highlight then esp.highlight.Enabled = false end
            continue
        end

        local col = rainbow and rainbowCol or (esp.ColorDependency and esp.ColorDependency(esp, distance, pos3D)) or nil

        if KoltESP.EspSettings.ShowTracer and esp.Types.Tracer then
            esp.tracerLine.Visible = true
            esp.tracerLine.From = tracerOrigins[KoltESP.EspSettings.TracerOrigin](vs)
            esp.tracerLine.To = Vector2.new(screenPos.X, screenPos.Y)
            esp.tracerLine.Color = col or esp.Colors.Tracer
        else
            esp.tracerLine.Visible = false
        end

        local yOffset = screenPos.Y - esp.FontSize
        if KoltESP.EspSettings.ShowName and esp.Types.Name then
            esp.nameText.Visible = true
            esp.nameText.Position = Vector2.new(screenPos.X, yOffset)
            esp.nameText.Text = esp.Name
            esp.nameText.Color = col or esp.Colors.Name
        else
            esp.nameText.Visible = false
        end

        if KoltESP.EspSettings.ShowDistance and esp.Types.Distance then
            esp.distanceText.Visible = true
            esp.distanceText.Position = Vector2.new(screenPos.X, yOffset + esp.FontSize)
            esp.distanceText.Text = esp.DistancePrefix .. string.format("%.1f", distance) .. esp.DistanceSuffix
            esp.distanceText.Color = col or esp.Colors.Distance
        else
            esp.distanceText.Visible = false
        end

        if esp.highlight then
            local show = (KoltESP.EspSettings.ShowHighlightFill and esp.Types.HighlightFill) or (KoltESP.EspSettings.ShowHighlightOutline and esp.Types.HighlightOutline)
            esp.highlight.Enabled = show
            if show then
                esp.highlight.FillColor = col or esp.Colors.Highlight.Filled
                esp.highlight.OutlineColor = col or esp.Colors.Highlight.Outline
            end
        end
    end
end)


return KoltESP
