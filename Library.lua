-- KoltESP Library v1.0
-- Biblioteca ESP orientada a objetos para Roblox
-- Carregamento: loadstring(game:HttpGet("URL"))()

local KoltESP = {}
KoltESP.__index = KoltESP

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Variáveis globais da biblioteca
local ESPObjects = {}
local Connections = {}
local IsLoaded = false

-- Configurações padrão
local DefaultConfig = {
    ["Tracer"] = {
        TracerOrigin = "Bottom", -- "Top", "Center", "Bottom"
        Visible = true,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1,
        Transparency = 0
    },
    ["Highlight"] = {
        Outline = true,
        Filled = true,
        Visible = true,
        OutlineColor = Color3.fromRGB(255, 0, 0),
        FillColor = Color3.fromRGB(255, 0, 0),
        OutlineTransparency = 0.3,
        FillTransparency = 0.5
    },
    ["Name"] = {
        Visible = true,
        Color = Color3.fromRGB(255, 255, 255),
        Size = 16,
        Font = Enum.Font.SourceSans,
        Container = "[]"
    },
    ["Distance"] = {
        Visible = true,
        Color = Color3.fromRGB(255, 255, 255),
        Size = 14,
        Font = Enum.Font.SourceSans,
        Container = "()"
    },
    EspMaxDistance = 300,
    EspMinDistance = 5
}

local CurrentConfig = DefaultConfig

-- Função para obter objeto do caminho
local function getObjectFromPath(path)
    local success, result = pcall(function()
        return loadstring("return " .. path)()
    end)
    return success and result or nil
end

-- Função para calcular posição do tracer
local function getTracerOrigin()
    local viewportSize = Camera.ViewportSize
    local origin = CurrentConfig.Tracer.TracerOrigin
    
    if origin == "Top" then
        return Vector2.new(viewportSize.X / 2, 0)
    elseif origin == "Center" then
        return Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    else -- Bottom
        return Vector2.new(viewportSize.X / 2, viewportSize.Y)
    end
end

-- Classe ESP Object
local ESPObject = {}
ESPObject.__index = ESPObject

function ESPObject.new(target, reference, config)
    local self = setmetatable({}, ESPObject)
    
    self.Target = target
    self.Reference = reference or target.Name
    self.Config = config or {}
    
    -- Elementos visuais
    self.Tracer = nil
    self.Highlight = nil
    self.NameLabel = nil
    self.DistanceLabel = nil
    self.Connection = nil
    
    -- Configurações específicas do objeto
    self.Color = self.Config.Color or Color3.fromRGB(255, 0, 0)
    self.Name = self.Config.Name or {
        Name = self.Reference,
        Container = CurrentConfig.Name.Container
    }
    self.DistanceContainer = self.Config.DistanceContainer or CurrentConfig.Distance.Container
    
    self:CreateElements()
    self:StartUpdating()
    
    return self
end

function ESPObject:CreateElements()
    if not self.Target or not self.Target.Parent then return end
    
    -- Criar Highlight
    if CurrentConfig.Highlight.Visible then
        self.Highlight = Instance.new("Highlight")
        self.Highlight.Adornee = self.Target
        self.Highlight.OutlineColor = self.Color
        self.Highlight.FillColor = self.Color
        self.Highlight.OutlineTransparency = CurrentConfig.Highlight.OutlineTransparency
        self.Highlight.FillTransparency = CurrentConfig.Highlight.FillTransparency
        self.Highlight.Enabled = CurrentConfig.Highlight.Outline or CurrentConfig.Highlight.Filled
        self.Highlight.Parent = self.Target
    end
    
    -- Criar GUI para Name e Distance
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KoltESP_" .. self.Reference
    screenGui.Parent = game.CoreGui
    
    -- Label do Nome
    if CurrentConfig.Name.Visible then
        self.NameLabel = Instance.new("TextLabel")
        self.NameLabel.Name = "NameLabel"
        self.NameLabel.Size = UDim2.new(0, 200, 0, CurrentConfig.Name.Size)
        self.NameLabel.BackgroundTransparency = 1
        self.NameLabel.TextColor3 = CurrentConfig.Name.Color
        self.NameLabel.TextSize = CurrentConfig.Name.Size
        self.NameLabel.Font = CurrentConfig.Name.Font
        self.NameLabel.TextStrokeTransparency = 0
        self.NameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        self.NameLabel.Text = self.Name.Container:gsub("%%s", self.Name.Name)
        self.NameLabel.Parent = screenGui
    end
    
    -- Label da Distância
    if CurrentConfig.Distance.Visible then
        self.DistanceLabel = Instance.new("TextLabel")
        self.DistanceLabel.Name = "DistanceLabel"
        self.DistanceLabel.Size = UDim2.new(0, 200, 0, CurrentConfig.Distance.Size)
        self.DistanceLabel.BackgroundTransparency = 1
        self.DistanceLabel.TextColor3 = CurrentConfig.Distance.Color
        self.DistanceLabel.TextSize = CurrentConfig.Distance.Size
        self.DistanceLabel.Font = CurrentConfig.Distance.Font
        self.DistanceLabel.TextStrokeTransparency = 0
        self.DistanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        self.DistanceLabel.Parent = screenGui
    end
    
    -- Criar Tracer
    if CurrentConfig.Tracer.Visible then
        local drawingGui = Instance.new("ScreenGui")
        drawingGui.Name = "TracerGui_" .. self.Reference
        drawingGui.Parent = game.CoreGui
        
        self.Tracer = Instance.new("Frame")
        self.Tracer.Name = "Tracer"
        self.Tracer.BackgroundColor3 = self.Color
        self.Tracer.BorderSizePixel = 0
        self.Tracer.Parent = drawingGui
    end
end

function ESPObject:UpdateElements()
    if not self.Target or not self.Target.Parent then
        self:Destroy()
        return
    end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local targetPosition = self.Target.Position or self.Target.CFrame.Position
    local distance = (character.HumanoidRootPart.Position - targetPosition).Magnitude
    
    -- Verificar distância
    if distance > CurrentConfig.EspMaxDistance or distance < CurrentConfig.EspMinDistance then
        self:SetVisible(false)
        return
    else
        self:SetVisible(true)
    end
    
    -- Atualizar posição na tela
    local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPosition)
    
    if onScreen then
        -- Atualizar Nome
        if self.NameLabel then
            self.NameLabel.Position = UDim2.new(0, screenPoint.X - 100, 0, screenPoint.Y - 30)
            local displayText = self.Name.Container:find("%%s") and 
                self.Name.Container:gsub("%%s", self.Name.Name) or 
                self.Name.Container:gsub(" ", "") .. self.Name.Name .. self.Name.Container:gsub(" ", "")
            self.NameLabel.Text = displayText
        end
        
        -- Atualizar Distância
        if self.DistanceLabel then
            local distanceText = self.DistanceContainer:find("%%s") and
                self.DistanceContainer:gsub("%%s", math.floor(distance)) or
                self.DistanceContainer:gsub(" ", "") .. math.floor(distance) .. self.DistanceContainer:gsub(" ", "")
            self.DistanceLabel.Text = distanceText
            self.DistanceLabel.Position = UDim2.new(0, screenPoint.X - 100, 0, screenPoint.Y + 10)
        end
        
        -- Atualizar Tracer
        if self.Tracer then
            local origin = getTracerOrigin()
            local targetPoint = Vector2.new(screenPoint.X, screenPoint.Y)
            
            local distance2D = (targetPoint - origin).Magnitude
            local angle = math.atan2(targetPoint.Y - origin.Y, targetPoint.X - origin.X)
            
            self.Tracer.Size = UDim2.new(0, distance2D, 0, CurrentConfig.Tracer.Thickness)
            self.Tracer.Position = UDim2.new(0, origin.X, 0, origin.Y)
            self.Tracer.Rotation = math.deg(angle)
            self.Tracer.AnchorPoint = Vector2.new(0, 0.5)
        end
    else
        self:SetVisible(false)
    end
end

function ESPObject:SetVisible(visible)
    if self.NameLabel then self.NameLabel.Visible = visible end
    if self.DistanceLabel then self.DistanceLabel.Visible = visible end
    if self.Tracer then self.Tracer.Visible = visible end
    if self.Highlight then self.Highlight.Enabled = visible end
end

function ESPObject:StartUpdating()
    self.Connection = RunService.Heartbeat:Connect(function()
        self:UpdateElements()
    end)
end

function ESPObject:Destroy()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    
    if self.Highlight then self.Highlight:Destroy() end
    if self.NameLabel and self.NameLabel.Parent then self.NameLabel.Parent:Destroy() end
    if self.Tracer and self.Tracer.Parent then self.Tracer.Parent:Destroy() end
    
    -- Remover da lista
    for i, obj in ipairs(ESPObjects) do
        if obj == self then
            table.remove(ESPObjects, i)
            break
        end
    end
end

-- Funções principais da biblioteca
function KoltESP.Add(path, reference, config)
    local target = getObjectFromPath(path)
    if not target then
        warn("KoltESP: Não foi possível encontrar o objeto no caminho: " .. path)
        return nil
    end
    
    local espObject = ESPObject.new(target, reference, config)
    table.insert(ESPObjects, espObject)
    
    return espObject
end

function KoltESP.Remove(target)
    for i, obj in ipairs(ESPObjects) do
        if obj.Target == target or obj.Reference == target then
            obj:Destroy()
            break
        end
    end
end

function KoltESP.Clear()
    for _, obj in ipairs(ESPObjects) do
        obj:Destroy()
    end
    ESPObjects = {}
end

function KoltESP.Config(newConfig)
    for category, settings in pairs(newConfig) do
        if CurrentConfig[category] then
            for setting, value in pairs(settings) do
                CurrentConfig[category][setting] = value
            end
        else
            CurrentConfig[category] = settings
        end
    end
    
    -- Recriar elementos com nova configuração
    local tempObjects = {}
    for _, obj in ipairs(ESPObjects) do
        table.insert(tempObjects, {obj.Target, obj.Reference, obj.Config})
        obj:Destroy()
    end
    
    ESPObjects = {}
    for _, data in ipairs(tempObjects) do
        KoltESP.Add(data[1], data[2], data[3])
    end
end

function KoltESP.Unload()
    KoltESP.Clear()
    
    -- Limpar conexões globais
    for _, connection in pairs(Connections) do
        connection:Disconnect()
    end
    Connections = {}
    
    -- Limpar GUIs restantes
    for _, gui in pairs(game.CoreGui:GetChildren()) do
        if gui.Name:find("KoltESP_") or gui.Name:find("TracerGui_") then
            gui:Destroy()
        end
    end
    
    IsLoaded = false
    print("KoltESP: Biblioteca descarregada com sucesso!")
end

-- Inicialização
function KoltESP.Init()
    if IsLoaded then
        warn("KoltESP: Biblioteca já está carregada!")
        return
    end
    
    IsLoaded = true
    print("KoltESP: Biblioteca carregada com sucesso!")
    
    -- Cleanup automático quando player sai
    Connections.PlayerRemoving = game:GetService("Players").PlayerRemoving:Connect(function(player)
        if player == LocalPlayer then
            KoltESP.Unload()
        end
    end)
end

-- Auto-inicializar
KoltESP.Init()

-- Aliases para compatibilidade
_G.KoltESP = KoltESP
_G.Kolt = KoltESP

return KoltESP
