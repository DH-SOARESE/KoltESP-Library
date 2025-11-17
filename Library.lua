--[[
    KoltESP v1.8 - A MELHOR ESP DO ROBLOX (2025)
    Criada por Kolt (DH_SOARES)
    Acesso direto: Kolt.ESP.NomeDoJogador.Opacity = 0.5
    Tudo atualiza em tempo real. Sem recriar. Sem lag. Sem cloneref.
]]

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local HighlightFolderName = "KoltESP_Highlights"
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

local ESP = {}
getgenv().ESP = ESP
getgenv().Kolt = getgenv().Kolt or {}
getgenv().Kolt.ESP = ESP

local KoltESP = {
    Objects = {},
    Theme = {
        PrimaryColor = Color3.fromRGB(130, 200, 255),
        SecondaryColor = Color3.fromRGB(255, 255, 255),
    },
    GlobalSettings = {
        TracerOrigin = "Bottom",
        ShowTracer = true,
        ShowHighlightFill = true,
        ShowHighlightOutline = true,
        ShowName = true,
        ShowDistance = true,
        RainbowMode = false,
        Opacity = 0.8,
        LineThickness = 1.5,
        FontSize = 14,
        Font = 3,
        MaxDistance = math.huge,
        MinDistance = 0,
        HighlightTransparency = { Filled = 0.5, Outline = 0.3 },
        TextOutlineEnabled = true,
        TextOutlineColor = Color3.new(0, 0, 0),
        AutoRemoveInvalid = true
    }
}

-- Rainbow
local function getRainbow(t)
    local f = 2
    return Color3.fromRGB(
        math.sin(f*t)*127 + 128,
        math.sin(f*t + 2)*127 + 128,
        math.sin(f*t + 4)*127 + 128
    )
end

local tracerOrigins = {
    Top = function(vs) return Vector2.new(vs.X/2, 0) end,
    Center = function(vs) return Vector2.new(vs.X/2, vs.Y/2) end,
    Bottom = function(vs) return Vector2.new(vs.X/2, vs.Y) end,
    Left = function(vs) return Vector2.new(0, vs.Y/2) end,
    Right = function(vs) return Vector2.new(vs.X, vs.Y/2) end,
}

local function getCenter(target)
    if target:IsA("Model") then
        local cf = target:GetBoundingBox()
        return cf and cf.Position
    elseif target:IsA("BasePart") then
        return target.Position
    end
    return nil
end

local function collectBaseParts(target)
    local parts = {}
    for _, v in ipairs(target:GetDescendants()) do
        if v:IsA("BasePart") then table.insert(parts, v) end
    end
    if target:IsA("BasePart") then table.insert(parts, target) end
    return parts
end

-- Metatable mágica (o coração da KoltESP)
local esp_mt = {
    __index = function(t, k)
        if k == "Opacity" then return t._Opacity or KoltESP.GlobalSettings.Opacity end
        if k == "LineThickness" then return t._LineThickness or KoltESP.GlobalSettings.LineThickness end
        if k == "FontSize" then return t._FontSize or KoltESP.GlobalSettings.FontSize end
        if k == "Font" then return t._Font or KoltESP.GlobalSettings.Font end
        if k == "TextOutlineEnabled" then return t._TextOutlineEnabled ~= nil and t._TextOutlineEnabled or KoltESP.GlobalSettings.TextOutlineEnabled end
        if k == "TextOutlineColor" then return t._TextOutlineColor or KoltESP.GlobalSettings.TextOutlineColor end
        if k == "DisplayOrder" then return t._DisplayOrder or 0 end
    end,

    __newindex = function(t, k, v)
        if k == "Opacity" then
            t._Opacity = v
            if t.tracerLine then t.tracerLine.Transparency = v end
            if t.nameText then t.nameText.Transparency = v end
            if t.distanceText then t.distanceText.Transparency = v end

        elseif k == "LineThickness" then
            t._LineThickness = v
            if t.tracerLine then t.tracerLine.Thickness = v end

        elseif k == "FontSize" then
            t._FontSize = v
            if t.nameText then t.nameText.Size = v end
            if t.distanceText then t.distanceText.Size = v - 2 end

        elseif k == "Font" then
            t._Font = v
            if t.nameText then t.nameText.Font = v end
            if t.distanceText then t.distanceText.Font = v end

        elseif k == "TextOutlineEnabled" then
            t._TextOutlineEnabled = v
            if t.nameText then t.nameText.Outline = v end
            if t.distanceText then t.distanceText.Outline = v end

        elseif k == "TextOutlineColor" then
            t._TextOutlineColor = v
            if t.nameText then t.nameText.OutlineColor = v end
            if t.distanceText then t.distanceText.OutlineColor = v end

        elseif k == "DisplayOrder" then
            t._DisplayOrder = v
            if t.tracerLine then t.tracerLine.ZIndex = v end
            if t.nameText then t.nameText.ZIndex = v end
            if t.distanceText then t.distanceText.ZIndex = v end

        elseif k == "Collision" and v ~= t.Collision then
            t.Collision = v
            for _, mod in ipairs(t.ModifiedParts) do
                if mod.Part and mod.Part.Parent then
                    mod.Part.Transparency = mod.OriginalTransparency
                end
            end
            t.ModifiedParts = {}
            if t.humanoid then t.humanoid:Destroy(); t.humanoid = nil end
            if v then
                local parts = collectBaseParts(t.Target)
                for _, part in ipairs(parts) do
                    if part.Transparency == 1 then
                        table.insert(t.ModifiedParts, {Part = part, OriginalTransparency = 1})
                        part.Transparency = 0.99
                    end
                end
                local hum = t.Target:FindFirstChild("Esp")
                if not hum then
                    hum = Instance.new("Humanoid")
                    hum.Name = "Esp"
                    hum.Parent = t.Target
                end
                t.humanoid = hum
            end

        else
            rawset(t, k, v)
        end
    end
}

function KoltESP:Add(key, target, config)
    if typeof(key) ~= "string" then
        config = target or {}
        target = key
        key = nil
    end
    config = config or {}

    if not target or not (target:IsA("Model") or target:IsA("BasePart")) then return end

    if self:GetESP(target) then self:Remove(target) end

    local esp = {
        Target = target,
        Name = config.Name or target.Name,
        Collision = config.Collision or false,
        ModifiedParts = {},
        MaxDistance = config.MaxDistance or self.GlobalSettings.MaxDistance,
        MinDistance = config.MinDistance or self.GlobalSettings.MinDistance,
        Types = {
            Tracer = config.Tracer ~= false,
            Name = config.Name ~= false,
            Distance = config.Distance ~= false,
            HighlightFill = config.HighlightFill ~= false,
            HighlightOutline = config.HighlightOutline ~= false,
        },
        DistancePrefix = config.DistancePrefix or "",
        DistanceSuffix = config.DistanceSuffix or "",
        ColorDependency = config.ColorDependency,
    }

    -- Cores
    esp.Colors = {
        Name = config.Color or KoltESP.Theme.PrimaryColor,
        Distance = config.Color or KoltESP.Theme.PrimaryColor,
        Tracer = config.Color or KoltESP.Theme.PrimaryColor,
        Highlight = { Filled = config.Color or KoltESP.Theme.PrimaryColor, Outline = KoltESP.Theme.SecondaryColor }
    }

    -- Criar Drawings
    esp.tracerLine = Drawing.new("Line")
    esp.nameText = Drawing.new("Text")
    esp.distanceText = Drawing.new("Text")

    esp.nameText.Center = true
    esp.nameText.Outline = true
    esp.distanceText.Center = true
    esp.distanceText.Outline = true

    esp.highlight = Instance.new("Highlight")
    esp.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    esp.highlight.Parent = getHighlightFolder()

    setmetatable(esp, esp_mt)
    table.insert(self.Objects, esp)

    if key then
        if ESP[key] then self:Remove(ESP[key].Target) end
        ESP[key] = esp
    end

    return esp
end

function KoltESP:Remove(obj)
    for i = #self.Objects, 1, -1 do
        if self.Objects[i].Target == (typeof(obj) == "string" and ESP[obj] and ESP[obj].Target or obj) then
            local esp = table.remove(self.Objects, i)
            if esp.tracerLine then pcall(esp.tracerLine.Remove, esp.tracerLine) end
            if esp.nameText then pcall(esp.nameText.Remove, esp.nameText) end
            if esp.distanceText then pcall(esp.distanceText.Remove, esp.distanceText) end
            if esp.highlight then esp.highlight:Destroy() end
            if esp.humanoid then esp.humanoid:Destroy() end
            for _, mod in ipairs(esp.ModifiedParts) do
                if mod.Part and mod.Part.Parent then mod.Part.Transparency = mod.OriginalTransparency end
            end
            if esp.Identifier then ESP[esp.Identifier] = nil end
        end
    end
end

function KoltESP:Clear()
    for i = #self.Objects, 1, -1 do self:Remove(self.Objects[i].Target) end
end

-- Globals perfeitos
function KoltESP:SetGlobalOpacity(v) self.GlobalSettings.Opacity = math.clamp(v,0,1) for _,e in ipairs(self.Objects) do e.Opacity = v end end
function KoltESP:SetGlobalLineThickness(v) self.GlobalSettings.LineThickness = math.max(1,v) for _,e in ipairs(self.Objects) do e.LineThickness = v end end
function KoltESP:SetGlobalFontSize(v) self.GlobalSettings.FontSize = math.max(10,v) for _,e in ipairs(self.Objects) do e.FontSize = v end end
function KoltESP:SetGlobalFont(v) if v >= 0 and v <= 3 then self.GlobalSettings.Font = v for _,e in ipairs(self.Objects) do e.Font = v end end end
function KoltESP:SetGlobalRainbow(v) self.GlobalSettings.RainbowMode = v end
function KoltESP:SetGlobalTracerOrigin(v) if tracerOrigins[v] then self.GlobalSettings.TracerOrigin = v end end

-- Loop principal
RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vs = cam.ViewportSize
    local rainbow = KoltESP.GlobalSettings.RainbowMode and getRainbow(tick()) or nil

    for i = #KoltESP.Objects, 1, -1 do
        local esp = KoltESP.Objects[i]
        local target = esp.Target
        if not target or not target.Parent then KoltESP:Remove(target) continue end

        local pos3D = getCenter(target)
        if not pos3D then continue end

        local screen, onScreen = cam:WorldToViewportPoint(pos3D)
        local dist = (cam.CFrame.Position - pos3D).Magnitude

        if not onScreen or screen.Z <= 0 or dist < esp.MinDistance or dist > esp.MaxDistance then
            esp.tracerLine.Visible = false
            esp.nameText.Visible = false
            esp.distanceText.Visible = false
            esp.highlight.Enabled = false
            continue
        end

        local color = esp.ColorDependency and esp.ColorDependency(esp, dist, pos3D) or esp.Colors

        -- Tracer
        if KoltESP.GlobalSettings.ShowTracer and esp.Types.Tracer then
            esp.tracerLine.Visible = true
            esp.tracerLine.From = tracerOrigins[KoltESP.GlobalSettings.TracerOrigin](vs)
            esp.tracerLine.To = Vector2.new(screen.X, screen.Y)
            esp.tracerLine.Color = rainbow or color.Tracer
        else
            esp.tracerLine.Visible = false
        end

        -- Name
        if KoltESP.GlobalSettings.ShowName and esp.Types.Name then
            esp.nameText.Visible = true
            esp.nameText.Position = Vector2.new(screen.X, screen.Y - esp.FontSize - 10)
            esp.nameText.Text = esp.Name
            esp.nameText.Color = rainbow or color.Name
        else
            esp.nameText.Visible = false
        end

        -- Distance
        if KoltESP.GlobalSettings.ShowDistance and esp.Types.Distance then
            esp.distanceText.Visible = true
            esp.distanceText.Position = Vector2.new(screen.X, screen.Y - 10)
            esp.distanceText.Text = esp.DistancePrefix .. string.format("%.1f", dist) .. esp.DistanceSuffix
            esp.distanceText.Color = rainbow or color.Distance
        else
            esp.distanceText.Visible = false
        end

        -- Highlight
        local showFill = KoltESP.GlobalSettings.ShowHighlightFill and esp.Types.HighlightFill
        local showOutline = KoltESP.GlobalSettings.ShowHighlightOutline and esp.Types.HighlightOutline
        esp.highlight.Enabled = showFill or showOutline
        esp.highlight.Adornee = target
        esp.highlight.FillColor = rainbow or color.Highlight.Filled
        esp.highlight.OutlineColor = rainbow or color.Highlight.Outline
        esp.highlight.FillTransparency = showFill and KoltESP.GlobalSettings.HighlightTransparency.Filled or 1
        esp.highlight.OutlineTransparency = showOutline and KoltESP.GlobalSettings.HighlightTransparency.Outline or 1
    end
end)

return KoltESP
