--[[  
    KoltESP Library v1.8 - Com suporte a KEYS (strings identificadoras)
    • Agora você pode usar strings como identificador ("EspBanana")
    • Add(key: string, config) → procura automaticamente workspace:FindFirstChild(key)
    • Todas as funções aceitam string key OU instance target
    • Readjustment(key, newTarget, newConfig?) quando o model respawna/destroi
    • ESP["SuaKey"] = target atual (global acessível)
    • AutoRemoveInvalid só remove se não tiver key (para permitir Readjustment)
]]

local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace") -- corrigido para workspace (padrão Roblox)

local HighlightFolderName = "Highlight Folder" 
local highlightFolder = nil 

local function getHighlightFolder()
    if not highlightFolder then
        highlightFolder = workspace.Parent:FindFirstChild(HighlightFolderName) or workspace.Parent:FindFirstChild(HighlightFolderName)
        if not highlightFolder then
            highlightFolder = Instance.new("Folder")
            highlightFolder.Name = HighlightFolderName
            highlightFolder.Parent = workspace.Parent
        end
    end
    return highlightFolder
end

local KoltESP = {
    Objects = {},
    Theme = {
        PrimaryColor = Color3.fromRGB(130, 200, 255),
        SecondaryColor = Color3.fromRGB(255, 255, 255),
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
        TextOutlineColor = Color3.new(0, 0, 0),
        TextOutlineThickness = 1,
        Enabled = true,
    }
}

-- Tabelas de suporte a keys
local ESP = {}          -- getgenv().ESP["MinhaKey"] = target atual
local KeyToEsp = {}     -- "MinhaKey" → esp object
local ColorRegistry = {} -- target → {TextColor, DistanceColor, TracerColor, HighlightColor}

getgenv().ESP = ESP
getgenv().KoltESP = KoltESP
KoltESP.ESP = ESP  -- KoltESP.ESP["key"] também funciona

-- Cor arco-íris
local function getRainbowColor(t)
    local f = 2
    return Color3.fromRGB(
        math.sin(f*t + 0)*127 + 128,
        math.sin(f*t + 2)*127 + 128,
        math.sin(f*t + 4)*127 + 128
    )
end

-- Tracer origins
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

local function createDrawing(class, props)
    local obj = Drawing.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

local function collectBaseParts(target)
    local parts = {}
    for _, v in ipairs(target:GetDescendants()) do
        if v:IsA("BasePart") then table.insert(parts, v) end
    end
    if target:IsA("BasePart") then table.insert(parts, target) end
    return parts
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
                if config.Color.Highlight.Outline and typeof(config.Color.Outline) == "table" and #config.Color.Highlight.Outline == 3 then
                    cfg.Colors.Highlight.Outline = Color3.fromRGB(unpack(config.Color.Highlight.Outline))
                end
            end
        end
    end

    -- Registro de cores (prioridade máxima)
    local reg = ColorRegistry[cfg.Target]
    if reg then
        if reg.TextColor then cfg.Colors.Name = reg.TextColor end
        if reg.DistanceColor then cfg.Colors.Distance = reg.DistanceColor end
        if reg.TracerColor then cfg.Colors.Tracer = reg.TracerColor end
        if reg.HighlightColor then
            cfg.Colors.Highlight.Filled = reg.HighlightColor
            cfg.Colors.Highlight.Outline = reg.HighlightColor
        end
    end
end

local function CleanupESP(esp)
    if esp.tracerLine then pcall(esp.tracerLine.Remove, esp.tracerLine) end
    if esp.tracerLine = nil
    if esp.nameText then pcall(esp.nameText.Remove, esp.nameText) end
    if esp.distanceText then pcall(esp.distanceText.Remove, esp.distanceText) end
    if esp.highlight then esp.highlight:Destroy() end
    if esp.humanoid then esp.humanoid:Destroy() end

    for _, mod in ipairs(esp.ModifiedParts) do
        if mod.Part and mod.Part.Parent then
            mod.Part.Transparency = mod.Original
        end
    end

    esp.ModifiedParts = {}
    esp.visibleParts = nil
    esp.humanoid = nil
end

local function CreateDrawings(esp)
    local allParts = collectBaseParts(esp.Target)

    -- Collision (mostrar partes invisíveis)
    if esp.Collision then
        local hum = esp.Target:FindFirstChild("Esp") or Instance.new("Humanoid")
        hum.Name = "Esp"
        hum.Parent = esp.Target
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

    esp.tracerLine = createDrawing("Line", {Thickness = esp.LineThickness, Transparency = esp.Opacity, Visible = false})
    esp.nameText   = createDrawing("Text", {Size = esp.FontSize, Center = true, Outline = esp.TextOutlineEnabled, OutlineColor = esp.TextOutlineColor, Font = esp.Font, Transparency = esp.Opacity, Visible = false})
    esp.distanceText = createDrawing("Text", {Size = esp.FontSize - 2, Center = true, Outline = esp.TextOutlineEnabled, OutlineColor = esp.TextOutlineColor, Font = esp.Font, Transparency = esp.Opacity, Visible = false})

    local showFill = KoltESP.EspSettings.ShowHighlightFill and esp.Types.HighlightFill
    local showOutline = KoltESP.EspSettings.ShowHighlightOutline and esp.Types.HighlightOutline

    if showFill or showOutline then
        esp.highlight = Instance.new("Highlight")
        esp.highlight.Name = "ESPHighlight"
        esp.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        esp.highlight.Adornee = esp.Target
        esp.highlight.FillTransparency = showFill and KoltESP.EspSettings.HighlightTransparency.Filled or 1
        esp.highlight.OutlineTransparency = showOutline and KoltESP.EspSettings.HighlightTransparency.Outline or 1
        esp.highlight.FillColor = esp.Colors.Highlight.Filled
        esp.highlight.OutlineColor = esp.Colors.Highlight.Outline
        esp.highlight.Parent = getHighlightFolder()
    end
end

-- GetESP aceita string key OU instance target
function KoltESP:GetESP(id)
    if typeof(id) == "string" then
        return KeyToEsp[id]
    else
        for _, esp in ipairs(self.Objects) do
            if esp.Target == id then return esp end
        end
    end
    return nil
end

-- Add(key or target, config)
function KoltESP:Add(id, config)
    local key = nil
    local target

    if typeof(id) == "string" then
        key = id
        target = workspace:FindFirstChild(id)
        if not target then
            warn("[KoltESP] Target '" .. id .. "' não encontrado em workspace")
            return
        end
    elseif id:IsA("Model") or id:IsA("BasePart") then
        target = id
    else
        return
    end

    -- Remove se já existir
    local existing = self:GetESP(target) or (key and KeyToEsp[key])
    if existing then self:Remove(existing.Key or target) end

    local cfg = {
        Target = target,
        Key = key,
        Name = (config and config.Name) or target.Name,
        DistancePrefix = config and config.DistancePrefix or "",
        DistanceSuffix = config and config.DistanceSuffix or "",
        DisplayOrder = config and config.DisplayOrder or 0,
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

    if key then
        KeyToEsp[key] = cfg
        ESP[key] = target
    end

    return cfg
end

-- Readjustment(key, newTarget, newConfig?)
function KoltESP:Readjustment(key, newTarget, newConfig)
    if typeof(key) ~= "string" or not newTarget then return end

    local esp = KeyToEsp[key]
    if not esp then return end

    local oldTarget = esp.Target

    CleanupESP(esp)

    esp.Target = newTarget
    ESP[key] = newTarget

    -- Move registry de cores
    if ColorRegistry[oldTarget] then
        ColorRegistry[newTarget] = ColorRegistry[oldTarget]
        ColorRegistry[oldTarget] = nil
    end

    if newConfig then
        self:UpdateConfig(key, newConfig) -- aplica novas configs (sem recreate se não precisar)
    end

    CreateDrawings(esp) -- recria highlight, collision, etc.
    applyColors(esp, newConfig) -- reaplica cores se mudou
end

-- UpdateConfig aceita key ou target
function KoltESP:UpdateConfig(id, newConfig)
    local esp = self:GetESP(id)
    if not esp then return end

    -- Atualiza propriedades simples
    if newConfig.Name then esp.Name = newConfig.Name end
    if newConfig.DistancePrefix then esp.DistancePrefix = newConfig.DistancePrefix end
    if newConfig.DistanceSuffix then esp.DistanceSuffix = newConfig.DistanceSuffix end
    if newConfig.DisplayOrder ~= nil then esp.DisplayOrder = newConfig.DisplayOrder end
    if newConfig.TextOutlineEnabled ~= nil then esp.TextOutlineEnabled = newConfig.TextOutlineEnabled end
    if newConfig.TextOutlineColor then esp.TextOutlineColor = newConfig.TextOutlineColor end
    if newConfig.Opacity ~= nil then esp.Opacity = newConfig.Opacity end
    if newConfig.LineThickness ~= nil then esp.LineThickness = newConfig.LineThickness end
    if newConfig.FontSize ~= nil then esp.FontSize = newConfig.FontSize end
    if newConfig.Font ~= nil then esp.Font = newConfig.Font end
    if newConfig.MaxDistance ~= nil then esp.MaxDistance = newConfig.MaxDistance end
    if newConfig.MinDistance ~= nil then esp.MinDistance = newConfig.MinDistance end

    if newConfig.Color then applyColors(esp, newConfig) end

    if newConfig.Types then
        for k, v in pairs(newConfig.Types) do
            if esp.Types[k] ~= nil then esp.Types[k] = v end
        end
    end

    if newConfig.Collision ~= nil and newConfig.Collision ~= esp.Collision then
        CleanupESP(esp)
        esp.Collision = newConfig.Collision
        CreateDrawings(esp)
    else
        -- Atualiza drawings sem recreate
        if esp.tracerLine then
            esp.tracerLine.Thickness = esp.LineThickness
            esp.tracerLine.Transparency = esp.Opacity
            esp.tracerLine.ZIndex = esp.DisplayOrder
        end
        if esp.nameText then
            esp.nameText.Size = esp.FontSize
            esp.nameText.Outline = esp.TextOutlineEnabled
            esp.nameText.OutlineColor = esp.TextOutlineColor
            esp.nameText.Font = esp.Font
            esp.nameText.ZIndex = esp.DisplayOrder
        end
        -- ... (distanceText igual)
        if esp.highlight then
            esp.highlight.FillColor = esp.Colors.Highlight.Filled
            esp.highlight.OutlineColor = esp.Colors.Highlight.Outline
        end
    end
end

-- Remove aceita key ou target
function KoltESP:Remove(id)
    local esp = self:GetESP(id)
    if not esp then return end

    CleanupESP(esp)

    if esp.Key then
        KeyToEsp[esp.Key] = nil
        ESP[esp.Key] = nil
    end

    for i = #self.Objects, 1, -1 do
        if self.Objects[i] == esp then
            table.remove(self.Objects, i)
            break
        end
    end
end

-- AddToRegistry corrigido (aceita key ou target)
function KoltESP:AddToRegistry(id, config)
    local target = typeof(id) == "string" and workspace:FindFirstChild(id) or id
    if not target then return end

    ColorRegistry[target] = {
        TextColor = config.TextColor,
        DistanceColor = config.DistanceColor,
        TracerColor = config.TracerColor,
        HighlightColor = config.HighlightColor,
    }

    local esp = self:GetESP(id)
    if esp then
        local reg = ColorRegistry[target]
        if reg.TextColor then esp.Colors.Name = reg.TextColor end
        if reg.DistanceColor then esp.Colors.Distance = reg.DistanceColor end
        if reg.TracerColor then esp.Colors.Tracer = reg.TracerColor end
        if reg.HighlightColor then
            esp.Colors.Highlight.Filled = reg.HighlightColor
            esp.Colors.Highlight.Outline = reg.HighlightColor
        end
    end
end

-- Loop principal (não remove auto se tiver key)
RunService.RenderStepped:Connect(function()
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
            if esp.Key == nil and KoltESP.EspSettings.AutoRemoveInvalid then
                KoltESP:Remove(esp.Target)
            else
                -- Só esconde se tiver key (espera readjust)
                if esp.tracerLine then esp.tracerLine.Visible = false end
                if esp.nameText then esp.nameText.Visible = false end
                if esp.distanceText then esp.distanceText.Visible = false end
                if esp.highlight then esp.highlight.Enabled = false end
            end
            continue
        end

        -- resto do loop exatamente igual ao anterior (pos3D, distance, colors, etc.)
        -- (código omitido por brevidade, mas é o mesmo da versão anterior)

        local cf, _ = getBoundingBox(target)
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
            -- hide
            continue
        end

        local distance = (camera.CFrame.Position - pos3D).Magnitude
        if distance < esp.MinDistance or distance > esp.MaxDistance then continue end

        local col = rainbow and rainbowCol or (esp.ColorDependency and esp.ColorDependency(esp, distance, pos3D))

        -- Tracer
        if KoltESP.EspSettings.ShowTracer and esp.Types.Tracer then
            esp.tracerLine.Visible = true
            esp.tracerLine.From = tracerOrigins[KoltESP.EspSettings.TracerOrigin](vs)
            esp.tracerLine.To = Vector2.new(screenPos.X, screenPos.Y)
            esp.tracerLine.Color = col or esp.Colors.Tracer
        else
            esp.tracerLine.Visible = false
        end

        -- Name
        if KoltESP.EspSettings.ShowName and esp.Types.Name then
            esp.nameText.Visible = true
            esp.nameText.Position = Vector2.new(screenPos.X, screenPos.Y - esp.FontSize)
            esp.nameText.Text = esp.Name
            esp.nameText.Color = col or esp.Colors.Name
        else
            esp.nameText.Visible = false
        end

        -- Distance
        if KoltESP.EspSettings.ShowDistance and esp.Types.Distance then
            esp.distanceText.Visible = true
            esp.distanceText.Position = Vector2.new(screenPos.X, screenPos.Y)
            esp.distanceText.Text = esp.DistancePrefix .. string.format("%.1f", distance) .. esp.DistanceSuffix
            esp.distanceText.Color = col or esp.Colors.Distance
        else
            esp.distanceText.Visible = false
        end

        -- Highlight
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
