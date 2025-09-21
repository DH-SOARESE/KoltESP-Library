# 📦 Kolt ESP Library V1.4

Uma biblioteca ESP (Extra Sensory Perception) minimalista, eficiente e altamente customizável para Roblox, desenvolvida por **DH_SOARES**. Projetada para oferecer um sistema de ESP robusto e responsivo, com foco em performance e facilidade de uso.

## ✨ Características

- 🎯 **ESP Completo**: Suporte a Tracer, Nome, Distância e Highlight.
- 🌈 **Modo Arco-íris**: Cores dinâmicas que mudam automaticamente.
- 🎨 **Customização Avançada de Cores**: Suporte a cores individuais por elemento (Name, Distance, Tracer, Highlight) via tabela ou Color3.
- ⚡ **Performance Otimizada**: Sistema de auto-remoção de objetos inválidos, verificação de duplicatas e atualizações eficientes por frame.
- 📱 **Responsivo**: Adapta-se a diferentes resoluções, com posicionamento preciso mesmo em distâncias próximas (1-10 metros).
- 🔧 **Fácil de Usar**: API intuitiva com métodos para gerenciamento avançado de ESPs.
- 🆕 **ESP Collision (Opcional e Individual)**: Cria um Humanoid "Kolt ESP" no alvo e ajusta transparência de parts invisíveis (de 1 para 0.99) para melhor detecção de colisões ou visibilidade.
- 🆕 **Customização de Textos**: Propriedades individuais para containers de nome (ex: `{Nome}`) e distância (ex: `<10.5.metros>`), com sufixos configuráveis.
- 🆕 **Novos Métodos**: Inclui `Readjustment` para mudar o alvo de um ESP, `ToggleIndividual`, `SetColor`, `SetName` e `UpdateConfig` para maior controle.
- 🐛 **Correções e Melhorias**: Evita duplicatas no método `Add`, otimiza gerenciamento de transparência e melhora a modularidade do código.

## 🚀 Instalação

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()
```

## 📋 Sumário (Atalhos)

- [Características](#-características)
- [Instalação](#-instalação)
- [Funcionalidades](#-funcionalidades)
- [Uso Básico](#️-uso-básico)
- [Gerenciamento Avançado](#-gerenciamento-avançado)
- [Configurações Globais](#-configurações-globais)
- [Exemplos Práticos](#-exemplos-práticos)
- [Configurações Disponíveis](#️-configurações-disponíveis)
- [Controles](#-controles)
- [Licença](#-licença)

## 📋 Funcionalidades

### 🎯 Componentes ESP
- **Tracer**: Linha do ponto de origem configurável até o centro do alvo.
- **Nome**: Exibe o nome do objeto, centralizado, com container personalizável (ex: `{Nome}`).
- **Distância**: Mostra a distância em metros com formatação precisa (ex: `<10.5.metros>`), com sufixo e container customizáveis.
- **Highlight**: Contorno e preenchimento colorido ao redor do objeto, com transparências ajustáveis.

### 🎮 Origens do Tracer
- `Top` - Topo da tela.
- `Center` - Centro da tela.
- `Bottom` - Parte inferior da tela (padrão).
- `Left` - Lateral esquerda.
- `Right` - Lateral direita.

### 🆕 Opção de Collision
- Ativada individualmente via `Collision = true` na configuração.
- Cria um Humanoid chamado "Kolt ESP" no alvo (se não existir).
- Ajusta temporariamente a transparência de parts com valor 1 para 0.99.
- Restaura transparências originais e remove Humanoid ao remover o ESP.

### 🆕 Propriedades Individuais para Textos
- **NameContainer**: Tabela com `Start` e `End` para envolver o nome (padrão: vazio).
- **DistanceSuffix**: Sufixo após o valor da distância (padrão: vazio).
- **DistanceContainer**: Tabela com `Start` e `End` para envolver a distância (padrão: vazio).

### 🆕 APIs Avançadas
- **Readjustment**: Altera o alvo de um ESP existente, aplicando nova configuração.
- **ToggleIndividual**: Habilita/desabilita um ESP específico sem removê-lo.
- **SetColor**: Define uma cor única para todos os elementos de um ESP.
- **SetName**: Altera o nome exibido de um ESP.
- **UpdateConfig**: Atualiza configurações de um ESP existente (nome, cores, containers, etc.) sem mudar o alvo.

## 🛠️ Uso Básico

### Adicionando ESP a um Objeto

```lua
-- Carregar a biblioteca
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Adicionar ESP básico
ModelESP:Add(workspace.SomeModel)

-- Adicionar ESP com nome, cor única, Collision e customização de textos
ModelESP:Add(workspace.SomeModel, {
    Name = "Alvo Especial",
    Color = Color3.fromRGB(255, 0, 0),
    Collision = true,
    NameContainer = {Start = "{", End = "}"},
    DistanceSuffix = ".metros",
    DistanceContainer = {Start = "<", End = ">"}
})

-- Adicionar ESP com cores personalizadas por elemento
ModelESP:Add(workspace.SomeModel, {
    Name = "Alvo Especial",
    Collision = true,
    NameContainer = {Start = "[", End = "]"},
    DistanceSuffix = "m",
    DistanceContainer = {Start = "(", End = ")"},
    Color = {
        Name = {255, 255, 255},
        Distance = {255, 255, 255},
        Tracer = {0, 255, 0},
        Highlight = {
            Filled = {100, 144, 0},
            Outline = {0, 255, 0}
        }
    }
})
```

## 🛠️ Gerenciamento Avançado

### Reajustando um ESP para Novo Alvo

```lua
-- Reajusta o ESP de um alvo antigo para um novo alvo com nova configuração
ModelESP:Readjustment(workspace.NewModel, workspace.OldModel, {
    Name = "Novo Alvo",
    Color = Color3.fromRGB(0, 255, 255),
    Collision = false,
    NameContainer = {Start = "[", End = "]"},
    DistanceSuffix = "m",
    DistanceContainer = {Start = "(", End = ")"}
})
```

### Atualizando Configurações de um ESP Existente

```lua
-- Atualiza configurações sem mudar o alvo
ModelESP:UpdateConfig(workspace.SomeModel, {
    Name = "Alvo Atualizado",
    Color = {
        Name = {255, 255, 0},
        Distance = {255, 255, 0},
        Tracer = {255, 215, 0},
        Highlight = {
            Filled = {255, 200, 0},
            Outline = {255, 255, 0}
        }
    },
    Collision = false,
    NameContainer = {Start = "{", End = "}"},
    DistanceSuffix = ".metros"
})
```

### Controlando ESP Individualmente

```lua
-- Desabilitar ESP de um objeto sem removê-lo
ModelESP:ToggleIndividual(workspace.SomeModel, false)

-- Alterar apenas a cor
ModelESP:SetColor(workspace.SomeModel, Color3.fromRGB(0, 255, 0))

-- Alterar apenas o nome
ModelESP:SetName(workspace.SomeModel, "Novo Nome")
```

### Removendo ESP

```lua
-- Remover ESP de um objeto específico (restaura transparências e remove Humanoid)
ModelESP:Remove(workspace.SomeModel)

-- Limpar todos os ESPs
ModelESP:Clear()
```

## 🎨 Configurações Globais

### Habilitando/Desabilitando Componentes

```lua
ModelESP:SetGlobalESPType("ShowTracer", true)
ModelESP:SetGlobalESPType("ShowName", true)
ModelESP:SetGlobalESPType("ShowDistance", true)
ModelESP:SetGlobalESPType("ShowHighlightFill", true)
ModelESP:SetGlobalESPType("ShowHighlightOutline", true)
```

### Personalizando Aparência

```lua
ModelESP:SetGlobalTracerOrigin("Bottom") -- Top, Center, Bottom, Left, Right
ModelESP:SetGlobalRainbow(true)
ModelESP:SetGlobalOpacity(0.8)
ModelESP:SetGlobalFontSize(16)
ModelESP:SetGlobalLineThickness(2)
```

### Controle de Distância

```lua
ModelESP.GlobalSettings.MaxDistance = 1000
ModelESP.GlobalSettings.MinDistance = 0
```

## 📖 Exemplos Práticos

### 🧑‍🤝‍🧑 ESP para Jogadores com Cores Personalizadas

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configurações globais
ModelESP:SetGlobalTracerOrigin("Top")
ModelESP:SetGlobalRainbow(true)
ModelESP:SetGlobalOpacity(0.8)
ModelESP:SetGlobalFontSize(16)
ModelESP:SetGlobalLineThickness(2)
ModelESP.GlobalSettings.MaxDistance = 500
ModelESP.GlobalSettings.MinDistance = 10
ModelESP.GlobalSettings.AutoRemoveInvalid = true
ModelESP:SetGlobalESPType("ShowTracer", true)
ModelESP:SetGlobalESPType("ShowName", true)
ModelESP:SetGlobalESPType("ShowDistance", true)
ModelESP:SetGlobalESPType("ShowHighlightFill", true)
ModelESP:SetGlobalESPType("ShowHighlightOutline", true)

-- Função para adicionar ESP a jogadores
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
                Tracer = {144, 0, 255},
                Highlight = {
                    Filled = {144, 0, 255},
                    Outline = {200, 0, 255}
                }
            }
        })
    end
end

-- Adicionar ESP para jogadores atuais
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
        addPlayerESP(player)
    end
end

-- Adicionar ESP para novos jogadores
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
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

### 🎯 ESP para Objetos Específicos com Collision

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Função para adicionar ESP a partes por nome
local function addPartESP(partName, espName, colorTable, collision, nameContainer, distanceSuffix, distanceContainer)
    for _, part in pairs(workspace:GetDescendants()) do
        if part.Name == partName and (part:IsA("BasePart") or part:IsA("Model")) then
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
}, true, {Start = "{", End = "}"}, ".m", {Start = "<", End = ">"})

addPartESP("Enemy", "👹 Inimigo", {
    Name = {255, 255, 255},
    Distance = {255, 255, 255},
    Tracer = {255, 0, 0},
    Highlight = {
        Filled = {200, 0, 0},
        Outline = {255, 0, 0}
    }
}, false)

addPartESP("PowerUp", "⚡ Power-Up", {
    Name = {255, 255, 255},
    Distance = {255, 255, 255},
    Tracer = {0, 255, 255},
    Highlight = {
        Filled = {0, 200, 200},
        Outline = {0, 255, 255}
    }
}, true, {Start = "[", End = "]"}, " metros", {Start = "(", End = ")"})
```

### 🔍 ESP por Path Específico com Reajuste Dinâmico

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configuração de alvos
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

-- Exemplo de reajuste dinâmico
game:GetService("RunService").Heartbeat:Connect(function()
    local oldTarget = workspace.OldModel
    local newTarget = workspace.NewModel
    if newTarget and oldTarget then
        ModelESP:Readjustment(newTarget, oldTarget, {
            Name = "Novo Tesouro",
            Collision = true,
            Color = {
                Name = {255, 255, 255},
                Distance = {255, 255, 255},
                Tracer = {0, 255, 255},
                Highlight = {
                    Filled = {0, 200, 200},
                    Outline = {0, 255, 255}
                }
            }
        })
    end
end)
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
    RainbowMode = false,
    MaxDistance = math.huge,
    MinDistance = 0,
    Opacity = 0.8,
    LineThickness = 1.5,
    FontSize = 14,
    AutoRemoveInvalid = true
}
```

### Estrutura de Configuração ao Adicionar/Reajustar ESP
```lua
{
    Name = "Nome Personalizado",
    Collision = true/false,
    NameContainer = {Start = "[", End = "]"},
    DistanceSuffix = "m",
    DistanceContainer = {Start = "(", End = ")"},
    Color = { ... } -- Tabela de cores ou Color3 único
}
```

### Estrutura de Cores Personalizadas
```lua
Color = {
    Name = {255, 255, 255},
    Distance = {255, 255, 255},
    Tracer = {0, 255, 0},
    Highlight = {
        Filled = {100, 144, 0},
        Outline = {0, 255, 0}
    }
}
```

## 🎮 Controles

```lua
-- Habilitar/desabilitar a biblioteca
ModelESP.Enabled = true/false

-- Verificar status
print("ESP ativo:", ModelESP.Enabled)
print("Objetos rastreados:", #ModelESP.Objects)
```

**Desenvolvido por DH_SOARES** | Versão 1.4 | Última atualização: Setembro 2025
