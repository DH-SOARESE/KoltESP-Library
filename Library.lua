-- KoltESP Library for Roblox ESP
-- Author: OpenAI (adapted for your request)
-- Load via: loadstring(game:HttpGet("URL_DA_LIBRARY"))()

local KoltESP = {}
KoltESP.__index = KoltESP

-- ==============================
-- INTERNAL TABLES
-- ==============================
local Targets = {}       -- Stores each ESP target
local Paused = false     -- Global pause flag
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Default config
KoltESP.ConfigDistanceMax = 400
KoltESP.ConfigDistanceMin = 5

local DefaultTransparency = {
    Highlight = {Filled = 0.5, Outline = 0.3}
}

local DefaultComponentsVisibility = {
    Name      = true,
    Distance  = true,
    Tracer    = true,
    Highlight = {Filled = true, Outline = true}
}

-- ==============================
-- HELPERS
-- ==============================
local function createDrawing(type, props)
    local d = Drawing.new(type)
    for k,v in pairs(props or {}) do
        d[k] = v
    end
    return d
end

local function worldToViewport(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, (pos - Camera.CFrame.Position).Magnitude
end

-- ==============================
-- CREATE TARGET / ESP
-- ==============================
function KoltESP:Target(path, refESP, options)
    options = options or {}
    local target = {
        Path        = path,
        RefESP      = refESP,
        Options     = options,
        Drawings    = {},
        Paused      = false
    }

    -- Create default components
    if options.Name then
        target.Drawings.Name = createDrawing("Text", {
            Color = Color3.fromRGB(table.unpack(options.Color and options.Color.Name or {255,255,255})),
            Center = true,
            Outline = true,
            Size = 16,
            Visible = DefaultComponentsVisibility.Name
        })
    end
    if options.Distance then
        target.Drawings.Distance = createDrawing("Text", {
            Color = Color3.fromRGB(table.unpack(options.Color and options.Color.Distancia or {0,255,0})),
            Center = true,
            Outline = true,
            Size = 14,
            Visible = DefaultComponentsVisibility.Distance
        })
    end
    if options.Color and options.Color.Tracer then
        target.Drawings.Tracer = createDrawing("Line", {
            Color = Color3.fromRGB(table.unpack(options.Color.Tracer)),
            Thickness = 1,
            Visible = DefaultComponentsVisibility.Tracer
        })
    end
    if options.Color and options.Color.Highlight then
        target.Drawings.Highlight = Instance.new("Highlight")
        target.Drawings.Highlight.Adornee = path
        target.Drawings.Highlight.FillColor = Color3.fromRGB(table.unpack(options.Color.Highlight.Filled or {0,40,144}))
        target.Drawings.Highlight.OutlineColor = Color3.fromRGB(table.unpack(options.Color.Highlight.Outline or {255,255,255}))
        target.Drawings.Highlight.FillTransparency = DefaultTransparency.Highlight.Filled
        target.Drawings.Highlight.OutlineTransparency = DefaultTransparency.Highlight.Outline
        target.Drawings.Highlight.Enabled = DefaultComponentsVisibility.Highlight.Filled or DefaultComponentsVisibility.Highlight.Outline
        target.Drawings.Highlight.Parent = workspace
    end

    Targets[refESP] = target
    return target
end

-- ==============================
-- TARGET API
-- ==============================
function KoltESP:NewTarget(path, oldRef, newRef)
    Targets[newRef] = Targets[oldRef]
    Targets[oldRef] = nil
end

function KoltESP:Clear(refESP)
    local t = Targets[refESP]
    if t then
        for _, v in pairs(t.Drawings) do
            if typeof(v) == "Instance" then
                v:Destroy()
            else
                v:Remove()
            end
        end
        Targets[refESP] = nil
    end
end

function KoltESP:Pause(refESP, pause)
    if refESP then
        local t = Targets[refESP]
        if t then t.Paused = pause end
    else
        Paused = pause
    end
end

-- ==============================
-- CONFIG API
-- ==============================
function KoltESP:Config(component, settings)
    if component == "Highlight" then
        for _, t in pairs(Targets) do
            if t.Drawings.Highlight then
                if settings.Filled ~= nil then t.Drawings.Highlight.FillTransparency = settings.Filled end
                if settings.Outline ~= nil then t.Drawings.Highlight.OutlineTransparency = settings.Outline end
            end
        end
    else
        for _, t in pairs(Targets) do
            if t.Drawings[component] then
                t.Drawings[component].Visible = settings.Visible
            end
        end
    end
end

function KoltESP:ConfigTransparency(component, settings)
    if component == "Highlight" then
        DefaultTransparency.Highlight = settings
        for _, t in pairs(Targets) do
            if t.Drawings.Highlight then
                t.Drawings.Highlight.FillTransparency = settings.Filled
                t.Drawings.Highlight.OutlineTransparency = settings.Outline
            end
        end
    end
end

-- ==============================
-- UPDATE LOOP
-- ==============================
RunService.RenderStepped:Connect(function()
    if Paused then return end
    for _, t in pairs(Targets) do
        if t.Paused then continue end
        local obj = t.Path
        if obj and obj:IsA("BasePart") then
            local pos = obj.Position
            local screenPos, onScreen, dist = worldToViewport(pos)
            if onScreen and dist >= KoltESP.ConfigDistanceMin and dist <= KoltESP.ConfigDistanceMax then
                if t.Drawings.Name and t.Options.Name then
                    t.Drawings.Name.Position = screenPos + Vector2.new(0, -20)
                    t.Drawings.Name.Text = (t.Options.Name.Container or "")..obj.Name..(t.Options.Name.Container and "" or "")
                    t.Drawings.Name.Visible = true
                end
                if t.Drawings.Distance and t.Options.Distance then
                    t.Drawings.Distance.Position = screenPos + Vector2.new(0, 5)
                    t.Drawings.Distance.Text = (t.Options.Distance.Container or "")..math.floor(dist)..(t.Options.Distance.Suffix or "")
                    t.Drawings.Distance.Visible = true
                end
                if t.Drawings.Tracer then
                    t.Drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    t.Drawings.Tracer.To = screenPos
                    t.Drawings.Tracer.Visible = true
                end
                if t.Drawings.Highlight then
                    t.Drawings.Highlight.Enabled = true
                end
            else
                if t.Drawings.Name then t.Drawings.Name.Visible = false end
                if t.Drawings.Distance then t.Drawings.Distance.Visible = false end
                if t.Drawings.Tracer then t.Drawings.Tracer.Visible = false end
                if t.Drawings.Highlight then t.Drawings.Highlight.Enabled = false end
            end
        end
    end
end)

-- ==============================
-- UNLOAD / CLEAR ALL
-- ==============================
function KoltESP:Unload()
    for k,v in pairs(Targets) do
        self:Clear(k)
    end
end

function KoltESP:ClearAll()
    for k,_ in pairs(Targets) do
        self:Clear(k)
    end
end

return KoltESP
