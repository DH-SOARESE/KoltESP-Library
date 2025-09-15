# 📦 Kolt ESP Library V1.3

Uma biblioteca ESP (Extra Sensory Perception) minimalista, eficiente e responsiva para Roblox, desenvolvida por **DH_SOARES**.

## ✨ Características

- 🎯 **ESP Completo**: Tracer, Nome, Distância e Highlight
- 🌈 **Modo Arco-íris**: Cores dinâmicas que mudam automaticamente
- 🎨 **Customização Avançada de Cores**: Suporte a cores individuais por elemento (Name, Distance, Tracer, Highlight) via tabela ou Color3
- ⚡ **Performance Otimizada**: Sistema de auto-remoção de objetos inválidos e atualizações eficientes por frame
- 📱 **Responsivo**: Adapta-se a diferentes resoluções de tela, com posicionamento preciso mesmo em distâncias próximas
- 🔧 **Fácil de Usar**: API simples e intuitiva
- 🆕 **ESP Collision (Opcional e Individual)**: Cria um Humanoid "Kolt ESP" no alvo e ajusta a transparência de parts invisíveis (de 1 para 0.99) para melhor detecção de colisões ou visibilidade
- 🐛 **Correções Recentes**: Melhoria no posicionamento de textos (Name e Distance) para evitar distorções quando o jogador está próximo (1-10 metros) do alvo

## 🚀 Instalação

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()
```

## 📋 Funcionalidades

### 🎯 Componentes ESP
- **Tracer**: Linha do ponto de origem até o centro do alvo
- **Nome**: Exibe o nome do objeto, centralizado
- **Distância**: Mostra a distância em metros, com formatação precisa (ex: "10.5m")
- **Highlight**: Contorno e preenchimento colorido ao redor do objeto, com transparências ajustáveis

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

## 🛠️ Uso Básico

### Adicionando ESP a um Objeto

```lua
-- Carregar a biblioteca
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Adicionar ESP básico
ModelESP:Add(workspace.SomeModel)

-- Adicionar ESP com nome personalizado, cor única e Collision ativada
ModelESP:Add(workspace.SomeModel, {
    Name = "Alvo Especial",
    Color = Color3.fromRGB(255, 0, 0),
    Collision = true  -- Ativa o modo Collision
})

-- Adicionar ESP com cores personalizadas por elemento e Collision
ModelESP:Add(workspace.SomeModel, {
    Name = "Alvo Especial",
    Collision = true,
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
```

### Controle de Distância

```lua
-- Configurar distância máxima (em studs)
ModelESP.GlobalSettings.MaxDistance = 1000

-- Configurar distância mínima
ModelESP.GlobalSettings.MinDistance = 0
```

## 📖 Exemplos Práticos

### 🧑‍🤝‍🧑 ESP para Jogadores com Cores Personalizadas e Collision

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Função para adicionar ESP a todos os jogadores
local function addPlayerESP()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            ModelESP:Add(player.Character, {
                Name = player.Name,
                Collision = true,  -- Ativa Collision para este jogador
                Color = {
                    Name = {255, 255, 255},        -- Nome em branco
                    Distance = {255, 255, 255},    -- Distância em branco
                    Tracer = {0, 255, 0},          -- Tracer verde
                    Highlight = {
                        Filled = {100, 144, 0},    -- Preenchimento verde escuro
                        Outline = {0, 255, 0}      -- Contorno verde
                    }
                }
            })
        end
    end
end

-- Adicionar ESP aos jogadores atuais
addPlayerESP()

-- Adicionar ESP automaticamente para novos jogadores
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        wait(1) -- Aguardar o character carregar completamente
        ModelESP:Add(character, {
            Name = player.Name,
            Collision = true,
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

-- ESP para partes específicas por nome
local function addPartESP(partName, espName, colorTable, collision)
    for _, part in pairs(workspace:GetDescendants()) do
        if part.Name == partName and part:IsA("BasePart") then
            ModelESP:Add(part, {
                Name = espName or part.Name,
                Collision = collision or false,
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
}, true)  -- Com Collision ativado

addPartESP("Enemy", "👹 Inimigo", {
    Name = {255, 255, 255},
    Distance = {255, 255, 255},
    Tracer = {255, 0, 0},
    Highlight = {
        Filled = {200, 0, 0},
        Outline = {255, 0, 0}
    }
}, false)  -- Sem Collision

addPartESP("PowerUp", "⚡ Power-Up", {
    Name = {255, 255, 255},
    Distance = {255, 255, 255},
    Tracer = {0, 255, 255},
    Highlight = {
        Filled = {0, 200, 200},
        Outline = {0, 255, 255}
    }
}, true)  -- Com Collision
```

### 🔍 ESP por Path Específico com Opções Avançadas

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- ESP para objetos em caminhos específicos
local targets = {
    {
        path = "workspace.Map.Treasures",
        name = "💎 Tesouro",
        collision = true,
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
    Name = "Nome Personalizado",    -- Nome exibido (opcional)
    Collision = true/false,         -- Ativar modo Collision (opcional, padrão false)
    Color = { ... }                 -- Tabela de cores ou Color3 único (opcional)
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

**Desenvolvido por DH_SOARES** | Versão 1.3 | Última atualização: Setembro 2025
