-- ==============================
-- KoltESP Library for Roblox ESP
-- Optimized, auto-remove invalid targets
-- Loadable via loadstring in executors like Delta
-- Supports Models, Parts, BaseParts, MeshParts
-- ==============================

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

-- Helper: get instance from path string
local function getInstanceFromPath(path)
    if typeof(path) == "Instance" then return path end
    local success, obj = pcall(function()
        return loadstring("return " .. path)()
    end)
    return success and obj or nil
end

-- Helper: get position from object
local function getPosition(obj)
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        if obj.PrimaryPart then
            return obj.PrimaryPart.Position
        else
            local part = obj:FindFirstChildWhichIsA("BasePart")
            if part then return part.Position end
        end
    end
    return nil
end

-- Update function for all ESPs
local function updateESP()
    if paused then return end

    rainbowHue = (rainbowHue + 0.005) % 1
    local screenCenter = Camera.ViewportSize / 2

    for ref, target in pairs(targets) do
        if target.paused then continue end

        local obj = getInstanceFromPath(target.path)
        if not obj or not obj.Parent then
            -- Remove invalid targets automatically
            KoltESP:Clear(ref)
            continue
        end

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

        -- Colors
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

-- Connect update
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
    if type(nameContainer) == "string" and #nameContainer == 2 then
        nameLeft = nameContainer:sub(1, 1)
        nameRight = nameContainer:sub(2, 2)
    else
        nameLeft = nameContainer
        nameRight = ""
    end

    local distLeft, distRight = "", ""
    if type(distContainer) == "string" and #distContainer == 2 then
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

    local esp = {
        Highlight = Instance.new("Highlight"),
        Tracer = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
    }

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
        esp = esp,
    }

    connectUpdate()
end

-- NewTarget
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

-- Clear
function KoltESP:Clear(ref)
    if ref then
        local target = targets[ref]
        if target then
            if target.esp.Highlight then target.esp.Highlight:Destroy() end
            if target.esp.Tracer then pcall(function() target.esp.Tracer:Remove() end) end
            if target.esp.Name then pcall(function() target.esp.Name:Remove() end) end
            if target.esp.Distance then pcall(function() target.esp.Distance:Remove() end) end
            targets[ref] = nil
        end
    else
        for ref2, _ in pairs(targets) do
            KoltESP:Clear(ref2)
        end
    end
end

-- Pause
function KoltESP:Pause(arg1, arg2)
    if arg2 ~= nil then
        local target = targets[arg1]
        if target then target.paused = arg2 end
    else
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
