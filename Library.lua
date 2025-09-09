--// 📦 Library Kolt V1.4 Enhanced
--// 👤 Autor: DH_SOARES
--// 🎨 Estilo: Minimalista, eficiente, responsivo com design moderno
--// ✨ Melhorias: Design aprimorado, SetTarget individual, cache otimizado

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

local ModelESP = {
    Objects = {},
    Enabled = true,
    _connections = {},
    _cache = {},
    _initialized = false,
    Theme = {
        PrimaryColor = Color3.fromRGB(130, 200, 255),
        SecondaryColor = Color3.fromRGB(255, 255, 255),
        OutlineColor = Color3.fromRGB(0, 0, 0),
        ErrorColor = Color3.fromRGB(255, 100, 100),
        ShadowColor = Color3.fromRGB(0, 0, 0),
        GradientColor = Color3.fromRGB(100, 150, 255),
    },
    GlobalSettings = {
        TracerOrigin = "Bottom",
        ShowTracer = true,
        ShowHighlightFill = true,
        ShowHighlightOutline = true,
        ShowName = true,
        ShowDistance = true,
        ShowBox = true,
        ShowSkeleton = false,
        ShowHealthBar = false,
        RainbowMode = false,
        MaxDistance = math.huge,
        MinDistance = 0,
        Opacity = 0.8,
        LineThickness = 1.5,
        BoxThickness = 1.5,
        SkeletonThickness = 1.2,
        BoxTransparency = 0.5,
        HighlightOutlineTransparency = 0.65,
        HighlightFillTransparency = 0.85,
        FontSize = 14,
        Font = Drawing.Fonts.Monospace,
        AutoRemoveInvalid = true,
        UpdateRate = 60,
        UseOcclusion = false,
        TeamCheck = false,
        ShadowEnabled = true, -- Nova configuração para sombras
        ShadowOpacity = 0.3,
        RoundedBox = true, -- Bordas arredondadas
        TracerAnimation = false, -- Animação de pulsação para tracers
        GradientEnabled = false, -- Gradiente para highlights
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
    if ModelESP._cache[model] and tick() - ModelESP._cache[model].time < 0.1 then
        return ModelESP._cache[model].center
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
    
    ModelESP._cache[model] = {center = center, time = tick()}
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

--// 👥 Verifica se é do mesmo time
local function isSameTeam(target)
    if not ModelESP.GlobalSettings.TeamCheck then return false end
    local targetPlayer = Players:GetPlayerFromCharacter(target)
    if targetPlayer and localPlayer.Team and targetPlayer.Team then
        return localPlayer.Team == targetPlayer.Team
    end
    return false
end

--// 🏥 Cria barra de vida
local function createHealthBar(config)
    if not ModelESP.GlobalSettings.ShowHealthBar then return {} end
    return {
        background = createDrawing("Square", {
            Thickness = 1,
            Color = ModelESP.Theme.OutlineColor,
            Transparency = 0.8,
            Filled = true,
            Visible = false
        }),
        foreground = createDrawing("Square", {
            Thickness = 1,
            Color = Color3.fromRGB(0, 255, 0),
            Transparency = 0.9,
            Filled = true,
            Visible = false
        })
    }
end

--// 🛠️ Cria sombra para texto ou caixa
local function createShadowDrawing(class, props)
    local shadow = createDrawing(class, props)
    if shadow then
        shadow.Color = ModelESP.Theme.ShadowColor
        shadow.Transparency = ModelESP.GlobalSettings.ShadowOpacity
    end
    return shadow
end

--// ➕ Adiciona ESP
function ModelESP:Add(target, config)
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
        BoxColor = config and config.BoxColor,
        TracerColor = config and config.TracerColor,
        ShowHealthBar = config and config.ShowHealthBar,
        CustomUpdate = config and config.CustomUpdate,
        ShadowEnabled = (config and config.ShadowEnabled) or self.GlobalSettings.ShadowEnabled,
        RoundedBox = (config and config.RoundedBox) or self.GlobalSettings.RoundedBox,
        GradientEnabled = (config and config.GradientEnabled) or self.GlobalSettings.GradientEnabled,
        TracerAnimation = (config and config.TracerAnimation) or self.GlobalSettings.TracerAnimation,
        Font = (config and config.Font) or self.GlobalSettings.Font,
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
        Outline = true,
        OutlineColor = self.Theme.OutlineColor,
        Font = cfg.Font,
        Transparency = self.GlobalSettings.Opacity,
        Visible = false
    })

    cfg.nameShadow = cfg.ShadowEnabled and createShadowDrawing("Text", {
        Text = cfg.Name,
        Size = self.GlobalSettings.FontSize,
        Center = true,
        Font = cfg.Font,
        Visible = false
    })

    cfg.distanceText = createDrawing("Text", {
        Text = "",
        Color = cfg.Color,
        Size = self.GlobalSettings.FontSize - 2,
        Center = true,
        Outline = true,
        OutlineColor = self.Theme.OutlineColor,
        Font = cfg.Font,
        Transparency = self.GlobalSettings.Opacity,
        Visible = false
    })

    cfg.distanceShadow = cfg.ShadowEnabled and createShadowDrawing("Text", {
        Text = "",
        Size = self.GlobalSettings.FontSize - 2,
        Center = true,
        Font = cfg.Font,
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

    if self.GlobalSettings.ShowBox then
        cfg.box = createDrawing("Square", {
            Thickness = self.GlobalSettings.BoxThickness,
            Color = cfg.BoxColor or cfg.Color,
            Transparency = self.GlobalSettings.BoxTransparency,
            Visible = false,
            Filled = false
        })
        cfg.boxShadow = cfg.ShadowEnabled and createShadowDrawing("Square", {
            Thickness = self.GlobalSettings.BoxThickness,
            Visible = false,
            Filled = false
        })
    end

    cfg.healthBar = createHealthBar(cfg)

    if self.GlobalSettings.ShowSkeleton and resolvedTarget:IsA("Model") then
        cfg.skeletonLines = {}
        local humanoid = resolvedTarget:FindFirstChild("Humanoid")
        if humanoid then
            local connections = {
                {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
                {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
                {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
                {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
                {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
            }
            for _, connection in ipairs(connections) do
                local line = createDrawing("Line", {
                    Thickness = self.GlobalSettings.SkeletonThickness,
                    Color = cfg.Color,
                    Transparency = self.GlobalSettings.Opacity,
                    Visible = false
                })
                if line then
                    line._connection = connection
                    table.insert(cfg.skeletonLines, line)
                end
            end
        end
    end

    table.insert(self.Objects, cfg)
    self._stats.totalObjects = #self.Objects
    return true
end

--// 🔄 Redefine o alvo de uma ESP individual
function ModelESP:SetTarget(oldTarget, newTarget)
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

            -- Atualiza skeleton se necessário
            if esp.skeletonLines then
                for _, line in ipairs(esp.skeletonLines) do
                    pcall(line.Remove, line)
                end
                esp.skeletonLines = {}
                if self.GlobalSettings.ShowSkeleton and resolvedTarget:IsA("Model") then
                    local humanoid = resolvedTarget:FindFirstChild("Humanoid")
                    if humanoid then
                        local connections = {
                            {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
                            {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
                            {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
                            {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
                            {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
                        }
                        for _, connection in ipairs(connections) do
                            local line = createDrawing("Line", {
                                Thickness = self.GlobalSettings.SkeletonThickness,
                                Color = esp.Color,
                                Transparency = self.GlobalSettings.Opacity,
                                Visible = false
                            })
                            if line then
                                line._connection = connection
                                table.insert(esp.skeletonLines, line)
                            end
                        end
                    end
                end
            end

            return true
        end
    end
    warn("[Kolt ESP] ESP não encontrada para o alvo especificado")
    return false
end

--// ➖ Remove ESP individual
function ModelESP:Remove(target)
    for i = #self.Objects, 1, -1 do
        local obj = self.Objects[i]
        if obj.Target == target then
            for _, draw in ipairs({obj.tracerLine, obj.nameText, obj.nameShadow, obj.distanceText, obj.distanceShadow, obj.box, obj.boxShadow}) do
                if draw then pcall(draw.Remove, draw) end
            end
            if obj.highlight then pcall(obj.highlight.Destroy, obj.highlight) end
            if obj.healthBar then
                for _, bar in pairs(obj.healthBar) do
                    if bar then pcall(bar.Remove, bar) end
                end
            end
            if obj.skeletonLines then
                for _, line in ipairs(obj.skeletonLines) do
                    if line then pcall(line.Remove, line) end
                end
            end
            self._cache[obj.Target] = nil -- Limpa cache
            table.remove(self.Objects, i)
            break
        end
    end
    self._stats.totalObjects = #self.Objects
end

--// 🧹 Limpa todos ESP
function ModelESP:Clear()
    for _, obj in ipairs(self.Objects) do
        for _, draw in ipairs({obj.tracerLine, obj.nameText, obj.nameShadow, obj.distanceText, obj.distanceShadow, obj.box, obj.boxShadow}) do
            if draw then pcall(draw.Remove, draw) end
        end
        if obj.highlight then pcall(obj.highlight.Destroy, obj.highlight) end
        if obj.healthBar then
            for _, bar in pairs(obj.healthBar) do
                if bar then pcall(bar.Remove, bar) end
            end
        end
        if obj.skeletonLines then
            for _, line in ipairs(obj.skeletonLines) do
                if line then pcall(line.Remove, line) end
            end
        end
        self._cache[obj.Target] = nil
    end
    self.Objects = {}
    self._cache = {}
    self._stats.totalObjects = 0
    self._stats.visibleObjects = 0
end

--// 🔄 Descarrega completamente
function ModelESP:Unload()
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
function ModelESP:UpdateGlobalSettings()
    for _, esp in ipairs(self.Objects) do
        if esp.tracerLine then 
            esp.tracerLine.Thickness = self.GlobalSettings.LineThickness 
            esp.tracerLine.Transparency = self.GlobalSettings.Opacity
        end
        if esp.nameText then 
            esp.nameText.Size = self.GlobalSettings.FontSize 
            esp.nameText.Font = self.GlobalSettings.Font
        end
        if esp.nameShadow then 
            esp.nameShadow.Size = self.GlobalSettings.FontSize 
            esp.nameShadow.Font = self.GlobalSettings.Font
        end
        if esp.distanceText then 
            esp.distanceText.Size = self.GlobalSettings.FontSize - 2 
            esp.distanceText.Font = self.GlobalSettings.Font
        end
        if esp.distanceShadow then 
            esp.distanceShadow.Size = self.GlobalSettings.FontSize - 2 
            esp.distanceShadow.Font = self.GlobalSettings.Font
        end
        if esp.box then 
            esp.box.Thickness = self.GlobalSettings.BoxThickness 
            esp.box.Transparency = self.GlobalSettings.BoxTransparency
        end
        if esp.boxShadow then 
            esp.boxShadow.Thickness = self.GlobalSettings.BoxThickness 
            esp.boxShadow.Transparency = self.GlobalSettings.ShadowOpacity
        end
        if esp.highlight then
            esp.highlight.FillTransparency = self.GlobalSettings.ShowHighlightFill and esp.FilledTransparency or 1
            esp.highlight.OutlineTransparency = self.GlobalSettings.ShowHighlightOutline and esp.HighlightOutlineTransparency or 1
        end
        if esp.skeletonLines then
            for _, l in ipairs(esp.skeletonLines) do
                l.Thickness = self.GlobalSettings.SkeletonThickness
                l.Transparency = self.GlobalSettings.Opacity
            end
        end
    end
end

--// ✅ APIs de Configuração Global
function ModelESP:SetGlobalTracerOrigin(origin) if tracerOrigins[origin] then self.GlobalSettings.TracerOrigin = origin end end
function ModelESP:SetGlobalESPType(typeName, enabled) if self.GlobalSettings[typeName] ~= nil then self.GlobalSettings[typeName] = enabled; self:UpdateGlobalSettings() end end
function ModelESP:SetGlobalRainbow(enable) self.GlobalSettings.RainbowMode = enable end
function ModelESP:SetGlobalOpacity(value) self.GlobalSettings.Opacity = math.clamp(value, 0, 1); self:UpdateGlobalSettings() end
function ModelESP:SetGlobalFontSize(size) self.GlobalSettings.FontSize = math.max(8, size); self:UpdateGlobalSettings() end
function ModelESP:SetGlobalFont(font) self.GlobalSettings.Font = font; self:UpdateGlobalSettings() end
function ModelESP:SetGlobalLineThickness(thick) self.GlobalSettings.LineThickness = math.max(1, thick); self:UpdateGlobalSettings() end
function ModelESP:SetGlobalBoxThickness(thick) self.GlobalSettings.BoxThickness = math.max(1, thick); self:UpdateGlobalSettings() end
function ModelESP:SetGlobalSkeletonThickness(thick) self.GlobalSettings.SkeletonThickness = math.max(1, thick); self:UpdateGlobalSettings() end
function ModelESP:SetGlobalBoxTransparency(value) self.GlobalSettings.BoxTransparency = math.clamp(value, 0, 1); self:UpdateGlobalSettings() end
function ModelESP:SetGlobalHighlightOutlineTransparency(value) self.GlobalSettings.HighlightOutlineTransparency = math.clamp(value, 0, 1); self:UpdateGlobalSettings() end
function ModelESP:SetGlobalHighlightFillTransparency(value) self.GlobalSettings.HighlightFillTransparency = math.clamp(value, 0, 1); self:UpdateGlobalSettings() end
function ModelESP:SetGlobalShadowEnabled(enable) self.GlobalSettings.ShadowEnabled = enable; self:UpdateGlobalSettings() end
function ModelESP:SetGlobalShadowOpacity(value) self.GlobalSettings.ShadowOpacity = math.clamp(value, 0, 1); self:UpdateGlobalSettings() end
function ModelESP:SetGlobalRoundedBox(enable) self.GlobalSettings.RoundedBox = enable; self:UpdateGlobalSettings() end
function ModelESP:SetGlobalTracerAnimation(enable) self.GlobalSettings.TracerAnimation = enable; self:UpdateGlobalSettings() end
function ModelESP:SetGlobalGradientEnabled(enable) self.GlobalSettings.GradientEnabled = enable; self:UpdateGlobalSettings() end
function ModelESP:SetMaxDistance(distance) self.GlobalSettings.MaxDistance = math.max(0, distance) end
function ModelESP:SetMinDistance(distance) self.GlobalSettings.MinDistance = math.max(0, distance) end
function ModelESP:SetUpdateRate(fps) self.GlobalSettings.UpdateRate = math.clamp(fps, 1, 144) end
function ModelESP:SetTeamCheck(enabled) self.GlobalSettings.TeamCheck = enabled end

--// 📊 Obter estatísticas
function ModelESP:GetStats()
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
function ModelESP:Initialize()
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
            
            if isSameTeam(target) then continue end
            
            local pos3D = getModelCenter(target)
            if not pos3D then continue end
            
            local success, pos2D = pcall(camera.WorldToViewportPoint, camera, pos3D)
            if not success or pos2D.Z <= 0 then
                esp._visible = false
                for _, draw in ipairs({esp.tracerLine, esp.nameText, esp.nameShadow, esp.distanceText, esp.distanceShadow, esp.box, esp.boxShadow}) do
                    if draw then draw.Visible = false end
                end
                if esp.highlight then esp.highlight.Enabled = false end
                if esp.skeletonLines then
                    for _, line in ipairs(esp.skeletonLines) do line.Visible = false end
                end
                continue
            end
            
            local distance = (camera.CFrame.Position - pos3D).Magnitude
            local visible = distance >= self.GlobalSettings.MinDistance and distance <= self.GlobalSettings.MaxDistance
            local screenPos = Vector2.new(pos2D.X, pos2D.Y)
            local color = self.GlobalSettings.RainbowMode and getRainbowColor(time) or (esp.GradientEnabled and getGradientColor(time, esp.Color) or esp.Color)
            
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
                    if esp.TracerAnimation then
                        esp.tracerLine.Transparency = self.GlobalSettings.Opacity * (0.8 + 0.2 * math.sin(time * 2))
                    end
                end
            end
            
            if esp.nameText then
                esp.nameText.Visible = self.GlobalSettings.ShowName and visible
                if visible then
                    esp.nameText.Position = screenPos - Vector2.new(0, 30)
                    esp.nameText.Text = esp.Name
                    esp.nameText.Color = color
                end
            end
            if esp.nameShadow and esp.ShadowEnabled then
                esp.nameShadow.Visible = self.GlobalSettings.ShowName and visible
                if visible then
                    esp.nameShadow.Position = screenPos - Vector2.new(0, 29)
                    esp.nameShadow.Text = esp.Name
                end
            end
            
            if esp.distanceText then
                esp.distanceText.Visible = self.GlobalSettings.ShowDistance and visible
                if visible then
                    esp.distanceText.Position = screenPos + Vector2.new(0, 5)
                    esp.distanceText.Text = string.format("%.1fm", distance)
                    esp.distanceText.Color = color
                end
            end
            if esp.distanceShadow and esp.ShadowEnabled then
                esp.distanceShadow.Visible = self.GlobalSettings.ShowDistance and visible
                if visible then
                    esp.distanceShadow.Position = screenPos + Vector2.new(0, 6)
                    esp.distanceShadow.Text = string.format("%.1fm", distance)
                end
            end
            
            if esp.highlight then
                esp.highlight.Enabled = (self.GlobalSettings.ShowHighlightFill or self.GlobalSettings.ShowHighlightOutline) and visible
                if visible then
                    esp.highlight.FillColor = color
                    esp.highlight.OutlineColor = esp.HighlightOutlineColor
                end
            end
            
            if esp.box then
                esp.box.Visible = self.GlobalSettings.ShowBox and visible
                if visible then
                    local boxSize = Vector2.new(60 - distance/10, 80 - distance/8)
                    esp.box.Size = Vector2.new(math.max(20, boxSize.X), math.max(30, boxSize.Y))
                    esp.box.Position = screenPos - esp.box.Size/2
                    esp.box.Color = esp.BoxColor or color
                    if esp.RoundedBox then
                        esp.box.Radius = 4 -- Bordas arredondadas
                    else
                        esp.box.Radius = 0
                    end
                end
            end
            if esp.boxShadow and esp.ShadowEnabled then
                esp.boxShadow.Visible = self.GlobalSettings.ShowBox and visible
                if visible then
                    esp.boxShadow.Size = Vector2.new(math.max(20, 60 - distance/10), math.max(30, 80 - distance/8))
                    esp.boxShadow.Position = screenPos - esp.boxShadow.Size/2 + Vector2.new(2, 2)
                    if esp.RoundedBox then
                        esp.boxShadow.Radius = 4
                    else
                        esp.boxShadow.Radius = 0
                    end
                end
            end
            
            if esp.healthBar and esp.healthBar.background and visible then
                local humanoid = target:FindFirstChild("Humanoid")
                if humanoid and self.GlobalSettings.ShowHealthBar then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local barHeight = 60
                    local barWidth = 4
                    local barPos = screenPos + Vector2.new(-35, -30)
                    
                    esp.healthBar.background.Visible = true
                    esp.healthBar.background.Size = Vector2.new(barWidth, barHeight)
                    esp.healthBar.background.Position = barPos
                    
                    esp.healthBar.foreground.Visible = true
                    esp.healthBar.foreground.Size = Vector2.new(barWidth, barHeight * healthPercent)
                    esp.healthBar.foreground.Position = barPos + Vector2.new(0, barHeight * (1 - healthPercent))
                    esp.healthBar.foreground.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                else
                    esp.healthBar.background.Visible = false
                    esp.healthBar.foreground.Visible = false
                end
            end
            
            if esp.skeletonLines and visible then
                for _, line in ipairs(esp.skeletonLines) do
                    line.Visible = self.GlobalSettings.ShowSkeleton
                    if self.GlobalSettings.ShowSkeleton and line._connection then
                        local part1 = target:FindFirstChild(line._connection[1])
                        local part2 = target:FindFirstChild(line._connection[2])
                        if part1 and part2 then
                            local pos1 = camera:WorldToViewportPoint(part1.Position)
                            local pos2 = camera:WorldToViewportPoint(part2.Position)
                            if pos1.Z > 0 and pos2.Z > 0 then
                                line.From = Vector2.new(pos1.X, pos1.Y)
                                line.To = Vector2.new(pos2.X, pos2.Y)
                                line.Color = color
                            else
                                line.Visible = false
                            end
                        end
                    end
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
ModelESP:Initialize()

if getgenv then getgenv().KoltESP = ModelESP end
if _G then _G.KoltESP = ModelESP end

return ModelESP
