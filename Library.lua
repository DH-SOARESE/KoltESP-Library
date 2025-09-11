--// 📦 Library Kolt V1.5 Enhanced
--// 👤 Autor: DH_SOARES
--// 🎨 Estilo: Minimalista, eficiente, responsivo com design moderno
--// ✨ Melhorias: Design aprimorado, SetTarget individual, cache otimizado


local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

local KoltESP = {
    Objects = {},
    Enabled = true,
    _connections = {},
    _cache = {},
    _initialized = false,
    Theme = {
        PrimaryColor = Color3.fromRGB(130, 200, 255),
        SecondaryColor = Color3.fromRGB(255, 255, 255),
        ErrorColor = Color3.fromRGB(255, 100, 100),
        GradientColor = Color3.fromRGB(100, 150, 255),
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
        HighlightOutlineTransparency = 0.65,
        HighlightFillTransparency = 0.85,
        FontSize = 14,
        NameFont = Drawing.Fonts.Monospace,
        DistanceFont = Drawing.Fonts.Monospace,
        NameContainer = "[]",
        DistanceContainer = "()",
        DistanceSuffix = "m",
        HighlightOutlineThickness = 1,
        AutoRemoveInvalid = true,
        UpdateRate = 60,
        UseOcclusion = false,
    },
    _stats = {
        totalObjects = 0,
        visibleObjects = 0,
        lastUpdateTime = 0,
        frameTime = 0,
    }
}

--// 🌈 Cor arco-íris otimizada
local function getRainbowColor(t, speed)
    speed = speed or 2
    return Color3.fromRGB(
        math.sin(speed * t + 0) * 127 + 128,
        math.sin(speed * t + 2.094) * 127 + 128,
        math.sin(speed * t + 4.188) * 127 + 128
    )
end

--// 🌈 Cor gradiente
local function getGradientColor(t, baseColor)
    local r = baseColor.R * 255
    local g = baseColor.G * 255
    local b = baseColor.B * 255
    return Color3.fromRGB(
        r + math.sin(t) * 30,
        g + math.sin(t + 2.094) * 30,
        b + math.sin(t + 4.188) * 30
    )
end

--// 📍 Tracer Origins
local tracerOrigins = {
    Top = function(vs) return Vector2.new(vs.X * 0.5, 0) end,
    Center = function(vs) return Vector2.new(vs.X * 0.5, vs.Y * 0.5) end,
    Bottom = function(vs) return Vector2.new(vs.X * 0.5, vs.Y) end,
    Left = function(vs) return Vector2.new(0, vs.Y * 0.5) end,
    Right = function(vs) return Vector2.new(vs.X, vs.Y * 0.5) end,
    Mouse = function() 
        local mouse = localPlayer:GetMouse()
        return Vector2.new(mouse.X, mouse.Y) 
    end,
}

--// 📍 Centro do modelo com cache
local function getModelCenter(model)
    if not model then return nil end
    if KoltESP._cache[model] and tick() - KoltESP._cache[model].time < 0.1 then
        return KoltESP._cache[model].center
    end
    
    local center
    if model:IsA("Model") and model.PrimaryPart then
        center = model.PrimaryPart.Position
    elseif model:IsA("BasePart") then
        center = model.Position
    else
        local cf = model:GetPivot()
        center = cf.Position
    end
    
    KoltESP._cache[model] = {center = center, time = tick()}
    return center
end

--// 🛠️ Cria Drawing com validação
local function createDrawing(class, props)
    local success, obj = pcall(function()
        local drawing = Drawing.new(class)
        for k, v in pairs(props or {}) do
            drawing[k] = v
        end
        return drawing
    end)
    return success and obj or nil
end

--// 🔍 Validação de target
local function isValidTarget(target)
    return target and target.Parent and (target:IsA("Model") or target:IsA("BasePart"))
end

--// 🔍 Resolve target a partir de string
local function resolveTarget(targetPath)
    if type(targetPath) == "string" then
        local success, obj = pcall(function()
            local parts = targetPath:split(".")
            local current = game
            for _, part in ipairs(parts) do
                current = current:FindFirstChild(part) or current[part]
                if not current then return nil end
            end
            return current
        end)
        return success and isValidTarget(obj) and obj or nil
    elseif type(targetPath) == "userdata" then
        return isValidTarget(targetPath) and targetPath or nil
    end
    return nil
end

--// ➕ Adiciona ESP
function KoltESP:Add(target, config)
    local resolvedTarget = resolveTarget(target)
    if not resolvedTarget then 
        warn("[Kolt ESP] Target inválido fornecido")
        return false
    end

    self:Remove(resolvedTarget)

    local cfg = setmetatable({
        Target = resolvedTarget,
        Name = (config and config.Name) or resolvedTarget.Name or "Unknown",
        Color = (config and config.Color) or self.Theme.PrimaryColor,
        HighlightOutlineColor = (config and config.HighlightOutlineColor) or self.Theme.OutlineColor,
        HighlightOutlineTransparency = (config and config.HighlightOutlineTransparency) or self.GlobalSettings.HighlightOutlineTransparency,
        FilledTransparency = (config and config.FilledTransparency) or self.GlobalSettings.HighlightFillTransparency,
        TracerColor = config and config.TracerColor,
        CustomUpdate = config and config.CustomUpdate,
        NameFont = (config and config.NameFont) or self.GlobalSettings.NameFont,
        DistanceFont = (config and config.DistanceFont) or self.GlobalSettings.DistanceFont,
        NameContainer = (config and config.NameContainer) or self.GlobalSettings.NameContainer,
        DistanceContainer = (config and config.DistanceContainer) or self.GlobalSettings.DistanceContainer,
        DistanceSuffix = (config and config.DistanceSuffix) or self.GlobalSettings.DistanceSuffix,
        HighlightOutlineThickness = (config and config.HighlightOutlineThickness) or self.GlobalSettings.HighlightOutlineThickness,
        _lastUpdate = 0,
        _visible = false,
    }, {__index = config or {}})

    for _, obj in ipairs(resolvedTarget:GetChildren()) do
        if obj:IsA("Highlight") and obj.Name == "ESPHighlight" then 
            obj:Destroy() 
        end
    end

    cfg.tracerLine = createDrawing("Line", {
        Thickness = self.GlobalSettings.LineThickness,
        Color = cfg.TracerColor or cfg.Color,
        Transparency = self.GlobalSettings.Opacity,
        Visible = false
    })

    cfg.nameText = createDrawing("Text", {
        Text = cfg.Name,
        Color = cfg.Color,
        Size = self.GlobalSettings.FontSize,
        Center = true,
        Outline = false,
        Font = cfg.NameFont,
        Transparency = self.GlobalSettings.Opacity,
        Visible = false
    })

    cfg.distanceText = createDrawing("Text", {
        Text = "",
        Color = cfg.Color,
        Size = self.GlobalSettings.FontSize - 2,
        Center = true,
        Outline = false,
        Font = cfg.DistanceFont,
        Transparency = self.GlobalSettings.Opacity,
        Visible = false
    })

    if self.GlobalSettings.ShowHighlightFill or self.GlobalSettings.ShowHighlightOutline then
        local success, highlight = pcall(function()
            local h = Instance.new("Highlight")
            h.Name = "ESPHighlight"
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.FillColor = cfg.Color
            h.OutlineColor = cfg.HighlightOutlineColor
            h.FillTransparency = self.GlobalSettings.ShowHighlightFill and cfg.FilledTransparency or 1
            h.OutlineTransparency = self.GlobalSettings.ShowHighlightOutline and cfg.HighlightOutlineTransparency or 1
            h.Parent = resolvedTarget
            return h
        end)
        if success then cfg.highlight = highlight end
    end

    table.insert(self.Objects, cfg)
    self._stats.totalObjects = #self.Objects
    return true
end

--// 🔄 Redefine o alvo de uma ESP individual
function KoltESP:SetTarget(oldTarget, newTarget)
    local resolvedTarget = resolveTarget(newTarget)
    if not resolvedTarget then
        warn("[Kolt ESP] Novo target inválido")
        return false
    end

    for _, esp in ipairs(self.Objects) do
        if esp.Target == oldTarget then
            -- Remove highlight antigo
            if esp.highlight then
                pcall(esp.highlight.Destroy, esp.highlight)
                esp.highlight = nil
            end

            -- Atualiza o alvo
            esp.Target = resolvedTarget
            esp.Name = resolvedTarget.Name or esp.Name

            -- Cria novo highlight
            if self.GlobalSettings.ShowHighlightFill or self.GlobalSettings.ShowHighlightOutline then
                local success, highlight = pcall(function()
                    local h = Instance.new("Highlight")
                    h.Name = "ESPHighlight"
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.FillColor = esp.Color
                    h.OutlineColor = esp.HighlightOutlineColor
                    h.FillTransparency = self.GlobalSettings.ShowHighlightFill and esp.FilledTransparency or 1
                    h.OutlineTransparency = self.GlobalSettings.ShowHighlightOutline and esp.HighlightOutlineTransparency or 1
                    h.Parent = resolvedTarget
                    return h
                end)
                if success then esp.highlight = highlight end
            end

            return true
        end
    end
    warn("[Kolt ESP] ESP não encontrada para o alvo especificado")
    return false
end

--// ➖ Remove ESP individual
function KoltESP:Remove(target)
    for i = #self.Objects, 1, -1 do
        local obj = self.Objects[i]
        if obj.Target == target then
            for _, draw in ipairs({obj.tracerLine, obj.nameText, obj.distanceText}) do
                if draw then pcall(draw.Remove, draw) end
            end
            if obj.highlight then pcall(obj.highlight.Destroy, obj.highlight) end
            self._cache[obj.Target] = nil -- Limpa cache
            table.remove(self.Objects, i)
            break
        end
    end
    self._stats.totalObjects = #self.Objects
end

--// 🧹 Limpa todos ESP
function KoltESP:Clear()
    for _, obj in ipairs(self.Objects) do
        for _, draw in ipairs({obj.tracerLine, obj.nameText, obj.distanceText}) do
            if draw then pcall(draw.Remove, draw) end
        end
        if obj.highlight then pcall(obj.highlight.Destroy, obj.highlight) end
        self._cache[obj.Target] = nil
    end
    self.Objects = {}
    self._cache = {}
    self._stats.totalObjects = 0
    self._stats.visibleObjects = 0
end

--// 🔄 Descarrega completamente
function KoltESP:Unload()
    print("[Kolt ESP] Descarregando biblioteca...")
    for _, connection in pairs(self._connections) do
        if connection then pcall(connection.Disconnect, connection) end
    end
    self:Clear()
    self.Enabled = false
    self._connections = {}
    self._cache = {}
    self._initialized = false
    self._stats = {
        totalObjects = 0,
        visibleObjects = 0,
        lastUpdateTime = 0,
        frameTime = 0,
    }
    if getgenv then getgenv().KoltESP = nil end
    if _G then _G.KoltESP = nil end
    print("[Kolt ESP] Biblioteca descarregada com sucesso!")
end

--// 🌐 Update GlobalSettings
function KoltESP:UpdateGlobalSettings()
    for _, esp in ipairs(self.Objects) do
        if esp.tracerLine then 
            esp.tracerLine.Thickness = self.GlobalSettings.LineThickness 
            esp.tracerLine.Transparency = self.GlobalSettings.Opacity
        end
        if esp.nameText then 
            esp.nameText.Size = self.GlobalSettings.FontSize 
            esp.nameText.Font = self.GlobalSettings.NameFont
        end
        if esp.distanceText then 
            esp.distanceText.Size = self.GlobalSettings.FontSize - 2 
            esp.distanceText.Font = self.GlobalSettings.DistanceFont
        end
        if esp.highlight then
            esp.highlight.FillTransparency = self.GlobalSettings.ShowHighlightFill and esp.FilledTransparency or 1
            esp.highlight.OutlineTransparency = self.GlobalSettings.ShowHighlightOutline and esp.HighlightOutlineTransparency or 1
        end
    end
end

--// ✅ APIs de Configuração Global
function KoltESP:SetGlobalTracerOrigin(origin) if tracerOrigins[origin] then self.GlobalSettings.TracerOrigin = origin end end
function KoltESP:SetGlobalESPType(typeName, enabled) if self.GlobalSettings[typeName] ~= nil then self.GlobalSettings[typeName] = enabled; self:UpdateGlobalSettings() end end
function KoltESP:SetGlobalRainbow(enable) self.GlobalSettings.RainbowMode = enable end
function KoltESP:SetGlobalOpacity(value) self.GlobalSettings.Opacity = math.clamp(value, 0, 1); self:UpdateGlobalSettings() end
function KoltESP:SetGlobalFontSize(size) self.GlobalSettings.FontSize = math.max(8, size); self:UpdateGlobalSettings() end
function KoltESP:SetGlobalFont(font) self.GlobalSettings.NameFont = font; self.GlobalSettings.DistanceFont = font; self:UpdateGlobalSettings() end
function KoltESP:SetGlobalLineThickness(thick) self.GlobalSettings.LineThickness = math.max(1, thick); self:UpdateGlobalSettings() end
function KoltESP:SetGlobalHighlightOutlineTransparency(value) self.GlobalSettings.HighlightOutlineTransparency = math.clamp(value, 0, 1); self:UpdateGlobalSettings() end
function KoltESP:SetGlobalHighlightFillTransparency(value) self.GlobalSettings.HighlightFillTransparency = math.clamp(value, 0, 1); self:UpdateGlobalSettings() end
function KoltESP:SetMaxDistance(distance) self.GlobalSettings.MaxDistance = math.max(0, distance) end
function KoltESP:SetMinDistance(distance) self.GlobalSettings.MinDistance = math.max(0, distance) end
function KoltESP:SetUpdateRate(fps) self.GlobalSettings.UpdateRate = math.clamp(fps, 1, 144) end

--// 📊 Obter estatísticas
function KoltESP:GetStats()
    return {
        totalObjects = self._stats.totalObjects,
        visibleObjects = self._stats.visibleObjects,
        frameTime = self._stats.frameTime,
        lastUpdate = self._stats.lastUpdateTime,
        cacheSize = #self._cache,
        enabled = self.Enabled
    }
end

--// 🚀 Inicialização
function KoltESP:Initialize()
    if self._initialized then return end
    
    local renderConnection = RunService.RenderStepped:Connect(function()
        local frameStart = tick()
        if not self.Enabled then return end
        
        local vs = camera.ViewportSize
        local time = tick()
        local deltaTime = time - self._stats.lastUpdateTime
        local targetFrameTime = 1 / self.GlobalSettings.UpdateRate
        
        if deltaTime < targetFrameTime then return end
        
        self._stats.lastUpdateTime = time
        self._stats.visibleObjects = 0
        
        for i = #self.Objects, 1, -1 do
            local esp = self.Objects[i]
            local target = esp.Target
            
            if not isValidTarget(target) then
                if self.GlobalSettings.AutoRemoveInvalid then
                    self:Remove(target)
                end
                continue
            end
            
            local pos3D = getModelCenter(target)
            if not pos3D then continue end
            
            local success, pos2D = pcall(camera.WorldToViewportPoint, camera, pos3D)
            if not success or pos2D.Z <= 0 then
                esp._visible = false
                for _, draw in ipairs({esp.tracerLine, esp.nameText, esp.distanceText}) do
                    if draw then draw.Visible = false end
                end
                if esp.highlight then esp.highlight.Enabled = false end
                continue
            end
            
            local distance = (camera.CFrame.Position - pos3D).Magnitude
            local visible = distance >= self.GlobalSettings.MinDistance and distance <= self.GlobalSettings.MaxDistance
            local screenPos = Vector2.new(pos2D.X, pos2D.Y)
            local color = self.GlobalSettings.RainbowMode and getRainbowColor(time) or esp.Color
            
            if visible then
                self._stats.visibleObjects = self._stats.visibleObjects + 1
                esp._visible = true
            end
            
            if esp.CustomUpdate then
                pcall(esp.CustomUpdate, esp, screenPos, distance, color, visible)
            end
            
            if esp.tracerLine then
                esp.tracerLine.Visible = self.GlobalSettings.ShowTracer and visible
                if visible then
                    esp.tracerLine.From = tracerOrigins[self.GlobalSettings.TracerOrigin](vs)
                    esp.tracerLine.To = screenPos
                    esp.tracerLine.Color = esp.TracerColor or color
                end
            end
            
            if esp.nameText then
                esp.nameText.Visible = self.GlobalSettings.ShowName and visible
                if visible then
                    local name_str = esp.Name
                    if esp.NameContainer and #esp.NameContainer >= 2 then
                        name_str = esp.NameContainer:sub(1,1) .. name_str .. esp.NameContainer:sub(2,2)
                    end
                    esp.nameText.Text = name_str
                    esp.nameText.Position = screenPos - Vector2.new(0, 30)
                    esp.nameText.Color = color
                end
            end
            
            if esp.distanceText then
                esp.distanceText.Visible = self.GlobalSettings.ShowDistance and visible
                if visible then
                    local dist_str = string.format("%.1f%s", distance, esp.DistanceSuffix)
                    if esp.DistanceContainer and #esp.DistanceContainer >= 2 then
                        dist_str = esp.DistanceContainer:sub(1,1) .. dist_str .. esp.DistanceContainer:sub(2,2)
                    end
                    esp.distanceText.Text = dist_str
                    esp.distanceText.Position = screenPos + Vector2.new(0, 5)
                    esp.distanceText.Color = color
                end
            end
            
            if esp.highlight then
                esp.highlight.Enabled = (self.GlobalSettings.ShowHighlightFill or self.GlobalSettings.ShowHighlightOutline) and visible
                if visible then
                    esp.highlight.FillColor = color
                    esp.highlight.OutlineColor = esp.HighlightOutlineColor
                end
            end
            
        end
        
        self._stats.frameTime = (tick() - frameStart) * 1000
    end)
    
    self._connections.renderStepped = renderConnection
    self._initialized = true
    print("[Kolt ESP] Inicializado com sucesso! Versão: 1.4")
end

-- Auto-inicializar
KoltESP:Initialize()

if getgenv then getgenv().KoltESP = KoltESP end
if _G then _G.KoltESP = KoltESP end

return KoltESP
