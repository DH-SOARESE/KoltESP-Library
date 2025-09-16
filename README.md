# 📦 Kolt ESP Library V1.5
### 👤 Autor: Kolt | 🎨 Estilo: Minimalista, eficiente e responsivo

Biblioteca completa de ESP (Extra Sensory Perception) para Roblox com Arrow ESP 360° corrigido e otimizado.

## 🚀 Instalação Rápida

```lua
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()
```

## 📋 Índice

- [🎯 Recursos Principais](#-recursos-principais)
- [🔥 Novidades V1.5](#-novidades-v15)
- [⚡ Início Rápido](#-início-rápido)
- [🔧 Configurações Globais](#-configurações-globais)
- [🎨 Personalização de Cores](#-personalização-de-cores)
- [🏹 Arrow ESP (Melhorado)](#-arrow-esp-melhorado)
- [👤 ESP para Players](#-esp-para-players)
- [📦 ESP para Objetos](#-esp-para-objetos)
- [🎛️ APIs Avançadas](#️-apis-avançadas)
- [📚 Exemplos Completos](#-exemplos-completos)
- [⚙️ Troubleshooting](#️-troubleshooting)

## 🎯 Recursos Principais

- ✨ **Arrow ESP 360°** - Setas indicativas funcionam em todas as direções
- 🔄 **Detecção Atrás da Câmera** - Arrows aparecem mesmo quando olhando para direção oposta
- 🎨 **Rainbow Mode** - Cores arco-íris animadas
- 🔍 **Highlight System** - Destaque visual através de paredes
- 📏 **Distance Control** - Controle de distância mínima/máxima
- 🎯 **Tracer Lines** - Linhas indicativas personalizáveis
- 👁️ **Name & Distance** - Exibição de nome e distância
- 🎭 **Collision Detection** - Torna objetos invisíveis visíveis
- 🔄 **Auto Remove** - Remove automaticamente objetos inválidos
- 🎪 **FOV Margin** - Margem configurável para campo de visão

## 🔥 Novidades V1.5

### 🛠️ **Correções Críticas:**
- **Arrow ESP Corrigida:** Agora funciona perfeitamente quando o player olha para direção oposta do alvo
- **Detecção 360°:** Sistema melhorado detecta objetos em todas as direções usando produto escalar
- **Cálculo de Direção:** Arrow aponta corretamente mesmo para objetos atrás da câmera

### ⚡ **Novas Funcionalidades:**
- **FOV Margin:** Margem configurável para determinar quando objeto está "fora de vista"
- **Campo de Visão Inteligente:** Detecta automaticamente objetos fora do campo de visão
- **Performance Otimizada:** Melhor gerenciamento de recursos e cálculos

### 🔧 **APIs Novas:**
```lua
ESP:SetFOVMargin(margin)  -- Configura margem do campo de visão
```

## ⚡ Início Rápido

### Carregamento Básico
```lua
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- ESP simples em todos os players
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer and player.Character then
        ESP:Add(player.Character)
    end
end

-- ESP em um objeto específico
ESP:Add(workspace.Part, {Name = "Parte Importante"})
```

### Controles Básicos
```lua
ESP.Enabled = true          -- Liga/desliga toda ESP
ESP:SetArrowEnabled(true)   -- Liga/desliga Arrow ESP
ESP:SetGlobalRainbow(true)  -- Liga modo arco-íris
ESP:SetFOVMargin(15)        -- Define margem do campo de visão
```

## 🔧 Configurações Globais

### Configurações Principais
```lua
ESP.GlobalSettings = {
    TracerOrigin = "Bottom",      -- "Top", "Center", "Bottom", "Left", "Right"
    ShowTracer = true,            -- Mostrar linhas tracer
    ShowHighlightFill = true,     -- Mostrar preenchimento do highlight
    ShowHighlightOutline = true,  -- Mostrar contorno do highlight
    ShowName = true,              -- Mostrar nome do objeto
    ShowDistance = true,          -- Mostrar distância
    RainbowMode = false,          -- Modo arco-íris
    MaxDistance = math.huge,      -- Distância máxima
    MinDistance = 0,              -- Distância mínima
    Opacity = 0.8,                -- Opacidade geral (0-1)
    LineThickness = 1.5,          -- Espessura das linhas
    FontSize = 14,                -- Tamanho da fonte
    AutoRemoveInvalid = true      -- Remove automaticamente objetos inválidos
}

-- Nova configuração V1.5
ESP.FOVMargin = 10  -- Margem para considerar objeto "fora de vista"
```

### APIs de Configuração Global
```lua
-- Configurar origem do tracer
ESP:SetGlobalTracerOrigin("Center")

-- Configurar tipos de ESP
ESP:SetGlobalESPType("ShowTracer", false)
ESP:SetGlobalESPType("ShowName", true)

-- Configurações visuais
ESP:SetGlobalRainbow(true)
ESP:SetGlobalOpacity(0.7)
ESP:SetGlobalFontSize(16)
ESP:SetGlobalLineThickness(2)

-- Nova API V1.5 - Margem do campo de visão
ESP:SetFOVMargin(20)  -- Pixels de margem para detectar "fora da tela"
```

## 🎨 Personalização de Cores

### Cor Única para Tudo
```lua
ESP:Add(target, {
    Color = Color3.fromRGB(255, 0, 0) -- Vermelho para tudo
})
```

### Cores Específicas por Elemento
```lua
ESP:Add(target, {
    Color = {
        Name = {0, 255, 0},        -- Verde para nome
        Distance = {255, 255, 0},   -- Amarelo para distância
        Tracer = {0, 0, 255},      -- Azul para tracer
        Highlight = {
            Filled = {255, 0, 255}, -- Magenta para preenchimento
            Outline = {255, 255, 255} -- Branco para contorno
        }
    }
})
```

### Tema Global
```lua
ESP.Theme = {
    PrimaryColor = Color3.fromRGB(130, 200, 255),   -- Cor primária
    SecondaryColor = Color3.fromRGB(255, 255, 255), -- Cor secundária
    OutlineColor = Color3.fromRGB(0, 0, 0)          -- Cor do contorno
}
```

## 🏹 Arrow ESP (Melhorado)

### 🔥 **Sistema Completamente Reformulado V1.5**

O Arrow ESP agora funciona perfeitamente em todas as situações:

- ✅ **Objetos atrás da câmera** - Arrow aponta corretamente
- ✅ **Objetos fora da tela** - Detecta precisamente objetos fora do campo de visão
- ✅ **Objetos muito próximos** - Lida com objetos com Z ≤ 0
- ✅ **Campo de visão inteligente** - Margem configurável para detecção

### Configuração Básica
```lua
ESP:SetArrowEnabled(true)           -- Liga Arrow ESP
ESP:SetArrowUseDrawing(true)        -- Usa Drawing API (melhor performance)
ESP:SetArrowRadius(150)             -- Raio das setas (distância do centro)
ESP:SetFOVMargin(10)                -- Margem para detectar "fora da tela"
```

### Personalizar Design das Setas
```lua
-- Para setas GUI (imagem)
GlobalArrowDesign.Gui = {
    image = "rbxassetid://11552476728",
    Color = {255, 0, 0},
    Opacity = 0.3,
    Size = {w = 30, h = 30},
    DisplayOrder = 18,
    RotationOffset = 90
}

-- Para setas Drawing (linhas) - Recomendado para performance
GlobalArrowDesign.Drawing = {
    Color = {255, 0, 0},
    OutlineColor = {0, 0, 0},
    Opacity = 0.3,
    Size = {w = 30, h = 30},
    OutlineThickness = 6,
    LineThickness = 3
}
```

### Como Funciona o Arrow ESP V1.5

```lua
-- O sistema agora detecta automaticamente:

-- 1. Objetos atrás da câmera (usando produto escalar)
if isBehindCamera(objectPosition) then
    -- Mostra arrow apontando na direção correta
end

-- 2. Objetos fora da tela (com margem configurável)
if not isInViewport(screenPos, viewportSize, FOVMargin) then
    -- Mostra arrow na borda da tela
end

-- 3. Objetos muito próximos (Z ≤ 0)
if screenPos.Z <= 0 then
    -- Mostra arrow para objetos muito próximos
end
```

## 👤 ESP para Players

### ESP Básica em Players
```lua
-- ESP simples em todos os players
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer and player.Character then
        ESP:Add(player.Character, {
            Name = player.Name,
            Color = Color3.fromRGB(255, 100, 100)
        })
    end
end
```

### ESP Avançada com Status e Arrow
```lua
-- ESP completa com Arrow para players
local function addPlayerESP(player)
    if not player.Character then return end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local health = humanoid and humanoid.Health or 0
    local maxHealth = humanoid and humanoid.MaxHealth or 100
    
    ESP:Add(player.Character, {
        Name = "👤 " .. player.Name,
        NameContainer = {Start = "[", End = "]"},
        DistanceSuffix = "m",
        DistanceContainer = {Start = "(", End = ")"},
        Color = health > 50 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    })
end

-- Configurar Arrow ESP
ESP:SetArrowEnabled(true)
ESP:SetArrowRadius(120)
ESP:SetFOVMargin(15)

-- Aplicar em todos os players
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
        addPlayerESP(player)
    end
end
```

### Auto-Update para Novos Players
```lua
-- Detectar novos players automaticamente
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        wait(1) -- Aguardar character carregar
        ESP:Add(character, {
            Name = "🆕 " .. player.Name,
            Color = Color3.fromRGB(0, 150, 255)
        })
    end)
end)

-- Remover players que saíram
game.Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        ESP:Remove(player.Character)
    end
end)
```

## 📦 ESP para Objetos

### ESP em Objetos Específicos
```lua
-- ESP em uma parte específica
ESP:Add(workspace.ImportantPart, {
    Name = "🎯 Item Importante",
    Color = Color3.fromRGB(255, 215, 0), -- Dourado
    DistanceSuffix = "m"
})

-- ESP em um modelo completo
ESP:Add(workspace.Treasure, {
    Name = "💰 Tesouro",
    Color = Color3.fromRGB(255, 0, 255),
    Collision = true -- Torna partes invisíveis visíveis
})
```

### ESP com Categorização
```lua
-- Sistema de categorias para diferentes tipos de objetos
local itemCategories = {
    Weapons = {
        color = Color3.fromRGB(255, 100, 100),
        icon = "🔫",
        suffix = " (Arma)"
    },
    Health = {
        color = Color3.fromRGB(0, 255, 100),
        icon = "❤️",
        suffix = " (Vida)"
    },
    Ammo = {
        color = Color3.fromRGB(255, 255, 0),
        icon = "📦",
        suffix = " (Munição)"
    }
}

-- Função para adicionar ESP baseada em categoria
local function addCategorizedESP(obj, category)
    local config = itemCategories[category]
    if config then
        ESP:Add(obj, {
            Name = config.icon .. " " .. obj.Name .. config.suffix,
            Color = config.color,
            DistanceSuffix = "m",
            Collision = true
        })
    end
end

-- Aplicar ESP baseada no nome do objeto
for _, obj in pairs(workspace:GetChildren()) do
    if obj.Name:find("Weapon") then
        addCategorizedESP(obj, "Weapons")
    elseif obj.Name:find("Health") then
        addCategorizedESP(obj, "Health")
    elseif obj.Name:find("Ammo") then
        addCategorizedESP(obj, "Ammo")
    end
end
```

## 🎛️ APIs Avançadas

### Gerenciamento de ESP
```lua
-- Adicionar ESP
ESP:Add(target, config)

-- Remover ESP específica
ESP:Remove(target)

-- Limpar todas as ESPs
ESP:Clear()

-- Atualizar configurações globais
ESP:UpdateGlobalSettings()
```

### Controle de Visibilidade
```lua
-- Liga/desliga sistema inteiro
ESP.Enabled = false

-- Liga/desliga elementos específicos
ESP:SetGlobalESPType("ShowTracer", false)
ESP:SetGlobalESPType("ShowHighlightFill", true)
ESP:SetGlobalESPType("ShowName", true)
ESP:SetGlobalESPType("ShowDistance", false)
```

### Arrow ESP Avançado V1.5
```lua
-- Alternar entre Drawing e GUI
ESP:SetArrowUseDrawing(true)  -- ✅ Melhor performance (Recomendado)
ESP:SetArrowUseDrawing(false) -- Mais customizável (imagens)

-- Ajustar raio das setas
ESP:SetArrowRadius(200) -- Setas mais longe do centro

-- 🆕 Nova API V1.5 - Margem do campo de visão
ESP:SetFOVMargin(25) -- Maior margem = arrow aparece mais cedo

-- Verificar status do Arrow ESP
print("Arrow ESP:", ESP.ArrowEnabled)
print("Using Drawing:", ESP.UseDrawingArrow)
print("Arrow Radius:", ESP.ArrowRadius)
print("FOV Margin:", ESP.FOVMargin)
```

## 📚 Exemplos Completos

### Sistema de ESP Completo V1.5
```lua
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- 🔧 Configurações iniciais otimizadas
ESP.Enabled = true
ESP:SetArrowEnabled(true)
ESP:SetArrowUseDrawing(true)  -- Melhor performance
ESP:SetArrowRadius(130)
ESP:SetFOVMargin(15)          -- Nova configuração V1.5
ESP:SetGlobalRainbow(false)
ESP:SetGlobalOpacity(0.85)
ESP:SetGlobalLineThickness(1.8)

-- 🎨 Configurar tema personalizado
ESP.Theme.PrimaryColor = Color3.fromRGB(100, 200, 255)
ESP.Theme.SecondaryColor = Color3.fromRGB(255, 255, 255)

-- 👤 ESP para players com status avançado
local function addAdvancedPlayerESP(player)
    if not player.Character then return end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local health = humanoid and humanoid.Health or 0
    local isAlive = health > 0
    
    -- Cores baseadas no status
    local playerColor = isAlive and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    local statusIcon = isAlive and "🟢" or "🔴"
    
    ESP:Add(player.Character, {
        Name = statusIcon .. " " .. player.Name,
        NameContainer = {Start = "[", End = "]"},
        DistanceSuffix = "m",
        DistanceContainer = {Start = " (", End = ")"},
        Color = {
            Name = playerColor,
            Distance = Color3.fromRGB(255, 255, 150),
            Tracer = playerColor,
            Highlight = {
                Filled = playerColor,
                Outline = Color3.fromRGB(255, 255, 255)
            }
        }
    })
end

-- Aplicar ESP em players existentes
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
        addAdvancedPlayerESP(player)
    end
end

-- 📦 ESP para itens do mundo com categorização
local itemConfig = {
    ["Weapon"] = {color = Color3.fromRGB(255, 100, 100), icon = "🔫"},
    ["Health"] = {color = Color3.fromRGB(100, 255, 100), icon = "❤️"},
    ["Ammo"] = {color = Color3.fromRGB(255, 255, 100), icon = "📦"},
    ["Key"] = {color = Color3.fromRGB(255, 215, 0), icon = "🗝️"},
    ["Treasure"] = {color = Color3.fromRGB(255, 0, 255), icon = "💎"}
}

for _, obj in pairs(workspace:GetChildren()) do
    for itemType, config in pairs(itemConfig) do
        if obj.Name:find(itemType) then
            ESP:Add(obj, {
                Name = config.icon .. " " .. obj.Name,
                Color = config.color,
                DistanceSuffix = "m",
                Collision = true
            })
            break
        end
    end
end

-- 🎮 Sistema de controles com keybinds
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local key = input.KeyCode
    
    if key == Enum.KeyCode.F1 then
        -- Toggle ESP geral
        ESP.Enabled = not ESP.Enabled
        print("🎯 ESP:", ESP.Enabled and "✅ ON" or "❌ OFF")
        
    elseif key == Enum.KeyCode.F2 then
        -- Toggle Arrow ESP
        ESP:SetArrowEnabled(not ESP.ArrowEnabled)
        print("🏹 Arrow ESP:", ESP.ArrowEnabled and "✅ ON" or "❌ OFF")
        
    elseif key == Enum.KeyCode.F3 then
        -- Toggle Rainbow Mode
        local newRainbow = not ESP.GlobalSettings.RainbowMode
        ESP:SetGlobalRainbow(newRainbow)
        print("🌈 Rainbow:", newRainbow and "✅ ON" or "❌ OFF")
        
    elseif key == Enum.KeyCode.F4 then
        -- Alternar entre Drawing e GUI arrows
        ESP:SetArrowUseDrawing(not ESP.UseDrawingArrow)
        local mode = ESP.UseDrawingArrow and "Drawing (Performance)" or "GUI (Visual)"
        print("🏹 Arrow Mode:", mode)
        
    elseif key == Enum.KeyCode.F5 then
        -- Limpar todas ESPs
        ESP:Clear()
        print("🧹 All ESP Cleared!")
    end
end)

print([[
🎮 Controles:
F1 - Toggle ESP Geral
F2 - Toggle Arrow ESP  
F3 - Toggle Rainbow Mode
F4 - Toggle Arrow Mode (Drawing/GUI)
F5 - Limpar Todas ESPs
]])
```

### Sistema de ESP com Monitoramento Automático
```lua
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configuração inicial
ESP:SetArrowEnabled(true)
ESP:SetFOVMargin(20)

-- 🔄 Auto-monitor para novos players
game.Players.PlayerAdded:Connect(function(player)
    local function onCharacterAdded(character)
        wait(2) -- Aguardar character carregar completamente
        
        if character and character.Parent then
            ESP:Add(character, {
                Name = "👤 " .. player.Name,
                Color = Color3.fromRGB(255, 150, 150),
                DistanceSuffix = "m"
            })
            print("✅ ESP adicionada para:", player.Name)
        end
    end
    
    player.CharacterAdded:Connect(onCharacterAdded)
    if player.Character then
        onCharacterAdded(player.Character)
    end
end)

-- 🗑️ Auto-remover players que saíram
game.Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        ESP:Remove(player.Character)
        print("❌ ESP removida para:", player.Name)
    end
end)

-- 📦 Monitor automático para novos objetos
local function monitorWorkspace()
    workspace.ChildAdded:Connect(function(obj)
        wait(0.1) -- Pequena espera para objeto carregar
        
        -- Detectar automaticamente tipo de objeto
        if obj.Name:find("Weapon") or obj.Name:find("Gun") then
            ESP:Add(obj, {
                Name = "🔫 " .. obj.Name,
                Color = Color3.fromRGB(255, 100, 100)
            })
        elseif obj.Name:find("Health") or obj.Name:find("Med") then
            ESP:Add(obj, {
                Name = "❤️ " .. obj.Name,
                Color = Color3.fromRGB(100, 255, 100)
            })
        elseif obj.Name:find("Key") or obj.Name:find("Card") then
            ESP:Add(obj, {
                Name = "🗝️ " .. obj.Name,
                Color = Color3.fromRGB(255, 215, 0)
            })
        end
    end)
end

monitorWorkspace()
```

## ⚙️ Troubleshooting

### Problemas Comuns V1.5

**Arrow ESP não funciona quando olho para trás:**
```lua
-- ✅ CORRIGIDO na V1.5! 
-- O sistema agora detecta automaticamente objetos atrás da câmera
ESP:SetArrowEnabled(true)
ESP:SetFOVMargin(15)  -- Ajuste conforme necessário
```

**ESP não aparece:**
```lua
-- Verificações básicas
ESP.Enabled = true

-- Verificar configurações de distância
ESP.GlobalSettings.MaxDistance = math.huge
ESP.GlobalSettings.MinDistance = 0

-- Verificar se objeto existe e é válido
if target and target.Parent and (target:IsA("Model") or target:IsA("BasePart")) then
    ESP:Add(target)
else
    print("❌ Objeto inválido para ESP")
end
```

**Performance baixa:**
```lua
-- ⚡ Configuração otimizada para melhor FPS
ESP:SetArrowUseDrawing(true)          -- Usa Drawing API (mais rápido)
ESP.GlobalSettings.MaxDistance = 800  -- Reduz distância máxima
ESP:SetGlobalLineThickness(1)         -- Linhas mais finas
ESP.GlobalSettings.FontSize = 12      -- Fonte menor
ESP.GlobalSettings.AutoRemoveInvalid = true -- Remove objetos inválidos

-- Desabilitar elementos desnecessários se precisar
ESP:SetGlobalESPType("ShowTracer", false)
ESP:SetGlobalESPType("ShowHighlightFill", false)
```

**Arrows aparecem quando não deveriam:**
```lua
-- Ajustar margem do campo de visão
ESP:SetFOVMargin(5)   -- Margem menor = arrow aparece só quando bem fora da tela
ESP:SetFOVMargin(30)  -- Margem maior = arrow aparece mais cedo
```

**Objetos atrás da câmera não têm arrow:**
```lua
-- ✅ Funciona automaticamente na V1.5
-- Se ainda não funciona, verifique:
print("Arrow ESP enabled:", ESP.ArrowEnabled)
print("FOV Margin:", ESP.FOVMargin)

-- Recriar arrows se necessário
ESP:SetArrowEnabled(false)
wait(0.1)
ESP:SetArrowEnabled(true)
```

### Configuração de Performance V1.5
```lua
-- 🚀 Configuração ultra-otimizada para máximo FPS
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Performance settings
ESP.GlobalSettings.AutoRemoveInvalid = true
ESP.GlobalSettings.MaxDistance = 500
ESP.GlobalSettings.LineThickness = 1
ESP.GlobalSettings.FontSize = 11
ESP.GlobalSettings.Opacity = 0.7

-- Arrow settings otimizadas
ESP:SetArrowEnabled(true)
ESP:SetArrowUseDrawing(true)  -- IMPORTANTE: Drawing é muito mais rápido
ESP:SetArrowRadius(100)       -- Raio menor = menos cálculos
ESP:SetFOVMargin(10)          -- Margem menor = menos verificações

-- Desabilitar elementos pesados se necessário
ESP:SetGlobalESPType("ShowHighlightFill", false)
ESP:SetGlobalESPType("ShowTracer", false)
```

### Debugging Avançado
```lua
-- 🔍 Sistema de debug para troubleshooting
local function debugESP()
    print("=== 🔍 ESP Debug Info ===")
    print("ESP Enabled:", ESP.Enabled)
    print("Arrow Enabled:", ESP.ArrowEnabled)
    print("Using Drawing:", ESP.UseDrawingArrow)
    print("Arrow Radius:", ESP.ArrowRadius)
    print("FOV Margin:", ESP.FOVMargin)
    print("Total Objects:", #ESP.Objects)
    print("Total Arrows:", 0)
    for _ in pairs(ESP.Arrows) do
        ESP.Objects[_] = (ESP.Objects[_] or 0) + 1
    end
    print("Arrow Objects:", ESP.Objects[_] or 0)
    print("Rainbow Mode:", ESP.GlobalSettings.RainbowMode)
    print("Max Distance:", ESP.GlobalSettings.MaxDistance)
    print("======================")
end

-- Chamar debug
debugESP()

-- Auto-debug a cada 10 segundos (remover em produção)
spawn(function()
    while true do
        wait(10)
        debugESP()
    end
end)
```

---

## 🎉 Changelog V1.5

### 🔥 **Principais Mudanças:**
- **Arrow ESP Completamente Reescrito** - Agora funciona em todas as direções
- **Detecção Atrás da Câmera** - Produto escalar para detectar objetos atrás
- **Sistema de FOV Inteligente** - Margem configurável para campo de visão
- **Performance Otimizada** - Melhores algoritmos de detecção
- **API Expandida** - Novas funções para controle avançado

### 🐛 **Bugs Corrigidos:**
- Arrow ESP não funcionando quando olhando para direção oposta
- Detecção incorreta de objetos fora da tela
- Arrows aparecendo para objetos visíveis na tela
- Cálculos incorretos para objetos muito próximos

### ⚡ **Otimizações:**
- Melhor gerenciamento de recursos Drawing API
- Cálculos matemáticos mais eficientes
- Redução de verificações desnecessárias
- Auto-limpeza de objetos inválidos aprimorada

---

## 🎉 Créditos

- **Autor:** Kolt
- **Versão:** 1.5
- **Estilo:** Minimalista, eficiente e responsivo
- **Destaque V1.5:** Arrow ESP 360° completamente funcional
- **Correção Principal:** Sistema de detecção atrás da câmera

Para suporte e atualizações, visite o repositório oficial!

---

*Biblioteca testada e otimizada para máxima performance e compatibilidade. V1.5 com Arrow ESP totalmente funcional em todas as direções!*
