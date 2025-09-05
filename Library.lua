-- KoltESP Library Melhorada
-- Suporte: Tracer, Name, Distance, HighlightOutline, HighlightFill
-- Orientada a objetos com configuração global e individual

local KoltESP = {}
KoltESP.__index = KoltESP

-- Configurações globais
local Settings = {
    TracerOrigin = "Bottom", -- Top, Center, Bottom
    TracerVisible = true,
    NameVisible = true,
    DistanceVisible = true,
    HighlightOutlineVisible = true,
    HighlightFillVisible = true,
    OutlineOpacity = 0.5,
    FillOpacity = 0.5,
    RainbowMode = false,
    ESPColor = Color3.fromRGB(255, 0, 0),

    MaxDistance = math.huge,
    MinDistance = 0,
    DistanceContainer = ""
}

-- Serviços
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Cria um objeto ESP
function KoltESP.new(target)
    local self = setmetatable({}, KoltESP)
    self.Target = target
    self.Color = Settings.ESPColor
    self.Elements = {}
    self.Name = nil
    self.DistanceSuffix = " m"
    self:Init()
    return self
end

-- Inicializa elementos ESP
function KoltESP:Init()
    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 1 - Settings.FillOpacity
    highlight.OutlineTransparency = 1 - Settings.OutlineOpacity
    highlight.Parent = game.CoreGui
    self.Elements.Highlight = highlight

    -- Tracer
    local tracer = Drawing.new("Line")
    tracer.Color = self.Color
    tracer.Thickness = 2
    tracer.Visible = true
    self.Elements.Tracer = tracer

    -- Nome
    local nameDraw = Drawing.new("Text")
    nameDraw.Size = 16
    nameDraw.Center = true
    nameDraw.Outline = true
    nameDraw.Color = self.Color
    nameDraw.Visible = false
    nameDraw.Font = 2
    self.Elements.NameDrawing = nameDraw

    -- Distância
    local distDraw = Drawing.new("Text")
    distDraw.Size = 14
    distDraw.Center = true
    distDraw.Outline = true
    distDraw.Color = self.Color
    distDraw.Visible = false
    distDraw.Font = 1
    self.Elements.DistanceDrawing = distDraw

    -- Loop update
    self.Connection = RunService.RenderStepped:Connect(function()
        self:Update()
    end)
end

-- Atualiza ESP
function KoltESP:Update()
    if not self.Target or not self.Target:IsDescendantOf(workspace) then
        self:Destroy()
        return
    end

    -- Pega posição dependendo do tipo
    local rootPos, rootInstance
    if self.Target:IsA("Model") then
        rootInstance = self.Target.PrimaryPart or self.Target:FindFirstChildWhichIsA("BasePart")
        if not rootInstance then return end
        rootPos = rootInstance.Position
    elseif self.Target:IsA("BasePart") then
        rootInstance = self.Target
        rootPos = rootInstance.Position
    else
        return
    end

    local pos, onScreen = Camera:WorldToViewportPoint(rootPos)
    if not onScreen then
        self.Elements.Tracer.Visible = false
        self.Elements.NameDrawing.Visible = false
        self.Elements.DistanceDrawing.Visible = false
        return
    end

    -- Rainbow mode
    if Settings.RainbowMode then
        local t = tick()
        self.Color = Color3.fromHSV((t % 5) / 5, 1, 1)
    end

    -- Tracer
    if Settings.TracerVisible then
        local originY = Camera.ViewportSize.Y
        if Settings.TracerOrigin == "Top" then
            originY = 0
        elseif Settings.TracerOrigin == "Center" then
            originY = Camera.ViewportSize.Y / 2
        end
        self.Elements.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, originY)
        self.Elements.Tracer.To = Vector2.new(pos.X, pos.Y)
        self.Elements.Tracer.Color = self.Color
        self.Elements.Tracer.Visible = true
    else
        self.Elements.Tracer.Visible = false
    end

    -- Nome
    if Settings.NameVisible and self.Name then
        self.Elements.NameDrawing.Text = self.Name
        self.Elements.NameDrawing.Position = Vector2.new(pos.X, pos.Y - 20)
        self.Elements.NameDrawing.Color = self.Color
        self.Elements.NameDrawing.Visible = true
    else
        self.Elements.NameDrawing.Visible = false
    end

    -- Distância
    if Settings.DistanceVisible and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
        local distance = (rootPos - LocalPlayer.Character.PrimaryPart.Position).Magnitude
        if distance >= Settings.MinDistance and distance <= Settings.MaxDistance then
            local value = string.format("%.1f%s", distance, self.DistanceSuffix or " m")
            if Settings.DistanceContainer ~= "" then
                value = string.format("%s%s%s",
                    string.sub(Settings.DistanceContainer, 1, 1),
                    value,
                    string.sub(Settings.DistanceContainer, -1)
                )
            end
            self.Elements.DistanceDrawing.Text = value
            self.Elements.DistanceDrawing.Position = Vector2.new(pos.X, pos.Y + 10)
            self.Elements.DistanceDrawing.Color = self.Color
            self.Elements.DistanceDrawing.Visible = true
        else
            self.Elements.DistanceDrawing.Visible = false
        end
    else
        self.Elements.DistanceDrawing.Visible = false
    end

    -- Highlight
    if self.Elements.Highlight then
        self.Elements.Highlight.FillTransparency = 1 - Settings.FillOpacity
        self.Elements.Highlight.OutlineTransparency = 1 - Settings.OutlineOpacity
        self.Elements.Highlight.FillColor = self.Color
        self.Elements.Highlight.OutlineColor = self.Color
        self.Elements.Highlight.Adornee = rootInstance
        self.Elements.Highlight.Enabled = (Settings.HighlightOutlineVisible or Settings.HighlightFillVisible)
    end
end

-- Adiciona ESP
function KoltESP:AddESP(config)
    if config.type == "Name" then
        self.Name = config.name or "Target"
    elseif config.type == "Distance" then
        self.DistanceSuffix = config.Suffix or " m"
    end
end

-- Configurações globais
function KoltESP.SetESP(config)
    for k, v in pairs(config) do
        Settings[k] = v
    end
end

-- Remover ESP
function KoltESP:Destroy()
    if self.Connection then self.Connection:Disconnect() end
    for _, v in pairs(self.Elements) do
        if typeof(v) == "Instance" then
            v:Destroy()
        elseif typeof(v) == "table" and v.Remove then
            v:Remove()
        elseif v.Destroy then
            v:Destroy()
        end
    end
    self.Elements = {}
end

-- Unload global
function KoltESP.Unload()
    for _, obj in pairs(KoltESP.Objects or {}) do
        obj:Destroy()
    end
    KoltESP.Objects = {}
end

return KoltESP
