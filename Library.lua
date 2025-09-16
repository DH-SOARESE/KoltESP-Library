--// 📦 Library Kolt V1.3
--// 👤 Autor: Kolt
--// 🎨 Estilo: Minimalista, eficiente e responsivo

local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local TopLayer = gethui and gethui() or game:GetService("CoreGui")

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
        ArrowType = "Drawing",
        ArrowRadius = 130,
        RainbowMode = false,
        MaxDistance = math.huge,
        MinDistance = 0,
        Opacity = 0.8,
        LineThickness = 1.5,
        FontSize = 14,
        AutoRemoveInvalid = true,
    },
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

--// Create Arrow Drawing
local function createArrowDrawing()
    local arrow = {}
    arrow.outline1 = Drawing.new("Line")
    arrow.outline2 = Drawing.new("Line")
    arrow.line1 = Drawing.new("Line")
    arrow.line2 = Drawing.new("Line")
    for _, line in pairs({arrow.outline1, arrow.outline2, arrow.line1, arrow.line2}) do
        line.Visible = false
    end
    return arrow
end

--// Create Arrow GUI
local function createArrowGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = TopLayer

    local image = Instance.new("ImageLabel")
    image.BackgroundTransparency = 1
    image.ImageTransparency = 1
    image.Size = UDim2.new(0, 0, 0, 0)
    image.Parent = screenGui

    local arrow = {Gui = screenGui, Image = image}
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

    -- Arrow
    if self.GlobalSettings.ShowArrow then
        if self.GlobalSettings.ArrowType == "Drawing" then
            cfg.arrow = createArrowDrawing()
        elseif self.GlobalSettings.ArrowType == "Gui" then
            cfg.arrow = createArrowGui()
            local designGui = self.GlobalArrowDesign.Gui
            if designGui then
                cfg.arrow.Image.Image = designGui.image or ""
                cfg.arrow.Gui.DisplayOrder = designGui.DisplayOrder or 18
            end
        end
    end

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
                if obj.arrow.Gui then
                    pcall(function() obj.arrow.Gui:Destroy() end)
                else
                    for _, draw in pairs(obj.arrow) do
                        pcall(function() draw:Remove() end)
                    end
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
            if obj.arrow.Gui then
                pcall(function() obj.arrow.Gui:Destroy() end)
            else
                for _, draw in pairs(obj.arrow) do
                    pcall(function() draw:Remove() end)
                end
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
        if esp.nameText then 
            esp.nameText.Size = self.GlobalSettings.FontSize 
            if esp.distanceText then esp.distanceText.Size = self.GlobalSettings.FontSize - 2 end
        end
    end
end

--// Update Arrows
function ModelESP:UpdateArrows()
    -- Destroy old arrows
    for _, esp in ipairs(self.Objects) do
        if esp.arrow then
            if self.GlobalSettings.ArrowType == "Gui" and esp.arrow.Gui then
                pcall(function() esp.arrow.Gui:Destroy() end)
            else
                for _, draw in pairs(esp.arrow) do
                    pcall(function() draw:Remove() end)
                end
            end
            esp.arrow = nil
        end
    end
    -- Create new if enabled
    if self.GlobalSettings.ShowArrow then
        for _, esp in ipairs(self.Objects) do
            if self.GlobalSettings.ArrowType == "Drawing" then
                esp.arrow = createArrowDrawing()
            elseif self.GlobalSettings.ArrowType == "Gui" then
                esp.arrow = createArrowGui()
                local designGui = self.GlobalArrowDesign.Gui
                if designGui then
                    esp.arrow.Image.Image = designGui.image or ""
                    esp.arrow.Gui.DisplayOrder = designGui.DisplayOrder or 18
                end
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
    if typeName == "ShowArrow" then
        self:UpdateArrows()
    end
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

--// Set Arrow
function ModelESP:SetArrow(cfg)
    local changed = false
    if cfg.ShowArrow ~= nil then
        self.GlobalSettings.ShowArrow = cfg.ShowArrow
        changed = true
    end
    if cfg.Type then
        self.GlobalSettings.ArrowType = cfg.Type
        changed = true
    end
    if cfg.visible ~= nil then
        self.GlobalSettings.ShowArrow = cfg.visible
        changed = true
    end
    if changed then
        self:UpdateArrows()
    end
end

--// Set Arrow Design
function ModelESP:SetArrowDesign(design)
    self.GlobalArrowDesign.Gui = design.Gui or self.GlobalArrowDesign.Gui
    self.GlobalArrowDesign.Drawing = design.Drawing or self.GlobalArrowDesign.Drawing
    -- Update existing GUIs
    for _, esp in ipairs(self.Objects) do
        if esp.arrow and self.GlobalSettings.ArrowType == "Gui" then
            local cfg = self.GlobalArrowDesign.Gui
            if cfg then
                esp.arrow.Image.Image = cfg.image or ""
                esp.arrow.Gui.DisplayOrder = cfg.DisplayOrder or 18
            end
        end
    end
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
        if not cf then 
            for _, draw in ipairs({esp.tracerLine,esp.nameText,esp.distanceText}) do if draw then draw.Visible=false end end
            if esp.highlight then esp.highlight.Enabled=false end
            if esp.arrow then
                if esp.arrow.Gui then
                    esp.arrow.Image.Visible = false
                else
                    for _, line in pairs(esp.arrow) do line.Visible = false end
                end
            end
            continue 
        end
        local pos3D = cf.Position

        local success, pos2D = pcall(function() return camera:WorldToViewportPoint(pos3D) end)
        if not success then
            for _, draw in ipairs({esp.tracerLine,esp.nameText,esp.distanceText}) do if draw then draw.Visible=false end end
            if esp.highlight then esp.highlight.Enabled=false end
            if esp.arrow then
                if esp.arrow.Gui then
                    esp.arrow.Image.Visible = false
                else
                    for _, line in pairs(esp.arrow) do line.Visible = false end
                end
            end
            continue
        end

        if pos2D.Z <= 0 then
            for _, draw in ipairs({esp.tracerLine,esp.nameText,esp.distanceText}) do if draw then draw.Visible=false end end
            if esp.highlight then esp.highlight.Enabled=false end
            if esp.arrow then
                if esp.arrow.Gui then
                    esp.arrow.Image.Visible = false
                else
                    for _, line in pairs(esp.arrow) do line.Visible = false end
                end
            end
            continue
        end

        local distance = (camera.CFrame.Position - pos3D).Magnitude
        local visible = distance >= ModelESP.GlobalSettings.MinDistance and distance <= ModelESP.GlobalSettings.MaxDistance
        if not visible then
            for _, draw in ipairs({esp.tracerLine,esp.nameText,esp.distanceText}) do if draw then draw.Visible=false end end
            if esp.highlight then esp.highlight.Enabled=false end
            if esp.arrow then
                if esp.arrow.Gui then
                    esp.arrow.Image.Visible = false
                else
                    for _, line in pairs(esp.arrow) do line.Visible = false end
                end
            end
            continue
        end

        local onScreen = pos2D.X >= 0 and pos2D.X <= vs.X and pos2D.Y >= 0 and pos2D.Y <= vs.Y
        local drawing_visible = onScreen
        local showArrow = not onScreen

        local rainbowColor = getRainbowColor(time)
        local useRainbow = ModelESP.GlobalSettings.RainbowMode

        -- Usar projeção do centro para posicionamento
        local centerX = pos2D.X
        local centerY = pos2D.Y
        local nameSize = ModelESP.GlobalSettings.FontSize
        local distSize = ModelESP.GlobalSettings.FontSize - 2
        local totalHeight = nameSize + distSize
        local startY = centerY - totalHeight / 2

        local nameTextStr = esp.NameContainerStart .. esp.Name .. esp.NameContainerEnd
        local distTextStr = esp.DistanceContainerStart .. string.format("%.1f", distance) .. esp.DistanceSuffix .. esp.DistanceContainerEnd

        local color_name = useRainbow and rainbowColor or esp.Colors.Name
        local color_dist = useRainbow and rainbowColor or esp.Colors.Distance
        local color_tracer = useRainbow and rainbowColor or esp.Colors.Tracer
        local hcolor_filled = useRainbow and rainbowColor or esp.Colors.Highlight.Filled
        local hcolor_outline = useRainbow and rainbowColor or esp.Colors.Highlight.Outline

        -- Highlight (sempre ativado se visível por distância)
        if esp.highlight then
            esp.highlight.FillColor = hcolor_filled
            esp.highlight.OutlineColor = hcolor_outline
            esp.highlight.FillTransparency = ModelESP.GlobalSettings.ShowHighlightFill and 0.85 or 1
            esp.highlight.OutlineTransparency = ModelESP.GlobalSettings.ShowHighlightOutline and 0.65 or 1
            esp.highlight.Enabled = true
        end

        -- Tracer
        if esp.tracerLine then
            esp.tracerLine.Color = color_tracer
            esp.tracerLine.Transparency = ModelESP.GlobalSettings.Opacity
            esp.tracerLine.Thickness = ModelESP.GlobalSettings.LineThickness
            esp.tracerLine.From = tracerOrigins[ModelESP.GlobalSettings.TracerOrigin](vs)
            esp.tracerLine.To = Vector2.new(pos2D.X, pos2D.Y)
            esp.tracerLine.Visible = ModelESP.GlobalSettings.ShowTracer and drawing_visible
        end

        -- Name
        if esp.nameText then
            esp.nameText.Color = color_name
            esp.nameText.Transparency = ModelESP.GlobalSettings.Opacity
            esp.nameText.Size = ModelESP.GlobalSettings.FontSize
            esp.nameText.Text = nameTextStr
            esp.nameText.Position = Vector2.new(centerX, startY)
            esp.nameText.Visible = ModelESP.GlobalSettings.ShowName and drawing_visible
        end

        -- Distance
        if esp.distanceText then
            esp.distanceText.Color = color_dist
            esp.distanceText.Transparency = ModelESP.GlobalSettings.Opacity
            esp.distanceText.Size = ModelESP.GlobalSettings.FontSize - 2
            esp.distanceText.Text = distTextStr
            esp.distanceText.Position = Vector2.new(centerX, startY + nameSize)
            esp.distanceText.Visible = ModelESP.GlobalSettings.ShowDistance and drawing_visible
        end

        -- Arrow
        if showArrow and esp.arrow then
            local screenPos = Vector2.new(pos2D.X, pos2D.Y)
            local screenCenter = Vector2.new(vs.X / 2, vs.Y / 2)
            local dirVec = screenPos - screenCenter
            local dir = dirVec.Unit
            if dir.Magnitude == 0 then dir = Vector2.new(1, 0) end
            local tip = screenCenter + dir * ModelESP.GlobalSettings.ArrowRadius
            local arrowColor = useRainbow and rainbowColor or Color3.fromRGB(unpack(ModelESP.GlobalArrowDesign[self.GlobalSettings.ArrowType].Color))

            if ModelESP.GlobalSettings.ArrowType == "Drawing" then
                local cfg = ModelESP.GlobalArrowDesign.Drawing
                local height = cfg.Size.h
                local width = cfg.Size.w
                local base = tip - dir * height
                local perp = Vector2.new(-dir.Y, dir.X).Unit
                local p1 = base + perp * (width / 2)
                local p2 = base - perp * (width / 2)

                esp.arrow.outline1.From = p1
                esp.arrow.outline1.To = tip
                esp.arrow.outline1.Color = Color3.fromRGB(unpack(cfg.OutlineColor))
                esp.arrow.outline1.Thickness = cfg.OutlineThickness
                esp.arrow.outline1.Transparency = cfg.Opacity
                esp.arrow.outline1.Visible = true

                esp.arrow.outline2.From = p2
                esp.arrow.outline2.To = tip
                esp.arrow.outline2.Color = Color3.fromRGB(unpack(cfg.OutlineColor))
                esp.arrow.outline2.Thickness = cfg.OutlineThickness
                esp.arrow.outline2.Transparency = cfg.Opacity
                esp.arrow.outline2.Visible = true

                esp.arrow.line1.From = p1
                esp.arrow.line1.To = tip
                esp.arrow.line1.Color = arrowColor
                esp.arrow.line1.Thickness = cfg.LineThickness
                esp.arrow.line1.Transparency = cfg.Opacity
                esp.arrow.line1.Visible = true

                esp.arrow.line2.From = p2
                esp.arrow.line2.To = tip
                esp.arrow.line2.Color = arrowColor
                esp.arrow.line2.Thickness = cfg.LineThickness
                esp.arrow.line2.Transparency = cfg.Opacity
                esp.arrow.line2.Visible = true
            elseif ModelESP.GlobalSettings.ArrowType == "Gui" then
                local cfg = ModelESP.GlobalArrowDesign.Gui
                local pos = tip - Vector2.new(cfg.Size.w / 2, cfg.Size.h / 2)
                esp.arrow.Image.Position = UDim2.fromOffset(pos.X, pos.Y)
                esp.arrow.Image.Size = UDim2.fromOffset(cfg.Size.w, cfg.Size.h)
                local angle = math.atan2(dir.Y, dir.X)
                esp.arrow.Image.Rotation = math.deg(angle) + (cfg.RotationOffset or 90)
                esp.arrow.Image.ImageColor3 = arrowColor
                esp.arrow.Image.ImageTransparency = 1 - cfg.Opacity
                esp.arrow.Image.Visible = true
            end
        elseif esp.arrow then
            if ModelESP.GlobalSettings.ArrowType == "Gui" then
                esp.arrow.Image.Visible = false
            else
                for _, line in pairs(esp.arrow) do
                    line.Visible = false
                end
            end
        end
    end
end)

return ModelESP
