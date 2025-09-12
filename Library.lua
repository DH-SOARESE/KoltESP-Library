-- ==============================
-- KoltESP Library v1.0
-- Advanced ESP System for Roblox
-- ==============================

local KoltESP = {}
KoltESP.__index = KoltESP

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- Variáveis principais
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local ESPTargets = {}
local ESPConnections = {}
local ESPSettings = {
    Name = {Visible = true},
    Distance = {Visible = true},
    Tracer = {Visible = true},
    Highlight = {Filled = true, Outline = true}
}

-- Configurações globais
KoltESP.ConfigDistanceMax = 400
KoltESP.ConfigDistanceMin = 5
local RainbowModeEnabled = false
local GlobalPaused = false

-- Funções utilitárias
local function parseObjectPath(path)
    local current = game
    for segment in string.gmatch(path, "[^%.]+") do
        if current:FindFirstChild(segment) then
            current = current[segment]
        else
            return nil
        end
    end
    return current
end

local function getObjectPosition(obj)
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") and obj.PrimaryPart then
        return obj.PrimaryPart.Position
    elseif obj:IsA("Model") then
        local humanoidRootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso")
        if humanoidRootPart then
            return humanoidRootPart.Position
        end
    end
    return obj:IsA("Instance") and obj.Position or Vector3.new(0, 0, 0)
end

local function createESPElements()
    local elements = {}
    
    -- ScreenGui principal
    elements.ScreenGui = Instance.new("ScreenGui")
    elements.ScreenGui.Name = "KoltESP_" .. math.random(1000, 9999)
    elements.ScreenGui.ResetOnSpawn = false
    elements.ScreenGui.Parent = LocalPlayer.PlayerGui
    
    -- Nome
    elements.NameLabel = Instance.new("TextLabel")
    elements.NameLabel.Name = "NameLabel"
    elements.NameLabel.BackgroundTransparency = 1
    elements.NameLabel.Size = UDim2.new(0, 200, 0, 20)
    elements.NameLabel.Font = Enum.Font.SourceSansBold
    elements.NameLabel.TextSize = 16
    elements.NameLabel.TextStrokeTransparency = 0
    elements.NameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    elements.NameLabel.Parent = elements.ScreenGui
    
    -- Distância
    elements.DistanceLabel = Instance.new("TextLabel")
    elements.DistanceLabel.Name = "DistanceLabel"
    elements.DistanceLabel.BackgroundTransparency = 1
    elements.DistanceLabel.Size = UDim2.new(0, 200, 0, 20)
    elements.DistanceLabel.Font = Enum.Font.SourceSans
    elements.DistanceLabel.TextSize = 14
    elements.DistanceLabel.TextStrokeTransparency = 0
    elements.DistanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    elements.DistanceLabel.Parent = elements.ScreenGui
    
    -- Tracer (linha)
    elements.TracerFrame = Instance.new("Frame")
    elements.TracerFrame.Name = "TracerFrame"
    elements.TracerFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    elements.TracerFrame.BorderSizePixel = 0
    elements.TracerFrame.Parent = elements.ScreenGui
    
    return elements
end

local function getRainbowColor()
    local time = tick() * 2
    return Color3.fromHSV((time % 5) / 5, 1, 1)
end

local function updateESPVisibility(espData)
    if GlobalPaused or espData.Paused then
        espData.Elements.NameLabel.Visible = false
        espData.Elements.DistanceLabel.Visible = false
        espData.Elements.TracerFrame.Visible = false
        if espData.Highlight then
            espData.Highlight.Enabled = false
        end
        return
    end
    
    local obj = espData.Object
    if not obj or not obj.Parent then
        return
    end
    
    local objPos = getObjectPosition(obj)
    local distance = (objPos - Camera.CFrame.Position).Magnitude
    
    -- Verificar limites de distância
    if distance > KoltESP.ConfigDistanceMax or distance < KoltESP.ConfigDistanceMin then
        espData.Elements.NameLabel.Visible = false
        espData.Elements.DistanceLabel.Visible = false
        espData.Elements.TracerFrame.Visible = false
        if espData.Highlight then
            espData.Highlight.Enabled = false
        end
        return
    end
    
    -- Converter posição 3D para 2D
    local screenPos, onScreen = Camera:WorldToScreenPoint(objPos)
    
    if onScreen then
        -- Cores rainbow ou normais
        local nameColor = RainbowModeEnabled and getRainbowColor() or espData.Config.Color.Name
        local distanceColor = RainbowModeEnabled and getRainbowColor() or espData.Config.Color.Distancia
        local tracerColor = RainbowModeEnabled and getRainbowColor() or espData.Config.Color.Tracer
        
        -- Atualizar nome
        if ESPSettings.Name.Visible then
            local nameContainer = espData.Config.Name.Container or ""
            local nameText = espData.Config.Name.Name or obj.Name
            local leftContainer, rightContainer = nameContainer:sub(1, #nameContainer/2), nameContainer:sub(#nameContainer/2 + 1)
            
            espData.Elements.NameLabel.Text = leftContainer .. nameText .. rightContainer
            espData.Elements.NameLabel.TextColor3 = nameColor
            espData.Elements.NameLabel.Position = UDim2.new(0, screenPos.X - 100, 0, screenPos.Y - 40)
            espData.Elements.NameLabel.Visible = true
        else
            espData.Elements.NameLabel.Visible = false
        end
        
        -- Atualizar distância
        if ESPSettings.Distance.Visible then
            local distanceContainer = espData.Config.Distance.Container or ""
            local distanceSuffix = espData.Config.Distance.Suffix or "m"
            local leftContainer, rightContainer = distanceContainer:sub(1, #distanceContainer/2), distanceContainer:sub(#distanceContainer/2 + 1)
            
            espData.Elements.DistanceLabel.Text = leftContainer .. math.floor(distance) .. distanceSuffix .. rightContainer
            espData.Elements.DistanceLabel.TextColor3 = distanceColor
            espData.Elements.DistanceLabel.Position = UDim2.new(0, screenPos.X - 100, 0, screenPos.Y - 20)
            espData.Elements.DistanceLabel.Visible = true
        else
            espData.Elements.DistanceLabel.Visible = false
        end
        
        -- Atualizar tracer
        if ESPSettings.Tracer.Visible then
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            local targetPos = Vector2.new(screenPos.X, screenPos.Y)
            
            local direction = (targetPos - screenCenter)
            local distance2D = direction.Magnitude
            local angle = math.atan2(direction.Y, direction.X)
            
            espData.Elements.TracerFrame.Size = UDim2.new(0, distance2D, 0, 2)
            espData.Elements.TracerFrame.Position = UDim2.new(0, screenCenter.X, 0, screenCenter.Y)
            espData.Elements.TracerFrame.Rotation = math.deg(angle)
            espData.Elements.TracerFrame.BackgroundColor3 = tracerColor
            espData.Elements.TracerFrame.Visible = true
        else
            espData.Elements.TracerFrame.Visible = false
        end
        
        -- Atualizar highlight
        if espData.Highlight and ESPSettings.Highlight.Filled and ESPSettings.Highlight.Outline then
            local highlightColor = RainbowModeEnabled and getRainbowColor() or espData.Config.Color.Highlight
            espData.Highlight.FillColor = highlightColor.Filled
            espData.Highlight.OutlineColor = highlightColor.Outline
            espData.Highlight.Enabled = true
        elseif espData.Highlight then
            espData.Highlight.Enabled = false
        end
    else
        espData.Elements.NameLabel.Visible = false
        espData.Elements.DistanceLabel.Visible = false
        espData.Elements.TracerFrame.Visible = false
        if espData.Highlight then
            espData.Highlight.Enabled = false
        end
    end
end

-- Função principal: Target
function KoltESP:Target(path, espId, config)
    local obj = parseObjectPath(path)
    if not obj then
        warn("KoltESP: Objeto não encontrado no caminho: " .. path)
        return
    end
    
    -- Remover ESP existente se houver
    if ESPTargets[espId] then
        self:Clear(espId)
    end
    
    -- Configurações padrão
    local defaultConfig = {
        Default = {255, 255, 255},
        Name = {Name = obj.Name, Container = ""},
        Distance = {Container = "", Suffix = "m"},
        Color = {
            Tracer = config.Default or {255, 255, 255},
            Name = config.Default or {255, 255, 255},
            Distancia = config.Default or {255, 255, 255},
            Highlight = {
                Outline = config.Default or {255, 255, 255},
                Filled = config.Default or {255, 255, 255}
            }
        }
    }
    
    -- Mesclar configurações
    for key, value in pairs(config) do
        if key == "Color" then
            for colorKey, colorValue in pairs(value) do
                if colorKey == "Highlight" then
                    for highlightKey, highlightValue in pairs(colorValue) do
                        defaultConfig.Color.Highlight[highlightKey] = Color3.fromRGB(highlightValue[1], highlightValue[2], highlightValue[3])
                    end
                else
                    defaultConfig.Color[colorKey] = Color3.fromRGB(colorValue[1], colorValue[2], colorValue[3])
                end
            end
        else
            defaultConfig[key] = value
        end
    end
    
    -- Criar elementos ESP
    local elements = createESPElements()
    
    -- Criar highlight se o objeto suportar
    local highlight = nil
    if obj:IsA("BasePart") or obj:IsA("Model") then
        highlight = Instance.new("Highlight")
        highlight.Parent = obj
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0.3
    end
    
    -- Armazenar dados da ESP
    ESPTargets[espId] = {
        Object = obj,
        Config = defaultConfig,
        Elements = elements,
        Highlight = highlight,
        Paused = false
    }
    
    -- Conectar loop de atualização
    ESPConnections[espId] = RunService.Heartbeat:Connect(function()
        updateESPVisibility(ESPTargets[espId])
    end)
end

-- Função: NewTarget (renomear ESP)
function KoltESP:NewTarget(path, oldEspId, newEspId)
    if not ESPTargets[oldEspId] then
        warn("KoltESP: ESP com ID '" .. oldEspId .. "' não encontrada")
        return
    end
    
    local obj = parseObjectPath(path)
    if not obj then
        warn("KoltESP: Objeto não encontrado no caminho: " .. path)
        return
    end
    
    -- Copiar configuração existente
    local oldESP = ESPTargets[oldEspId]
    ESPTargets[newEspId] = {
        Object = obj,
        Config = oldESP.Config,
        Elements = oldESP.Elements,
        Highlight = oldESP.Highlight,
        Paused = oldESP.Paused
    }
    
    -- Transferir conexão
    ESPConnections[newEspId] = ESPConnections[oldEspId]
    ESPConnections[oldEspId] = nil
    ESPTargets[oldEspId] = nil
end

-- Função: Clear (limpar ESP específica ou todas)
function KoltESP:Clear(espId)
    if espId then
        -- Limpar ESP específica
        if ESPTargets[espId] then
            if ESPConnections[espId] then
                ESPConnections[espId]:Disconnect()
                ESPConnections[espId] = nil
            end
            
            if ESPTargets[espId].Elements.ScreenGui then
                ESPTargets[espId].Elements.ScreenGui:Destroy()
            end
            
            if ESPTargets[espId].Highlight then
                ESPTargets[espId].Highlight:Destroy()
            end
            
            ESPTargets[espId] = nil
        end
    else
        -- Limpar todas as ESPs
        for id in pairs(ESPTargets) do
            self:Clear(id)
        end
    end
end

-- Função: Pause (pausar ESP específica ou todas)
function KoltESP:Pause(espIdOrGlobal, state)
    if type(espIdOrGlobal) == "string" then
        -- Pausar ESP específica
        if ESPTargets[espIdOrGlobal] then
            ESPTargets[espIdOrGlobal].Paused = state
        end
    elseif type(espIdOrGlobal) == "boolean" then
        -- Pausar globalmente
        GlobalPaused = espIdOrGlobal
    end
end

-- Função: Config (configurar componentes)
function KoltESP:Config(component, settings)
    if ESPSettings[component] then
        for key, value in pairs(settings) do
            ESPSettings[component][key] = value
        end
    end
end

-- Função: RainbowMode
function KoltESP:RainbowMode(enabled)
    RainbowModeEnabled = enabled
end

-- Função: ConfigTransparency
function KoltESP:ConfigTransparency(component, settings)
    if component == "Highlight" then
        for _, espData in pairs(ESPTargets) do
            if espData.Highlight then
                if settings.Filled then
                    espData.Highlight.FillTransparency = settings.Filled
                end
                if settings.Outline then
                    espData.Highlight.OutlineTransparency = settings.Outline
                end
            end
        end
    end
end

-- Função: Unload (descarregar library)
function KoltESP:Unload()
    self:Clear() -- Limpar todas as ESPs
    
    -- Limpar todas as conexões restantes
    for _, connection in pairs(ESPConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    ESPTargets = {}
    ESPConnections = {}
    
    -- Resetar configurações
    ESPSettings = {
        Name = {Visible = true},
        Distance = {Visible = true},
        Tracer = {Visible = true},
        Highlight = {Filled = true, Outline = true}
    }
    
    RainbowModeEnabled = false
    GlobalPaused = false
end

return KoltESP
