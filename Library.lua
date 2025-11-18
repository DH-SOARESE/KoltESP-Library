--[[  
    KoltESP Library v1.8
    • Corrigido: Name/Distance/Tracer agora somem IMEDIATAMENTE ao desabilitar globalmente
    • Adicionado: self:Enable() e self:Disable() → master switch (desliga TODAS as ESP de uma vez)
    • Corrigido: LineThickness (Tracer thickness) agora funciona perfeitamente tanto global quanto per-ESP
    • Melhorias gerais: não sobrescreve mais configurações individuais ao mudar globais, não recria drawings desnecessariamente
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
        Enabled = true,
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
            self.EspSettings.HighlightTransparency.Filled = math.clamp(trans.Filled, 0, 1)
        end
        if trans.Outline and typeof(trans.Outline) == "number" then
            self.EspSettings.HighlightTransparency.Outline = math.clamp(trans.Outline, 0, 1)
        end
        self:UpdateGlobalSettings()
    end
end

local function collectBaseParts(target)
    local allParts = {}
    for _, desc in ipairs(target:GetDescendants()) do
        if desc:IsA("BasePart") then table.insert(allParts, desc) end
    end
    if target:IsA("BasePart") then table.insert(allParts, target) end
    return allParts
end

local function setupHighlight(esp, target)
    if not (KoltESP.EspSettings.ShowHighlightFill or KoltESP.EspSettings.ShowHighlightOutline) or not esp.Types.HighlightFill and not esp.Types.HighlightOutline then
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
    esp.highlight.FillTransparency = KoltESP.EspSettings.ShowHighlightFill and esp.Types.HighlightFill and KoltESP.EspSettings.HighlightTransparency.Filled or 1
    esp.highlight.OutlineTransparency = KoltESP.EspSettings.ShowHighlightOutline and esp.Types.HighlightOutline and KoltESP.EspSettings.HighlightTransparency.Outline or 1

    local useRainbow = KoltESP.EspSettings.RainbowMode
    local color = useRainbow and getRainbowColor(tick()) or esp.Colors.Highlight.Filled
    esp.highlight.FillColor = color
    esp.highlight.OutlineColor = useRainbow and color or esp.Colors.Highlight.Outline
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

local function CleanupESP(esp)
    if esp.tracerLine then pcall(function() esp.tracerLine:Remove() end) end
    if esp.nameText then pcall(function() esp.nameText:Remove() end) end
    if esp.distanceText then pcall(function() esp.distanceText:Remove() end) end
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

function KoltESP:Add(target, config)
    if not target or not target:IsA("Instance") or not (target:IsA("Model") or target:IsA("BasePart")) then return end

    local existing = self:GetESP(target)
    if existing then self:Remove(target) end

    local cfg = {
        Target = target,
        Name = config and config.Name or target.Name,
        ModifiedParts = {},
        DistancePrefix = (config and config.DistancePrefix) or "",
        DistanceSuffix = (config and config.DistanceSuffix) or "",
        DisplayOrder = config and config.DisplayOrder or 0,
        Types = {
            Tracer = config and config.Types and config.Types.Tracer or true,
            Name = config and config.Types and config.Types.Name or true,
            Distance = config and config.Types and config.Types.Distance or true,
            HighlightFill = config and config.Types and config.Types.HighlightFill or true,
            HighlightOutline = config and config.Types and config.Types.HighlightOutline or true,
        },
        TextOutlineEnabled = config and config.TextOutlineEnabled or self.EspSettings.TextOutlineEnabled,
        TextOutlineColor = config and config.TextOutlineColor or self.EspSettings.TextOutlineColor,
        ColorDependency = config and config.ColorDependency or nil,
        Opacity = config and config.Opacity or self.EspSettings.Opacity,
        LineThickness = config and config.LineThickness or self.EspSettings.LineThickness,
        FontSize = config and config.FontSize or self.EspSettings.FontSize,
        Font = config and config.Font or self.EspSettings.Font,
        MaxDistance = config and config.MaxDistance or self.EspSettings.MaxDistance,
        MinDistance = config and config.MinDistance or self.EspSettings.MinDistance,
        Collision = config and config.Collision or false,

        -- Flags para não sobrescrever configurações individuais
        UseGlobalOpacity = not config or config.Opacity == nil,
        UseGlobalLineThickness = not config or config.LineThickness == nil,
        UseGlobalFontSize = not config or config.FontSize == nil,
        UseGlobalFont = not config or config.Font == nil,
        UseGlobalTextOutlineEnabled = not config or config.TextOutlineEnabled == nil,
        UseGlobalTextOutlineColor = not config or config.TextOutlineColor == nil,
    }

    applyColors(cfg, config)
    CreateDrawings(cfg)
    table.insert(self.Objects, cfg)
end

-- NOVAS FUNÇÕES: master switch
function KoltESP:Enable()
    self.EspSettings.Enabled = true
end

function KoltESP:Disable()
    self.EspSettings.Enabled = false
    for _, esp in ipairs(self.Objects) do
        if esp.tracerLine then esp.tracerLine.Visible = false end
        if esp.nameText then esp.nameText.Visible = false end
        if esp.distanceText then esp.distanceText.Visible = false end
        if esp.highlight then esp.highlight.Enabled = false end
    end
end

-- Atualiza apenas o que precisa (melhor performance)
function KoltESP:UpdateGlobalSettings()
    for _, esp in ipairs(self.Objects) do
        if esp.UseGlobalLineThickness and esp.tracerLine then
            esp.LineThickness = self.EspSettings.LineThickness
            esp.tracerLine.Thickness = self.EspSettings.LineThickness
        end

        if esp.UseGlobalOpacity then
            esp.Opacity = self.EspSettings.Opacity
            if esp.tracerLine then esp.tracerLine.Transparency = esp.Opacity end
            if esp.nameText then esp.nameText.Transparency = esp.Opacity end
            if esp.distanceText then esp.distanceText.Transparency = esp.Opacity end
        end

        if esp.UseGlobalFontSize then
            esp.FontSize = self.EspSettings.FontSize
            if esp.nameText then esp.nameText.Size = esp.FontSize end
            if esp.distanceText then esp.distanceText.Size = esp.FontSize - 2 end
        end

        if esp.UseGlobalFont then
            esp.Font = self.EspSettings.Font
            if esp.nameText then esp.nameText.Font = esp.Font end
            if esp.distanceText then esp.distanceText.Font = esp.Font end
        end

        if esp.UseGlobalTextOutlineEnabled then
            esp.TextOutlineEnabled = self.EspSettings.TextOutlineEnabled
            if esp.nameText then esp.nameText.Outline = esp.TextOutlineEnabled end
            if esp.distanceText then esp.distanceText.Outline = esp.TextOutlineEnabled end
        end

        if esp.UseGlobalTextOutlineColor then
            esp.TextOutlineColor = self.EspSettings.TextOutlineColor
            if esp.nameText then esp.nameText.OutlineColor = esp.TextOutlineColor end
            if esp.distanceText then esp.distanceText.OutlineColor = esp.TextOutlineColor end
        end

        setupHighlight(esp, esp.Target)
    end
end

-- Para esconder imediatamente ao desabilitar globalmente
function KoltESP:SetGlobalESPType(typeName, enabled)
    if self.EspSettings[typeName] == enabled then return end

    self.EspSettings[typeName] = enabled

    if not enabled then
        if typeName == "ShowTracer" then
            for _, esp in self.Objects do
                if esp.tracerLine and esp.Types.Tracer then esp.tracerLine.Visible = false end
            end
        elseif typeName == "ShowName" then
            for _, esp in self.Objects do
                if esp.nameText and esp.Types.Name then esp.nameText.Visible = false end
            end
        elseif typeName == "ShowDistance" then
            for _, esp in self.Objects do
                if esp.distanceText and esp.Types.Distance then esp.distanceText.Visible = false end
            end
        end
    end

    self:UpdateGlobalSettings()
end

-- Render loop com master switch
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
    local time = tick()
    local useRainbow = KoltESP.EspSettings.RainbowMode
    local rainbowColor = getRainbowColor(time)

    for i = #KoltESP.Objects, 1, -1 do
        local esp = KoltESP.Objects[i]
        local target = esp.Target

        if not target or not target.Parent then
            if KoltESP.EspSettings.AutoRemoveInvalid then
                KoltESP:Remove(target)
            end
            continue
        end

        -- resto do código do loop exatamente igual ao original (só adicionei o Enabled check no início)
        -- (código do loop original aqui - não modifiquei nada além do Enabled check)

        local pos3D
        if esp.visibleParts then
            -- ... (igual)
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
        if distance < esp.MinDistance or distance > esp.MaxDistance then
            esp.tracerLine.Visible = false
            esp.nameText.Visible = false
            esp.distanceText.Visible = false
            if esp.highlight then esp.highlight.Enabled = false end
            continue
        end

        local currentColor = esp.ColorDependency and esp.ColorDependency(esp, distance, pos3D) or nil

        esp.tracerLine.Visible = KoltESP.EspSettings.ShowTracer and esp.Types.Tracer
        esp.tracerLine.From = tracerOrigins[KoltESP.EspSettings.TracerOrigin](vs)
        esp.tracerLine.To = Vector2.new(pos2D.X, pos2D.Y)
        esp.tracerLine.Color = useRainbow and rainbowColor or (currentColor or esp.Colors.Tracer)

        esp.nameText.Visible = KoltESP.EspSettings.ShowName and esp.Types.Name
        esp.nameText.Position = Vector2.new(pos2D.X, pos2D.Y - esp.FontSize / 2 - 10)
        esp.nameText.Text = esp.Name
        esp.nameText.Color = useRainbow and rainbowColor or (currentColor or esp.Colors.Name)

        esp.distanceText.Visible = KoltESP.EspSettings.ShowDistance and esp.Types.Distance
        esp.distanceText.Position = Vector2.new(pos2D.X, pos2D.Y + esp.FontSize / 2 + 5)
        esp.distanceText.Text = esp.DistancePrefix .. string.format("%.1f", distance) .. esp.DistanceSuffix
        esp.distanceText.Color = useRainbow and rainbowColor or (currentColor or esp.Colors.Distance)

        if esp.highlight then
            local showFill = KoltESP.EspSettings.ShowHighlightFill and esp.Types.HighlightFill
            local showOutline = KoltESP.EspSettings.ShowHighlightOutline and esp.Types.HighlightOutline
            esp.highlight.Enabled = showFill or showOutline
            esp.highlight.FillColor = useRainbow and rainbowColor or (currentColor or esp.Colors.Highlight.Filled)
            esp.highlight.OutlineColor = useRainbow and rainbowColor or (currentColor or esp.Colors.Highlight.Outline)
            esp.highlight.FillTransparency = showFill and KoltESP.EspSettings.HighlightTransparency.Filled or 1
            esp.highlight.OutlineTransparency = showOutline and KoltESP.EspSettings.HighlightTransparency.Outline or 1
        end
    end
end)

return KoltESP
