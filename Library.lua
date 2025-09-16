--// 📦 Library Kolt V1.5
--// 👤 Autor: Kolt
--// 🎨 Estilo: Minimalista, eficiente e responsivo
--// ✨ Correção: Arrow ESP agora funciona corretamente em todas as direções
--// 🔧 Melhorias: Sistema de detecção de campo de visão e otimizações

local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

-- Configuração global para Arrow ESP
GlobalArrowDesign = {
    Gui = {
        image = "rbxassetid://11552476728",
        Color = {255, 0, 0},
        Opacity = 0.3,
        Size = {w = 30, h = 30},
        DisplayOrder = 18,
        RotationOffset = 90,
    },
    Drawing = {
        Color = {255, 0, 0},
        OutlineColor = {0, 0, 0},
        Opacity = 0.3,
        Size = {w = 30, h = 30},
        OutlineThickness = 6,
        LineThickness = 3,
    }
}

local ModelESP = {
    Objects = {},
    Arrows = {},
    Enabled = true,
    ArrowEnabled = false,
    UseDrawingArrow = false,
    ArrowRadius = 130,
    FOVMargin = 10, -- Margem para considerar objeto "fora de vista"
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
    }
}

-- Layer GUI para arrows
local TopLayer = gethui and gethui() or game:GetService("CoreGui")

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

--// Função para verificar se objeto está no campo de visão
local function isInViewport(pos2D, vs, margin)
    margin = margin or 0
    return pos2D.X >= -margin and pos2D.X <= vs.X + margin and 
           pos2D.Y >= -margin and pos2D.Y <= vs.Y + margin
end

--// Função para verificar se objeto está atrás da câmera
local function isBehindCamera(worldPos)
    local cameraPos = camera.CFrame.Position
    local cameraLook = camera.CFrame.LookVector
    local toTarget = (worldPos - cameraPos).Unit
    
    -- Produto escalar para verificar se está atrás (< 0 = atrás)
    local dot = cameraLook:Dot(toTarget)
    return dot < 0
end

--// Função melhorada para determinar se arrow deve aparecer
local function shouldShowArrow(worldPos, pos2D, vs)
    -- Se está atrás da câmera, sempre mostra arrow
    if isBehindCamera(worldPos) then
        return true
    end
    
    -- Se está na frente mas fora da tela (com margem), mostra arrow
    if not isInViewport(pos2D, vs, ModelESP.FOVMargin) then
        return true
    end
    
    -- Se Z <= 0 (muito próximo), mostra arrow
    if pos2D.Z <= 0 then
        return true
    end
    
    return false
end

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

--// Função para criar arrow Drawing
local function createArrowDrawing()
    local cfg = GlobalArrowDesign.Drawing
    local arrow = {}
    arrow.outline1 = Drawing.new("Line")
    arrow.outline2 = Drawing.new("Line")
    arrow.line1 = Drawing.new("Line")
    arrow.line2 = Drawing.new("Line")

    for _, line in pairs({arrow.outline1, arrow.outline2}) do
        line.Color = Color3.fromRGB(table.unpack(cfg.OutlineColor))
        line.Thickness = cfg.OutlineThickness
        line.Visible = false
        line.Transparency = cfg.Opacity
    end

    for _, line in pairs({arrow.line1, arrow.line2}) do
        line.Color = Color3.fromRGB(table.unpack(cfg.Color))
        line.Thickness = cfg.LineThickness
        line.Visible = false
        line.Transparency = cfg.Opacity
    end

    return arrow
end

--// Função para criar arrow GUI
local function createArrowGui()
    local cfg = GlobalArrowDesign.Gui
    local arrow = {}
    local screenGui = Instance.new("ScreenGui")
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = cfg.DisplayOrder
    screenGui.Parent = TopLayer

    local image = Instance.new("ImageLabel")
    image.Size = UDim2.fromOffset(cfg.Size.w, cfg.Size.h)
    image.BackgroundTransparency = 1
    image.Image = cfg.image
    image.ImageColor3 = Color3.fromRGB(table.unpack(cfg.Color))
    image.ImageTransparency = 1 - cfg.Opacity
    image.Visible = false
    image.Parent = screenGui

    arrow.Gui = screenGui
    arrow.Image = image
    return arrow
end

--// Adiciona ESP
function ModelESP:Add(target, config)
    if not target or not target:IsA("Instance") then return end
    if not (target:IsA("Model") or target:IsA("BasePart")) then return end

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
        Name = config and config.Name or target.Name,
        Colors = defaultColors,
        ModifiedParts = {},
        NameContainerStart = (config and config.NameContainer and config.NameContainer.Start) or "",
        NameContainerEnd = (config and config.NameContainer and config.NameContainer.End) or "",
        DistanceSuffix = (config and config.DistanceSuffix) or "",
        DistanceContainerStart = (config and config.DistanceContainer and config.DistanceContainer.Start) or "",
        DistanceContainerEnd = (config and config.DistanceContainer and config.DistanceContainer.End) or ""
    }

    -- Aplicar cores customizadas se fornecidas
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

    -- Opção de Collision (individual)
    if config and config.Collision then
        local humanoid = target:FindFirstChild("Kolt ESP")
        if not humanoid then
            humanoid = Instance.new("Humanoid")
            humanoid.Name = "Kolt ESP"
            humanoid.Parent = target
        end
        cfg.humanoid = humanoid

        for _, part in ipairs(target:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency == 1 then
                table.insert(cfg.ModifiedParts, {Part = part, OriginalTransparency = part.Transparency})
                part.Transparency = 0.99
            end
        end
    end

    -- Drawings básicos
    cfg.tracerLine = createDrawing("Line", {
        Thickness = self.GlobalSettings.LineThickness,
        Transparency = self.GlobalSettings.Opacity,
        Visible = false
    })
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

    -- Highlight
    if self.GlobalSettings.ShowHighlightFill or self.GlobalSettings.ShowHighlightOutline then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = self.GlobalSettings.ShowHighlightFill and 0.85 or 1
        highlight.OutlineTransparency = self.GlobalSettings.ShowHighlightOutline and 0.65 or 1
        highlight.Parent = target
        cfg.highlight = highlight
    end

    -- Criar arrow para este objeto
    if self.ArrowEnabled then
        local arrow = self.UseDrawingArrow and createArrowDrawing() or createArrowGui()
        self.Arrows[target] = arrow
    end

    table.insert(self.Objects, cfg)
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

    -- Remove arrow
    if self.Arrows[target] then
        if self.UseDrawingArrow then
            for _, obj in pairs(self.Arrows[target]) do 
                if obj then pcall(obj.Remove, obj) end 
            end
        else
            if self.Arrows[target].Gui then 
                pcall(self.Arrows[target].Gui.Destroy, self.Arrows[target].Gui) 
            end
        end
        self.Arrows[target] = nil
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

    -- Limpa todas as arrows
    for target, arrow in pairs(self.Arrows) do
        if self.UseDrawingArrow then
            for _, obj in pairs(arrow) do 
                if obj then pcall(obj.Remove, obj) end 
            end
        else
            if arrow.Gui then 
                pcall(arrow.Gui.Destroy, arrow.Gui) 
            end
        end
    end

    self.Objects = {}
    self.Arrows = {}
end

--// Update GlobalSettings
function ModelESP:UpdateGlobalSettings()
    for _, esp in ipairs(self.Objects) do
        if esp.tracerLine then esp.tracerLine.Thickness = self.GlobalSettings.LineThickness end
        if esp.nameText then esp.nameText.Size = self.GlobalSettings.FontSize end
        if esp.distanceText then esp.distanceText.Size = self.GlobalSettings.FontSize-2 end
    end
end

--// APIs para Arrow
function ModelESP:SetArrowEnabled(enabled)
    self.ArrowEnabled = enabled
    if not enabled then
        -- Oculta todas as arrows quando desabilitado
        for _, arrow in pairs(self.Arrows) do
            if self.UseDrawingArrow then
                for _, obj in pairs(arrow) do 
                    if obj then obj.Visible = false end 
                end
            else
                if arrow.Image then arrow.Image.Visible = false end
            end
        end
    else
        -- Cria arrows para objetos existentes se não existirem
        for _, esp in ipairs(self.Objects) do
            if not self.Arrows[esp.Target] then
                local arrow = self.UseDrawingArrow and createArrowDrawing() or createArrowGui()
                self.Arrows[esp.Target] = arrow
            end
        end
    end
end

function ModelESP:SetArrowUseDrawing(useDrawing)
    if self.UseDrawingArrow ~= useDrawing then
        -- Remove arrows existentes
        for target, arrow in pairs(self.Arrows) do
            if self.UseDrawingArrow then
                for _, obj in pairs(arrow) do 
                    if obj then pcall(obj.Remove, obj) end 
                end
            else
                if arrow.Gui then 
                    pcall(arrow.Gui.Destroy, arrow.Gui) 
                end
            end
        end
        
        self.UseDrawingArrow = useDrawing
        self.Arrows = {}
        
        -- Recria arrows se habilitado
        if self.ArrowEnabled then
            for _, esp in ipairs(self.Objects) do
                local arrow = self.UseDrawingArrow and createArrowDrawing() or createArrowGui()
                self.Arrows[esp.Target] = arrow
            end
        end
    end
end

function ModelESP:SetArrowRadius(radius)
    self.ArrowRadius = math.max(50, radius)
end

function ModelESP:SetFOVMargin(margin)
    self.FOVMargin = math.max(0, margin)
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
    local screenCenter = Vector2.new(vs.X / 2, vs.Y / 2)
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

        local cf, size = getBoundingBox(target)
        if not cf then continue end
        local pos3D = cf.Position

        local success, pos2D = pcall(function() return camera:WorldToViewportPoint(pos3D) end)
        if not success then
            for _, draw in ipairs({esp.tracerLine,esp.nameText,esp.distanceText}) do if draw then draw.Visible=false end end
            if esp.highlight then esp.highlight.Enabled=false end
            continue
        end

        local distance = (camera.CFrame.Position - pos3D).Magnitude
        local visible = distance >= ModelESP.GlobalSettings.MinDistance and distance <= ModelESP.GlobalSettings.MaxDistance
        
        if not visible then
            for _, draw in ipairs({esp.tracerLine,esp.nameText,esp.distanceText}) do if draw then draw.Visible=false end end
            if esp.highlight then esp.highlight.Enabled=false end
            -- Arrow também fica invisível quando fora do range
            if ModelESP.ArrowEnabled and ModelESP.Arrows[target] then
                if ModelESP.UseDrawingArrow then
                    for _, obj in pairs(ModelESP.Arrows[target]) do 
                        if obj then obj.Visible = false end 
                    end
                else
                    if ModelESP.Arrows[target].Image then 
                        ModelESP.Arrows[target].Image.Visible = false 
                    end
                end
            end
            continue
        end

        local rainbowColor = getRainbowColor(time)
        local useRainbow = ModelESP.GlobalSettings.RainbowMode

        -- Arrow Logic melhorada - considera todas as situações
        if ModelESP.ArrowEnabled and ModelESP.Arrows[target] then
            local arrow = ModelESP.Arrows[target]
            local showArrow = shouldShowArrow(pos3D, pos2D, vs)
            
            if showArrow then
                -- Calcula direção da arrow considerando objetos atrás da câmera
                local dir
                if isBehindCamera(pos3D) then
                    -- Se está atrás, inverte a direção para apontar corretamente
                    local cameraPos = camera.CFrame.Position
                    local toTarget = (pos3D - cameraPos)
                    -- Projeta no plano da tela
                    local cameraRight = camera.CFrame.RightVector
                    local cameraUp = camera.CFrame.UpVector
                    local screenX = cameraRight:Dot(toTarget)
                    local screenY = -cameraUp:Dot(toTarget) -- Inverte Y
                    dir = Vector2.new(screenX, screenY).Unit
                else
                    -- Se está na frente mas fora da tela, usa direção normal
                    dir = (Vector2.new(pos2D.X, pos2D.Y) - screenCenter).Unit
                end
                
                local tip = screenCenter + dir * ModelESP.ArrowRadius
                
                if ModelESP.UseDrawingArrow then
                    local cfg = GlobalArrowDesign.Drawing
                    for _, obj in pairs(arrow) do 
                        if obj then obj.Visible = true end 
                    end
                    
                    local base = tip - dir * cfg.Size.h
                    local perp = Vector2.new(-dir.Y, dir.X)
                    local p1 = base + perp * (cfg.Size.w / 2)
                    local p2 = base - perp * (cfg.Size.w / 2)

                    arrow.outline1.From, arrow.outline1.To = p1, tip
                    arrow.outline2.From, arrow.outline2.To = p2, tip
                    arrow.line1.From, arrow.line1.To = p1, tip
                    arrow.line2.From, arrow.line2.To = p2, tip
                    
                    -- Aplicar cores rainbow se ativo
                    if useRainbow then
                        for _, line in pairs({arrow.line1, arrow.line2}) do
                            line.Color = rainbowColor
                        end
                    end
                else
                    local cfg = GlobalArrowDesign.Gui
                    arrow.Image.Visible = true
                    arrow.Image.Position = UDim2.fromOffset(tip.X - cfg.Size.w/2, tip.Y - cfg.Size.h/2)
                    
                    local angle = math.atan2(dir.Y, dir.X)
                    arrow.Image.Rotation = math.deg(angle) + cfg.RotationOffset
                    
                    -- Aplicar cores rainbow se ativo
                    if useRainbow then
                        arrow.Image.ImageColor3 = rainbowColor
                    end
                end
            else
                -- Esconde arrow quando não necessária
                if ModelESP.UseDrawingArrow then
                    for _, obj in pairs(arrow) do 
                        if obj then obj.Visible = false end 
                    end
                else
                    if arrow.Image then arrow.Image.Visible = false end
                end
            end
        end

        -- ESP normal - só aparece quando objeto está visível na tela e não atrás da câmera
        local onScreen = isInViewport(pos2D, vs, 0) and pos2D.Z > 0 and not isBehindCamera(pos3D)
        local shouldHideESP = ModelESP.ArrowEnabled and not onScreen
        
        if shouldHideESP then
            -- Esconde ESP normal quando arrow está sendo mostrado ou objeto não visível
            for _, draw in ipairs({esp.tracerLine,esp.nameText,esp.distanceText}) do 
                if draw then draw.Visible = false end 
            end
            if esp.highlight then esp.highlight.Enabled = false end
        else
            -- Mostra ESP normal quando objeto está na tela
            -- Calcular bounds na tela
            local screenPoints = {}
            local hx, hy, hz = size.X/2, size.Y/2, size.Z/2
            local relPositions = {
                Vector3.new(hx, hy, hz), Vector3.new(hx, hy, -hz), Vector3.new(hx, -hy, hz), Vector3.new(hx, -hy, -hz),
                Vector3.new(-hx, hy, hz), Vector3.new(-hx, hy, -hz), Vector3.new(-hx, -hy, hz), Vector3.new(-hx, -hy, -hz),
            }
            for _, rel in ipairs(relPositions) do
                local worldPos = cf * rel
                local vp = camera:WorldToViewportPoint(worldPos)
                if vp.Z > 0 then
                    table.insert(screenPoints, Vector2.new(vp.X, vp.Y))
                end
            end

            local showBounds = #screenPoints > 0
            local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge
            if showBounds then
                for _, p in ipairs(screenPoints) do
                    minX = math.min(minX, p.X)
                    maxX = math.max(maxX, p.X)
                    minY = math.min(minY, p.Y)
                    maxY = math.max(maxY, p.Y)
                end
            else
                minX, maxX, minY, maxY = pos2D.X-25, pos2D.X+25, pos2D.Y-25, pos2D.Y+25
            end

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
                esp.highlight.FillTransparency = ModelESP.GlobalSettings.ShowHighlightFill and 0.85 or 1
                esp.highlight.OutlineTransparency = ModelESP.GlobalSettings.ShowHighlightOutline and 0.65 or 1
            end
        end
    end
end)

return ModelESP
