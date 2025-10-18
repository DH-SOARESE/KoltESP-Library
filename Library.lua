--// 📦 Library Kolt V1.7
--// 👤 Autor: Kolt
--// 🎨 Estilo: Minimalista, eficiente e responsivo

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

local KoltESP = {
    Objects = {},
    Enabled = true,
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
        MaxDistance = math.huge,
        MinDistance = 0,
        Opacity = 0.8,
        LineThickness = 1.5,
        FontSize = 14,
        Font = 3,  -- 0: UI, 1: System, 2: Plex, 3: Monospace
        AutoRemoveInvalid = true,
        HighlightTransparency = {
            Filled = 0.5,
            Outline = 0.3
        },
        TextOutlineEnabled = true,
        TextOutlineColor = Color3.fromRGB(0, 0, 0),
        TextOutlineThickness = 1,
        FovEnabled = false,
        Fov = 90,
        FovCircleEnabled = false
    }
}

--// Funções auxiliares
local function getRainbowColor(t)
    local f = 2
    return Color3.fromRGB(
        math.floor(math.sin(f * t + 0) * 127 + 128),
        math.floor(math.sin(f * t + 2) * 127 + 128),
        math.floor(math.sin(f * t + 4) * 127 + 128)
    )
end

local tracerOrigins = {
    Top = function(vs) return Vector2.new(vs.X / 2, 0) end,
    Center = function(vs) return Vector2.new(vs.X / 2, vs.Y / 2) end,
    Bottom = function(vs) return Vector2.new(vs.X / 2, vs.Y) end,
    Left = function(vs) return Vector2.new(0, vs.Y / 2) end,
    Right = function(vs) return Vector2.new(vs.X, vs.Y / 2) end,
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
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

local fovCircle = createDrawing("Circle", {
    NumSides = 64,
    Filled = false,
    Thickness = 1.5,
    Transparency = KoltESP.GlobalSettings.Opacity,
    Color = KoltESP.Theme.SecondaryColor,
    Visible = false
})

local function collectBaseParts(target)
    local parts = {}
    if target:IsA("BasePart") then
        table.insert(parts, target)
    end
    for _, desc in target:GetDescendants() do
        if desc:IsA("BasePart") then
            table.insert(parts, desc)
        end
    end
    return parts
end

local function applyColors(esp, config)
    local colors = {
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
            colors.Name = config.Color
            colors.Distance = config.Color
            colors.Tracer = config.Color
            colors.Highlight.Filled = config.Color
            colors.Highlight.Outline = config.Color
        elseif typeof(config.Color) == "table" then
            if config.Color.Name and typeof(config.Color.Name) == "table" and #config.Color.Name == 3 then
                colors.Name = Color3.fromRGB(unpack(config.Color.Name))
            end
            if config.Color.Distance and typeof(config.Color.Distance) == "table" and #config.Color.Distance == 3 then
                colors.Distance = Color3.fromRGB(unpack(config.Color.Distance))
            end
            if config.Color.Tracer and typeof(config.Color.Tracer) == "table" and #config.Color.Tracer == 3 then
                colors.Tracer = Color3.fromRGB(unpack(config.Color.Tracer))
            end
            if config.Color.Highlight and typeof(config.Color.Highlight) == "table" then
                if config.Color.Highlight.Filled and typeof(config.Color.Highlight.Filled) == "table" and #config.Color.Highlight.Filled == 3 then
                    colors.Highlight.Filled = Color3.fromRGB(unpack(config.Color.Highlight.Filled))
                end
                if config.Color.Highlight.Outline and typeof(config.Color.Highlight.Outline) == "table" and #config.Color.Highlight.Outline == 3 then
                    colors.Highlight.Outline = Color3.fromRGB(unpack(config.Color.Highlight.Outline))
                end
            end
        end
    end

    esp.Colors = colors
end

local function setupCollision(esp, target, collision, parts)
    esp.ModifiedParts = {}
    esp.visibleParts = nil

    if collision then
        for _, part in ipairs(parts) do
            if part.Transparency >= 0.99 then
                table.insert(esp.ModifiedParts, {Part = part, OriginalTransparency = part.Transparency})
                part.Transparency = 0.98  -- Ligeiramente ajustado para melhor visibilidade
            end
        end
    else
        esp.visibleParts = {}
        for _, part in ipairs(parts) do
            if part.Transparency < 0.99 then
                table.insert(esp.visibleParts, part)
            end
        end
    end
end

local function setupHighlight(esp, target)
    if esp.highlight then
        esp.highlight:Destroy()
        esp.highlight = nil
    end

    if KoltESP.GlobalSettings.ShowHighlightFill or KoltESP.GlobalSettings.ShowHighlightOutline then
        esp.highlight = Instance.new("Highlight")
        esp.highlight.Name = "ESPHighlight"
        esp.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        esp.highlight.Adornee = target
        esp.highlight.Parent = getHighlightFolder()
        esp.highlight.FillTransparency = KoltESP.GlobalSettings.ShowHighlightFill and KoltESP.GlobalSettings.HighlightTransparency.Filled or 1
        esp.highlight.OutlineTransparency = KoltESP.GlobalSettings.ShowHighlightOutline and KoltESP.GlobalSettings.HighlightTransparency.Outline or 1
    end
end

--// APIs Principais
function KoltESP:GetESP(target)
    for _, esp in self.Objects do
        if esp.Target == target then
            return esp
        end
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
        if typeof(trans.Filled) == "number" then
            self.GlobalSettings.HighlightTransparency.Filled = math.clamp(trans.Filled, 0, 1)
        end
        if typeof(trans.Outline) == "number" then
            self.GlobalSettings.HighlightTransparency.Outline = math.clamp(trans.Outline, 0, 1)
        end
        self:UpdateGlobalSettings()
    end
end

function KoltESP:Add(target, config)
    if not target or not target:IsA("Instance") or not (target:IsA("Model") or target:IsA("BasePart")) then
        return
    end

    local existing = self:GetESP(target)
    if existing then
        self:Remove(target)
    end

    for _, child in target:GetChildren() do
        if child:IsA("Highlight") and child.Name == "ESPHighlight" then
            child:Destroy()
        end
    end

    local esp = {
        Target = target,
        Enabled = true,
        Name = config.Name or target.Name,
        DistancePrefix = config.DistancePrefix or "",
        DistanceSuffix = config.DistanceSuffix or "",
        DisplayOrder = config.DisplayOrder or 0,
        Types = {
            Tracer = config.Types and config.Types.Tracer ~= false or true,
            Name = config.Types and config.Types.Name ~= false or true,
            Distance = config.Types and config.Types.Distance ~= false or true,
            HighlightFill = config.Types and config.Types.HighlightFill ~= false or true,
            HighlightOutline = config.Types and config.Types.HighlightOutline ~= false or true,
        },
        TextOutlineEnabled = config.TextOutlineEnabled ~= nil and config.TextOutlineEnabled or self.GlobalSettings.TextOutlineEnabled,
        TextOutlineColor = config.TextOutlineColor or self.GlobalSettings.TextOutlineColor,
        TextOutlineThickness = config.TextOutlineThickness or self.GlobalSettings.TextOutlineThickness,
        ColorDependency = config.ColorDependency or nil,
        Opacity = config.Opacity or self.GlobalSettings.Opacity,
        LineThickness = config.LineThickness or self.GlobalSettings.LineThickness,
        FontSize = config.FontSize or self.GlobalSettings.FontSize,
        Font = config.Font or self.GlobalSettings.Font,
        MaxDistance = config.MaxDistance or self.GlobalSettings.MaxDistance,
        MinDistance = config.MinDistance or self.GlobalSettings.MinDistance,
        ModifiedParts = {},
    }

    applyColors(esp, config)

    local parts = collectBaseParts(target)
    setupCollision(esp, target, config.Collision, parts)
    setupHighlight(esp, target)

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

    table.insert(self.Objects, esp)
    return esp
end

function KoltESP:Readjustment(newTarget, oldTarget, newConfig)
    local esp = self:GetESP(oldTarget)
    if not esp then
        return
    end

    -- Limpa setups antigos
    for _, mod in esp.ModifiedParts do
        if mod.Part and mod.Part.Parent then
            mod.Part.Transparency = mod.OriginalTransparency
        end
    end
    esp.ModifiedParts = {}

    esp.Target = newTarget
    esp.Name = newConfig.Name or newTarget.Name
    esp.DistancePrefix = newConfig.DistancePrefix or ""
    esp.DistanceSuffix = newConfig.DistanceSuffix or ""
    esp.DisplayOrder = newConfig.DisplayOrder or 0
    esp.TextOutlineEnabled = newConfig.TextOutlineEnabled ~= nil and newConfig.TextOutlineEnabled or self.GlobalSettings.TextOutlineEnabled
    esp.TextOutlineColor = newConfig.TextOutlineColor or self.GlobalSettings.TextOutlineColor
    esp.TextOutlineThickness = newConfig.TextOutlineThickness or self.GlobalSettings.TextOutlineThickness
    esp.ColorDependency = newConfig.ColorDependency or nil
    esp.Opacity = newConfig.Opacity or self.GlobalSettings.Opacity
    esp.LineThickness = newConfig.LineThickness or self.GlobalSettings.LineThickness
    esp.FontSize = newConfig.FontSize or self.GlobalSettings.FontSize
    esp.Font = newConfig.Font or self.GlobalSettings.Font
    esp.MaxDistance = newConfig.MaxDistance or self.GlobalSettings.MaxDistance
    esp.MinDistance = newConfig.MinDistance or self.GlobalSettings.MinDistance

    esp.Types = {
        Tracer = newConfig.Types and newConfig.Types.Tracer ~= false or true,
        Name = newConfig.Types and newConfig.Types.Name ~= false or true,
        Distance = newConfig.Types and newConfig.Types.Distance ~= false or true,
        HighlightFill = newConfig.Types and newConfig.Types.HighlightFill ~= false or true,
        HighlightOutline = newConfig.Types and newConfig.Types.HighlightOutline ~= false or true,
    }

    applyColors(esp, newConfig)

    local parts = collectBaseParts(newTarget)
    setupCollision(esp, newTarget, newConfig.Collision, parts)
    setupHighlight(esp, newTarget)

    esp.tracerLine.ZIndex = esp.DisplayOrder
    esp.tracerLine.Thickness = esp.LineThickness
    esp.tracerLine.Transparency = esp.Opacity

    esp.nameText.ZIndex = esp.DisplayOrder
    esp.nameText.Outline = esp.TextOutlineEnabled
    esp.nameText.OutlineColor = esp.TextOutlineColor
    esp.nameText.Size = esp.FontSize
    esp.nameText.Transparency = esp.Opacity
    esp.nameText.Font = esp.Font

    esp.distanceText.ZIndex = esp.DisplayOrder
    esp.distanceText.Outline = esp.TextOutlineEnabled
    esp.distanceText.OutlineColor = esp.TextOutlineColor
    esp.distanceText.Size = esp.FontSize - 2
    esp.distanceText.Transparency = esp.Opacity
    esp.distanceText.Font = esp.Font
end

function KoltESP:UpdateConfig(target, newConfig)
    local esp = self:GetESP(target)
    if not esp then
        return
    end

    if newConfig.Name then esp.Name = newConfig.Name end
    if newConfig.DistancePrefix then esp.DistancePrefix = newConfig.DistancePrefix end
    if newConfig.DistanceSuffix then esp.DistanceSuffix = newConfig.DistanceSuffix end
    if newConfig.DisplayOrder ~= nil then
        esp.DisplayOrder = newConfig.DisplayOrder
        esp.tracerLine.ZIndex = esp.DisplayOrder
        esp.nameText.ZIndex = esp.DisplayOrder
        esp.distanceText.ZIndex = esp.DisplayOrder
    end
    if newConfig.TextOutlineEnabled ~= nil then
        esp.TextOutlineEnabled = newConfig.TextOutlineEnabled
        esp.nameText.Outline = esp.TextOutlineEnabled
        esp.distanceText.Outline = esp.TextOutlineEnabled
    end
    if newConfig.TextOutlineColor then
        esp.TextOutlineColor = newConfig.TextOutlineColor
        esp.nameText.OutlineColor = esp.TextOutlineColor
        esp.distanceText.OutlineColor = esp.TextOutlineColor
    end
    if newConfig.TextOutlineThickness then
        esp.TextOutlineThickness = newConfig.TextOutlineThickness
    end
    if newConfig.ColorDependency then
        esp.ColorDependency = newConfig.ColorDependency
    end
    if newConfig.Opacity ~= nil then
        esp.Opacity = newConfig.Opacity
        esp.tracerLine.Transparency = esp.Opacity
        esp.nameText.Transparency = esp.Opacity
        esp.distanceText.Transparency = esp.Opacity
    end
    if newConfig.LineThickness ~= nil then
        esp.LineThickness = newConfig.LineThickness
        esp.tracerLine.Thickness = esp.LineThickness
    end
    if newConfig.FontSize ~= nil then
        esp.FontSize = newConfig.FontSize
        esp.nameText.Size = esp.FontSize
        esp.distanceText.Size = esp.FontSize - 2
    end
    if newConfig.Font ~= nil then
        esp.Font = newConfig.Font
        esp.nameText.Font = esp.Font
        esp.distanceText.Font = esp.Font
    end
    if newConfig.MaxDistance ~= nil then esp.MaxDistance = newConfig.MaxDistance end
    if newConfig.MinDistance ~= nil then esp.MinDistance = newConfig.MinDistance end

    if newConfig.Color then
        applyColors(esp, newConfig)
    end

    if newConfig.Types then
        if newConfig.Types.Tracer ~= nil then esp.Types.Tracer = newConfig.Types.Tracer end
        if newConfig.Types.Name ~= nil then esp.Types.Name = newConfig.Types.Name end
        if newConfig.Types.Distance ~= nil then esp.Types.Distance = newConfig.Types.Distance end
        if newConfig.Types.HighlightFill ~= nil then esp.Types.HighlightFill = newConfig.Types.HighlightFill end
        if newConfig.Types.HighlightOutline ~= nil then esp.Types.HighlightOutline = newConfig.Types.HighlightOutline end
    end

    if newConfig.Collision ~= nil and newConfig.Collision ~= (esp.ModifiedParts and #esp.ModifiedParts > 0) then
        -- Limpa atual
        for _, mod in esp.ModifiedParts do
            if mod.Part and mod.Part.Parent then
                mod.Part.Transparency = mod.OriginalTransparency
            end
        end
        esp.ModifiedParts = {}
        esp.visibleParts = nil

        local parts = collectBaseParts(target)
        setupCollision(esp, target, newConfig.Collision, parts)
    end

    setupHighlight(esp, target)
end

function KoltESP:ToggleIndividual(target, enabled)
    local esp = self:GetESP(target)
    if esp then
        esp.Enabled = enabled == nil and not esp.Enabled or enabled
    end
end

function KoltESP:SetColor(target, color)
    local esp = self:GetESP(target)
    if esp and typeof(color) == "Color3" then
        esp.Colors.Name = color
        esp.Colors.Distance = color
        esp.Colors.Tracer = color
        esp.Colors.Highlight.Filled = color
        esp.Colors.Highlight.Outline = color
    end
end

function KoltESP:SetName(target, newName)
    local esp = self:GetESP(target)
    if esp then
        esp.Name = newName
        esp.nameText.Text = newName
    end
end

function KoltESP:SetDisplayOrder(target, displayOrder)
    local esp = self:GetESP(target)
    if esp then
        esp.DisplayOrder = displayOrder
        esp.tracerLine.ZIndex = displayOrder
        esp.nameText.ZIndex = displayOrder
        esp.distanceText.ZIndex = displayOrder
    end
end

function KoltESP:SetTextOutline(target, enabled, color, thickness)
    local esp = self:GetESP(target)
    if esp then
        if enabled ~= nil then
            esp.TextOutlineEnabled = enabled
            esp.nameText.Outline = enabled
            esp.distanceText.Outline = enabled
        end
        if color then
            esp.TextOutlineColor = color
            esp.nameText.OutlineColor = color
            esp.distanceText.OutlineColor = color
        end
        if thickness then
            esp.TextOutlineThickness = thickness
        end
    end
end

function KoltESP:Remove(target)
    for i = #self.Objects, 1, -1 do
        local esp = self.Objects[i]
        if esp.Target == target then
            esp.tracerLine:Remove()
            esp.nameText:Remove()
            esp.distanceText:Remove()
            if esp.highlight then
                esp.highlight:Destroy()
            end
            for _, mod in esp.ModifiedParts do
                if mod.Part and mod.Part.Parent then
                    mod.Part.Transparency = mod.OriginalTransparency
                end
            end
            table.remove(self.Objects, i)
            break
        end
    end
end

function KoltESP:Clear()
    for _, esp in self.Objects do
        esp.tracerLine:Remove()
        esp.nameText:Remove()
        esp.distanceText:Remove()
        if esp.highlight then
            esp.highlight:Destroy()
        end
        for _, mod in esp.ModifiedParts do
            if mod.Part and mod.Part.Parent then
                mod.Part.Transparency = mod.OriginalTransparency
            end
        end
    end
    self.Objects = {}
end

function KoltESP:Unload()
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end
    self.Enabled = false
    for player in pairs(PlayerESPs) do
        self:RemoveFromPlayer(player)
    end
    self:Clear()
    if highlightFolder then
        highlightFolder:Destroy()
        highlightFolder = nil
    end
    fovCircle:Remove()
end

function KoltESP:EnableAll()
    self.Enabled = true
end

function KoltESP:DisableAll()
    self.Enabled = false
end

function KoltESP:UpdateGlobalSettings()
    for _, esp in self.Objects do
        esp.tracerLine.Thickness = self.GlobalSettings.LineThickness
        esp.tracerLine.Transparency = self.GlobalSettings.Opacity
        esp.nameText.Size = self.GlobalSettings.FontSize
        esp.nameText.Transparency = self.GlobalSettings.Opacity
        esp.nameText.Outline = self.GlobalSettings.TextOutlineEnabled
        esp.nameText.OutlineColor = self.GlobalSettings.TextOutlineColor
        esp.nameText.Font = self.GlobalSettings.Font
        esp.distanceText.Size = self.GlobalSettings.FontSize - 2
        esp.distanceText.Transparency = self.GlobalSettings.Opacity
        esp.distanceText.Outline = self.GlobalSettings.TextOutlineEnabled
        esp.distanceText.OutlineColor = self.GlobalSettings.TextOutlineColor
        esp.distanceText.Font = self.GlobalSettings.Font
        setupHighlight(esp, esp.Target)
    end
end

--// APIs Globais
function KoltESP:SetGlobalTracerOrigin(origin)
    if tracerOrigins[origin] then
        self.GlobalSettings.TracerOrigin = origin
    end
end

function KoltESP:SetGlobalESPType(typeName, enabled)
    if self.GlobalSettings[typeName] ~= nil then
        self.GlobalSettings[typeName] = enabled
        self:UpdateGlobalSettings()
    end
end

function KoltESP:SetGlobalRainbow(enabled)
    self.GlobalSettings.RainbowMode = enabled
end

function KoltESP:SetGlobalOpacity(value)
    self.GlobalSettings.Opacity = math.clamp(value, 0, 1)
    self:UpdateGlobalSettings()
end

function KoltESP:SetGlobalFontSize(size)
    self.GlobalSettings.FontSize = math.clamp(size, 8, 36)
    self:UpdateGlobalSettings()
end

function KoltESP:SetGlobalLineThickness(thick)
    self.GlobalSettings.LineThickness = math.clamp(thick, 0.5, 5)
    self:UpdateGlobalSettings()
end

function KoltESP:SetGlobalTextOutline(enabled, color, thickness)
    if enabled ~= nil then self.GlobalSettings.TextOutlineEnabled = enabled end
    if color then self.GlobalSettings.TextOutlineColor = color end
    if thickness then self.GlobalSettings.TextOutlineThickness = math.clamp(thickness, 1, 3) end
    self:UpdateGlobalSettings()
end

function KoltESP:SetGlobalFont(font)
    if typeof(font) == "number" and font >= 0 and font <= 3 then
        self.GlobalSettings.Font = font
        self:UpdateGlobalSettings()
    end
end

function KoltESP:SetFov(enabled, fov, circleEnabled)
    self.GlobalSettings.FovEnabled = enabled
    if fov then self.GlobalSettings.Fov = math.clamp(fov, 1, 360) end
    self.GlobalSettings.FovCircleEnabled = circleEnabled ~= nil and circleEnabled or enabled
end

--// Suporte a Players
local PlayerESPs = {}

function KoltESP:AddToPlayer(player, config)
    if not player:IsA("Player") then return end

    if PlayerESPs[player] then
        self:RemoveFromPlayer(player)
    end

    local entry = {
        Config = config or {},
        Connections = {},
        CurrentTarget = nil
    }
    PlayerESPs[player] = entry

    local function setupESP(char)
        if char then
            task.wait(0.1)  -- Pequeno delay para garantir carregamento
            local esp = self:Add(char, entry.Config)
            entry.CurrentTarget = char
        end
    end

    entry.Connections.charAdded = player.CharacterAdded:Connect(setupESP)
    entry.Connections.charRemoving = player.CharacterRemoving:Connect(function(oldChar)
        self:Remove(oldChar)
        entry.CurrentTarget = nil
    end)

    setupESP(player.Character)
end

function KoltESP:RemoveFromPlayer(player)
    local entry = PlayerESPs[player]
    if not entry then return end

    for _, conn in entry.Connections do
        conn:Disconnect()
    end

    if entry.CurrentTarget then
        self:Remove(entry.CurrentTarget)
    end

    PlayerESPs[player] = nil
end

--// Loop de Atualização
KoltESP.connection = RunService.RenderStepped:Connect(function()
    if not KoltESP.Enabled then return end

    local camera = workspace.CurrentCamera
    if not camera then return end

    local vs = camera.ViewportSize
    local time = tick()
    local useRainbow = KoltESP.GlobalSettings.RainbowMode
    local rainbowColor = getRainbowColor(time)

    if KoltESP.GlobalSettings.FovCircleEnabled then
        local fovRad = math.rad(KoltESP.GlobalSettings.Fov / 2)
        local camFovRad = math.rad(camera.FieldOfView / 2)
        local radius = (vs.Y / 2) * (math.tan(fovRad) / math.tan(camFovRad))
        fovCircle.Position = vs / 2
        fovCircle.Radius = radius
        fovCircle.Color = useRainbow and rainbowColor or KoltESP.Theme.SecondaryColor
        fovCircle.Transparency = KoltESP.GlobalSettings.Opacity
        fovCircle.Thickness = KoltESP.GlobalSettings.LineThickness
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end

    for i = #KoltESP.Objects, 1, -1 do
        local esp = KoltESP.Objects[i]
        local target = esp.Target

        if not target or not target.Parent then
            if KoltESP.GlobalSettings.AutoRemoveInvalid then
                KoltESP:Remove(target)
            end
            continue
        end

        if not esp.Enabled then
            esp.tracerLine.Visible = false
            esp.nameText.Visible = false
            esp.distanceText.Visible = false
            if esp.highlight then esp.highlight.Enabled = false end
            continue
        end

        local parts = esp.visibleParts or collectBaseParts(target)  -- Dinâmico se não collision
        local pos3D = Vector3.zero
        local totalVolume = 0
        local validCount = 0

        for _, part in parts do
            if part and part.Parent then
                local vol = part.Size.Magnitude
                pos3D += part.Position * vol
                totalVolume += vol
                validCount += 1
            end
        end

        if validCount == 0 or totalVolume == 0 then
            local cf = getBoundingBox(target)
            if cf then
                pos3D = cf.Position
            else
                continue
            end
        else
            pos3D /= totalVolume
        end

        local pos2D, onScreen = camera:WorldToViewportPoint(pos3D)
        if not onScreen then
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

        if KoltESP.GlobalSettings.FovEnabled then
            local direction = (pos3D - camera.CFrame.Position).Unit
            local dot = camera.CFrame.LookVector:Dot(direction)
            local angle = math.acos(dot)
            if angle > math.rad(KoltESP.GlobalSettings.Fov / 2) then
                esp.tracerLine.Visible = false
                esp.nameText.Visible = false
                esp.distanceText.Visible = false
                if esp.highlight then esp.highlight.Enabled = false end
                continue
            end
        end

        local currentColor = esp.ColorDependency and esp.ColorDependency(esp, distance, pos3D) or nil

        local centerX, centerY = pos2D.X, pos2D.Y
        local nameSize = esp.nameText.Size
        local distSize = esp.distanceText.Size
        local totalHeight = (esp.Types.Name and nameSize or 0) + (esp.Types.Distance and distSize or 0)
        local startY = centerY - totalHeight / 2

        if KoltESP.GlobalSettings.ShowTracer and esp.Types.Tracer then
            esp.tracerLine.Visible = true
            esp.tracerLine.From = tracerOrigins[KoltESP.GlobalSettings.TracerOrigin](vs)
            esp.tracerLine.To = Vector2.new(centerX, centerY)
            esp.tracerLine.Color = useRainbow and rainbowColor or (currentColor or esp.Colors.Tracer)
        else
            esp.tracerLine.Visible = false
        end

        if KoltESP.GlobalSettings.ShowName and esp.Types.Name then
            esp.nameText.Visible = true
            esp.nameText.Position = Vector2.new(centerX, startY)
            esp.nameText.Color = useRainbow and rainbowColor or (currentColor or esp.Colors.Name)
        else
            esp.nameText.Visible = false
        end

        if KoltESP.GlobalSettings.ShowDistance and esp.Types.Distance then
            esp.distanceText.Visible = true
            esp.distanceText.Position = Vector2.new(centerX, startY + (esp.Types.Name and nameSize or 0))
            esp.distanceText.Text = esp.DistancePrefix .. math.floor(distance) .. esp.DistanceSuffix
            esp.distanceText.Color = useRainbow and rainbowColor or (currentColor or esp.Colors.Distance)
        else
            esp.distanceText.Visible = false
        end

        if esp.highlight then
            local showFill = KoltESP.GlobalSettings.ShowHighlightFill and esp.Types.HighlightFill
            local showOutline = KoltESP.GlobalSettings.ShowHighlightOutline and esp.Types.HighlightOutline
            esp.highlight.Enabled = showFill or showOutline
            esp.highlight.FillColor = useRainbow and rainbowColor or (currentColor or esp.Colors.Highlight.Filled)
            esp.highlight.OutlineColor = useRainbow and rainbowColor or esp.Colors.Highlight.Outline
            esp.highlight.FillTransparency = showFill and KoltESP.GlobalSettings.HighlightTransparency.Filled or 1
            esp.highlight.OutlineTransparency = showOutline and KoltESP.GlobalSettings.HighlightTransparency.Outline or 1
        end
    end
end)

return KoltESP
