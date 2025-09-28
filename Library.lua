--// 📦 Library Kolt V1.5
--// 👤 Autor: Kolt
--// 🎨 Estilo: Minimalista, eficiente e responsivo


local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local camera = workspace.CurrentCamera

local HighlightFolderName = "KoltESPHighlights" 
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

local ModelESP = {
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
        AutoRemoveInvalid = true,
        HighlightTransparency = {
            Filled = 0.5,
            Outline = 0.3
        }
    }
}

--// Cor arco-íris
local function getRainbowColor(t)
    local f = 2
    return Color3.fromRGB(
        math.sin(f*t+0)*127+128,
        math.sin(f*t+2)*127+128,
        math.sin(f*t+4)*127+128
    )
end

--// Tracer Origins (global only)
local tracerOrigins = {
    Top = function(vs) return Vector2.new(vs.X/2, 0) end,
    Center = function(vs) return Vector2.new(vs.X/2, vs.Y/2) end,
    Bottom = function(vs) return Vector2.new(vs.X/2, vs.Y) end,
    Left = function(vs) return Vector2.new(0, vs.Y/2) end,
    Right = function(vs) return Vector2.new(vs.X, vs.Y/2) end,
}

--/ Get Bounding Box
local function getBoundingBox(target)
    if target:IsA("Model") then
        return target:GetBoundingBox()
    elseif target:IsA("BasePart") then
        return target.CFrame, target.Size
    end
    return nil, nil
end

--// Cria Drawing
local function createDrawing(class, props)
    local obj = Drawing.new(class)
    for k,v in pairs(props) do obj[k]=v end
    return obj
end

--// Função interna para obter ESP por target
function ModelESP:GetESP(target)
    for _, esp in ipairs(self.Objects) do
        if esp.Target == target then return esp end
    end
    return nil
end

--// Configura o nome da pasta de highlights
function ModelESP:SetHighlightFolderName(name)
    if typeof(name) == "string" and name ~= "" then
        HighlightFolderName = name
        -- Reseta a pasta para recriação com novo nome se necessário
        highlightFolder = nil
    end
end

--// Define transparências globais de highlight
function ModelESP:SetGlobalHighlightTransparency(trans)
    if typeof(trans) == "table" then
        if trans.Filled and typeof(trans.Filled) == "number" then
            self.GlobalSettings.HighlightTransparency.Filled = math.clamp(trans.Filled, 0, 1)
        end
        if trans.Outline and typeof(trans.Outline) == "number" then
            self.GlobalSettings.HighlightTransparency.Outline = math.clamp(trans.Outline, 0, 1)
        end
    end
end

--// Adiciona ESP
function ModelESP:Add(target, config)
    if not target or not target:IsA("Instance") then return end
    if not (target:IsA("Model") or target:IsA("BasePart")) then return end

    -- Verifica se já existe e remove para evitar duplicatas
    local existing = self:GetESP(target)
    if existing then self:Remove(target) end

    for _, obj in ipairs(target:GetChildren()) do
        if obj:IsA("Highlight") and obj.Name == "ESPHighlight" then obj:Destroy() end
    end

    local defaultColors = {
        Name = self.Theme.PrimaryColor,
        Distance = self.Theme.PrimaryColor,
        Tracer = self.Theme.PrimaryColor,
        Highlight = {
            Filled = self.Theme.PrimaryColor,
            Outline = self.Theme.SecondaryColor
        }
    }

    local cfg = {
        Target = target,
        Enabled = true,  -- Adicionado: habilitado individualmente
        Name = config and config.Name or target.Name,
        Colors = defaultColors,
        ModifiedParts = {},
        NameContainerStart = (config and config.NameContainer and config.NameContainer.Start) or "",
        NameContainerEnd = (config and config.NameContainer and config.NameContainer.End) or "",
        DistanceSuffix = (config and config.DistanceSuffix) or "",
        DistanceContainerStart = (config and config.DistanceContainer and config.DistanceContainer.Start) or "",
        DistanceContainerEnd = (config and config.DistanceContainer and config.DistanceContainer.End) or "",
        DisplayOrder = config and config.DisplayOrder or 0  -- Novo: Camada individual
    }

    -- Aplicar cores customizadas se fornecidas
    if config and config.Color then
        if typeof(config.Color) == "Color3" then
            -- Compatibilidade com cor única (aplica a todos)
            cfg.Colors.Name = config.Color
            cfg.Colors.Distance = config.Color
            cfg.Colors.Tracer = config.Color
            cfg.Colors.Highlight.Filled = config.Color
            cfg.Colors.Highlight.Outline = config.Color
        elseif typeof(config.Color) == "table" then
            -- Tabela de cores personalizadas
            if config.Color.Name and typeof(config.Color.Name) == "table" and #config.Color.Name == 3 then
                cfg.Colors.Name = Color3.fromRGB(unpack(config.Color.Name))
            end
            if config.Color.Distance and typeof(config.Color.Distance) == "table" and #config.Color.Distance == 3 then
                cfg.Colors.Distance = Color3.fromRGB(unpack(config.Color.Distance))
            end
            if config.Color.Tracer and typeof(config.Color.Tracer) == "table" and #config.Color.Tracer == 3 then
                cfg.Colors.Tracer = Color3.fromRGB(unpack(config.Color.Tracer))
            end
            if config.Color.Highlight and typeof(config.Color.Highlight) == "table" then
                if config.Color.Highlight.Filled and typeof(config.Color.Highlight.Filled) == "table" and #config.Color.Highlight.Filled == 3 then
                    cfg.Colors.Highlight.Filled = Color3.fromRGB(unpack(config.Color.Highlight.Filled))
                end
                if config.Color.Highlight.Outline and typeof(config.Color.Highlight.Outline) == "table" and #config.Color.Highlight.Outline == 3 then
                    cfg.Colors.Highlight.Outline = Color3.fromRGB(unpack(config.Color.Highlight.Outline))
                end
            end
        end
    end

    -- Coletar todas as BaseParts
    local allParts = {}
    for _, desc in ipairs(target:GetDescendants()) do
        if desc:IsA("BasePart") then
            table.insert(allParts, desc)
        end
    end
    if target:IsA("BasePart") then
        table.insert(allParts, target)
    end

    -- Opção de Collision (individual)
    if config and config.Collision then
        local humanoid = target:FindFirstChild("Kolt ESP")
        if not humanoid then
            humanoid = Instance.new("Humanoid")
            humanoid.Name = "Kolt ESP"
            humanoid.Parent = target
        end
        cfg.humanoid = humanoid

        for _, part in ipairs(allParts) do
            if part.Transparency == 1 then
                table.insert(cfg.ModifiedParts, {Part = part, OriginalTransparency = part.Transparency})
                part.Transparency = 0.99
            end
        end
    else
        cfg.visibleParts = {}
        for _, part in ipairs(allParts) do
            if part.Transparency < 0.99 then
                table.insert(cfg.visibleParts, part)
            end
        end
    end

    -- Drawings básicos
    cfg.tracerLine = createDrawing("Line", {
        Thickness = self.GlobalSettings.LineThickness,
        Transparency = self.GlobalSettings.Opacity,
        Visible = false
    })
    cfg.tracerLine.ZIndex = cfg.DisplayOrder

    cfg.nameText = createDrawing("Text", {
        Text = cfg.Name,
        Size = self.GlobalSettings.FontSize,
        Center = true,
        Outline = false,
        OutlineColor = self.Theme.OutlineColor,
        Font = Drawing.Fonts.Monospace,
        Transparency = self.GlobalSettings.Opacity,
        Visible = false
    })
    cfg.nameText.ZIndex = cfg.DisplayOrder

    cfg.distanceText = createDrawing("Text", {
        Text = "",
        Size = self.GlobalSettings.FontSize-2,
        Center = true,
        Outline = false,
        OutlineColor = self.Theme.OutlineColor,
        Font = Drawing.Fonts.Monospace,
        Transparency = self.GlobalSettings.Opacity,
        Visible = false
    })
    cfg.distanceText.ZIndex = cfg.DisplayOrder

    -- Highlight
    if self.GlobalSettings.ShowHighlightFill or self.GlobalSettings.ShowHighlightOutline then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = self.GlobalSettings.ShowHighlightFill and self.GlobalSettings.HighlightTransparency.Filled or 1
        highlight.OutlineTransparency = self.GlobalSettings.ShowHighlightOutline and self.GlobalSettings.HighlightTransparency.Outline or 1
        local useRainbow = self.GlobalSettings.RainbowMode
        local initColor = useRainbow and getRainbowColor(tick()) or cfg.Colors.Highlight.Filled
        highlight.FillColor = initColor
        highlight.OutlineColor = useRainbow and initColor or cfg.Colors.Highlight.Outline
        highlight.Adornee = target
        highlight.Parent = getHighlightFolder()
        cfg.highlight = highlight
    end

    table.insert(self.Objects, cfg)
end

--// Reajusta ESP para novo alvo com nova config
function ModelESP:Readjustment(newTarget, oldTarget, newConfig)
    if not newTarget or not newTarget:IsA("Instance") then return end
    if not (newTarget:IsA("Model") or newTarget:IsA("BasePart")) then return end

    local esp = self:GetESP(oldTarget)
    if not esp then return end

    -- Limpa setups antigos
    if esp.humanoid then
        esp.humanoid:Destroy()
        esp.humanoid = nil
    end
    for _, mod in ipairs(esp.ModifiedParts) do
        if mod.Part and mod.Part.Parent then
            mod.Part.Transparency = mod.OriginalTransparency
        end
    end
    esp.ModifiedParts = {}
    esp.visibleParts = nil

    -- Atualiza target
    esp.Target = newTarget

    -- Atualiza config
    esp.Name = newConfig and newConfig.Name or newTarget.Name
    esp.NameContainerStart = (newConfig and newConfig.NameContainer and newConfig.NameContainer.Start) or ""
    esp.NameContainerEnd = (newConfig and newConfig.NameContainer and newConfig.NameContainer.End) or ""
    esp.DistanceSuffix = (newConfig and newConfig.DistanceSuffix) or ""
    esp.DistanceContainerStart = (newConfig and newConfig.DistanceContainer and newConfig.DistanceContainer.Start) or ""
    esp.DistanceContainerEnd = (newConfig and newConfig.DistanceContainer and newConfig.DistanceContainer.End) or ""
    esp.DisplayOrder = newConfig and newConfig.DisplayOrder or 0  -- Novo: Atualiza DisplayOrder

    -- Atualiza cores
    local defaultColors = {
        Name = self.Theme.PrimaryColor,
        Distance = self.Theme.PrimaryColor,
        Tracer = self.Theme.PrimaryColor,
        Highlight = {
            Filled = self.Theme.PrimaryColor,
            Outline = self.Theme.SecondaryColor
        }
    }
    esp.Colors = defaultColors
    if newConfig and newConfig.Color then
        if typeof(newConfig.Color) == "Color3" then
            esp.Colors.Name = newConfig.Color
            esp.Colors.Distance = newConfig.Color
            esp.Colors.Tracer = newConfig.Color
            esp.Colors.Highlight.Filled = newConfig.Color
            esp.Colors.Highlight.Outline = newConfig.Color
        elseif typeof(newConfig.Color) == "table" then
            if newConfig.Color.Name and typeof(newConfig.Color.Name) == "table" and #newConfig.Color.Name == 3 then
                esp.Colors.Name = Color3.fromRGB(unpack(newConfig.Color.Name))
            end
            if newConfig.Color.Distance and typeof(newConfig.Color.Distance) == "table" and #newConfig.Color.Distance == 3 then
                esp.Colors.Distance = Color3.fromRGB(unpack(newConfig.Color.Distance))
            end
            if newConfig.Color.Tracer and typeof(newConfig.Color.Tracer) == "table" and #newConfig.Color.Tracer == 3 then
                esp.Colors.Tracer = Color3.fromRGB(unpack(newConfig.Color.Tracer))
            end
            if newConfig.Color.Highlight and typeof(newConfig.Color.Highlight) == "table" then
                if newConfig.Color.Highlight.Filled and typeof(newConfig.Color.Highlight.Filled) == "table" and #newConfig.Color.Highlight.Filled == 3 then
                    esp.Colors.Highlight.Filled = Color3.fromRGB(unpack(newConfig.Color.Highlight.Filled))
                end
                if newConfig.Color.Highlight.Outline and typeof(newConfig.Color.Highlight.Outline) == "table" and #newConfig.Color.Highlight.Outline == 3 then
                    esp.Colors.Highlight.Outline = Color3.fromRGB(unpack(newConfig.Color.Highlight.Outline))
                end
            end
        end
    end

    -- Coletar novas BaseParts
    local allParts = {}
    for _, desc in ipairs(newTarget:GetDescendants()) do
        if desc:IsA("BasePart") then table.insert(allParts, desc) end
    end
    if newTarget:IsA("BasePart") then table.insert(allParts, newTarget) end

    -- Reconfigura Collision se aplicável
    local collision = newConfig and newConfig.Collision
    if collision then
        local humanoid = newTarget:FindFirstChild("Kolt ESP")
        if not humanoid then
            humanoid = Instance.new("Humanoid")
            humanoid.Name = "Kolt ESP"
            humanoid.Parent = newTarget
        end
        esp.humanoid = humanoid
        for _, part in ipairs(allParts) do
            if part.Transparency == 1 then
                table.insert(esp.ModifiedParts, {Part = part, OriginalTransparency = part.Transparency})
                part.Transparency = 0.99
            end
        end
    else
        esp.visibleParts = {}
        for _, part in ipairs(allParts) do
            if part.Transparency < 0.99 then table.insert(esp.visibleParts, part) end
        end
    end

    -- Novo Highlight
    if self.GlobalSettings.ShowHighlightFill or self.GlobalSettings.ShowHighlightOutline then
        if esp.highlight then
            esp.highlight.Adornee = newTarget
            local useRainbow = self.GlobalSettings.RainbowMode
            local initColor = useRainbow and getRainbowColor(tick()) or esp.Colors.Highlight.Filled
            esp.highlight.FillColor = initColor
            esp.highlight.OutlineColor = useRainbow and initColor or esp.Colors.Highlight.Outline
            esp.highlight.FillTransparency = self.GlobalSettings.ShowHighlightFill and self.GlobalSettings.HighlightTransparency.Filled or 1
            esp.highlight.OutlineTransparency = self.GlobalSettings.ShowHighlightOutline and self.GlobalSettings.HighlightTransparency.Outline or 1
        else
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESPHighlight"
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            local useRainbow = self.GlobalSettings.RainbowMode
            local initColor = useRainbow and getRainbowColor(tick()) or esp.Colors.Highlight.Filled
            highlight.FillColor = initColor
            highlight.OutlineColor = useRainbow and initColor or esp.Colors.Highlight.Outline
            highlight.FillTransparency = self.GlobalSettings.ShowHighlightFill and self.GlobalSettings.HighlightTransparency.Filled or 1
            highlight.OutlineTransparency = self.GlobalSettings.ShowHighlightOutline and self.GlobalSettings.HighlightTransparency.Outline or 1
            highlight.Adornee = newTarget
            highlight.Parent = getHighlightFolder()
            esp.highlight = highlight
        end
    else
        if esp.highlight then
            esp.highlight:Destroy()
            esp.highlight = nil
        end
    end

    -- Atualiza ZIndex dos drawings
    if esp.tracerLine then esp.tracerLine.ZIndex = esp.DisplayOrder end
    if esp.nameText then esp.nameText.ZIndex = esp.DisplayOrder end
    if esp.distanceText then esp.distanceText.ZIndex = esp.DisplayOrder end
end

--// Atualiza config de um ESP existente sem mudar o target
function ModelESP:UpdateConfig(target, newConfig)
    local esp = self:GetESP(target)
    if not esp then return end

    -- Atualiza campos simples
    if newConfig.Name then esp.Name = newConfig.Name end
    if newConfig.NameContainer then
        esp.NameContainerStart = newConfig.NameContainer.Start or ""
        esp.NameContainerEnd = newConfig.NameContainer.End or ""
    end
    if newConfig.DistanceSuffix then esp.DistanceSuffix = newConfig.DistanceSuffix end
    if newConfig.DistanceContainer then
        esp.DistanceContainerStart = newConfig.DistanceContainer.Start or ""
        esp.DistanceContainerEnd = newConfig.DistanceContainer.End or ""
    end
    if newConfig.DisplayOrder ~= nil then 
        esp.DisplayOrder = newConfig.DisplayOrder
        if esp.tracerLine then esp.tracerLine.ZIndex = esp.DisplayOrder end
        if esp.nameText then esp.nameText.ZIndex = esp.DisplayOrder end
        if esp.distanceText then esp.distanceText.ZIndex = esp.DisplayOrder end
    end

    -- Atualiza cores
    if newConfig.Color then
        if typeof(newConfig.Color) == "Color3" then
            esp.Colors.Name = newConfig.Color
            esp.Colors.Distance = newConfig.Color
            esp.Colors.Tracer = newConfig.Color
            esp.Colors.Highlight.Filled = newConfig.Color
            esp.Colors.Highlight.Outline = newConfig.Color
        elseif typeof(newConfig.Color) == "table" then
            if newConfig.Color.Name then esp.Colors.Name = Color3.fromRGB(unpack(newConfig.Color.Name)) end
            if newConfig.Color.Distance then esp.Colors.Distance = Color3.fromRGB(unpack(newConfig.Color.Distance)) end
            if newConfig.Color.Tracer then esp.Colors.Tracer = Color3.fromRGB(unpack(newConfig.Color.Tracer)) end
            if newConfig.Color.Highlight then
                if newConfig.Color.Highlight.Filled then esp.Colors.Highlight.Filled = Color3.fromRGB(unpack(newConfig.Color.Highlight.Filled)) end
                if newConfig.Color.Highlight.Outline then esp.Colors.Highlight.Outline = Color3.fromRGB(unpack(newConfig.Color.Highlight.Outline)) end
            end
        end
    end

    -- Se Collision mudou, reconfigura (requer limpeza e re-setup)
    local newCollision = newConfig.Collision
    if newCollision ~= (esp.humanoid ~= nil) then
        -- Limpa atual
        if esp.humanoid then esp.humanoid:Destroy() esp.humanoid = nil end
        for _, mod in ipairs(esp.ModifiedParts) do
            if mod.Part and mod.Part.Parent then mod.Part.Transparency = mod.OriginalTransparency end
        end
        esp.ModifiedParts = {}
        esp.visibleParts = nil

        -- Re-setup baseado no novo
        local allParts = {}
        for _, desc in ipairs(target:GetDescendants()) do
            if desc:IsA("BasePart") then table.insert(allParts, desc) end
        end
        if target:IsA("BasePart") then table.insert(allParts, target) end

        if newCollision then
            local humanoid = target:FindFirstChild("Kolt ESP")
            if not humanoid then
                humanoid = Instance.new("Humanoid")
                humanoid.Name = "Kolt ESP"
                humanoid.Parent = target
            end
            esp.humanoid = humanoid
            for _, part in ipairs(allParts) do
                if part.Transparency == 1 then
                    table.insert(esp.ModifiedParts, {Part = part, OriginalTransparency = part.Transparency})
                    part.Transparency = 0.99
                end
            end
        else
            esp.visibleParts = {}
            for _, part in ipairs(allParts) do
                if part.Transparency < 0.99 then table.insert(esp.visibleParts, part) end
            end
        end

        -- Atualiza Highlight se existir ou cria novo
        if self.GlobalSettings.ShowHighlightFill or self.GlobalSettings.ShowHighlightOutline then
            if esp.highlight then
                local useRainbow = self.GlobalSettings.RainbowMode
                local initColor = useRainbow and getRainbowColor(tick()) or esp.Colors.Highlight.Filled
                esp.highlight.FillColor = initColor
                esp.highlight.OutlineColor = useRainbow and initColor or esp.Colors.Highlight.Outline
                esp.highlight.FillTransparency = self.GlobalSettings.ShowHighlightFill and self.GlobalSettings.HighlightTransparency.Filled or 1
                esp.highlight.OutlineTransparency = self.GlobalSettings.ShowHighlightOutline and self.GlobalSettings.HighlightTransparency.Outline or 1
            else
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESPHighlight"
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                local useRainbow = self.GlobalSettings.RainbowMode
                local initColor = useRainbow and getRainbowColor(tick()) or esp.Colors.Highlight.Filled
                highlight.FillColor = initColor
                highlight.OutlineColor = useRainbow and initColor or esp.Colors.Highlight.Outline
                highlight.FillTransparency = self.GlobalSettings.ShowHighlightFill and self.GlobalSettings.HighlightTransparency.Filled or 1
                highlight.OutlineTransparency = self.GlobalSettings.ShowHighlightOutline and self.GlobalSettings.HighlightTransparency.Outline or 1
                highlight.Adornee = target
                highlight.Parent = getHighlightFolder()
                esp.highlight = highlight
            end
        else
            if esp.highlight then
                esp.highlight:Destroy()
                esp.highlight = nil
            end
        end
    end
end

--// API útil: Alterna habilitado individual
function ModelESP:ToggleIndividual(target, enabled)
    local esp = self:GetESP(target)
    if esp then
        esp.Enabled = enabled
    end
end

--// API útil: Define cor única para um ESP
function ModelESP:SetColor(target, color)
    local esp = self:GetESP(target)
    if esp and typeof(color) == "Color3" then
        esp.Colors.Name = color
        esp.Colors.Distance = color
        esp.Colors.Tracer = color
        esp.Colors.Highlight.Filled = color
        esp.Colors.Highlight.Outline = color
    end
end

--// API útil: Define nome para um ESP
function ModelESP:SetName(target, newName)
    local esp = self:GetESP(target)
    if esp then
        esp.Name = newName
    end
end

--// API útil: Define DisplayOrder para um ESP
function ModelESP:SetDisplayOrder(target, displayOrder)
    local esp = self:GetESP(target)
    if esp then
        esp.DisplayOrder = displayOrder
        if esp.tracerLine then esp.tracerLine.ZIndex = esp.DisplayOrder end
        if esp.nameText then esp.nameText.ZIndex = esp.DisplayOrder end
        if esp.distanceText then esp.distanceText.ZIndex = esp.DisplayOrder end
    end
end

--// Remove ESP individual
function ModelESP:Remove(target)
    for i=#self.Objects,1,-1 do
        local obj = self.Objects[i]
        if obj.Target == target then
            for _, draw in ipairs({obj.tracerLine,obj.nameText,obj.distanceText}) do if draw then pcall(draw.Remove,draw) end end
            if obj.highlight then pcall(obj.highlight.Destroy,obj.highlight) end
            if obj.humanoid then pcall(obj.humanoid.Destroy, obj.humanoid) end
            for _, mod in ipairs(obj.ModifiedParts) do
                if mod.Part then mod.Part.Transparency = mod.OriginalTransparency end
            end
            table.remove(self.Objects,i)
            break
        end
    end
end

--//  Limpa todas ESP
function ModelESP:Clear()
    for _, obj in ipairs(self.Objects) do
        for _, draw in ipairs({obj.tracerLine,obj.nameText,obj.distanceText}) do if draw then pcall(draw.Remove,draw) end end
        if obj.highlight then pcall(obj.highlight.Destroy,obj.highlight) end
        if obj.humanoid then pcall(obj.humanoid.Destroy, obj.humanoid) end
        for _, mod in ipairs(obj.ModifiedParts) do
            if mod.Part then mod.Part.Transparency = mod.OriginalTransparency end
        end
    end
    self.Objects = {}
end

--// Update GlobalSettings
function ModelESP:UpdateGlobalSettings()
    for _, esp in ipairs(self.Objects) do
        if esp.tracerLine then esp.tracerLine.Thickness = self.GlobalSettings.LineThickness end
        if esp.nameText then esp.nameText.Size = self.GlobalSettings.FontSize end
        if esp.distanceText then esp.distanceText.Size = self.GlobalSettings.FontSize-2 end
        if esp.highlight then
            esp.highlight.FillTransparency = self.GlobalSettings.ShowHighlightFill and self.GlobalSettings.HighlightTransparency.Filled or 1
            esp.highlight.OutlineTransparency = self.GlobalSettings.ShowHighlightOutline and self.GlobalSettings.HighlightTransparency.Outline or 1
        end
    end
end

--// Configs Globais (APIs)
function ModelESP:SetGlobalTracerOrigin(origin)
    if tracerOrigins[origin] then
        self.GlobalSettings.TracerOrigin = origin
    end
end
function ModelESP:SetGlobalESPType(typeName, enabled)
    self.GlobalSettings[typeName] = enabled
    self:UpdateGlobalSettings()
end
function ModelESP:SetGlobalRainbow(enable)
    self.GlobalSettings.RainbowMode = enable
end
function ModelESP:SetGlobalOpacity(value)
    self.GlobalSettings.Opacity = math.clamp(value,0,1)
    self:UpdateGlobalSettings()
end
function ModelESP:SetGlobalFontSize(size)
    self.GlobalSettings.FontSize = math.max(10,size)
    self:UpdateGlobalSettings()
end
function ModelESP:SetGlobalLineThickness(thick)
    self.GlobalSettings.LineThickness = math.max(1,thick)
    self:UpdateGlobalSettings()
end

--// Atualização por frame
RunService.RenderStepped:Connect(function()
    if not ModelESP.Enabled then return end
    local vs = camera.ViewportSize
    local time = tick()

    for i=#ModelESP.Objects,1,-1 do
        local esp = ModelESP.Objects[i]
        local target = esp.Target
        if not target or not target.Parent then
            if ModelESP.GlobalSettings.AutoRemoveInvalid then
                ModelESP:Remove(target)
            end
            continue
        end

        if not esp.Enabled then
            for _, draw in ipairs({esp.tracerLine,esp.nameText,esp.distanceText}) do if draw then draw.Visible=false end end
            if esp.highlight then esp.highlight.Enabled=false end
            continue
        end

        local pos3D
        if esp.visibleParts then
            local totalPos = Vector3.zero
            local totalVolume = 0
            for _, part in ipairs(esp.visibleParts) do
                if part.Parent then
                    local vol = part.Size.X * part.Size.Y * part.Size.Z
                    totalPos += part.Position * vol
                    totalVolume += vol
                end
            end
            if totalVolume <= 0 then continue end
            pos3D = totalPos / totalVolume
        else
            local cf = getBoundingBox(target)
            if not cf then continue end
            pos3D = cf.Position
        end

        local success, pos2D = pcall(function() return camera:WorldToViewportPoint(pos3D) end)
        if not success or pos2D.Z <= 0 then
            for _, draw in ipairs({esp.tracerLine,esp.nameText,esp.distanceText}) do if draw then draw.Visible=false end end
            if esp.highlight then esp.highlight.Enabled=false end
            continue
        end

        local distance = (camera.CFrame.Position - pos3D).Magnitude
        local visible = distance >= ModelESP.GlobalSettings.MinDistance and distance <= ModelESP.GlobalSettings.MaxDistance
        if not visible then
            for _, draw in ipairs({esp.tracerLine,esp.nameText,esp.distanceText}) do if draw then draw.Visible=false end end
            if esp.highlight then esp.highlight.Enabled=false end
            continue
        end

        local rainbowColor = getRainbowColor(time)
        local useRainbow = ModelESP.GlobalSettings.RainbowMode

        -- Usar projeção do centro para posicionamento para evitar distorção
        local centerX = pos2D.X
        local centerY = pos2D.Y
        local nameSize = esp.nameText.Size
        local distSize = esp.distanceText.Size
        local totalHeight = nameSize + distSize
        local startY = centerY - totalHeight / 2

        -- Tracer
        if esp.tracerLine then
            esp.tracerLine.Visible = ModelESP.GlobalSettings.ShowTracer
            esp.tracerLine.From = tracerOrigins[ModelESP.GlobalSettings.TracerOrigin](vs)
            esp.tracerLine.To = Vector2.new(pos2D.X, pos2D.Y)
            esp.tracerLine.Color = useRainbow and rainbowColor or esp.Colors.Tracer
        end
        -- Name
        if esp.nameText then
            esp.nameText.Visible = ModelESP.GlobalSettings.ShowName
            esp.nameText.Position = Vector2.new(centerX, startY)
            esp.nameText.Text = esp.NameContainerStart .. esp.Name .. esp.NameContainerEnd
            esp.nameText.Color = useRainbow and rainbowColor or esp.Colors.Name
        end
        -- Distance
        if esp.distanceText then
            esp.distanceText.Visible = ModelESP.GlobalSettings.ShowDistance
            esp.distanceText.Position = Vector2.new(centerX, startY + nameSize)
            esp.distanceText.Text = esp.DistanceContainerStart .. string.format("%.1f", distance) .. esp.DistanceSuffix .. esp.DistanceContainerEnd
            esp.distanceText.Color = useRainbow and rainbowColor or esp.Colors.Distance
        end
        -- Highlight
        if esp.highlight then
            esp.highlight.Enabled = ModelESP.GlobalSettings.ShowHighlightFill or ModelESP.GlobalSettings.ShowHighlightOutline
            esp.highlight.FillColor = useRainbow and rainbowColor or esp.Colors.Highlight.Filled
            esp.highlight.OutlineColor = useRainbow and rainbowColor or esp.Colors.Highlight.Outline
            esp.highlight.FillTransparency = ModelESP.GlobalSettings.ShowHighlightFill and ModelESP.GlobalSettings.HighlightTransparency.Filled or 1
            esp.highlight.OutlineTransparency = ModelESP.GlobalSettings.ShowHighlightOutline and ModelESP.GlobalSettings.HighlightTransparency.Outline or 1
        end
    end
end)

return ModelESP
