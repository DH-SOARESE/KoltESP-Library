--[[
    KoltESP Library
    Uma biblioteca de ESP (Extra Sensory Perception) orientada a endereços de alvos no Roblox.
    
    Funcionalidades:
      - Tracer, Name, Distance, HighlightOutline, HighlightFill
      - Configuração individual por alvo ou global
      - Fácil integração via loadstring

    Versão: 1.0.0
    Autor: Kolt
]]

local KoltESP = {}
KoltESP.__index = KoltESP

-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Internal storage
local ESPObjects = {}
local ESPConnections = {}
local ESPConfig = {
    Tracer = {Visible = true, Origin = "Top", espessura = 1},
    Name = {Visible = true},
    Distance = {Visible = true},
    Highlight = {Outline = true, Filled = true, Transparency = {Outline = 0.3, Filled = 0.5}},
    DistanceMax = 300,
    DistanceMin = 5
}

local isPaused = false

-- Utility functions
local function getObjectFromPath(path)
    local current = game
    for part in string.gmatch(path, "[^%.]+") do
        if current and current:FindFirstChild(part) then
            current = current:FindFirstChild(part)
        else
            return nil
        end
    end
    return current
end

local function worldToScreen(position)
    local screenPoint, onScreen = Camera:WorldToScreenPoint(position)
    return Vector2.new(screenPoint.X, screenPoint.Y), onScreen
end

local function getDistance(obj)
    if not obj or not obj.Position then return 0 end
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return 0 end
    
    return math.floor((character.HumanoidRootPart.Position - obj.Position).Magnitude)
end

-- ESP Target Class
local ESPTarget = {}
ESPTarget.__index = ESPTarget

function ESPTarget.new(path, reference, config)
    local self = setmetatable({}, ESPTarget)
    
    self.path = path
    self.reference = reference
    self.object = getObjectFromPath(path)
    self.config = config or {}
    
    -- Default configurations
    self.EspColor = self.config.EspColor or {255, 255, 255}
    self.EspName = self.config.EspName or {DisplayName = "Object", Container = ""}
    self.EspDistance = self.config.EspDistance or {Container = "", Suffix = "m"}
    
    -- Color configurations
    local colors = self.config.Colors or {}
    self.EspNameColor = colors.EspNameColor or self.EspColor
    self.EspDistanceColor = colors.EspDistanceColor or self.EspColor
    self.EspHighlight = colors.EspHighlight or {Outline = self.EspColor, Filled = self.EspColor}
    self.EspTracerColor = colors.EspTracer or self.EspColor
    
    -- Drawing objects
    self.drawings = {}
    
    self:createDrawings()
    self:startUpdateLoop()
    
    return self
end

function ESPTarget:createDrawings()
    -- Tracer
    if ESPConfig.Tracer.Visible then
        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Color = Color3.fromRGB(unpack(self.EspTracerColor))
        tracer.Thickness = ESPConfig.Tracer.espessura
        tracer.Transparency = 1
        self.drawings.tracer = tracer
    end
    
    -- Name
    if ESPConfig.Name.Visible then
        local nameText = Drawing.new("Text")
        nameText.Visible = false
        nameText.Color = Color3.fromRGB(unpack(self.EspNameColor))
        nameText.Size = 16
        nameText.Center = true
        nameText.Outline = true
        nameText.OutlineColor = Color3.new(0, 0, 0)
        nameText.Font = 2
        self.drawings.name = nameText
    end
    
    -- Distance
    if ESPConfig.Distance.Visible then
        local distanceText = Drawing.new("Text")
        distanceText.Visible = false
        distanceText.Color = Color3.fromRGB(unpack(self.EspDistanceColor))
        distanceText.Size = 14
        distanceText.Center = true
        distanceText.Outline = true
        distanceText.OutlineColor = Color3.new(0, 0, 0)
        distanceText.Font = 2
        self.drawings.distance = distanceText
    end
    
    -- Highlight
    if ESPConfig.Highlight.Outline or ESPConfig.Highlight.Filled then
        if self.object then
            local highlight = Instance.new("Highlight")
            highlight.Parent = self.object
            highlight.Adornee = self.object
            
            if ESPConfig.Highlight.Outline then
                highlight.OutlineColor = Color3.fromRGB(unpack(self.EspHighlight.Outline))
                highlight.OutlineTransparency = ESPConfig.Highlight.Transparency.Outline
            else
                highlight.OutlineTransparency = 1
            end
            
            if ESPConfig.Highlight.Filled then
                highlight.FillColor = Color3.fromRGB(unpack(self.EspHighlight.Filled))
                highlight.FillTransparency = ESPConfig.Highlight.Transparency.Filled
            else
                highlight.FillTransparency = 1
            end
            
            self.drawings.highlight = highlight
        end
    end
end

function ESPTarget:update()
    if isPaused or not self.object or not self.object.Parent then
        self:setVisible(false)
        return
    end
    
    local distance = getDistance(self.object)
    
    -- Distance check
    if distance < ESPConfig.DistanceMin or distance > ESPConfig.DistanceMax then
        self:setVisible(false)
        return
    end
    
    local screenPos, onScreen = worldToScreen(self.object.Position)
    
    if not onScreen then
        self:setVisible(false)
        return
    end
    
    self:setVisible(true)
    
    -- Update tracer
    if self.drawings.tracer then
        local origin
        if ESPConfig.Tracer.Origin == "Top" then
            origin = Vector2.new(Camera.ViewportSize.X / 2, 0)
        elseif ESPConfig.Tracer.Origin == "Center" then
            origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        else -- Bottom
            origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        end
        
        self.drawings.tracer.From = origin
        self.drawings.tracer.To = screenPos
    end
    
    -- Update name
    if self.drawings.name then
        local displayName = self.EspName.DisplayName
        if self.EspName.Container and self.EspName.Container ~= "" then
            local containerValue = self.object:FindFirstChild(self.EspName.Container:gsub("[<>]", ""))
            if containerValue and containerValue.Value then
                displayName = tostring(containerValue.Value)
            end
        end
        
        self.drawings.name.Text = displayName
        self.drawings.name.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
    end
    
    -- Update distance
    if self.drawings.distance then
        local distanceStr = tostring(distance) .. self.EspDistance.Suffix
        if self.EspDistance.Container and self.EspDistance.Container ~= "" then
            distanceStr = self.EspDistance.Container:gsub("<int>", tostring(distance))
        end
        
        self.drawings.distance.Text = distanceStr
        local yOffset = self.drawings.name and 35 or 20
        self.drawings.distance.Position = Vector2.new(screenPos.X, screenPos.Y + yOffset)
    end
end

function ESPTarget:setVisible(visible)
    for _, drawing in pairs(self.drawings) do
        if drawing and drawing.Visible ~= nil then
            drawing.Visible = visible
        end
    end
end

function ESPTarget:startUpdateLoop()
    local connection = RunService.Heartbeat:Connect(function()
        self:update()
    end)
    
    ESPConnections[self] = connection
end

function ESPTarget:destroy()
    -- Disconnect update loop
    if ESPConnections[self] then
        ESPConnections[self]:Disconnect()
        ESPConnections[self] = nil
    end
    
    -- Remove drawings
    for _, drawing in pairs(self.drawings) do
        if drawing then
            if drawing.Destroy then
                drawing:Destroy()
            elseif drawing.Remove then
                drawing:Remove()
            end
        end
    end
    
    self.drawings = {}
end

-- Main KoltESP functions
function KoltESP:Add(path, reference, config)
    local target = ESPTarget.new(path, reference, config)
    ESPObjects[reference] = target
    return target
end

function KoltESP:Remove(reference)
    if ESPObjects[reference] then
        ESPObjects[reference]:destroy()
        ESPObjects[reference] = nil
    end
end

function KoltESP:Clear()
    for reference, target in pairs(ESPObjects) do
        target:destroy()
    end
    ESPObjects = {}
end

function KoltESP:Unload()
    self:Clear()
    
    -- Disconnect all connections
    for _, connection in pairs(ESPConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    ESPConnections = {}
end

function KoltESP:Pause(state)
    isPaused = state
    
    if isPaused then
        for _, target in pairs(ESPObjects) do
            target:setVisible(false)
        end
    end
end

-- Configuration function
function KoltESP:Config(config)
    for key, value in pairs(config) do
        if key == "Tracer" then
            ESPConfig.Tracer = value
        elseif key == "Name" then
            ESPConfig.Name = value
        elseif key == "Distance" then
            ESPConfig.Distance = value
        elseif key == "Highlight" then
            ESPConfig.Highlight = value
        elseif key == "DistanceMax" then
            ESPConfig.DistanceMax = value
        elseif key == "DistanceMin" then
            ESPConfig.DistanceMin = value
        end
    end
    
    -- Recreate all ESP objects with new config
    local tempObjects = {}
    for reference, target in pairs(ESPObjects) do
        tempObjects[reference] = {
            path = target.path,
            config = target.config
        }
        target:destroy()
    end
    
    ESPObjects = {}
    
    for reference, data in pairs(tempObjects) do
        self:Add(data.path, reference, data.config)
    end
end

-- Return the library
return KoltESP
