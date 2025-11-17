--[[  
    KoltESP Library v1.7
    • Biblioteca de ESP voltada para endereços de objetos (Model e BasePart).  
    • Oferece diversas APIs úteis para seus projetos, incluindo a visualização de todas as colisões de um alvo.  
    • O ponto central do alvo é definido com base na parte mais visível — se houver colisões invisíveis, a prioridade será dada à parte com maior visibilidade, e não ao centro exato do modelo.
]]
   
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
    Theme = {
        PrimaryColor = Color3.fromRGB(130, 200, 255),
        SecondaryColor = Color3.fromRGB(255, 255, 255),
        OutlineColor = Color3.fromRGB(0, 0, 0),
    },
    EspSettings  = {
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
        Font = 3,
        AutoRemoveInvalid = true,
        HighlightTransparency = {
            Filled = 0.5,
            Outline = 0.3
        },
        TextOutlineEnabled = true,
        TextOutlineColor = Color3.fromRGB(0, 0, 0),
        TextOutlineThickness = 1,
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

--Tracer Origins
local tracerOrigins = {
    Top = function(vs) return Vector2.new(vs.X/2, 0) end,
    Center = function(vs) return Vector2.new(vs.X/2, vs.Y/2) end,
    Bottom = function(vs) return Vector2.new(vs.X/2, vs.Y) end,
    Left = function(vs) return Vector2.new(0, vs.Y/2) end,
    Right = function(vs) return Vector2.new(vs.X, vs.Y/2) end,
}

--<< Get Bounding Box
local function getBoundingBox(target)
    if target:IsA("Model") then
        return target:GetBoundingBox()
    elseif target:IsA("BasePart") then
        return target.CFrame, target.Size
    end
    return nil, nil
end

-- Cria Drawing
local function createDrawing(class, props)
    local obj = Drawing.new(class)
    for k,v in pairs(props) do obj[k]=v end
    return obj
end

-- Função interna para obter ESP por target
function KoltESP:GetESP(target)
    for _, esp in ipairs(self.Objects) do
        if esp.Target == target then return esp end
    end
    return nil
end

-- Configura o nome da pasta de highlights
function KoltESP:SetHighlightFolderName(name)
    if typeof(name) == "string" and name ~= "" then
        HighlightFolderName = name
        highlightFolder = nil  -- Reseta para recriação
    end
end

-- Define transparências globais de highlight
function KoltESP:SetGlobalHighlightTransparency(trans)
    if typeof(trans) == "table" then
        if trans.Filled and typeof(trans.Filled) == "number" then
            self.EspSettings .HighlightTransparency.Filled = math.clamp(trans.Filled, 0, 1)
        end
        if trans.Outline and typeof(trans.Outline) == "number" then
            self.EspSettings .HighlightTransparency.Outline = math.clamp(trans.Outline, 0, 1)
        end
    end
end

-- Função auxiliar para coletar BaseParts
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

-- Função auxiliar para criar ou atualizar highlight
local function setupHighlight(esp, target)
    if KoltESP.EspSettings .ShowHighlightFill or KoltESP.EspSettings .ShowHighlightOutline then
        if not esp.highlight then
            esp.highlight = Instance.new("Highlight")
            esp.highlight.Name = "ESPHighlight"
            esp.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            esp.highlight.Parent = getHighlightFolder()
        end
        esp.highlight.Adornee = target
        esp.highlight.FillTransparency = KoltESP.EspSettings .ShowHighlightFill and KoltESP.EspSettings .HighlightTransparency.Filled or 1
        esp.highlight.OutlineTransparency = KoltESP.EspSettings .ShowHighlightOutline and KoltESP.EspSettings .HighlightTransparency.Outline or 1
        local useRainbow = KoltESP.EspSettings .RainbowMode
        local initColor = useRainbow and getRainbowColor(tick()) or esp.Colors.Highlight.Filled
        esp.highlight.FillColor = initColor
        esp.highlight.OutlineColor = useRainbow and initColor or esp.Colors.Highlight.Outline
    elseif esp.highlight then
        esp.highlight:Destroy()
        esp.highlight = nil
    end
end

-- Função auxiliar para aplicar cores de config
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
end

-- Função auxiliar para setup de collision
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
                table.insert(esp.ModifiedParts, {Part = part, OriginalTransparency = part.Transparency})
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

-- Função auxiliar para limpar drawings e setups de um ESP
local function CleanupESP(esp)
    for _, draw in ipairs({esp.tracerLine, esp.nameText, esp.distanceText}) do
        if draw then pcall(draw.Remove, draw) end
    end
    esp.tracerLine = nil
    esp.nameText = nil
    esp.distanceText = nil
    if esp.highlight then pcall(esp.highlight.Destroy, esp.highlight) esp.highlight = nil end
    if esp.humanoid then pcall(esp.humanoid.Destroy, esp.humanoid) esp.humanoid = nil end
    for _, mod in ipairs(esp.ModifiedParts) do
        if mod.Part and mod.Part.Parent then
            mod.Part.Transparency = mod.OriginalTransparency
        end
    end
    esp.ModifiedParts = {}
    esp.visibleParts = nil
end

-- Função auxiliar para criar drawings e setups de um ESP
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

-- Adiciona ESP
function KoltESP:Add(target, config)
    if not target or not target:IsA("Instance") or not (target:IsA("Model") or target:IsA("BasePart")) then return end

    local existing = self:GetESP(target)
    if existing then self:Remove(target) end

    for _, obj in ipairs(target:GetChildren()) do
        if obj:IsA("Highlight") and obj.Name == "ESPHighlight" then obj:Destroy() end
    end

    local cfg = {
        Target = target,
        Name = config and config.Name or target.Name,
        ModifiedParts = {},
        DistancePrefix = (config and config.DistancePrefix) or "",
        DistanceSuffix = (config and config.DistanceSuffix) or "",
        DisplayOrder = config and config.DisplayOrder or 0,
        Types = {
            Tracer = config and config.Types and config.Types.Tracer == false and false or true,
            Name = config and config.Types and config.Types.Name == false and false or true,
            Distance = config and config.Types and config.Types.Distance == false and false or true,
            HighlightFill = config and config.Types and config.Types.HighlightFill == false and false or true,
            HighlightOutline = config and config.Types and config.Types.HighlightOutline == false and false or true,
        },
        TextOutlineEnabled = config and config.TextOutlineEnabled or self.EspSettings .TextOutlineEnabled,
        TextOutlineColor = config and config.TextOutlineColor or self.EspSettings .TextOutlineColor,
        TextOutlineThickness = config and config.TextOutlineThickness or self.EspSettings .TextOutlineThickness,
        ColorDependency = config and config.ColorDependency or nil,
        Opacity = config and config.Opacity or self.EspSettings .Opacity,
        LineThickness = config and config.LineThickness or self.EspSettings .LineThickness,
        FontSize = config and config.FontSize or self.EspSettings .FontSize,
        Font = config and config.Font or self.EspSettings .Font,
        MaxDistance = config and config.MaxDistance or self.EspSettings .MaxDistance,
        MinDistance = config and config.MinDistance or self.EspSettings .MinDistance,
        Collision = config and config.Collision or false
    }

    applyColors(cfg, config)

    CreateDrawings(cfg)

    table.insert(self.Objects, cfg)
end

-- Reajusta ESP para novo alvo com nova config
function KoltESP:Readjustment(newTarget, oldTarget, newConfig)
    if not newTarget or not newTarget:IsA("Instance") or not (newTarget:IsA("Model") or newTarget:IsA("BasePart")) then return end

    local esp = self:GetESP(oldTarget)
    if not esp then return end

    -- Limpa setups antigos
    CleanupESP(esp)

    -- Atualiza target e config
    esp.Target = newTarget
    esp.Name = newConfig and newConfig.Name or newTarget.Name
    esp.DistancePrefix = (newConfig and newConfig.DistancePrefix) or ""
    esp.DistanceSuffix = (newConfig and newConfig.DistanceSuffix) or ""
    esp.DisplayOrder = newConfig and newConfig.DisplayOrder or 0
    esp.TextOutlineEnabled = newConfig and newConfig.TextOutlineEnabled or self.EspSettings .TextOutlineEnabled
    esp.TextOutlineColor = newConfig and newConfig.TextOutlineColor or self.EspSettings .TextOutlineColor
    esp.TextOutlineThickness = newConfig and newConfig.TextOutlineThickness or self.EspSettings .TextOutlineThickness
    esp.ColorDependency = newConfig and newConfig.ColorDependency or nil
    esp.Opacity = newConfig and newConfig.Opacity or self.EspSettings .Opacity
    esp.LineThickness = newConfig and newConfig.LineThickness or self.EspSettings .LineThickness
    esp.FontSize = newConfig and newConfig.FontSize or self.EspSettings .FontSize
    esp.Font = newConfig and newConfig.Font or self.EspSettings .Font
    esp.MaxDistance = newConfig and newConfig.MaxDistance or self.EspSettings .MaxDistance
    esp.MinDistance = newConfig and newConfig.MinDistance or self.EspSettings .MinDistance
    esp.Collision = newConfig and newConfig.Collision or false

    applyColors(esp, newConfig)

    esp.Types = {
        Tracer = newConfig and newConfig.Types and newConfig.Types.Tracer == false and false or true,
        Name = newConfig and newConfig.Types and newConfig.Types.Name == false and false or true,
        Distance = newConfig and newConfig.Types and newConfig.Types.Distance == false and false or true,
        HighlightFill = newConfig and newConfig.Types and newConfig.Types.HighlightFill == false and false or true,
        HighlightOutline = newConfig and newConfig.Types and newConfig.Types.HighlightOutline == false and false or true,
    }

    CreateDrawings(esp)
end

-- Atualiza config de um ESP existente sem mudar o target
function KoltESP:UpdateConfig(target, newConfig)
    local esp = self:GetESP(target)
    if not esp then return end

    local needsRecreate = false

    if newConfig.Name then esp.Name = newConfig.Name end
    if newConfig.DistancePrefix then esp.DistancePrefix = newConfig.DistancePrefix end
    if newConfig.DistanceSuffix then esp.DistanceSuffix = newConfig.DistanceSuffix end
    if newConfig.DisplayOrder ~= nil then 
        esp.DisplayOrder = newConfig.DisplayOrder
        needsRecreate = true
    end
    if newConfig.TextOutlineEnabled ~= nil then 
        esp.TextOutlineEnabled = newConfig.TextOutlineEnabled
        needsRecreate = true
    end
    if newConfig.TextOutlineColor then 
        esp.TextOutlineColor = newConfig.TextOutlineColor
        needsRecreate = true
    end
    if newConfig.TextOutlineThickness then 
        esp.TextOutlineThickness = newConfig.TextOutlineThickness
    end
    if newConfig.ColorDependency then 
        esp.ColorDependency = newConfig.ColorDependency
    end
    if newConfig.Opacity ~= nil then 
        esp.Opacity = newConfig.Opacity
        needsRecreate = true
    end
    if newConfig.LineThickness ~= nil then 
        esp.LineThickness = newConfig.LineThickness
        needsRecreate = true
    end
    if newConfig.FontSize ~= nil then 
        esp.FontSize = newConfig.FontSize
        needsRecreate = true
    end
    if newConfig.Font ~= nil then 
        esp.Font = newConfig.Font
        needsRecreate = true
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

    local newCollision = newConfig.Collision
    if newCollision ~= nil and newCollision ~= esp.Collision then
        CleanupESP(esp)
        esp.Collision = newCollision
        needsRecreate = true
    end

    if needsRecreate then
        CreateDrawings(esp)
    end
end

-- API útil: Define cor única para um ESP
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

-- API útil: Define nome para um ESP
function KoltESP:SetName(target, newName)
    local esp = self:GetESP(target)
    if esp then
        esp.Name = newName
    end
end

-- API útil: Define DisplayOrder para um ESP
function KoltESP:SetDisplayOrder(target, displayOrder)
    local esp = self:GetESP(target)
    if esp then
        esp.DisplayOrder = displayOrder
        if esp.tracerLine then esp.tracerLine.ZIndex = displayOrder end
        if esp.nameText then esp.nameText.ZIndex = displayOrder end
        if esp.distanceText then esp.distanceText.ZIndex = displayOrder end
    end
end

-- API útil: Define propriedades de outline de texto para um ESP
function KoltESP:SetTextOutline(target, enabled, color, thickness)
    local esp = self:GetESP(target)
    if esp then
        if enabled ~= nil then
            esp.TextOutlineEnabled = enabled
            if esp.nameText then esp.nameText.Outline = enabled end
            if esp.distanceText then esp.distanceText.Outline = enabled end
        end
        if color then
            esp.TextOutlineColor = color
            if esp.nameText then esp.nameText.OutlineColor = color end
            if esp.distanceText then esp.distanceText.OutlineColor = color end
        end
        if thickness then
            esp.TextOutlineThickness = thickness
        end
    end
end

-- Remove ESP individual
function KoltESP:Remove(target)
    for i = #self.Objects, 1, -1 do
        local obj = self.Objects[i]
        if obj.Target == target then
            CleanupESP(obj)
            table.remove(self.Objects, i)
            break
        end
    end
end

-- Limpa todas ESP
function KoltESP:Clear()
    for i = #self.Objects, 1, -1 do
        local obj = self.Objects[i]
        CleanupESP(obj)
        table.remove(self.Objects, i)
    end
end

-- Update EspSettings 
function KoltESP:UpdateGlobalSettings()
    for _, esp in ipairs(self.Objects) do
        if esp.tracerLine then
            esp.tracerLine.Thickness = self.EspSettings .LineThickness
            esp.tracerLine.Transparency = self.EspSettings .Opacity
        end
        if esp.nameText then
            esp.nameText.Size = self.EspSettings .FontSize
            esp.nameText.Transparency = self.EspSettings .Opacity
            esp.nameText.Outline = self.EspSettings .TextOutlineEnabled
            esp.nameText.OutlineColor = self.EspSettings .TextOutlineColor
            esp.nameText.Font = self.EspSettings .Font
        end
        if esp.distanceText then
            esp.distanceText.Size = self.EspSettings .FontSize - 2
            esp.distanceText.Transparency = self.EspSettings .Opacity
            esp.distanceText.Outline = self.EspSettings .TextOutlineEnabled
            esp.distanceText.OutlineColor = self.EspSettings .TextOutlineColor
            esp.distanceText.Font = self.EspSettings .Font
        end
        setupHighlight(esp, esp.Target)
    end
end

-- Configs Globais (APIs)
function KoltESP:SetGlobalTracerOrigin(origin)
    if tracerOrigins[origin] then
        self.EspSettings .TracerOrigin = origin
    end
end

function KoltESP:SetGlobalESPType(typeName, enabled)
    self.EspSettings [typeName] = enabled
    self:UpdateGlobalSettings()
end

function KoltESP:SetGlobalRainbow(enable)
    self.EspSettings .RainbowMode = enable
end

function KoltESP:SetGlobalOpacity(value)
    self.EspSettings .Opacity = math.clamp(value, 0, 1)
    self:UpdateGlobalSettings()
end

function KoltESP:SetGlobalFontSize(size)
    self.EspSettings .FontSize = math.max(10, size)
    self:UpdateGlobalSettings()
end

function KoltESP:SetGlobalLineThickness(thick)
    self.EspSettings .LineThickness = math.max(1, thick)
    self:UpdateGlobalSettings()
end

function KoltESP:SetGlobalTextOutline(enabled, color, thickness)
    if enabled ~= nil then self.EspSettings .TextOutlineEnabled = enabled end
    if color then self.EspSettings .TextOutlineColor = color end
    if thickness then self.EspSettings .TextOutlineThickness = thickness end
    self:UpdateGlobalSettings()
end

function KoltESP:SetGlobalFont(font)
    if typeof(font) == "number" and font >= 0 and font <= 3 then
        self.EspSettings .Font = font
        self:UpdateGlobalSettings()
    end
end

-- Suporte a players com respawn/reset
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

    local function setupESP()
        local char = player.Character
        if char then
            task.wait()
            self:Add(char, entry.Config)
            entry.CurrentTarget = char
        end
    end

    entry.Connections.charAdded = player.CharacterAdded:Connect(setupESP)
    entry.Connections.charRemoving = player.CharacterRemoving:Connect(function(oldChar)
        self:Remove(oldChar)
        entry.CurrentTarget = nil
    end)

    setupESP()
end

function KoltESP:RemoveFromPlayer(player)
    local entry = PlayerESPs[player]
    if not entry then return end

    for _, conn in pairs(entry.Connections) do
        conn:Disconnect()
    end

    if entry.CurrentTarget then
        self:Remove(entry.CurrentTarget)
    end

    PlayerESPs[player] = nil
end

-- Atualização por frame
KoltESP.connection = RunService.RenderStepped:Connect(function()

    local camera = workspace.CurrentCamera
    local vs = camera.ViewportSize
    local time = tick()
    local useRainbow = KoltESP.EspSettings .RainbowMode
    local rainbowColor = getRainbowColor(time)

    for i = #KoltESP.Objects, 1, -1 do
        local esp = KoltESP.Objects[i]
        local target = esp.Target
        if not target or not target.Parent then
            if KoltESP.EspSettings .AutoRemoveInvalid then
                KoltESP:Remove(target)
            end
            continue
        end

        local pos3D
        if esp.visibleParts then
            local totalPos = Vector3.zero
            local totalVolume = 0
            local validParts = 0
            for _, part in ipairs(esp.visibleParts) do
                if part and part.Parent then
                    local vol = part.Size.X * part.Size.Y * part.Size.Z
                    totalPos += part.Position * vol
                    totalVolume += vol
                    validParts += 1
                end
            end
            if totalVolume > 0 and validParts > 0 then
                pos3D = totalPos / totalVolume
            else
                local cf = getBoundingBox(target)
                if cf then
                    pos3D = cf.Position
                else
                    continue
                end
            end
        else
            local cf = getBoundingBox(target)
            if not cf then continue end
            pos3D = cf.Position
        end

        local success, pos2D = pcall(camera.WorldToViewportPoint, camera, pos3D)
        if not success or pos2D.Z <= 0 then
            esp.tracerLine.Visible = false
            esp.nameText.Visible = false
            esp.distanceText.Visible = false
            if esp.highlight then esp.highlight.Enabled = false end
            continue
        end

        local distance = (camera.CFrame.Position - pos3D).Magnitude
        local visible = distance >= esp.MinDistance and distance <= esp.MaxDistance
        if not visible then
            esp.tracerLine.Visible = false
            esp.nameText.Visible = false
            esp.distanceText.Visible = false
            if esp.highlight then esp.highlight.Enabled = false end
            continue
        end

        -- Dependência de cor
        local currentColor = nil
        if esp.ColorDependency and typeof(esp.ColorDependency) == "function" then
            currentColor = esp.ColorDependency(esp, distance, pos3D)
        end

        -- Posicionamento
        local centerX = pos2D.X
        local centerY = pos2D.Y
        local nameSize = esp.nameText.Size
        local distSize = esp.distanceText.Size
        local totalHeight = nameSize + distSize
        local startY = centerY - totalHeight / 2

        -- Tracer
        esp.tracerLine.Visible = KoltESP.EspSettings .ShowTracer and esp.Types.Tracer
        esp.tracerLine.From = tracerOrigins[KoltESP.EspSettings .TracerOrigin](vs)
        esp.tracerLine.To = Vector2.new(pos2D.X, pos2D.Y)
        esp.tracerLine.Color = useRainbow and rainbowColor or (currentColor or esp.Colors.Tracer)

        -- Name
        esp.nameText.Visible = KoltESP.EspSettings .ShowName and esp.Types.Name
        esp.nameText.Position = Vector2.new(centerX, startY)
        esp.nameText.Text = esp.Name
        esp.nameText.Color = useRainbow and rainbowColor or (currentColor or esp.Colors.Name)

        -- Distance
        esp.distanceText.Visible = KoltESP.EspSettings .ShowDistance and esp.Types.Distance
        esp.distanceText.Position = Vector2.new(centerX, startY + nameSize)
        esp.distanceText.Text = esp.DistancePrefix .. string.format("%.1f", distance) .. esp.DistanceSuffix
        esp.distanceText.Color = useRainbow and rainbowColor or (currentColor or esp.Colors.Distance)

        -- Highlight
        if esp.highlight then
            local showFill = KoltESP.EspSettings .ShowHighlightFill and esp.Types.HighlightFill
            local showOutline = KoltESP.EspSettings .ShowHighlightOutline and esp.Types.HighlightOutline
            esp.highlight.Enabled = showFill or showOutline
            esp.highlight.FillColor = useRainbow and rainbowColor or (currentColor or esp.Colors.Highlight.Filled)
            esp.highlight.OutlineColor = useRainbow and rainbowColor or (currentColor or esp.Colors.Highlight.Outline)
            esp.highlight.FillTransparency = showFill and KoltESP.EspSettings .HighlightTransparency.Filled or 1
            esp.highlight.OutlineTransparency = showOutline and KoltESP.EspSettings .HighlightTransparency.Outline or 1
        end
    end
end)

return KoltESP
