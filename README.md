# 📦 Kolt ESP Library V1.4
### 👤 Autor: Kolt | 🎨 Estilo: Minimalista, eficiente e responsivo

Biblioteca completa de ESP (Extra Sensory Perception) para Roblox com suporte a Arrow ESP para objetos fora de campo de visão.

## 🚀 Instalação Rápida

```lua
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()
```

## 📋 Índice

- [🎯 Recursos Principais](#-recursos-principais)
- [⚡ Início Rápido](#-início-rápido)
- [🔧 Configurações Globais](#-configurações-globais)
- [🎨 Personalização de Cores](#-personalização-de-cores)
- [🏹 Arrow ESP](#-arrow-esp)
- [👤 ESP para Players](#-esp-para-players)
- [📦 ESP para Objetos](#-esp-para-objetos)
- [🎛️ APIs Avançadas](#️-apis-avançadas)
- [📚 Exemplos Completos](#-exemplos-completos)
- [⚙️ Troubleshooting](#️-troubleshooting)

## 🎯 Recursos Principais

- ✨ **Arrow ESP** - Setas indicativas para objetos fora da tela
- 🎨 **Rainbow Mode** - Cores arco-íris animadas
- 🔍 **Highlight System** - Destaque visual através de paredes
- 📏 **Distance Control** - Controle de distância mínima/máxima
- 🎯 **Tracer Lines** - Linhas indicativas personalizáveis
- 👁️ **Name & Distance** - Exibição de nome e distância
- 🎭 **Collision Detection** - Torna objetos invisíveis visíveis
- 🔄 **Auto Remove** - Remove automaticamente objetos inválidos

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

## 🏹 Arrow ESP

### Configuração Básica
```lua
ESP:SetArrowEnabled(true)           -- Liga Arrow ESP
ESP:SetArrowUseDrawing(true)        -- Usa Drawing API (mais performance)
ESP:SetArrowRadius(150)             -- Raio das setas (distância do centro)
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

-- Para setas Drawing (linhas)
GlobalArrowDesign.Drawing = {
    Color = {255, 0, 0},
    OutlineColor = {0, 0, 0},
    Opacity = 0.3,
    Size = {w = 30, h = 30},
    OutlineThickness = 6,
    LineThickness = 3
}
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

### ESP Avançada com Status
```lua
-- ESP com informações extras
local function addPlayerESP(player)
    if not player.Character then return end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local health = humanoid and humanoid.Health or 0
    local maxHealth = humanoid and humanoid.MaxHealth or 100
    
    ESP:Add(player.Character, {
        Name = player.Name,
        NameContainer = {Start = "[", End = "]"},
        DistanceSuffix = "m",
        DistanceContainer = {Start = "(", End = ")"},
        Color = health > 50 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    })
end

-- Aplicar em todos os players
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
        addPlayerESP(player)
    end
end
```

### Auto-Update para Novos Players
```lua
-- Detectar novos players
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        wait(1) -- Aguardar character carregar
        ESP:Add(character, {
            Name = player.Name,
            Color = Color3.fromRGB(0, 150, 255)
        })
    end)
end)
```

## 📦 ESP para Objetos

### ESP em Objetos Específicos
```lua
-- ESP em uma parte
ESP:Add(workspace.ImportantPart, {
    Name = "Item Importante",
    Color = Color3.fromRGB(255, 215, 0) -- Dourado
})

-- ESP em um modelo
ESP:Add(workspace.Treasure, {
    Name = "Tesouro",
    Color = Color3.fromRGB(255, 0, 255),
    Collision = true -- Torna partes invisíveis visíveis
})
```

### ESP em Múltiplos Objetos
```lua
-- ESP em todos os objetos com um nome específico
for _, obj in pairs(workspace:GetChildren()) do
    if obj.Name == "Coin" then
        ESP:Add(obj, {
            Name = "Moeda",
            Color = Color3.fromRGB(255, 215, 0)
        })
    end
end
```

### ESP com Filtros de Distância
```lua
-- Configurar distância antes de adicionar ESP
ESP.GlobalSettings.MaxDistance = 500  -- Máximo 500 studs
ESP.GlobalSettings.MinDistance = 10   -- Mínimo 10 studs

-- Adicionar ESP
ESP:Add(workspace.FarObject, {
    Name = "Objeto Distante"
})
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

### Arrow ESP Avançado
```lua
-- Alternar entre Drawing e GUI
ESP:SetArrowUseDrawing(true)  -- Melhor performance
ESP:SetArrowUseDrawing(false) -- Mais customizável

-- Ajustar raio das setas
ESP:SetArrowRadius(200) -- Setas mais longe do centro
```

## 📚 Exemplos Completos

### Sistema de ESP Completo
```lua
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configurações iniciais
ESP.Enabled = true
ESP:SetArrowEnabled(true)
ESP:SetArrowUseDrawing(true)
ESP:SetArrowRadius(120)
ESP:SetGlobalRainbow(false)
ESP:SetGlobalOpacity(0.8)

-- ESP para players inimigos
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer and player.Character then
        ESP:Add(player.Character, {
            Name = "👤 " .. player.Name,
            DistanceSuffix = "m",
            Color = {
                Name = {255, 100, 100},
                Distance = {255, 255, 100},
                Tracer = {255, 0, 0},
                Highlight = {
                    Filled = {255, 0, 0},
                    Outline = {255, 255, 255}
                }
            }
        })
    end
end

-- ESP para itens importantes
for _, obj in pairs(workspace:GetChildren()) do
    if obj.Name:find("Weapon") then
        ESP:Add(obj, {
            Name = "🔫 " .. obj.Name,
            Color = Color3.fromRGB(0, 255, 0),
            Collision = true
        })
    elseif obj.Name:find("Health") then
        ESP:Add(obj, {
            Name = "❤️ Vida",
            Color = Color3.fromRGB(0, 255, 0)
        })
    end
end
```

### ESP com Toggle Dinâmico
```lua
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Variáveis de controle
local showPlayers = true
local showItems = true
local rainbowMode = false

-- Função para toggle
local function toggleESP()
    ESP.Enabled = not ESP.Enabled
    print("ESP:", ESP.Enabled and "ON" or "OFF")
end

-- Função para toggle rainbow
local function toggleRainbow()
    rainbowMode = not rainbowMode
    ESP:SetGlobalRainbow(rainbowMode)
    print("Rainbow:", rainbowMode and "ON" or "OFF")
end

-- Keybinds (exemplo)
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        toggleESP()
    elseif input.KeyCode == Enum.KeyCode.F2 then
        toggleRainbow()
    elseif input.KeyCode == Enum.KeyCode.F3 then
        ESP:SetArrowEnabled(not ESP.ArrowEnabled)
        print("Arrow ESP:", ESP.ArrowEnabled and "ON" or "OFF")
    end
end)
```

## ⚙️ Troubleshooting

### Problemas Comuns

**ESP não aparece:**
```lua
-- Verificar se está habilitado
ESP.Enabled = true

-- Verificar configurações de distância
ESP.GlobalSettings.MaxDistance = math.huge
ESP.GlobalSettings.MinDistance = 0

-- Verificar se objeto existe
if target and target.Parent then
    ESP:Add(target)
end
```

**Performance baixa:**
```lua
-- Usar Drawing para arrows
ESP:SetArrowUseDrawing(true)

-- Reduzir distância máxima
ESP.GlobalSettings.MaxDistance = 1000

-- Desabilitar elementos desnecessários
ESP:SetGlobalESPType("ShowTracer", false)
```

**Arrows não funcionam:**
```lua
-- Verificar se está habilitado
ESP:SetArrowEnabled(true)

-- Verificar se objetos estão fora da tela
-- (arrows só aparecem para objetos fora do campo de visão)
```

### Configuração de Performance
```lua
-- Configuração otimizada para melhor FPS
ESP.GlobalSettings.AutoRemoveInvalid = true  -- Remove objetos inválidos
ESP:SetArrowUseDrawing(true)                 -- Usa Drawing API
ESP.GlobalSettings.MaxDistance = 500         -- Limita distância
ESP.GlobalSettings.LineThickness = 1         -- Linhas mais finas
ESP.GlobalSettings.FontSize = 12             -- Fonte menor
```

---

## 🎉 Créditos

- **Autor:** Kolt
- **Versão:** 1.4
- **Estilo:** Minimalista, eficiente e responsivo
- **Nova funcionalidade:** Arrow ESP para objetos fora de campo de visão

Para suporte e atualizações, visite o repositório oficial!

---

*Biblioteca testada e otimizada para máxima performance e compatibilidade.*
