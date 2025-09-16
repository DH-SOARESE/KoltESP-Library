# 📦 Kolt ESP Library V1.4

Uma biblioteca ESP (Extra Sensory Perception) **minimalista, eficiente e responsiva** para Roblox, desenvolvida por **DH_SOARES**. Agora com suporte a **setas off-screen** para alvos fora do campo de visão!

## ✨ Características

- 🎯 **ESP Completo**: Tracer, Nome, Distância, Highlight e **Seta Off-Screen** (nova!)
- 🌈 **Modo Arco-íris**: Cores dinâmicas que mudam automaticamente em todos os elementos
- 🎨 **Customização Avançada de Cores**: Suporte a cores individuais por elemento (Name, Distance, Tracer, Highlight) via tabela RGB ou Color3 único
- ⚡ **Performance Otimizada**: Auto-remoção de objetos inválidos, atualizações eficientes por frame e detecção precisa de visibilidade
- 📱 **Responsivo e Preciso**: Adapta-se a resoluções variadas, com posicionamento anti-distorção para alvos próximos (1-10 studs)
- 🔧 **API Intuitiva**: Fácil integração com funções globais e configurações individuais
- 🆕 **ESP Collision (Individual)**: Cria Humanoid "Kolt ESP" e ajusta transparência de parts invisíveis (1 → 0.99) para melhor colisão/visibilidade
- 🆕 **Customização de Textos**: Containers para nome/distância e sufixos personalizáveis (ex: [Nome] (10.5m))
- 🆕 **Seta Off-Screen Global**: Uma seta por alvo (Drawing-based), aparece só quando fora da tela, usando cor do Tracer. Configurável globalmente!
- 🐛 **Melhorias Recentes**: Suporte a setas off-screen, otimizações em transparências e rotação dinâmica das setas

## 🚀 Instalação

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()
```

## 📋 Sumário (Atalhos)

- [Características](#-características)
- [Instalação](#-instalação)
- [Funcionalidades](#-funcionalidades)
- [Uso Básico](#️-uso-básico)
- [Removendo ESP](#-removendo-esp)
- [Configurações Globais](#-configurações-globais)
- [Exemplos Práticos](#-exemplos-práticos)
- [Configurações Disponíveis](#️-configurações-disponíveis)
- [Controles](#-controles)
- [Licença](#-licença)

## 📋 Funcionalidades

### 🎯 Componentes ESP
- **Tracer**: Linha da origem até o centro do alvo (origens: Top, Center, Bottom, Left, Right)
- **Nome**: Texto centralizado com container customizável (ex: [Nome])
- **Distância**: Valor em metros formatado (ex: (10.5m)), com sufixo e container personalizáveis
- **Highlight**: Preenchimento e contorno coloridos, com transparências fixas (0.85 fill / 0.65 outline)
- **🆕 Seta Off-Screen**: Seta triangular (Drawing) que aponta para alvos fora da tela, usando cor do Tracer. Global e única por alvo!

### 🎮 Origens do Tracer
- `Top` - Topo da tela
- `Center` - Centro da tela
- `Bottom` - Inferior da tela (padrão)
- `Left` - Esquerda
- `Right` - Direita

### 🆕 Opção de Collision (Individual)
- Ative via `Collision = true` no config
- Cria Humanoid "Kolt ESP" (se ausente) e altera transparência de parts invisíveis
- Restaura tudo ao remover o ESP (transparências + Humanoid)

### 🆕 Customização de Textos
- **NameContainer**: `{Start = "[", End = "]"}` (padrão: vazio)
- **DistanceSuffix**: `"m"` (padrão)
- **DistanceContainer**: `{Start = "(", End = ")"}` (padrão: vazio)

### 🆕 Configuração de Seta Off-Screen
- Ative globalmente: `ModelESP:Arrow(true)`
- Usa Drawing (linhas para triângulo com outline preto)
- Configs globais: Raio (130), Largura (24), Altura (20), Opacidade (0.3), Espessuras (Outline:6, Linha:3)
- Rotação dinâmica baseada na direção do alvo

## 🛠️ Uso Básico

### Adicionando ESP a um Objeto

```lua
-- Carregar a biblioteca
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Adicionar ESP básico
ModelESP:Add(workspace.SomeModel)

-- Com nome, cor única, Collision e textos customizados
ModelESP:Add(workspace.SomeModel, {
    Name = "Alvo Especial",
    Color = Color3.fromRGB(255, 0, 0),
    Collision = true,
    NameContainer = {Start = "{", End = "}"},
    DistanceSuffix = ".metros",
    DistanceContainer = {Start = "<", End = ">"}
})

-- Cores por elemento + Collision
ModelESP:Add(workspace.SomeModel, {
    Name = "Alvo Especial",
    Collision = true,
    NameContainer = {Start = "[", End = "]"},
    DistanceSuffix = "m",
    DistanceContainer = {Start = "(", End = ")"},
    Color = {
        Name = {255, 255, 255},            -- Nome (RGB)
        Distance = {255, 255, 255},        -- Distância (RGB)
        Tracer = {0, 255, 0},              -- Tracer (RGB) - Usado na seta!
        Highlight = {
            Filled = {100, 144, 0},        -- Preenchimento (RGB)
            Outline = {0, 255, 0}          -- Contorno (RGB)
        }
    }
})
```

### Removendo ESP

```lua
-- Remove um específico (restaura transparências/Collision)
ModelESP:Remove(workspace.SomeModel)

-- Limpa todos
ModelESP:Clear()
```

## 🎨 Configurações Globais

### Habilitando/Desabilitando

```lua
-- Componentes ESP
ModelESP:SetGlobalESPType("ShowTracer", true)
ModelESP:SetGlobalESPType("ShowName", true)
ModelESP:SetGlobalESPType("ShowDistance", true)
ModelESP:SetGlobalESPType("ShowHighlightFill", true)
ModelESP:SetGlobalESPType("ShowHighlightOutline", true)

-- 🆕 Seta Off-Screen (global)
ModelESP:Arrow(true)  -- true/false
```

### Personalizando Aparência

```lua
-- Origem Tracer
ModelESP:SetGlobalTracerOrigin("Bottom")  -- Top, Center, Bottom, Left, Right

-- Arco-íris (afeta setas também)
ModelESP:SetGlobalRainbow(true)

-- Opacidade geral (não afeta setas)
ModelESP:SetGlobalOpacity(0.8)

-- Fonte e linhas
ModelESP:SetGlobalFontSize(16)
ModelESP:SetGlobalLineThickness(2)

-- 🆕 Configs de Seta (direto no GlobalSettings)
ModelESP.GlobalSettings.ArrowRadius = 150        -- Distância da borda
ModelESP.GlobalSettings.ArrowWidth = 30          -- Largura base
ModelESP.GlobalSettings.ArrowHeight = 25         -- Altura ponta
ModelESP.GlobalSettings.ArrowOpacity = 0.4       -- Transparência
ModelESP.GlobalSettings.ArrowOutlineThickness = 8 -- Outline
ModelESP.GlobalSettings.ArrowLineThickness = 4   -- Linha interna
```

### Controle de Distância

```lua
ModelESP.GlobalSettings.MaxDistance = 1000  -- Studs máx.
ModelESP.GlobalSettings.MinDistance = 0     -- Studs mín.
```

## 📖 Exemplos Práticos

### 🧑‍🤝‍🧑 ESP para Jogadores com Cores, Collision e Seta

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configs Globais
ModelESP:SetGlobalTracerOrigin("Top")
ModelESP:SetGlobalRainbow(false)
ModelESP:SetGlobalOpacity(0.8)
ModelESP:SetGlobalFontSize(16)
ModelESP:SetGlobalLineThickness(2)
ModelESP.GlobalSettings.MaxDistance = 500
ModelESP.GlobalSettings.MinDistance = 10
ModelESP.GlobalSettings.AutoRemoveInvalid = true

-- Ativar componentes + 🆕 Seta
ModelESP:SetGlobalESPType("ShowTracer", true)
ModelESP:SetGlobalESPType("ShowName", true)
ModelESP:SetGlobalESPType("ShowDistance", true)
ModelESP:SetGlobalESPType("ShowHighlightFill", true)
ModelESP:SetGlobalESPType("ShowHighlightOutline", true)
ModelESP:Arrow(true)  -- Ativa setas off-screen

-- Função para jogadores
local function addPlayerESP(player)
    if player.Character then
        ModelESP:Add(player.Character, {
            Name = player.Name,
            Collision = false,
            DistanceSuffix = ".m",
            DistanceContainer = {Start = "(", End = ")"},
            Color = {
                Name = {144, 0, 255},
                Distance = {144, 0, 255},
                Tracer = {144, 0, 255},       -- Cor da seta!
                Highlight = {
                    Filled = {144, 0, 255},
                    Outline = {200, 0, 255}
                }
            }
        })
    end
end

-- Adicionar atuais
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then addPlayerESP(player) end
end

-- Novos jogadores
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function() wait(1); addPlayerESP(player) end)
end)

-- Remover ao sair
game.Players.PlayerRemoving:Connect(function(player)
    if player.Character then ModelESP:Remove(player.Character) end
end)
```

### 🎯 ESP para Objetos com Collision e Seta Customizada

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configs de seta maiores
ModelESP.GlobalSettings.ArrowRadius = 150
ModelESP.GlobalSettings.ArrowWidth = 30
ModelESP.GlobalSettings.ArrowHeight = 25
ModelESP:Arrow(true)

local function addPartESP(partName, espName, colorTable, collision)
    for _, part in pairs(workspace:GetDescendants()) do
        if part.Name == partName and part:IsA("BasePart") then
            ModelESP:Add(part, {
                Name = espName or part.Name,
                Collision = collision or false,
                NameContainer = {Start = "{", End = "}"},
                DistanceSuffix = ".m",
                DistanceContainer = {Start = "<", End = ">"},
                Color = colorTable or {
                    Name = {255, 255, 0},
                    Distance = {255, 255, 0},
                    Tracer = {255, 255, 0},       -- Cor da seta
                    Highlight = {Filled = {255, 215, 0}, Outline = {255, 255, 0}}
                }
            })
        end
    end
end

-- Exemplos
addPartESP("Chest", "💰 Baú", {Name = {255, 255, 255}, Tracer = {255, 215, 0}, Highlight = {Filled = {255, 215, 0}}}, true)
addPartESP("Enemy", "👹 Inimigo", {Tracer = {255, 0, 0}, Highlight = {Filled = {200, 0, 0}}}, false)
```

### 🔍 ESP por Path com Seta e Arco-íris

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

ModelESP:SetGlobalRainbow(true)  -- Arco-íris nas setas também!
ModelESP:Arrow(true)
ModelESP.GlobalSettings.ArrowOpacity = 0.5

local targets = {
    {path = "workspace.Map.Treasures", name = "💎 Tesouro", collision = true, color = {Tracer = {255, 0, 255}}},
    {path = "workspace.Enemies", name = "⚔️ Inimigo", collision = false, color = {Tracer = {255, 100, 100}}},
    {path = "workspace.Items", name = "📦 Item", collision = true, color = {Tracer = {100, 255, 100}}}
}

for _, target in pairs(targets) do
    local obj = game
    for part in target.path:split(".") do
        obj = obj:FindFirstChild(part)
        if not obj then break end
    end
    if obj then
        for _, child in pairs(obj:GetChildren()) do
            if child:IsA("Model") or child:IsA("BasePart") then
                ModelESP:Add(child, {
                    Name = target.name,
                    Collision = target.collision,
                    Color = target.color
                })
            end
        end
    end
end
```

## ⚙️ Configurações Disponíveis

### GlobalSettings
```lua
{
    TracerOrigin = "Bottom",
    ShowTracer = true,
    ShowHighlightFill = true,
    ShowHighlightOutline = true,
    ShowName = true,
    ShowDistance = true,
    ShowArrow = false,                  -- 🆕 Seta off-screen
    RainbowMode = false,
    MaxDistance = math.huge,
    MinDistance = 0,
    Opacity = 0.8,
    ArrowOpacity = 0.3,                 -- 🆕 Opacidade seta
    ArrowRadius = 130,                  -- 🆕 Distância borda
    ArrowWidth = 24,                    -- 🆕 Largura base
    ArrowHeight = 20,                   -- 🆕 Altura ponta
    ArrowOutlineThickness = 6,          -- 🆕 Outline
    ArrowLineThickness = 3,             -- 🆕 Linha interna
    LineThickness = 1.5,
    FontSize = 14,
    AutoRemoveInvalid = true
}
```

### Config ao Adicionar ESP
```lua
{
    Name = "Nome",                          -- Opcional
    Collision = false,                      -- Opcional
    NameContainer = {Start = "[", End = "]"}, -- Opcional
    DistanceSuffix = "m",                   -- Opcional
    DistanceContainer = {Start = "(", End = ")"}, -- Opcional
    Color = { ... }                         -- Opcional (tabela ou Color3)
}
```

### Estrutura de Cores
```lua
Color = {
    Name = {255, 255, 255},        -- RGB
    Distance = {255, 255, 255},    -- RGB
    Tracer = {0, 255, 0},          -- RGB (seta usa isso!)
    Highlight = {
        Filled = {100, 144, 0},    -- RGB
        Outline = {0, 255, 0}      -- RGB
    }
}
-- Ou Color3 único: Color = Color3.fromRGB(255, 0, 0)
```

## 🎮 Controles

```lua
-- Ligar/desligar tudo
ModelESP.Enabled = false

-- Status
print("Ativo:", ModelESP.Enabled)
print("Alvos:", #ModelESP.Objects)
```

## 📄 Licença

Fornecida "as is" para fins educacionais e de entretenimento em Roblox. Não viole ToS ou use maliciosamente.

---

**Desenvolvido por DH_SOARES** | Versão 1.4 | Última atualização: 15 de Setembro de 2025
