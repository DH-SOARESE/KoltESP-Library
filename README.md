# 📦 Kolt ESP Library V1.3

Uma biblioteca ESP (Extra Sensory Perception) minimalista, eficiente e responsiva para Roblox, desenvolvida por **DH_SOARES**.

## ✨ Características

- 🎯 **ESP Completo**: Tracer, Nome, Distância, Highlight e **Arrow Off-Screen**
- 🌈 **Modo Arco-íris**: Cores dinâmicas que mudam automaticamente
- 🎨 **Customização Avançada de Cores**: Suporte a cores individuais por elemento (Name, Distance, Tracer, Highlight, Arrow) via tabela ou Color3
- ⚡ **Performance Otimizada**: Sistema de auto-remoção de objetos inválidos e atualizações eficientes por frame
- 📱 **Responsivo**: Adapta-se a diferentes resoluções de tela, com posicionamento preciso mesmo em distâncias próximas
- 🔧 **Fácil de Usar**: API simples e intuitiva
- 🆕 **ESP Collision (Opcional e Individual)**: Cria um Humanoid "Kolt ESP" no alvo e ajusta a transparência de parts invisíveis (de 1 para 0.99) para melhor detecção de colisões ou visibilidade
- 🆕 **Customização de Textos**: Propriedades individuais para containers (ex: colchetes para nome) e sufixo/container para distância (ex: ".m" com parênteses)
- 🆕 **Arrow Off-Screen**: Seta direcional que aparece na borda da tela quando o alvo está fora do campo de visão, configurável em Drawing ou GUI
- 🐛 **Correções Recentes**: Melhoria no posicionamento de textos (Name e Distance) para evitar distorções quando o jogador está próximo (1-10 metros) do alvo; integração fluida de Arrow com lógica de visibilidade

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
- **Tracer**: Linha do ponto de origem até o centro do alvo
- **Nome**: Exibe o nome do objeto, centralizado, com container personalizável (ex: [Nome])
- **Distância**: Mostra a distância em metros, com formatação precisa (ex: (10.5.m)), sufixo e container personalizáveis
- **Highlight**: Contorno e preenchimento colorido ao redor do objeto, com transparências ajustáveis
- **Arrow Off-Screen**: Seta direcional que aponta para o alvo quando ele está fora da tela; aparece na borda da viewport, com rotação automática e suporte a Drawing (linhas) ou GUI (imagem)

### 🎮 Origens do Tracer
- `Top` - Topo da tela
- `Center` - Centro da tela
- `Bottom` - Parte inferior da tela (padrão)
- `Left` - Lateral esquerda
- `Right` - Lateral direita

### 🆕 Opção de Collision
- Ativada individualmente via `Collision = true` no config ao adicionar ESP
- Cria um Humanoid chamado "Kolt ESP" no alvo (se não existir)
- Ajusta temporariamente a transparência de todas as parts com valor 1 para 0.99
- Ao remover o ESP, restaura as transparências originais e destrói o Humanoid

### 🆕 Propriedades Individuais para Textos
- **NameContainer**: Tabela com `Start` e `End` para envolver o nome (padrão: {Start = "[", End = "]"})
- **DistanceSuffix**: Sufixo após o valor da distância (padrão: "m")
- **DistanceContainer**: Tabela com `Start` e `End` para envolver a distância (padrão: {Start = "(", End = ")"})

### 🆕 Configuração de Arrow
- **Tipos Suportados**: "Drawing" (linhas simples) ou "Gui" (imagem rotacionável)
- **Design Personalizável**: Cores, opacidade, tamanho e rotação via `SetArrowDesign`
- **Raio**: Distância da borda da tela para posicionar a seta (padrão: 130 pixels)
- **Visibilidade**: Automática – aparece apenas quando o alvo está off-screen e outros elementos ESP estão ocultos

## 🛠️ Uso Básico

### Adicionando ESP a um Objeto

```lua
-- Carregar a biblioteca
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Adicionar ESP básico
ModelESP:Add(workspace.SomeModel)

-- Adicionar ESP com nome personalizado, cor única, Collision e customização de textos
ModelESP:Add(workspace.SomeModel, {
    Name = "Alvo Especial",
    Color = Color3.fromRGB(255, 0, 0),
    Collision = true,  -- Ativa o modo Collision
    NameContainer = {Start = "{", End = "}"},  -- Customiza container do nome
    DistanceSuffix = ".metros",  -- Customiza sufixo da distância
    DistanceContainer = {Start = "<", End = ">" }  -- Customiza container da distância
})

-- Adicionar ESP com cores personalizadas por elemento, Collision e textos customizados
ModelESP:Add(workspace.SomeModel, {
    Name = "Alvo Especial",
    Collision = true,
    NameContainer = {Start = "[", End = "]"},
    DistanceSuffix = "m",
    DistanceContainer = {Start = "(", End = ")"},
    Color = {
        Name = {255, 255, 255},            -- Cor do texto do nome (RGB)
        Distance = {255, 255, 255},        -- Cor do texto da distância (RGB)
        Tracer = {0, 255, 0},              -- Cor da linha tracer (RGB)
        Highlight = {
            Filled = {100, 144, 0},        -- Cor do preenchimento do highlight (RGB)
            Outline = {0, 255, 0}          -- Cor do contorno do highlight (RGB)
        }
    }
})
```

### Removendo ESP

```lua
-- Remover ESP de um objeto específico (restaura transparências e remove Humanoid se Collision estava ativado)
ModelESP:Remove(workspace.SomeModel)

-- Limpar todos os ESPs (restaura tudo)
ModelESP:Clear()
```

## 🎨 Configurações Globais

### Habilitando/Desabilitando Componentes

```lua
-- Mostrar/ocultar tracers
ModelESP:SetGlobalESPType("ShowTracer", true)

-- Mostrar/ocultar nomes
ModelESP:SetGlobalESPType("ShowName", true)

-- Mostrar/ocultar distâncias
ModelESP:SetGlobalESPType("ShowDistance", true)

-- Mostrar/ocultar highlight fill
ModelESP:SetGlobalESPType("ShowHighlightFill", true)

-- Mostrar/ocultar highlight outline
ModelESP:SetGlobalESPType("ShowHighlightOutline", true)

-- Mostrar/ocultar arrow off-screen
ModelESP:SetGlobalESPType("ShowArrow", true)
```

### Personalizando Aparência

```lua
-- Definir origem do tracer
ModelESP:SetGlobalTracerOrigin("Bottom") -- Top, Center, Bottom, Left, Right

-- Ativar modo arco-íris (sobrescreve cores individuais)
ModelESP:SetGlobalRainbow(true)

-- Ajustar opacidade (0-1)
ModelESP:SetGlobalOpacity(0.8)

-- Definir tamanho da fonte
ModelESP:SetGlobalFontSize(16)

-- Ajustar espessura da linha
ModelESP:SetGlobalLineThickness(2)

-- Configurar arrow (tipo e visibilidade)
ModelESP:SetArrow{ShowArrow = true, Type = "Drawing"}  -- Ou "Gui"

-- Configurar design da arrow
ModelESP:SetArrowDesign {
    Gui = {  -- Config para GUI
        image = "rbxassetid://11552476728",
        Color = {255, 0, 0},
        Opacity = 0.3,
        Size = {w = 30, h = 30},
        DisplayOrder = 18,
        RotationOffset = 90
    },
    Drawing = {  -- Config para Drawing
        Color = {255, 0, 0},
        OutlineColor = {0, 0, 0},
        Opacity = 0.3,
        Size = {w = 30, h = 30},
        OutlineThickness = 6,
        LineThickness = 3
    }
}
```

### Controle de Distância

```lua
-- Configurar distância máxima (em studs)
ModelESP.GlobalSettings.MaxDistance = 1000

-- Configurar distância mínima
ModelESP.GlobalSettings.MinDistance = 0

-- Raio da arrow (distância da borda da tela)
ModelESP.GlobalSettings.ArrowRadius = 130
```

## 📖 Exemplos Práticos

### 🧑‍🤝‍🧑 ESP para Jogadores com Cores Personalizadas, Collision, Textos Customizados e Arrow

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- ===============================
-- CONFIGURAÇÕES GLOBAIS
-- ===============================
ModelESP:SetGlobalTracerOrigin("Top")  -- Origem do tracer: Top, Center, Bottom, Left, Right
ModelESP:SetGlobalRainbow(true)        -- Ativa modo arco-íris
ModelESP:SetGlobalOpacity(0.8)         -- Opacidade (0-1)
ModelESP:SetGlobalFontSize(16)         -- Tamanho da fonte
ModelESP:SetGlobalLineThickness(2)     -- Espessura da linha

-- Distâncias
ModelESP.GlobalSettings.MaxDistance = 500
ModelESP.GlobalSettings.MinDistance = 10
ModelESP.GlobalSettings.ArrowRadius = 150  -- Raio da arrow

-- Auto remoção de objetos inválidos
ModelESP.GlobalSettings.AutoRemoveInvalid = true

-- Tipos de ESP visíveis
ModelESP:SetGlobalESPType("ShowTracer", true)
ModelESP:SetGlobalESPType("ShowName", true)
ModelESP:SetGlobalESPType("ShowDistance", true)
ModelESP:SetGlobalESPType("ShowHighlightFill", true)
ModelESP:SetGlobalESPType("ShowHighlightOutline", true)
ModelESP:SetArrow{ShowArrow = true, Type = "Gui"}  -- Ativa arrow em GUI

-- Design da arrow
ModelESP:SetArrowDesign {
    Gui = {
        image = "rbxassetid://11552476728",
        Color = {255, 0, 0},
        Opacity = 0.5,
        Size = {w = 40, h = 40},
        DisplayOrder = 20
    }
}

-- ===============================
-- FUNÇÃO PARA ADICIONAR ESP A JOGADORES
-- ===============================
local function addPlayerESP(player)
    if player.Character then
        ModelESP:Add(player.Character, {
            Name = player.Name,
            Collision = false,
            DistanceSuffix = ".m",
            DistanceContainer = {Start = "(", End = ")"},
            Color = {
                Name = {144, 0, 255},         -- Nome roxo
                Distance = {144, 0, 255},     -- Distância roxa
                Tracer = {144, 0, 255},       -- Tracer roxo
                Highlight = {
                    Filled = {144, 0, 255},   -- Preenchimento roxo
                    Outline = {200, 0, 255}   -- Contorno roxo mais claro
                }
            }
        })
    end
end

-- Adicionar ESP para todos os jogadores atuais
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
        addPlayerESP(player)
    end
end

-- Adicionar ESP automaticamente para novos jogadores
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1) -- Espera o character carregar
        addPlayerESP(player)
    end)
end)

-- Remover ESP quando jogador sair
game.Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        ModelESP:Remove(player.Character)
    end
end)
```

### 🎯 ESP para Objetos Específicos com Collision, Textos Customizados e Arrow em Drawing

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configurar arrow em Drawing
ModelESP:SetArrow{ShowArrow = true, Type = "Drawing"}
ModelESP:SetArrowDesign {
    Drawing = {
        Color = {255, 0, 255},
        OutlineColor = {0, 0, 0},
        Opacity = 0.4,
        Size = {w = 25, h = 25},
        OutlineThickness = 4,
        LineThickness = 2
    }
}

-- ESP para partes específicas por nome
local function addPartESP(partName, espName, colorTable, collision, nameContainer, distanceSuffix, distanceContainer)
    for _, part in pairs(workspace:GetDescendants()) do
        if part.Name == partName and part:IsA("BasePart") then
            ModelESP:Add(part, {
                Name = espName or part.Name,
                Collision = collision or false,
                NameContainer = nameContainer or {Start = "[", End = "]"},
                DistanceSuffix = distanceSuffix or "m",
                DistanceContainer = distanceContainer or {Start = "(", End = ")"},
                Color = colorTable or {
                    Name = {255, 255, 0},
                    Distance = {255, 255, 0},
                    Tracer = {255, 255, 0},
                    Highlight = {
                        Filled = {255, 215, 0},
                        Outline = {255, 255, 0}
                    }
                }
            })
        end
    end
end

-- Exemplos de uso
addPartESP("Chest", "💰 Baú", {
    Name = {255, 255, 255},
    Distance = {255, 255, 255},
    Tracer = {255, 215, 0},
    Highlight = {
        Filled = {255, 215, 0},
        Outline = {255, 255, 255}
    }
}, true, {Start = "{", End = "}"}, ".m", {Start = "<", End = ">"})  -- Com Collision e textos customizados

addPartESP("Enemy", "👹 Inimigo", {
    Name = {255, 255, 255},
    Distance = {255, 255, 255},
    Tracer = {255, 0, 0},
    Highlight = {
        Filled = {200, 0, 0},
        Outline = {255, 0, 0}
    }
}, false)  -- Sem Collision, textos padrão

addPartESP("PowerUp", "⚡ Power-Up", {
    Name = {255, 255, 255},
    Distance = {255, 255, 255},
    Tracer = {0, 255, 255},
    Highlight = {
        Filled = {0, 200, 200},
        Outline = {0, 255, 255}
    }
}, true, {Start = "[", End = "]"}, " metros", {Start = "(", End = ")"})  -- Com Collision e sufixo customizado
```

### 🔍 ESP por Path Específico com Opções Avançadas e Arrow

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Ativar arrow em GUI com design customizado
ModelESP:SetArrow{ShowArrow = true, Type = "Gui"}
ModelESP:SetArrowDesign {
    Gui = {
        image = "rbxassetid://11552476728",
        Color = {0, 255, 0},
        Opacity = 0.6,
        Size = {w = 35, h = 35},
        DisplayOrder = 18,
        RotationOffset = 90
    }
}

-- ESP para objetos em caminhos específicos
local targets = {
    {
        path = "workspace.Map.Treasures",
        name = "💎 Tesouro",
        collision = true,
        nameContainer = {Start = "[", End = "]"},
        distanceSuffix = "m",
        distanceContainer = {Start = "(", End = ")"},
        color = {
            Name = {255, 255, 255},
            Distance = {255, 255, 255},
            Tracer = {255, 0, 255},
            Highlight = {
                Filled = {200, 0, 200},
                Outline = {255, 0, 255}
            }
        }
    },
    {
        path = "workspace.Enemies",
        name = "⚔️ Inimigo",
        collision = false,
        nameContainer = {Start = "{", End = "}"},
        distanceSuffix = ".m",
        distanceContainer = {Start = "<", End = ">"},
        color = {
            Name = {255, 255, 255},
            Distance = {255, 255, 255},
            Tracer = {255, 100, 100},
            Highlight = {
                Filled = {200, 50, 50},
                Outline = {255, 100, 100}
            }
        }
    },
    {
        path = "workspace.Items",
        name = "📦 Item",
        collision = true,
        nameContainer = {Start = "[", End = "]"},
        distanceSuffix = "m",
        distanceContainer = {Start = "(", End = ")"},
        color = {
            Name = {255, 255, 255},
            Distance = {255, 255, 255},
            Tracer = {100, 255, 100},
            Highlight = {
                Filled = {50, 200, 50},
                Outline = {100, 255, 100}
            }
        }
    }
}

for _, target in pairs(targets) do
    local obj = game
    for _, part in ipairs(target.path:split(".")) do
        obj = obj:FindFirstChild(part)
        if not obj then break end
    end
    if obj then
        for _, child in pairs(obj:GetChildren()) do
            if child:IsA("Model") or child:IsA("BasePart") then
                ModelESP:Add(child, {
                    Name = target.name,
                    Collision = target.collision,
                    NameContainer = target.nameContainer,
                    DistanceSuffix = target.distanceSuffix,
                    DistanceContainer = target.distanceContainer,
                    Color = target.color
                })
            end
        end
    end
end
```

### 🌈 Configuração Avançada

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configurar tema personalizado
ModelESP.Theme.PrimaryColor = Color3.fromRGB(130, 200, 255)
ModelESP.Theme.SecondaryColor = Color3.fromRGB(255, 255, 255)
ModelESP.Theme.OutlineColor = Color3.fromRGB(0, 0, 0)

-- Configurações avançadas
ModelESP:SetGlobalTracerOrigin("Center")
ModelESP:SetGlobalRainbow(true)
ModelESP:SetGlobalOpacity(0.9)
ModelESP:SetGlobalFontSize(18)
ModelESP:SetGlobalLineThickness(3)

-- Arrow avançada
ModelESP:SetArrow{ShowArrow = true, Type = "Drawing"}
ModelESP.GlobalSettings.ArrowRadius = 120

-- Definir distâncias
ModelESP.GlobalSettings.MaxDistance = 500 -- 500 studs máximo
ModelESP.GlobalSettings.MinDistance = 10  -- 10 studs mínimo

-- Habilitar auto-remoção de objetos inválidos
ModelESP.GlobalSettings.AutoRemoveInvalid = true
```

## ⚙️ Configurações Disponíveis

### GlobalSettings
```lua
{
    TracerOrigin = "Bottom",        -- Origem do tracer
    ShowTracer = true,              -- Mostrar linha tracer
    ShowHighlightFill = true,       -- Mostrar preenchimento do highlight
    ShowHighlightOutline = true,    -- Mostrar contorno do highlight
    ShowName = true,                -- Mostrar nome
    ShowDistance = true,            -- Mostrar distância
    ShowArrow = false,              -- Mostrar arrow off-screen
    ArrowType = "Drawing",          -- Tipo de arrow: "Drawing" ou "Gui"
    ArrowRadius = 130,              -- Raio da arrow (pixels)
    RainbowMode = false,            -- Modo arco-íris
    MaxDistance = math.huge,        -- Distância máxima
    MinDistance = 0,                -- Distância mínima
    Opacity = 0.8,                  -- Opacidade (0-1)
    LineThickness = 1.5,            -- Espessura da linha
    FontSize = 14,                  -- Tamanho da fonte
    AutoRemoveInvalid = true        -- Auto-remover objetos inválidos
}
```

### Estrutura de Configuração ao Adicionar ESP
```lua
{
    Name = "Nome Personalizado",                -- Nome exibido (opcional)
    Collision = true/false,                     -- Ativar modo Collision (opcional, padrão false)
    NameContainer = {Start = "[", End = "]"},   -- Container para o nome (opcional)
    DistanceSuffix = "m",                       -- Sufixo para distância (opcional)
    DistanceContainer = {Start = "(", End = ")"}, -- Container para distância (opcional)
    Color = { ... }                             -- Tabela de cores ou Color3 único (opcional)
}
```

### Estrutura de Cores Personalizadas
```lua
Color = {
    Name = {255, 255, 255},            -- Cor do texto do nome (RGB)
    Distance = {255, 255, 255},        -- Cor do texto da distância (RGB)
    Tracer = {0, 255, 0},              -- Cor da linha tracer (RGB)
    Highlight = {
        Filled = {100, 144, 0},        -- Cor do preenchimento do highlight (RGB)
        Outline = {0, 255, 0}          -- Cor do contorno do highlight (RGB)
    }
    -- Nota: Arrow usa cores globais do GlobalArrowDesign, mas herda RainbowMode
}
```

### GlobalArrowDesign
```lua
{
    Gui = {  -- Config para tipo "Gui"
        image = "rbxassetid://ID",     -- ID da imagem da seta
        Color = {255, 0, 0},           -- Cor (RGB)
        Opacity = 0.3,                 -- Opacidade (0-1)
        Size = {w = 30, h = 30},       -- Tamanho (largura x altura)
        DisplayOrder = 18,             -- Ordem de exibição
        RotationOffset = 90            -- Offset de rotação (graus)
    },
    Drawing = {  -- Config para tipo "Drawing"
        Color = {255, 0, 0},           -- Cor das linhas (RGB)
        OutlineColor = {0, 0, 0},      -- Cor do outline (RGB)
        Opacity = 0.3,                 -- Opacidade (0-1)
        Size = {w = 30, h = 30},       -- Tamanho base (largura x altura)
        OutlineThickness = 6,          -- Espessura do outline
        LineThickness = 3              -- Espessura das linhas principais
    }
}
```

## 🎮 Controles

```lua
-- Habilitar/desabilitar completamente a biblioteca
ModelESP.Enabled = true/false

-- Verificar status
print("ESP ativo:", ModelESP.Enabled)
print("Objetos rastreados:", #ModelESP.Objects)
```

## 📄 Licença

Esta biblioteca é fornecida como está, para uso educacional e de entretenimento em Roblox. Não é destinada a violar termos de serviço ou ser usada em contextos maliciosos.

---

**Desenvolvido por DH_SOARES** | Versão 1.4 | Última atualização: 15 de Setembro de 2025
