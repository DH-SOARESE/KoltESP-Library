local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

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

getgenv().ESP = ESP
getgenv().Kolt = getgenv().Kolt or {}
getgenv().Kolt.ESP = ESP

local KoltESP = {
    Objects = {},
    Named = ESP,
    Theme = {
        PrimaryColor = Color3.fromRGB(130, 200, 255),
        SecondaryColor = Color3.fromRGB(255, 255, 255),
        OutlineColor = Color3.fromRGB(0, 0, 0),
    },
    GlobalSettings = {
        TracerOrigin = "Bottom",
        ShowTracer = true,
        ShowHighlightFill = true,
        ShowHighlightOutline = true,
        ShowName = true,
        ShowDistance = true,
        RainbowMode = false,
        Opacity = 0.8,
        LineThickness = 1.5,
        FontSize = 14,
        Font = 3,
        HighlightTransparency = {
            Filled = 0.5,
            Outline = 0.3
        },
        TextOutlineEnabled = true,
        TextOutlineColor = Color3.fromRGB(0, 0, 0),
    }
}

-- Cor arco-íris
local function getRainbowColor(t)
    local f = 2
    return Color3.fromRGB(
        math.sin(f*t+0)*127+128,
        math.sin(f*t+2)*127+128,
        math.sin(f*t+4)*127+128
    )
end

local tracerOrigins = {
    Top = function(vs) return Vector2.new(vs.X/2, 0) end,
    Center = function(vs) return Vector2.new(vs.X/2, vs.Y/2) end,
    Bottom = function(vs) return Vector2.new(vs.X/2, vs.Y) end,
    Left = function(vs) return Vector2.new(0, vs.Y/2) end,
    Right = function(vs) return Vector2.new(vs.X, vs.Y/2) end,
}

local function getBoundingBox(target)
    if target:IsA("Model") then
        return target:GetBoundingBox()
    elseif target:IsA("BasePart") then
        return target.CFrame, target.Size
    end
    return nil, nil
end

local function createDrawing(class, props)
    local obj = Drawing.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
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
            self.GlobalSettings.HighlightTransparency.Filled = math.clamp(trans.Filled, 0, 1)
        end
        if trans.Outline and typeof(trans.Outline) == "number" then
            self.GlobalSettings.HighlightTransparency.Outline = math.clamp(trans.Outline, 0, 1)
        end
    end
end

local function collectBaseParts(target)
    local allParts = {}
    for _, desc in ipairs(target:GetDescendants()) do
        if desc:IsA("BasePart") then
            table.insert(allParts, desc)
        end
    end
    if target:IsA("BasePart") then
        table.insert(allParts, target)
    end
    return allParts
end

local function setupHighlight(esp, target)
    if not (KoltESP.GlobalSettings.ShowHighlightFill or KoltESP.GlobalSettings.ShowHighlightOutline) then
        if esp.highlight then
            esp.highlight:Destroy()
            esp.highlight = nil
        end
        return
    end

    if not esp.highlight then
        esp.highlight = Instance.new("Highlight")
        esp.highlight.Name = "ESPHighlight"
        esp.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        esp.highlight.Parent = getHighlightFolder()
    end

    esp.highlight.Adornee = target
end

local function applyColors(cfg, config)
    local defaultColors = {
        Name = KoltESP.Theme.PrimaryColor,
        Distance = KoltESP.Theme.PrimaryColor,
        Tracer = KoltESP.Theme.PrimaryColor,
        Highlight = {
            Filled = KoltESP.Theme.PrimaryColor,
            Outline = KoltESP.Theme.SecondaryColor
        }
    }
    cfg.Colors = defaultColors

    if config and config.Color then
        if typeof(config.Color) == "Color3" then
            cfg.Colors.Name = config.Color
            cfg.Colors.Distance = config.Color
            cfg.Colors.Tracer = config.Color
            cfg.Colors.Highlight.Filled = config.Color
            cfg.Colors.Highlight.Outline = config.Color
        elseif typeof(config.Color) == "table" then
            if config.Color.Name then cfg.Colors.Name = Color3.fromRGB(unpack(config.Color.Name)) end
            if config.Color.Distance then cfg.Colors.Distance = Color3.fromRGB(unpack(config.Color.Distance)) end
            if config.Color.Tracer then cfg.Colors.Tracer = Color3.fromRGB(unpack(config.Color.Tracer)) end
            if config.Color.Highlight then
                if config.Color.Highlight.Filled then cfg.Colors.Highlight.Filled = Color3.fromRGB(unpack(config.Color.Highlight.Filled)) end
                if config.Color.Highlight.Outline then cfg.Colors.Highlight.Outline = Color3.fromRGB(unpack(config.Color.Highlight.Outline)) end
            end
        end
    end
end

local function setupCollision(esp, target, collision, allParts)
    if collision then
        local humanoid = target:FindFirstChild("Esp")
        if not humanoid then
            humanoid = Instance.new("Humanoid")
            humanoid.Name = "Esp"
            humanoid.Parent = target
        end
        esp.humanoid = humanoid

        for _, part in ipairs(allParts) do
            if part.Transparency == 1 then
                table.insert(esp.ModifiedParts, {Part = part, OriginalTransparency = 1})
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

local function CleanupESP(esp)
    if esp.tracerLine then pcall(esp.tracerLine.Remove, esp.tracerLine) end
    if esp.nameText then pcall(esp.nameText.Remove, esp.nameText) end
    if esp.distanceText then pcall(esp.distanceText.Remove, esp.distanceText) end
    if esp.highlight then esp.highlight:Destroy() end
    if esp.humanoid then esp.humanoid:Destroy() end

    for _, mod in ipairs(esp.ModifiedParts) do
        if mod.Part and mod.Part.Parent then
            mod.Part.Transparency = mod.OriginalTransparency
        end
    end
    esp.ModifiedParts = {}
    esp.visibleParts = nil
end

local function CreateDrawings(esp)
    local allParts = collectBaseParts(esp.Target)
    setupCollision(esp, esp.Target, esp.Collision, allParts)

    esp.tracerLine = createDrawing("Line", {
        Thickness = esp.LineThickness,
        Transparency = esp.Opacity,
        Visible = false,
        ZIndex = esp.DisplayOrder
    })

    esp.nameText = createDrawing("Text", {
        Text = esp.Name,
        Size = esp.FontSize,
        Center = true,
        Outline = esp.TextOutlineEnabled,
        OutlineColor = esp.TextOutlineColor,
        Font = esp.Font,
        Transparency = esp.Opacity,
        Visible = false,
        ZIndex = esp.DisplayOrder
    })

    esp.distanceText = createDrawing("Text", {
        Text = "",
        Size = esp.FontSize - 2,
        Center = true,
        Outline = esp.TextOutlineEnabled,
        OutlineColor = esp.TextOutlineColor,
        Font = esp.Font,
        Transparency = esp.Opacity,
        Visible = false,
        ZIndex = esp.DisplayOrder
    })

    setupHighlight(esp, esp.Target)
end

local esp_mt = {
    __newindex = function(t, k, v)
        local old = rawget(t, k)
        if k == "Collision" and v ~= old then
            rawset(t, "Collision", v)
            
            for _, mod in ipairs(t.ModifiedParts) do
                if mod.Part and mod.Part.Parent then
                    mod.Part.Transparency = mod.OriginalTransparency
                end
            end
            t.ModifiedParts = {}

            if t.humanoid then
                t.humanoid:Destroy()
                t.humanoid = nil
            end

            local allParts = collectBaseParts(t.Target)
            setupCollision(t, t.Target, v, allParts)
            return
        end
        rawset(t, k, v)
    end
}

function KoltESP:Add(a1, a2, a3)
    local key, target, config

    if typeof(a1) == "string" then
        key = a1
        target = a2
        config = a3 or {}
    else
        key = nil
        target = a1
        config = a2 or {}
    end

    if not target or not target:IsA("Instance") or not (target:IsA("Model") or target:IsA("BasePart")) then return end

    local existing = self:GetESP(target)
    if existing then self:Remove(target) end

    for _, obj in ipairs(target:GetChildren()) do
        if obj:IsA("Highlight") and obj.Name == "ESPHighlight" then obj:Destroy() end
    end

    local cfg = {
        Target = target,
        Name = config.Name or target.Name,
        ModifiedParts = {},
        DistancePrefix = config.DistancePrefix or "",
        DistanceSuffix = config.DistanceSuffix or "",
        DisplayOrder = config.DisplayOrder or 0,
        Types = {
            Tracer = (config.Types and config.Types.Tracer ~= false) and true or false,
            Name = (config.Types and config.Types.Name ~= false) and true or false,
            Distance = (config.Types and config.Types.Distance ~= false) and true or false,
            HighlightFill = (config.Types and config.Types.HighlightFill ~= false) and true or false,
            HighlightOutline = (config.Types and config.Types.HighlightOutline ~= false) and true or false,
        },
        TextOutlineEnabled = config.TextOutlineEnabled ~= nil and config.TextOutlineEnabled or self.GlobalSettings.TextOutlineEnabled,
        TextOutlineColor = config.TextOutlineColor or self.GlobalSettings.TextOutlineColor,
        Opacity = config.Opacity or self.GlobalSettings.Opacity,
        LineThickness = config.LineThickness or self.GlobalSettings.LineThickness,
        FontSize = config.FontSize or self.GlobalSettings.FontSize,
        Font = config.Font or self.GlobalSettings.Font,
        MaxDistance = config.MaxDistance or self.GlobalSettings.MaxDistance,
        MinDistance = config.MinDistance or self.GlobalSettings.MinDistance,
        Collision = config.Collision or false,
        Identifier = key,
    }

    applyColors(cfg, config)

    CreateDrawings(cfg)

    setmetatable(cfg, esp_mt)

    table.insert(self.Objects, cfg)

    if key then
        if ESP[key] then
            self:Remove(ESP[key].Target)
        end
        ESP[key] = cfg
    end

    return cfg
end

function KoltESP:Remove(identifier)
    local target = identifier
    if typeof(identifier) == "string" then
        local esp = ESP[identifier]
        if not esp then return end
        target = esp.Target
    end

    for i = #self.Objects, 1, -1 do
        local obj = self.Objects[i]
        if obj.Target == target then
            CleanupESP(obj)
            if obj.Identifier then
                ESP[obj.Identifier] = nil
            end
            table.remove(self.Objects, i)
            break
        end
end

function KoltESP:Clear()
    for i = #self.Objects, 1, -1 do
        CleanupESP(self.Objects[i])
        if self.Objects[i].Identifier then
            ESP[self.Objects[i].Identifier] = nil
        end
        table.remove(self.Objects, i)
    end
end

function KoltESP:SetGlobalOpacity(value)
    value = math.clamp(value, 0, 1)
    self.GlobalSettings.Opacity = value
    for _, esp in ipairs(self.Objects) do
        esp.Opacity = value
    end
end

function KoltESP:SetGlobalLineThickness(thick)
    self.GlobalSettings.LineThickness = math.max(1, thick)
    for _, esp in ipairs(self.Objects) do
        esp.LineThickness = self.GlobalSettings.LineThickness
    end
end

function KoltESP:SetGlobalFontSize(size)
    self.GlobalSettings.FontSize = math.max(10, size)
    for _, esp in ipairs(self.Objects) do
        esp.FontSize = self.GlobalSettings.FontSize
    end
end

function KoltESP:SetGlobalFont(font)
    if typeof(font) == "number" and font >= 0 and font <= 3 then
        self.GlobalSettings.Font = font
        for _, esp in ipairs(self.Objects) do
            esp.Font = font
        end
    end
end

function KoltESP:SetGlobalTextOutline(enabled, color)
    if enabled ~= nil then self.GlobalSettings.TextOutlineEnabled = enabled end
    if color then self.GlobalSettings.TextOutlineColor = color end

    for _, esp in ipairs(self.Objects) do
        if enabled ~= nil then esp.TextOutlineEnabled = enabled end
        if color then esp.TextOutlineColor = color end
    end
end

function KoltESP:SetGlobalTracerOrigin(origin) if tracerOrigins[origin] then self.GlobalSettings.TracerOrigin = origin end end
function KoltESP:SetGlobalESPType(typeName, enabled) self.GlobalSettings[typeName] = enabled end
function KoltESP:SetGlobalRainbow(enable) self.GlobalSettings.RainbowMode = enable end

RunService.RenderStepped:Connect(function()
    local camera = workspace.CurrentCamera
    local vs = camera.ViewportSize
    local time = tick()
    local useRainbow = KoltESP.GlobalSettings.RainbowMode
    local rainbowColor = getRainbowColor(time)

    for i = #KoltESP.Objects, 1, -1 do
        local esp = KoltESP.Objects[i]
        local target = esp.Target
        if not target or not target.Parent then
            if KoltESP.GlobalSettings.AutoRemoveInvalid then
                KoltESP:Remove(target)
            end
            continue
        end

        -- atualiza propriedades visuais dinamicamente
        if esp.tracerLine then
            esp.tracerLine.Thickness = esp.LineThickness
            esp.tracerLine.Transparency = esp.Opacity
            esp.tracerLine.ZIndex = esp.DisplayOrder
        end
        if esp.nameText then
            esp.nameText.Size = esp.FontSize
            esp.nameText.Transparency = esp.Opacity
            esp.nameText.Outline = esp.TextOutlineEnabled
            esp.nameText.OutlineColor = esp.TextOutlineColor
            esp.nameText.Font = esp.Font
            esp.nameText.ZIndex = esp.DisplayOrder
        end
        if esp.distanceText then
            esp.distanceText.Size = esp.FontSize - 2
            esp.distanceText.Transparency = esp.Opacity
            esp.distanceText.Outline = esp.TextOutlineEnabled
            esp.distanceText.OutlineColor = esp.TextOutlineColor
            esp.distanceText.Font = esp.Font
            esp.distanceText.ZIndex = esp.DisplayOrder
        end
        
        local pos3D
        if esp.visibleParts then
            local totalPos = Vector3.zero
            local totalVolume = 0
            for _, part in ipairs(esp.visibleParts) do
                if part and part.Parent then
                    local vol = part.Size.X * part.Size.Y * part.Size.Z
                    totalPos += part.Position * vol
                    totalVolume += vol
                end
            end
            if totalVolume > 0 then
                pos3D = totalPos / totalVolume
            else
                local cf, _ = getBoundingBox(target)
                pos3D = cf and cf.Position
            end
        else
            local cf, _ = getBoundingBox(target)
            if cf then pos3D = cf.Position end
        end

        if not pos3D then continue end

        local success, pos2D = pcall(camera.WorldToViewportPoint, camera, pos3D)
        if not success or pos2D.Z <= 0 then
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

        local currentColor = esp.ColorDependency and esp.ColorDependency(esp, distance, pos3D)

        local centerX = pos2D.X
        local centerY = pos2D.Y
        local nameSize = esp.nameText.Size
        local distSize = esp.distanceText.Size
        local totalHeight = nameSize + distSize
        local startY = centerY - totalHeight / 2

        esp.tracerLine.Visible = KoltESP.GlobalSettings.ShowTracer and esp.Types.Tracer
        esp.tracerLine.From = tracerOrigins[KoltESP.GlobalSettings.TracerOrigin](vs)
        esp.tracerLine.To = Vector2.new(pos2D.X, pos2D.Y)
        esp.tracerLine.Color = useRainbow and rainbowColor or (currentColor or esp.Colors.Tracer)

        esp.nameText.Visible = KoltESP.GlobalSettings.ShowName and esp.Types.Name
        esp.nameText.Position = Vector2.new(centerX, startY)
        esp.nameText.Text = esp.Name
        esp.nameText.Color = useRainbow and rainbowColor or (currentColor or esp.Colors.Name)

        esp.distanceText.Visible = KoltESP.GlobalSettings.ShowDistance and esp.Types.Distance
        esp.distanceText.Position = Vector2.new(centerX, startY + nameSize)
        esp.distanceText.Text = esp.DistancePrefix .. string.format("%.1f", distance) .. esp.DistanceSuffix
        esp.distanceText.Color = useRainbow and rainbowColor or (currentColor or esp.Colors.Distance)

        if esp.highlight then
            local showFill = KoltESP.GlobalSettings.ShowHighlightFill and esp.Types.HighlightFill
            local showOutline = KoltESP.GlobalSettings.ShowHighlightOutline and esp.Types.HighlightOutline
            esp.highlight.Enabled = showFill or showOutline
            esp.highlight.FillColor = useRainbow and rainbowColor or (currentColor or esp.Colors.Highlight.Filled)
            esp.highlight.OutlineColor = useRainbow and rainbowColor or (currentColor or esp.Colors.Highlight.Outline)
            esp.highlight.FillTransparency = showFill and KoltESP.GlobalSettings.HighlightTransparency.Filled or 1
            esp.highlight.OutlineTransparency = showOutline and KoltESP.GlobalSettings.HighlightTransparency.Outline or 1
        end
    end
end)

return KoltESP
