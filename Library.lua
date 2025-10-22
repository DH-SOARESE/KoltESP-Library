--// 📦 Library KoltESP V1.7.0
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
    }
}

--// Função para cor arco-íris (agora com frequência ajustável)
local function getRainbowColor(t, frequency)
    frequency = frequency or 2
    return Color3.fromRGB(
        math.sin(frequency * t + 0) * 127 + 128,
        math.sin(frequency * t + 2) * 127 + 128,
        math.sin(frequency * t + 4) * 127 + 128
    )
end

--// Origens de tracers globais
local tracerOrigins = {
    Top = function(vs) return Vector2.new(vs.X / 2, 0) end,
    Center = function(vs) return Vector2.new(vs.X / 2, vs.Y / 2) end,
    Bottom = function(vs) return Vector2.new(vs.X / 2, vs.Y) end,
    Left = function(vs) return Vector2.new(0, vs.Y / 2) end,
    Right = function(vs) return Vector2.new(vs.X, vs.Y / 2) end,
}

--// Obtém bounding box de target
local function getBoundingBox(target)
    if target:IsA("Model") then
        return target:GetBoundingBox()
    elseif target:IsA("BasePart") then
        return target.CFrame, target.Size
    end
    return nil, nil
end

--// Cria objeto Drawing com propriedades
local function createDrawing(class, props)
    local obj = Drawing.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

--// Obtém ESP existente por target
function KoltESP:GetESP(target)
    for _, esp in ipairs(self.Objects) do
        if esp.Target == target then
            return esp
        end
    end
    return nil
end

--// Define nome da pasta de highlights
function KoltESP:SetHighlightFolderName(name)
    if self.Unloaded then return end
    if typeof(name) == "string" and name ~= "" then
        HighlightFolderName = name
        highlightFolder = nil  -- Reset para recriação
    end
end

--// Define transparências globais de highlights
function KoltESP:SetGlobalHighlightTransparency(trans)
    if self.Unloaded then return end
    if typeof(trans) == "table" then
        if trans.Filled and typeof(trans.Filled) == "number" then
            self.GlobalSettings.HighlightTransparency.Filled = math.clamp(trans.Filled, 0, 1)
        end
        if trans.Outline and typeof(trans.Outline) == "number" then
            self.GlobalSettings.HighlightTransparency.Outline = math.clamp(trans.Outline, 0, 1)
        end
    end
end

--// Coleta todas as BaseParts do target
local function collectBaseParts(target)
    local allParts = {}
    if target:IsA("BasePart") then
        table.insert(allParts, target)
    end
    for _, desc in ipairs(target:GetDescendants()) do
        if desc:IsA("BasePart") then
            table.insert(allParts, desc)
        end
    end
    return allParts
end

--// Configura ou atualiza highlight
local function setupHighlight(esp, target)
    if esp.Types.HighlightFill or esp.Types.HighlightOutline then
        if not esp.highlight then
            esp.highlight = Instance.new("Highlight")
            esp.highlight.Name = "ESPHighlight"
            esp.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            esp.highlight.Parent = getHighlightFolder()
        end
        esp.highlight.Adornee = target
        esp.highlight.FillTransparency = esp.Types.HighlightFill and KoltESP.GlobalSettings.HighlightTransparency.Filled or 1
        esp.highlight.OutlineTransparency = esp.Types.HighlightOutline and KoltESP.GlobalSettings.HighlightTransparency.Outline or 1
    elseif esp.highlight then
        esp.highlight:Destroy()
        esp.highlight = nil
    end
end

--// Aplica cores de configuração
local function applyColors(esp, config)
    esp.Colors = {
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
            esp.Colors.Name = config.Color
            esp.Colors.Distance = config.Color
            esp.Colors.Tracer = config.Color
            esp.Colors.Highlight.Filled = config.Color
            esp.Colors.Highlight.Outline = config.Color
        elseif typeof(config.Color) == "table" then
            if config.Color.Name and typeof(config.Color.Name) == "table" and #config.Color.Name == 3 then
                esp.Colors.Name = Color3.fromRGB(unpack(config.Color.Name))
            end
            if config.Color.Distance and typeof(config.Color.Distance) == "table" and #config.Color.Distance == 3 then
                esp.Colors.Distance = Color3.fromRGB(unpack(config.Color.Distance))
            end
            if config.Color.Tracer and typeof(config.Color.Tracer) == "table" and #config.Color.Tracer == 3 then
                esp.Colors.Tracer = Color3.fromRGB(unpack(config.Color.Tracer))
            end
            if config.Color.Highlight and typeof(config.Color.Highlight) == "table" then
                if config.Color.Highlight.Filled and typeof(config.Color.Highlight.Filled) == "table" and #config.Color.Highlight.Filled == 3 then
                    esp.Colors.Highlight.Filled = Color3.fromRGB(unpack(config.Color.Highlight.Filled))
                end
                if config.Color.Highlight.Outline and typeof(config.Color.Highlight.Outline) == "table" and #config.Color.Highlight.Outline == 3 then
                    esp.Colors.Highlight.Outline = Color3.fromRGB(unpack(config.Color.Highlight.Outline))
                end
            end
        end
    end
end

--// Configura colisão para highlights
local function setupCollision(esp, target, allParts)
    if esp.Collision then
        local humanoid = target:FindFirstChild("Esp")
        if not humanoid then
            humanoid = Instance.new("Humanoid")
            humanoid.Name = "Esp"
            humanoid.Parent = target
        end
        esp.humanoid = humanoid

        for _, part in ipairs(allParts) do
            if part.Transparency >= 0.99 then  -- Ajustado para >= 0.99 para consistência
                table.insert(esp.ModifiedParts, {Part = part, OriginalTransparency = part.Transparency})
                part.Transparency = 0.98  -- Ajustado para 0.98 para melhor visibilidade
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

--// Limpa ESP (drawings, highlight, humanoid, restaura transparências)
local function CleanupESP(esp)
    for _, draw in ipairs({esp.tracerLine, esp.nameText, esp.distanceText}) do
        if draw then
            pcall(draw.Remove, draw)
        end
    end
    esp.tracerLine = nil
    esp.nameText = nil
    esp.distanceText = nil

    if esp.highlight then
        pcall(esp.highlight.Destroy, esp.highlight)
        esp.highlight = nil
    end

    if esp.humanoid then
        pcall(esp.humanoid.Destroy, esp.humanoid)
        esp.humanoid = nil
    end

    for _, mod in ipairs(esp.ModifiedParts) do
        if mod.Part and mod.Part.Parent then
            mod.Part.Transparency = mod.OriginalTransparency
        end
    end
    esp.ModifiedParts = {}
    esp.visibleParts = nil
    esp.cachedCenter = nil  -- Limpa cache de centro
end

--// Cria drawings e setups para ESP
local function CreateDrawings(esp)
    local allParts = collectBaseParts(esp.Target)
    setupCollision(esp, esp.Target, allParts)

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

--// Adiciona novo ESP
function KoltESP:Add(target, config)
    if self.Unloaded then return end
    if not target or not target:IsA("Instance") or not (target:IsA("Model") or target:IsA("BasePart")) then return end

    local existing = self:GetESP(target)
    if existing then
        self:Remove(target)
    end

    for _, obj in ipairs(target:GetChildren()) do
        if obj:IsA("Highlight") and obj.Name == "ESPHighlight" then
            obj:Destroy()
        end
    end

    local cfg = {
        Target = target,
        Enabled = true,
        Name = config and config.Name or target.Name,
        ModifiedParts = {},
        DistancePrefix = config and config.DistancePrefix or "",
        DistanceSuffix = config and config.DistanceSuffix or "",
        DisplayOrder = config and config.DisplayOrder or 0,
        Types = {
            Tracer = config and config.Types and config.Types.Tracer ~= nil and config.Types.Tracer or true,
            Name = config and config.Types and config.Types.Name ~= nil and config.Types.Name or true,
            Distance = config and config.Types and config.Types.Distance ~= nil and config.Types.Distance or true,
            HighlightFill = config and config.Types and config.Types.HighlightFill ~= nil and config.Types.HighlightFill or true,
            HighlightOutline = config and config.Types and config.Types.HighlightOutline ~= nil and config.Types.HighlightOutline or true,
        },
        TextOutlineEnabled = config and config.TextOutlineEnabled ~= nil and config.TextOutlineEnabled or self.GlobalSettings.TextOutlineEnabled,
        TextOutlineColor = config and config.TextOutlineColor or self.GlobalSettings.TextOutlineColor,
        TextOutlineThickness = config and config.TextOutlineThickness or self.GlobalSettings.TextOutlineThickness,
        ColorDependency = config and config.ColorDependency or nil,
        Opacity = config and config.Opacity or self.GlobalSettings.Opacity,
        LineThickness = config and config.LineThickness or self.GlobalSettings.LineThickness,
        FontSize = config and config.FontSize or self.GlobalSettings.FontSize,
        Font = config and config.Font or self.GlobalSettings.Font,
        MaxDistance = config and config.MaxDistance or self.GlobalSettings.MaxDistance,
        MinDistance = config and config.MinDistance or self.GlobalSettings.MinDistance,
        Collision = config and config.Collision or false,
        DistanceFloat = config and config.DistanceFloat ~= nil and config.DistanceFloat or true,
        RainbowMode = config and config.RainbowMode ~= nil and config.RainbowMode or self.GlobalSettings.RainbowMode,  -- Novo: rainbow por ESP
        cachedCenter = nil  -- Cache para centro visível
    }

    applyColors(cfg, config)

    if self.Enabled then
        CreateDrawings(cfg)
    else
        local allParts = collectBaseParts(target)
        setupCollision(cfg, target, allParts)
        setupHighlight(cfg, target)
    end

    table.insert(self.Objects, cfg)
end

--// Reajusta ESP para novo target/config
function KoltESP:Readjustment(newTarget, oldTarget, newConfig)
    if self.Unloaded then return end
    if not newTarget or not newTarget:IsA("Instance") or not (newTarget:IsA("Model") or newTarget:IsA("BasePart")) then return end

    local esp = self:GetESP(oldTarget)
    if not esp then return end

    CleanupESP(esp)

    esp.Target = newTarget
    esp.Name = newConfig and newConfig.Name or newTarget.Name
    esp.DistancePrefix = newConfig and newConfig.DistancePrefix or ""
    esp.DistanceSuffix = newConfig and newConfig.DistanceSuffix or ""
    esp.DisplayOrder = newConfig and newConfig.DisplayOrder or 0
    esp.TextOutlineEnabled = newConfig and newConfig.TextOutlineEnabled ~= nil and newConfig.TextOutlineEnabled or self.GlobalSettings.TextOutlineEnabled
    esp.TextOutlineColor = newConfig and newConfig.TextOutlineColor or self.GlobalSettings.TextOutlineColor
    esp.TextOutlineThickness = newConfig and newConfig.TextOutlineThickness or self.GlobalSettings.TextOutlineThickness
    esp.ColorDependency = newConfig and newConfig.ColorDependency or nil
    esp.Opacity = newConfig and newConfig.Opacity or self.GlobalSettings.Opacity
    esp.LineThickness = newConfig and newConfig.LineThickness or self.GlobalSettings.LineThickness
    esp.FontSize = newConfig and newConfig.FontSize or self.GlobalSettings.FontSize
    esp.Font = newConfig and newConfig.Font or self.GlobalSettings.Font
    esp.MaxDistance = newConfig and newConfig.MaxDistance or self.GlobalSettings.MaxDistance
    esp.MinDistance = newConfig and newConfig.MinDistance or self.GlobalSettings.MinDistance
    esp.Collision = newConfig and newConfig.Collision or false
    esp.DistanceFloat = newConfig and newConfig.DistanceFloat ~= nil and newConfig.DistanceFloat or true
    esp.RainbowMode = newConfig and newConfig.RainbowMode ~= nil and newConfig.RainbowMode or self.GlobalSettings.RainbowMode

    applyColors(esp, newConfig)

    esp.Types = {
        Tracer = newConfig and newConfig.Types and newConfig.Types.Tracer ~= nil and newConfig.Types.Tracer or true,
        Name = newConfig and newConfig.Types and newConfig.Types.Name ~= nil and newConfig.Types.Name or true,
        Distance = newConfig and newConfig.Types and newConfig.Types.Distance ~= nil and newConfig.Types.Distance or true,
        HighlightFill = newConfig and newConfig.Types and newConfig.Types.HighlightFill ~= nil and newConfig.Types.HighlightFill or true,
        HighlightOutline = newConfig and newConfig.Types and newConfig.Types.HighlightOutline ~= nil and newConfig.Types.HighlightOutline or true,
    }

    if self.Enabled then
        CreateDrawings(esp)
    end
end

--// Atualiza config de ESP existente
function KoltESP:UpdateConfig(target, newConfig)
    if self.Unloaded then return end
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
    if newConfig.DistanceFloat ~= nil then esp.DistanceFloat = newConfig.DistanceFloat end
    if newConfig.RainbowMode ~= nil then esp.RainbowMode = newConfig.RainbowMode end

    if newConfig.Color then
        applyColors(esp, newConfig)
    end

    if newConfig.Types then
        if newConfig.Types.Tracer ~= nil then esp.Types.Tracer = newConfig.Types.Tracer end
        if newConfig.Types.Name ~= nil then esp.Types.Name = newConfig.Types.Name end
        if newConfig.Types.Distance ~= nil then esp.Types.Distance = newConfig.Types.Distance end
        if newConfig.Types.HighlightFill ~= nil then 
            esp.Types.HighlightFill = newConfig.Types.HighlightFill 
            setupHighlight(esp, target)
        end
        if newConfig.Types.HighlightOutline ~= nil then 
            esp.Types.HighlightOutline = newConfig.Types.HighlightOutline 
            setupHighlight(esp, target)
        end
    end

    local newCollision = newConfig.Collision
    if newCollision ~= nil and newCollision ~= esp.Collision then
        CleanupESP(esp)
        esp.Collision = newCollision
        needsRecreate = true
    end

    if needsRecreate and self.Enabled then
        CreateDrawings(esp)
    elseif newCollision ~= nil then
        local allParts = collectBaseParts(target)
        setupCollision(esp, target, allParts)
        setupHighlight(esp, target)
    end
end

--// Alterna ESP individual
function KoltESP:ToggleIndividual(target, enabled)
    if self.Unloaded then return end
    local esp = self:GetESP(target)
    if esp then
        esp.Enabled = enabled ~= nil and enabled or not esp.Enabled
    end
end

--// Define cor única para ESP
function KoltESP:SetColor(target, color)
    if self.Unloaded then return end
    local esp = self:GetESP(target)
    if esp and typeof(color) == "Color3" then
        esp.Colors.Name = color
        esp.Colors.Distance = color
        esp.Colors.Tracer = color
        esp.Colors.Highlight.Filled = color
        esp.Colors.Highlight.Outline = color
    end
end

--// Define nome para ESP
function KoltESP:SetName(target, newName)
    if self.Unloaded then return end
    local esp = self:GetESP(target)
    if esp then
        esp.Name = newName
    end
end

--// Define ordem de display para ESP
function KoltESP:SetDisplayOrder(target, displayOrder)
    if self.Unloaded then return end
    local esp = self:GetESP(target)
    if esp then
        esp.DisplayOrder = displayOrder
        if esp.tracerLine then esp.tracerLine.ZIndex = displayOrder end
        if esp.nameText then esp.nameText.ZIndex = displayOrder end
        if esp.distanceText then esp.distanceText.ZIndex = displayOrder end
    end
end

--// Define outline de texto para ESP
function KoltESP:SetTextOutline(target, enabled, color, thickness)
    if self.Unloaded then return end
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

--// Remove ESP individual
function KoltESP:Remove(target)
    if self.Unloaded then return end
    for i = #self.Objects, 1, -1 do
        if self.Objects[i].Target == target then
            CleanupESP(self.Objects[i])
            table.remove(self.Objects, i)
            break
        end
    end
end

--// Limpa todos ESPs
function KoltESP:Clear()
    if self.Unloaded then return end
    for i = #self.Objects, 1, -1 do
        CleanupESP(self.Objects[i])
        table.remove(self.Objects, i)
    end
end

--// Descarrega a library
function KoltESP:Unload()
    if self.Unloaded then return end
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end
    self.Enabled = false
    for player in pairs(PlayerESPs) do
        self:RemoveFromPlayer(player)
    end
    self:Clear()
    local folder = ReplicatedStorage:FindFirstChild(HighlightFolderName)
    if folder then
        folder:Destroy()
    end
    highlightFolder = nil
    self.Unloaded = true
end

--// Habilita todos ESPs
function KoltESP:EnableAll()
    if self.Unloaded then return end
    self.Enabled = true
    for _, esp in ipairs(self.Objects) do
        if not esp.tracerLine then
            CreateDrawings(esp)
        end
    end
end

--// Desabilita todos ESPs
function KoltESP:DisableAll()
    if self.Unloaded then return end
    self.Enabled = false
    for _, esp in ipairs(self.Objects) do
        CleanupESP(esp)
    end
end

--// Atualiza settings globais em todos ESPs
function KoltESP:UpdateGlobalSettings()
    if self.Unloaded then return end
    for _, esp in ipairs(self.Objects) do
        if esp.tracerLine then
            esp.tracerLine.Thickness = self.GlobalSettings.LineThickness
            esp.tracerLine.Transparency = self.GlobalSettings.Opacity
        end
        if esp.nameText then
            esp.nameText.Size = self.GlobalSettings.FontSize
            esp.nameText.Transparency = self.GlobalSettings.Opacity
            esp.nameText.Outline = self.GlobalSettings.TextOutlineEnabled
            esp.nameText.OutlineColor = self.GlobalSettings.TextOutlineColor
            esp.nameText.Font = self.GlobalSettings.Font
        end
        if esp.distanceText then
            esp.distanceText.Size = self.GlobalSettings.FontSize - 2
            esp.distanceText.Transparency = self.GlobalSettings.Opacity
            esp.distanceText.Outline = self.GlobalSettings.TextOutlineEnabled
            esp.distanceText.OutlineColor = self.GlobalSettings.TextOutlineColor
            esp.distanceText.Font = self.GlobalSettings.Font
        end
        setupHighlight(esp, esp.Target)
    end
end

--// APIs globais
function KoltESP:SetGlobalTracerOrigin(origin)
    if self.Unloaded then return end
    if tracerOrigins[origin] then
        self.GlobalSettings.TracerOrigin = origin
    end
end

function KoltESP:SetGlobalESPType(typeName, enabled)
    if self.Unloaded then return end
    if self.GlobalSettings[typeName] ~= nil then
        self.GlobalSettings[typeName] = enabled
        self:UpdateGlobalSettings()
    end
end

function KoltESP:SetGlobalRainbow(enable)
    if self.Unloaded then return end
    self.GlobalSettings.RainbowMode = enable
    self:UpdateGlobalSettings()
end

function KoltESP:SetGlobalOpacity(value)
    if self.Unloaded then return end
    self.GlobalSettings.Opacity = math.clamp(value, 0, 1)
    self:UpdateGlobalSettings()
end

function KoltESP:SetGlobalFontSize(size)
    if self.Unloaded then return end
    self.GlobalSettings.FontSize = math.max(10, size)
    self:UpdateGlobalSettings()
end

function KoltESP:SetGlobalLineThickness(thick)
    if self.Unloaded then return end
    self.GlobalSettings.LineThickness = math.max(1, thick)
    self:UpdateGlobalSettings()
end

function KoltESP:SetGlobalTextOutline(enabled, color, thickness)
    if self.Unloaded then return end
    if enabled ~= nil then self.GlobalSettings.TextOutlineEnabled = enabled end
    if color then self.GlobalSettings.TextOutlineColor = color end
    if thickness then self.GlobalSettings.TextOutlineThickness = thickness end
    self:UpdateGlobalSettings()
end

function KoltESP:SetGlobalFont(font)
    if self.Unloaded then return end
    if typeof(font) == "number" and font >= 0 and font <= 3 then
        self.GlobalSettings.Font = font
        self:UpdateGlobalSettings()
    end
end

--// Suporte a ESPs para players (com respawn)
local PlayerESPs = {}

function KoltESP:AddToPlayer(player, config)
    if self.Unloaded then return end
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
            task.wait(0.1)  -- Pequeno delay para estabilidade
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
    if self.Unloaded then return end
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

--// Loop de atualização (RenderStepped)
KoltESP.connection = RunService.RenderStepped:Connect(function()
    if not KoltESP.Enabled then return end

    local camera = workspace.CurrentCamera
    if not camera then return end
    local vs = camera.ViewportSize
    local time = tick()

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

        local pos3D
        if esp.Collision then
            local cf = getBoundingBox(target)
            if not cf then continue end
            pos3D = cf.Position
        else
            -- Use cache se disponível, senão calcule
            if not esp.cachedCenter then
                local totalPos = Vector3.zero
                local totalVolume = 0
                local validParts = 0
                for _, part in ipairs(esp.visibleParts or {}) do
                    if part and part.Parent then
                        local vol = part.Size.Magnitude  -- Usando Magnitude para simplificar (mais rápido que X*Y*Z)
                        totalPos = totalPos + part.Position * vol
                        totalVolume = totalVolume + vol
                        validParts = validParts + 1
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
                esp.cachedCenter = pos3D  -- Cache para próximo frame (invalidar se necessário, mas por agora assume estático)
            else
                pos3D = esp.cachedCenter
            end
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
        if distance < esp.MinDistance or distance > esp.MaxDistance then
            esp.tracerLine.Visible = false
            esp.nameText.Visible = false
            esp.distanceText.Visible = false
            if esp.highlight then esp.highlight.Enabled = false end
            continue
        end

        -- Cor dependente
        local currentColor = nil
        if esp.ColorDependency and typeof(esp.ColorDependency) == "function" then
            currentColor = esp.ColorDependency(esp, distance, pos3D)
        end

        -- Cor rainbow se ativado
        local useRainbow = esp.RainbowMode  -- Agora por ESP
        local rainbowColor = useRainbow and getRainbowColor(time) or nil

        -- Posicionamento de texto
        local centerX = pos2D.X
        local centerY = pos2D.Y
        local nameSize = esp.nameText.Size
        local distSize = esp.distanceText.Size
        local totalHeight = (esp.Types.Name and nameSize or 0) + (esp.Types.Distance and distSize or 0)
        local startY = centerY - totalHeight / 2

        -- Atualiza tracer
        if KoltESP.GlobalSettings.ShowTracer and esp.Types.Tracer then
            esp.tracerLine.Visible = true
            esp.tracerLine.From = tracerOrigins[KoltESP.GlobalSettings.TracerOrigin](vs)
            esp.tracerLine.To = Vector2.new(pos2D.X, pos2D.Y)
            esp.tracerLine.Color = rainbowColor or currentColor or esp.Colors.Tracer
        else
            esp.tracerLine.Visible = false
        end

        -- Atualiza nome
        if KoltESP.GlobalSettings.ShowName and esp.Types.Name then
            esp.nameText.Visible = true
            esp.nameText.Position = Vector2.new(centerX, startY)
            esp.nameText.Text = esp.Name
            esp.nameText.Color = rainbowColor or currentColor or esp.Colors.Name
            startY = startY + nameSize
        else
            esp.nameText.Visible = false
        end

        -- Atualiza distância
        if KoltESP.GlobalSettings.ShowDistance and esp.Types.Distance then
            esp.distanceText.Visible = true
            esp.distanceText.Position = Vector2.new(centerX, startY)
            local distStr = esp.DistanceFloat and string.format("%.1f", distance) or tostring(math.floor(distance + 0.5))
            esp.distanceText.Text = esp.DistancePrefix .. distStr .. esp.DistanceSuffix
            esp.distanceText.Color = rainbowColor or currentColor or esp.Colors.Distance
        else
            esp.distanceText.Visible = false
        end

        -- Atualiza highlight
        if esp.highlight then
            local showFill = KoltESP.GlobalSettings.ShowHighlightFill and esp.Types.HighlightFill
            local showOutline = KoltESP.GlobalSettings.ShowHighlightOutline and esp.Types.HighlightOutline
            esp.highlight.Enabled = showFill or showOutline
            esp.highlight.FillColor = rainbowColor or currentColor or esp.Colors.Highlight.Filled
            esp.highlight.OutlineColor = rainbowColor or currentColor or esp.Colors.Highlight.Outline
            esp.highlight.FillTransparency = showFill and KoltESP.GlobalSettings.HighlightTransparency.Filled or 1
            esp.highlight.OutlineTransparency = showOutline and KoltESP.GlobalSettings.HighlightTransparency.Outline or 1
        end
    end
end)

return KoltESP
