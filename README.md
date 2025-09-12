# KoltESP Library v1.0

Uma biblioteca poderosa e flexível para ESP (Extra Sensory Perception) no Roblox, orientada a objetos e com suporte completo para múltiplos tipos de visualização.

## 📋 Índice

- [Instalação](#instalação)
- [Recursos](#recursos)
- [Configuração Global](#configuração-global)
- [Métodos Principais](#métodos-principais)
- [Exemplos de Uso](#exemplos-de-uso)
- [Referência da API](#referência-da-api)
- [Exemplos Avançados](#exemplos-avançados)
- [Troubleshooting](#troubleshooting)

## 🚀 Instalação

A biblioteca é carregada via `loadstring` diretamente do GitHub:

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()
```

## ✨ Recursos

- **Tracer Lines**: Linhas conectando objetos à tela
- **Name Display**: Exibição de nomes personalizados
- **Distance Display**: Mostra distância em tempo real
- **3D Highlights**: Contorno e preenchimento 3D
- **Configuração Flexível**: Cores e configurações por objeto
- **Sistema de Pausar**: Controle total sobre renderização
- **Otimizado**: Sistema eficiente de renderização
- **Compatibilidade**: Funciona com BasePart e Model

## ⚙️ Configuração Global

A biblioteca possui configurações globais que afetam todos os objetos:

```lua
KoltESP.Config = {
    Tracer = { 
        Visible = true,           -- Mostrar tracers
        Origin = "Bottom",        -- "Top", "Center", "Bottom"
        Thickness = 1            -- Espessura da linha
    },
    Name = { 
        Visible = true           -- Mostrar nomes
    },
    Distance = { 
        Visible = true           -- Mostrar distâncias
    },
    Highlight = { 
        Outline = true,          -- Contorno 3D
        Filled = true,           -- Preenchimento 3D
        Transparency = { 
            Outline = 0.3,       -- Transparência do contorno
            Filled = 0.5         -- Transparência do preenchimento
        }
    },
    DistanceMax = 300,           -- Distância máxima para renderizar
    DistanceMin = 5              -- Distância mínima para renderizar
}
```

## 📚 Métodos Principais

### KoltESP:Add(objeto, configuração)

Adiciona um novo objeto ao sistema ESP.

**Parâmetros:**
- `objeto`: Instance do Roblox ou string com caminho
- `configuração`: Tabela com configurações do objeto

**Retorna:** Referência do target criado

### KoltESP.Remove(target)

Remove um target específico do sistema.

### KoltESP.Clear()

Remove todos os targets ativos.

### KoltESP.Pause(boolean)

Pausa ou resume a renderização.

### KoltESP.Unload()

Descarrega completamente a biblioteca.

## 🎯 Exemplos de Uso

### Exemplo Básico

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- ESP simples em um jogador
local target = KoltESP:Add(game.Players.SomePlayer.Character, {
    EspColor = {255, 0, 0},  -- Vermelho
    EspName = {
        DisplayName = "Inimigo",
        Container = " [ALVO]"
    }
})
```

### Exemplo com Todas as Funcionalidades

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configurar globalmente
KoltESP.Config.Tracer.Origin = "Center"
KoltESP.Config.DistanceMax = 500

-- Adicionar ESP completo
local player = game.Players.LocalPlayer
local targetPlayer = game.Players:FindFirstChild("TargetName")

if targetPlayer and targetPlayer.Character then
    local target = KoltESP:Add(targetPlayer.Character, {
        EspColor = {0, 255, 255},  -- Ciano
        EspName = {
            DisplayName = targetPlayer.DisplayName,
            Container = " ⭐"
        },
        EspDistance = {
            Container = "[%d metros]",  -- %d será substituído pela distância
            Suffix = ""
        },
        Colors = {
            EspTracer = {255, 255, 0},        -- Tracer amarelo
            EspNameColor = {0, 255, 0},       -- Nome verde
            EspDistanceColor = {255, 255, 255}, -- Distância branca
            EspHighlight = {
                Outline = {255, 0, 0},        -- Contorno vermelho
                Filled = {0, 0, 255}          -- Preenchimento azul
            }
        }
    })
end
```

### ESP em Múltiplos Jogadores

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Função para adicionar ESP a um jogador
local function addPlayerESP(player)
    if player == LocalPlayer then return end
    
    local function onCharacterAdded(character)
        wait(1) -- Aguardar character carregar
        
        KoltESP:Add(character, {
            EspColor = {255, 165, 0},  -- Laranja
            EspName = {
                DisplayName = player.DisplayName,
                Container = " 👤"
            },
            EspDistance = {
                Container = "%dm",
                Suffix = ""
            }
        })
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
end

-- Adicionar ESP para jogadores existentes
for _, player in pairs(Players:GetPlayers()) do
    addPlayerESP(player)
end

-- Adicionar ESP para novos jogadores
Players.PlayerAdded:Connect(addPlayerESP)
```

### ESP em Objetos Específicos

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- ESP em baús ou itens
for _, obj in pairs(workspace:GetDescendants()) do
    if obj.Name == "Chest" or obj.Name == "Treasure" then
        KoltESP:Add(obj, {
            EspColor = {255, 215, 0},  -- Dourado
            EspName = {
                DisplayName = "💰 Tesouro",
                Container = ""
            },
            EspDistance = {
                Container = "[%d]",
                Suffix = "m"
            },
            Colors = {
                EspHighlight = {
                    Outline = {255, 215, 0},
                    Filled = {255, 255, 0}
                }
            }
        })
    end
end
```

## 📖 Referência da API

### Estrutura de Configuração do Objeto

```lua
local config = {
    EspColor = {R, G, B},              -- Cor padrão (0-255)
    EspName = {
        DisplayName = "string",         -- Nome a ser exibido
        Container = "string"            -- Texto adicional
    },
    EspDistance = {
        Container = "formato",          -- Use %d para distância
        Suffix = "string"               -- Sufixo após a distância
    },
    Colors = {                          -- Cores específicas (opcional)
        EspTracer = {R, G, B},
        EspNameColor = {R, G, B},
        EspDistanceColor = {R, G, B},
        EspHighlight = {
            Outline = {R, G, B},
            Filled = {R, G, B}
        }
    }
}
```

### Propriedades do Target

Cada target retornado por `KoltESP:Add()` possui:

```lua
target = {
    Object = Instance,          -- Objeto original
    EspColor = {R, G, B},      -- Cor configurada
    EspName = {...},           -- Configuração de nome
    EspDistance = {...},       -- Configuração de distância
    Colors = {...},            -- Cores específicas
    Tracer = DrawingObject,    -- Objeto de linha
    NameText = DrawingObject,  -- Texto do nome
    DistanceText = DrawingObject, -- Texto da distância
    Highlight = Instance       -- Highlight 3D
}
```

## 🔧 Exemplos Avançados

### Sistema de ESP com Toggle

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()
local UserInputService = game:GetService("UserInputService")

local espEnabled = true
local targets = {}

-- Função toggle
local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        print("ESP Ativado")
        -- Recriar targets
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                local target = KoltESP:Add(player.Character, {
                    EspColor = {255, 100, 100},
                    EspName = {
                        DisplayName = player.Name,
                        Container = ""
                    }
                })
                table.insert(targets, target)
            end
        end
    else
        print("ESP Desativado")
        KoltESP.Clear()
        targets = {}
    end
end

-- Bind da tecla F
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        toggleESP()
    end
end)
```

### ESP com Diferentes Distâncias

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configurar diferentes ranges
KoltESP.Config.DistanceMax = 1000
KoltESP.Config.DistanceMin = 10

local function getColorByDistance(distance)
    if distance < 50 then
        return {255, 0, 0}  -- Vermelho - muito perto
    elseif distance < 150 then
        return {255, 255, 0}  -- Amarelo - perto
    elseif distance < 300 then
        return {0, 255, 0}  -- Verde - médio
    else
        return {0, 0, 255}  -- Azul - longe
    end
end

-- Adicionar com cores dinâmicas
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer and player.Character then
        local distance = (game.Players.LocalPlayer.Character.Head.Position - player.Character.Head.Position).Magnitude
        local color = getColorByDistance(distance)
        
        KoltESP:Add(player.Character, {
            EspColor = color,
            EspName = {
                DisplayName = player.Name,
                Container = string.format(" [%.0fm]", distance)
            }
        })
    end
end
```

### ESP com Filtros

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

local targetNames = {"Player1", "Player2", "VIP_User"}
local ignoredNames = {"Friend1", "Ally2"}

local function shouldAddESP(player)
    -- Apenas jogadores específicos
    if #targetNames > 0 then
        for _, name in pairs(targetNames) do
            if player.Name:lower():find(name:lower()) then
                return true, {255, 0, 0}  -- Vermelho para alvos
            end
        end
        return false
    end
    
    -- Ignorar amigos
    for _, name in pairs(ignoredNames) do
        if player.Name:lower():find(name:lower()) then
            return false
        end
    end
    
    return true, {255, 255, 255}  -- Branco para outros
end

-- Aplicar filtros
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
        local should, color = shouldAddESP(player)
        if should and player.Character then
            KoltESP:Add(player.Character, {
                EspColor = color,
                EspName = {
                    DisplayName = player.DisplayName,
                    Container = ""
                }
            })
        end
    end
end
```

### Sistema de ESP Responsivo

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local activeTargets = {}

-- Função para atualizar ESP baseado na performance
local lastUpdate = 0
local updateInterval = 1 -- segundos

RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lastUpdate < updateInterval then return end
    lastUpdate = now
    
    local fps = math.floor(1 / RunService.Heartbeat:Wait())
    
    -- Ajustar qualidade baseado no FPS
    if fps < 30 then
        -- Performance baixa - reduzir qualidade
        KoltESP.Config.DistanceMax = 200
        KoltESP.Config.Tracer.Visible = false
        KoltESP.Config.Highlight.Filled = false
        updateInterval = 2
    elseif fps > 60 then
        -- Performance alta - máxima qualidade
        KoltESP.Config.DistanceMax = 500
        KoltESP.Config.Tracer.Visible = true
        KoltESP.Config.Highlight.Filled = true
        updateInterval = 0.5
    end
end)
```

## 🐛 Troubleshooting

### Problemas Comuns

1. **ESP não aparece:**
   - Verifique se o objeto existe e tem Parent
   - Confirme se está dentro da distância configurada
   - Verifique se o objeto é BasePart ou Model com PrimaryPart

2. **Performance baixa:**
   - Reduza `DistanceMax` na configuração
   - Desative highlight fill: `KoltESP.Config.Highlight.Filled = false`
   - Use `KoltESP.Pause(true)` quando não precisar

3. **Cores não funcionam:**
   - Use valores RGB de 0-255
   - Formato correto: `{255, 0, 0}` para vermelho

4. **Tracer na posição errada:**
   - Configure `KoltESP.Config.Tracer.Origin` para "Top", "Center" ou "Bottom"

### Exemplo de Debugging

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Debug function
local function debugESP()
    print("=== KoltESP Debug ===")
    print("Config:", KoltESP.Config)
    print("Targets ativos:", #targets or "N/A")
    
    -- Testar objeto simples
    local testPart = Instance.new("Part")
    testPart.Name = "ESP_Test"
    testPart.Position = Vector3.new(0, 10, 0)
    testPart.BrickColor = BrickColor.new("Bright red")
    testPart.Parent = workspace
    
    local target = KoltESP:Add(testPart, {
        EspColor = {0, 255, 0},
        EspName = {
            DisplayName = "TESTE",
            Container = " ✓"
        }
    })
    
    if target then
        print("Target criado com sucesso!")
    else
        print("Falha ao criar target")
    end
end

-- Executar debug
debugESP()
```

### Limpeza e Gerenciamento

```lua
-- Limpeza automática de objetos removidos
game:GetService("RunService").Heartbeat:Connect(function()
    -- A biblioteca já faz isso automaticamente
    -- Este é apenas um exemplo de como implementar verificações extras
end)

-- Limpeza manual quando sair do jogo
game.Players.LocalPlayer.CharacterRemoving:Connect(function()
    KoltESP.Unload()
end)

-- Limpeza de memória periódica
spawn(function()
    while wait(30) do -- A cada 30 segundos
        collectgarbage("collect")
    end
end)
```

## 📄 Licença

Esta biblioteca é fornecida "como está". Use por sua própria conta e risco.

## 🤝 Contribuição

Para reportar bugs ou sugerir melhorias, abra uma issue no repositório GitHub.

---

**KoltESP Library v1.0** - Uma solução completa para ESP no Roblox
