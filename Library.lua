--// 📦 Library Kolt V1.3
--// 👤 Autor: Kolt
--// 🎨 Estilo: Minimalista, eficiente e responsivo

local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

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
        ShowArrow = false,
        RainbowMode = false,
        MaxDistance = math.huge,
        MinDistance = 0,
        Opacity = 0.8,
        ArrowOpacity = 0.3,
        ArrowRadius = 130,
        ArrowWidth = 24,
        ArrowHeight = 20,
        ArrowOutlineThickness = 6,
        ArrowLineThickness = 3,
        LineThickness = 1.5,
        FontSize = 14,
        AutoRemoveInvalid = true,
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

--// Cria Arrow Drawing
local function createArrowDrawing(esp, globalSettings)
    local arrow = {}
    local outlineProps = {
        Color = Color3.new(0, 0, 0),
        Thickness = globalSettings.ArrowOutlineThickness,
        Transparency = globalSettings.ArrowOpacity,
        Visible = false
    }
    local lineProps = {
        Color = esp.Colors.Tracer,
        Thickness = globalSettings.ArrowLineThickness,
        Transparency = globalSettings.ArrowOpacity,
        Visible = false
    }
    arrow.outline1 = createDrawing("Line", outlineProps)
    arrow.outline2 = createDrawing("Line", outlineProps)
    arrow.line1 = createDrawing("Line", lineProps)
    arrow.line2 = createDrawing("Line", lineProps)
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
        DistanceContainerEnd = (config and config.DistanceContainer and config.DistanceContainer.End) or "",
        arrow = nil
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
            if obj.arrow then
                for _, line in ipairs({obj.arrow.outline1, obj.arrow.outline2, obj.arrow.line1, obj.arrow.line2}) do
                    if line then pcall(line.Remove, line) end
                end
            end
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
        if obj.arrow then
            for _, line in ipairs({obj.arrow.outline1, obj.arrow.outline2, obj.arrow.line1, obj.arrow.line2}) do
                if line then pcall(line.Remove, line) end
            end
        end
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
        if esp.arrow then
            for _, line in ipairs({esp.arrow.outline1, esp.arrow.outline2}) do
                if line then line.Thickness = self.GlobalSettings.ArrowOutlineThickness; line.Transparency = self.GlobalSettings.ArrowOpacity end
            end
            for _, line in ipairs({esp.arrow.line1, esp.arrow.line2}) do
                if line then line.Thickness = self.GlobalSettings.ArrowLineThickness; line.Transparency = self.GlobalSettings.ArrowOpacity end
            end
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
function ModelESP:Arrow(enabled)
    self.GlobalSettings.ShowArrow = enabled
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

        local cf, size = getBoundingBox(target)
        if not cf then continue end
        local pos3D = cf.Position

        local pos2D, onScreen = camera:WorldToViewportPoint(pos3D)
        local distance = (camera.CFrame.Position - pos3D).Magnitude
        local visible = distance >= ModelESP.GlobalSettings.MinDistance and distance <= ModelESP.GlobalSettings.MaxDistance
        if not visible then
            for _, draw in ipairs({esp.tracerLine,esp.nameText,esp.distanceText}) do if draw then draw.Visible=false end end
            if esp.highlight then esp.highlight.Enabled=false end
            if esp.arrow then
                for _, line in ipairs({esp.arrow.outline1, esp.arrow.outline2, esp.arrow.line1, esp.arrow.line2}) do
                    if line then line.Visible = false end
                end
            end
            continue
        end

        local rainbowColor = getRainbowColor(time)
        local useRainbow = ModelESP.GlobalSettings.RainbowMode

        local screenCenter = Vector2.new(vs.X / 2, vs.Y / 2)

        if onScreen then
            -- Show ESP elements
            -- Calcular bounds na tela (mantido para fallback, mas posicionamento usa projeção do centro)
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
                -- Fallback para centro se nenhum corner visível, mas centro é
                minX, maxX, minY, maxY = pos2D.X-25, pos2D.X+25, pos2D.Y-25, pos2D.Y+25
            end

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
                esp.tracerLine.Transparency = ModelESP.GlobalSettings.Opacity
            end
            -- Name
            if esp.nameText then
                esp.nameText.Visible = ModelESP.GlobalSettings.ShowName
                esp.nameText.Position = Vector2.new(centerX, startY)
                esp.nameText.Text = esp.NameContainerStart .. esp.Name .. esp.NameContainerEnd
                esp.nameText.Color = useRainbow and rainbowColor or esp.Colors.Name
                esp.nameText.Transparency = ModelESP.GlobalSettings.Opacity
            end
            -- Distance
            if esp.distanceText then
                esp.distanceText.Visible = ModelESP.GlobalSettings.ShowDistance
                esp.distanceText.Position = Vector2.new(centerX, startY + nameSize)
                esp.distanceText.Text = esp.DistanceContainerStart .. string.format("%.1f", distance) .. esp.DistanceSuffix .. esp.DistanceContainerEnd
                esp.distanceText.Color = useRainbow and rainbowColor or esp.Colors.Distance
                esp.distanceText.Transparency = ModelESP.GlobalSettings.Opacity
            end
            -- Highlight
            if esp.highlight then
                esp.highlight.Enabled = ModelESP.GlobalSettings.ShowHighlightFill or ModelESP.GlobalSettings.ShowHighlightOutline
                esp.highlight.FillColor = useRainbow and rainbowColor or esp.Colors.Highlight.Filled
                esp.highlight.OutlineColor = useRainbow and rainbowColor or esp.Colors.Highlight.Outline
                esp.highlight.FillTransparency = ModelESP.GlobalSettings.ShowHighlightFill and 0.85 or 1
                esp.highlight.OutlineTransparency = ModelESP.GlobalSettings.ShowHighlightOutline and 0.65 or 1
            end

            -- Hide arrow
            if esp.arrow then
                for _, line in ipairs({esp.arrow.outline1, esp.arrow.outline2, esp.arrow.line1, esp.arrow.line2}) do
                    if line then line.Visible = false end
                end
            end
        else
            -- Hide ESP elements
            for _, draw in ipairs({esp.tracerLine,esp.nameText,esp.distanceText}) do if draw then draw.Visible=false end end
            if esp.highlight then esp.highlight.Enabled=false end

            -- Show arrow if enabled
            if ModelESP.GlobalSettings.ShowArrow then
                if not esp.arrow then
                    esp.arrow = createArrowDrawing(esp, ModelESP.GlobalSettings)
                end
                local arrow = esp.arrow
                local dir = (Vector2.new(pos2D.X, pos2D.Y) - screenCenter).Unit
                local tip = screenCenter + dir * ModelESP.GlobalSettings.ArrowRadius
                local base = tip - dir * ModelESP.GlobalSettings.ArrowHeight
                local perp = Vector2.new(-dir.Y, dir.X)
                local p1 = base + perp * (ModelESP.GlobalSettings.ArrowWidth / 2)
                local p2 = base - perp * (ModelESP.GlobalSettings.ArrowWidth / 2)

                arrow.outline1.From = p1
                arrow.outline1.To = tip
                arrow.outline2.From = p2
                arrow.outline2.To = tip
                arrow.line1.From = p1
                arrow.line1.To = tip
                arrow.line2.From = p2
                arrow.line2.To = tip

                local arrowColor = useRainbow and rainbowColor or esp.Colors.Tracer
                arrow.line1.Color = arrowColor
                arrow.line2.Color = arrowColor
                arrow.outline1.Color = Color3.new(0, 0, 0)
                arrow.outline2.Color = Color3.new(0, 0, 0)

                for _, line in ipairs({arrow.outline1, arrow.outline2, arrow.line1, arrow.line2}) do
                    if line then line.Visible = true end
                end
            end
        end
    end
end)

return ModelESP
