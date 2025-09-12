-- KoltESP Library for Roblox ESP
-- Oriented to objects like Models, Parts, BaseParts, MeshParts
-- Loadable via loadstring in executors like Delta

local KoltESP = {}

-- Services
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Internal tables
local targets = {}
local globalConfig = {
    Components = {
        Name = {Visible = true},
        Distance = {Visible = true},
        Tracer = {Visible = true},
        Highlight = {Filled = true, Outline = true},
    },
    Transparency = {
        Highlight = {Filled = 0.5, Outline = 0.3},
    },
    RainbowMode = false,
}
local paused = false
local rainbowHue = 0
local updateConnection

-- Properties
KoltESP.ConfigDistanceMax = 400
KoltESP.ConfigDistanceMin = 5

-- Helper to get instance from path string (e.g., "workspace.banana")
local function getInstanceFromPath(path)
    local parts = string.split(path, ".")
    local current = _G
    for _, part in ipairs(parts) do
        current = current[part]
        if not current then return nil end
    end
    return current
end

-- Helper to get position from object
local function getPosition(obj)
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        local cframe = obj:GetBoundingBox()
        return cframe.Position
    end
    return nil
end

-- Update function for all ESPs
local function updateESP()
    if paused then return end

    rainbowHue = (rainbowHue + 0.005) % 1  -- Rainbow speed

    local screenCenter = Camera.ViewportSize / 2
    for ref, target in pairs(targets) do
        if target.paused then continue end

        local obj = getInstanceFromPath(target.path)
        if not obj then continue end

        local pos = getPosition(obj)
        if not pos then continue end

        local dist = (Camera.CFrame.Position - pos).Magnitude
        if dist > KoltESP.ConfigDistanceMax or dist < KoltESP.ConfigDistanceMin then
            target.esp.Tracer.Visible = false
            target.esp.Name.Visible = false
            target.esp.Distance.Visible = false
            target.esp.Highlight.Enabled = false
            continue
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
        if not onScreen then
            target.esp.Tracer.Visible = false
            target.esp.Name.Visible = false
            target.esp.Distance.Visible = false
            target.esp.Highlight.Enabled = globalConfig.Components.Highlight.Filled or globalConfig.Components.Highlight.Outline
            continue
        end

        -- Colors (apply rainbow if enabled)
        local colTracer = target.colors.Tracer
        local colName = target.colors.Name
        local colDistance = target.colors.Distance
        local colHlOutline = target.colors.HighlightOutline
        local colHlFill = target.colors.HighlightFill
        if globalConfig.RainbowMode then
            local rainbowCol = Color3.fromHSV(rainbowHue, 1, 1)
            colTracer = rainbowCol
            colName = rainbowCol
            colDistance = rainbowCol
            colHlOutline = rainbowCol
            colHlFill = rainbowCol
        end

        -- Update elements
        target.esp.Tracer.Color = colTracer
        target.esp.Tracer.From = Vector2.new(screenCenter.X, Camera.ViewportSize.Y)
        target.esp.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
        target.esp.Tracer.Visible = globalConfig.Components.Tracer.Visible

        target.esp.Name.Color = colName
        target.esp.Name.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
        target.esp.Name.Visible = globalConfig.Components.Name.Visible

        target.esp.Distance.Color = colDistance
        target.esp.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + 5)
        target.esp.Distance.Text = target.distLeft .. math.floor(dist) .. target.distSuffix .. target.distRight
        target.esp.Distance.Visible = globalConfig.Components.Distance.Visible

        local hl = target.esp.Highlight
        hl.FillColor = colHlFill
        hl.OutlineColor = colHlOutline
        hl.FillTransparency = globalConfig.Components.Highlight.Filled and globalConfig.Transparency.Highlight.Filled or 1
        hl.OutlineTransparency = globalConfig.Components.Highlight.Outline and globalConfig.Transparency.Highlight.Outline or 1
        hl.Enabled = (hl.FillTransparency < 1 or hl.OutlineTransparency < 1)
    end
end

-- Connect update if not already
local function connectUpdate()
    if not updateConnection then
        updateConnection = RunService.RenderStepped:Connect(updateESP)
    end
end

-- Target creation
function KoltESP:Target(path, ref, options)
    if targets[ref] then
        self:Clear(ref)
    end

    local obj = getInstanceFromPath(path)
    if not obj then return end

    local nameOpts = options.Name or {}
    local distOpts = options.Distance or {}
    local displayName = nameOpts.Name or obj.Name
    local nameContainer = nameOpts.Container or ""
    local distContainer = distOpts.Container or ""
    local distSuffix = distOpts.Suffix or ""

    local nameLeft, nameRight = "", ""
    if #nameContainer == 2 then
        nameLeft = nameContainer:sub(1, 1)
        nameRight = nameContainer:sub(2, 2)
    else
        nameLeft = nameContainer
        nameRight = ""
    end

    local distLeft, distRight = "", ""
    if #distContainer == 2 then
        distLeft = distContainer:sub(1, 1)
        distRight = distContainer:sub(2, 2)
    else
        distLeft = distContainer
        distRight = ""
    end

    local defaultCol = options.Default or {255, 255, 255}
    local colors = options.Color or {}
    local function getCol(comp, subcomp)
        if subcomp then
            return (colors[comp] and colors[comp][subcomp]) or defaultCol
        end
        return colors[comp] or defaultCol
    end

    targets[ref] = {
        path = path,
        obj = obj,
        displayName = displayName,
        nameLeft = nameLeft,
        nameRight = nameRight,
        distLeft = distLeft,
        distRight = distRight,
        distSuffix = distSuffix,
        colors = {
            Tracer = Color3.fromRGB(unpack(getCol("Tracer"))),
            Name = Color3.fromRGB(unpack(getCol("Name"))),
            Distance = Color3.fromRGB(unpack(getCol("Distancia") or getCol("Distance"))),
            HighlightOutline = Color3.fromRGB(unpack(getCol("Highlight", "Outline"))),
            HighlightFill = Color3.fromRGB(unpack(getCol("Highlight", "Filled"))),
        },
        paused = false,
        esp = {
            Highlight = Instance.new("Highlight"),
            Tracer = Drawing.new("Line"),
            Name = Drawing.new("Text"),
            Distance = Drawing.new("Text"),
        }
    }

    local esp = targets[ref].esp
    esp.Highlight.Adornee = obj
    esp.Highlight.Parent = game.CoreGui
    esp.Tracer.Thickness = 1
    esp.Name.Size = 16
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Distance.Size = 16
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Name.Text = nameLeft .. displayName .. nameRight

    connectUpdate()
end

-- NewTarget (change path and/or ref)
function KoltESP:NewTarget(path, oldRef, newRef)
    local target = targets[oldRef]
    if not target then return end

    local newObj = getInstanceFromPath(path)
    if newObj then
        target.path = path
        target.obj = newObj
        target.esp.Highlight.Adornee = newObj
    end

    targets[newRef] = target
    targets[oldRef] = nil
end

-- Clear specific or all
function KoltESP:Clear(ref)
    if ref then
        local target = targets[ref]
        if target then
            target.esp.Highlight:Destroy()
            target.esp.Tracer:Remove()
            target.esp.Name:Remove()
            target.esp.Distance:Remove()
            targets[ref] = nil
        end
    else
        for _, target in pairs(targets) do
            target.esp.Highlight:Destroy()
            target.esp.Tracer:Remove()
            target.esp.Name:Remove()
            target.esp.Distance:Remove()
        end
        targets = {}
    end
end

-- Pause specific or all
function KoltESP:Pause(arg1, arg2)
    if arg2 ~= nil then
        -- Specific
        local target = targets[arg1]
        if target then
            target.paused = arg2
        end
    else
        -- Global
        paused = arg1
    end
end

-- Config components
function KoltESP:Config(component, opts)
    local comp = globalConfig.Components[component]
    if comp then
        for key, value in pairs(opts) do
            comp[key] = value
        end
    end
end

-- Rainbow mode
function KoltESP:RainbowMode(enable)
    globalConfig.RainbowMode = enable
end

-- Config transparency
function KoltESP:ConfigTransparency(component, opts)
    local trans = globalConfig.Transparency[component]
    if trans then
        for key, value in pairs(opts) do
            trans[key] = value
        end
    end
end

-- Unload library
function KoltESP:Unload()
    self:Clear()
    if updateConnection then
        updateConnection:Disconnect()
        updateConnection = nil
    end
end

_G.KoltESP = KoltESP
return KoltESP
