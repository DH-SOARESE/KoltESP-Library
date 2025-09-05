-- KoltESP Library
-- Github ready, loadable via loadstring

local KoltESP = {}
KoltESP.__index = KoltESP

-- ===== Configurações Globais =====
KoltESP.Settings = {
    TracerOrigin = "Top", -- Top, Center, Bottom
    HighlightOutlineOpacity = 0.5,
    HighlightFillOpacity = 0.5,
    TracerVisible = true,
    NameVisible = true,
    DistanceVisible = true,
    HighlightOutlineVisible = true,
    HighlightFillVisible = true,
    RainbowMode = false
}

-- Armazena os targets e ESPs
KoltESP.Targets = {}

-- ===== Função para criar ESP para um alvo =====
function KoltESP:NewTarget(target)
    if not target then return end
    local t = {
        Object = target,
        ESPs = {}
    }
    table.insert(self.Targets, t)
    return t
end

-- ===== Adiciona ESP a um alvo =====
function KoltESP:AddESP(target, data)
    if not target or not data.type then return end
    local t = target
    local espType = data.type
    t.ESPs[espType] = data
end

-- ===== Configurações Individuais ou Globais =====
function KoltESP:SetESP(data)
    local espType = data.type
    if not espType then return end
    for _, t in ipairs(self.Targets) do
        if t.ESPs[espType] then
            for k,v in pairs(data) do
                if k ~= "type" then
                    t.ESPs[espType][k] = v
                end
            end
        end
    end
    -- Atualiza global se não for target específico
    for k,v in pairs(data) do
        if k ~= "type" then
            local key = k
            if key == "Origin" then self.Settings.TracerOrigin = v end
            if key == "Visible" then
                if espType == "Tracer" then self.Settings.TracerVisible = v end
                if espType == "Name" then self.Settings.NameVisible = v end
                if espType == "Distance" then self.Settings.DistanceVisible = v end
                if espType == "HighlightOutline" then self.Settings.HighlightOutlineVisible = v end
                if espType == "HighlightFill" then self.Settings.HighlightFillVisible = v end
            end
            if key == "Opacity" then
                if espType == "HighlightOutline" then self.Settings.HighlightOutlineOpacity = v end
                if espType == "HighlightFill" then self.Settings.HighlightFillOpacity = v end
            end
            if key == "RainbowMode" then self.Settings.RainbowMode = v end
        end
    end
end

-- ===== Remove um target =====
function KoltESP:RemoveTarget(target)
    for i, t in ipairs(self.Targets) do
        if t.Object == target then
            table.remove(self.Targets, i)
            break
        end
    end
end

-- ===== Unload todos ESPs =====
function KoltESP:Unload()
    for i, t in ipairs(self.Targets) do
        t.ESPs = {}
    end
    self.Targets = {}
end

-- ===== Render loop =====
spawn(function()
    local RunService = game:GetService("RunService")
    RunService.RenderStepped:Connect(function()
        for _, t in ipairs(KoltESP.Targets) do
            if not t.Object then continue end
            local position
            if t.Object:IsA("BasePart") then
                position = t.Object.Position
            elseif t.Object:IsA("Model") and t.Object.PrimaryPart then
                position = t.Object.PrimaryPart.Position
            end

            for espType, esp in pairs(t.ESPs) do
                if espType == "Tracer" and KoltESP.Settings.TracerVisible then
                    -- Aqui você pode adicionar seu desenho de linha (tracer)
                elseif espType == "Name" and KoltESP.Settings.NameVisible then
                    -- Adicionar BillboardGui ou TextLabel
                elseif espType == "Distance" and KoltESP.Settings.DistanceVisible then
                    -- Calcula distância e exibe
                elseif espType == "HighlightOutline" and KoltESP.Settings.HighlightOutlineVisible then
                    -- Highlight Outline
                elseif espType == "HighlightFill" and KoltESP.Settings.HighlightFillVisible then
                    -- Highlight Fill
                end
            end
        end
    end)
end)

return KoltESP
