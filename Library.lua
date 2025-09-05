-- KoltESP Library
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

    -- NOVO: Distância máxima e mínima
    MaxDistance = math.huge, -- sem limite
    MinDistance = 0,

    -- Container padrão (pode ser "", "[]", "{}", "()", etc)
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
    self.DistanceSuffix = " m" -- padrão
    self:Init()
    return self
end

-- Inicializa elementos ESP
function KoltESP:Init()
    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Adornee = self.Target
    highlight.FillTransparency = 1 - Settings.FillOpacity
    highlight.OutlineTransparency = 1 - Settings.OutlineOpacity
    highlight.Parent = game.CoreGui
    self.Elements.Highlight = highlight

    -- Billboard (Nome e Distância separados)
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.Parent = game.CoreGui
    self.Elements.Billboard = billboard

    -- Label do Nome
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = self.Color
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = 14
    nameLabel.Parent = billboard
    self.Elements.NameLabel = nameLabel

    -- Label da Distância
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = self.Color
    distLabel.TextStrokeTransparency = 0
    distLabel.Font = Enum.Font.SourceSans
    distLabel.TextSize = 13
    distLabel.Parent = billboard
    self.Elements.DistanceLabel = distLabel

    -- Tracer (linha)
    local tracer = Drawing.new("Line")
    tracer.Color = self.Color
    tracer.Thickness = 2
    tracer.Visible = true
    self.Elements.Tracer = tracer

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

    local root = self.Target.PrimaryPart or self.Target:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
    if not onScreen then
        self.Elements.Tracer.Visible = false
        self.Elements.Billboard.Enabled = false
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
        self.Elements.NameLabel.Text = self.Name
        self.Elements.NameLabel.TextColor3 = self.Color
    else
        self.Elements.NameLabel.Text = ""
    end

    -- Distância
    if Settings.DistanceVisible then
        local distance = (LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and
            (root.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude) or 0

        -- Checa Min/Max
        if distance >= Settings.MinDistance and distance <= Settings.MaxDistance then
            local value = string.format("%.1f%s", distance, self.DistanceSuffix or " m")

            -- Container
            if Settings.DistanceContainer ~= "" then
                value = string.format("%s%s%s",
                    string.sub(Settings.DistanceContainer, 1, 1),
                    value,
                    string.sub(Settings.DistanceContainer, -1)
                )
            end

            self.Elements.DistanceLabel.Text = value
            self.Elements.DistanceLabel.TextColor3 = self.Color
        else
            self.Elements.DistanceLabel.Text = ""
        end
    else
        self.Elements.DistanceLabel.Text = ""
    end

    self.Elements.Billboard.Enabled = (Settings.NameVisible or Settings.DistanceVisible)
    self.Elements.Billboard.Adornee = root

    -- Highlight
    if self.Elements.Highlight then
        self.Elements.Highlight.FillTransparency = 1 - Settings.FillOpacity
        self.Elements.Highlight.OutlineTransparency = 1 - Settings.OutlineOpacity
        self.Elements.Highlight.FillColor = self.Color
        self.Elements.Highlight.OutlineColor = self.Color
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
