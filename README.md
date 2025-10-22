# Kolt ESP Library V1.6.5

Biblioteca ESP (Extra Sensory Perception) minimalista e eficiente para Roblox, desenvolvida por **Kolt (DH_SOARES)**. Sistema robusto focado em performance, facilidade de uso e gerenciamento otimizado de recursos.

## Características Principais

- **ESP Completo**: Tracer, Nome, Distância e Highlight (preenchimento e outline)
- **Performance Otimizada**: Auto-remoção de objetos inválidos, verificação de duplicatas, atualizações eficientes
- **Customização Avançada**: Cores individuais por elemento, fontes, opacidades, espessuras
- **Sistema de Camadas**: DisplayOrder individual para controle de sobreposição
- **Gerenciamento de Recursos**: Limpeza automática ao pausar, recriação ao retomar
- **Highlights Centralizados**: Armazenamento em pasta do ReplicatedStorage com Adornee
- **Modo Rainbow**: Cores dinâmicas automáticas
- **Collision Opcional**: Destaque de todas as partes do alvo
- **Dependência de Cor Dinâmica**: Cálculo de cores baseado em distância ou posição

## Instalação

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()
```

## Documentação

### Índice

1. [Uso Básico](#uso-básico)
2. [Configurações Globais](#configurações-globais)
3. [Gerenciamento Avançado](#gerenciamento-avançado)
4. [Referência de API](#referência-de-api)
5. [Exemplos Práticos](#exemplos-práticos)

---

## Uso Básico

### Adicionando ESP Simples

```lua
-- ESP básico com configurações padrão
KoltESP:Add(workspace.SomeModel)

-- ESP com nome personalizado
KoltESP:Add(workspace.SomeModel, {
    Name = "Alvo Especial"
})
```

### Adicionando ESP Completo

```lua
KoltESP:Add(workspace.SomeModel, {
    Name = "Alvo Especial",
    Color = Color3.fromRGB(255, 0, 0),
    Collision = true,
    DistancePrefix = "Dist: ",
    DistanceSuffix = "m",
    DisplayOrder = 5,
    Types = {
        Tracer = true,
        Name = true,
        Distance = true,
        HighlightFill = false,
        HighlightOutline = true
    },
    Font = 3,
    Opacity = 0.9,
    LineThickness = 2,
    FontSize = 16,
    MaxDistance = 500,
    MinDistance = 10
})
```

---

## Configurações Globais

### Componentes Visuais

```lua
-- Habilitar/desabilitar componentes
KoltESP:SetGlobalESPType("ShowTracer", true)
KoltESP:SetGlobalESPType("ShowName", true)
KoltESP:SetGlobalESPType("ShowDistance", true)
KoltESP:SetGlobalESPType("ShowHighlightFill", true)
KoltESP:SetGlobalESPType("ShowHighlightOutline", true)
```

### Aparência

```lua
-- Origem do tracer
KoltESP:SetGlobalTracerOrigin("Bottom") -- Top, Center, Bottom, Left, Right

-- Estilo visual
KoltESP:SetGlobalRainbow(true)
KoltESP:SetGlobalOpacity(0.8)
KoltESP:SetGlobalFontSize(16)
KoltESP:SetGlobalLineThickness(2)
KoltESP:SetGlobalFont(3) -- 0: UI, 1: System, 2: Plex, 3: Monospace

-- Transparência dos highlights
KoltESP:SetGlobalHighlightTransparency({
    Filled = 0.5,
    Outline = 0.3
})

-- Contorno de texto
KoltESP:SetGlobalTextOutline(true, Color3.fromRGB(0, 0, 0), 1)
```

### Distância

```lua
KoltESP.GlobalSettings.MaxDistance = 1000
KoltESP.GlobalSettings.MinDistance = 0
```

### Controle Geral

```lua
KoltESP:EnableAll()  -- Ativa todos os ESPs
KoltESP:DisableAll() -- Desativa todos os ESPs
KoltESP:Clear()      -- Remove todos os ESPs
KoltESP:Unload()     -- Descarrega a biblioteca completamente
```

---

## Gerenciamento Avançado

### Reajustar ESP

```lua
KoltESP:Readjustment(workspace.NewModel, workspace.OldModel, {
    Name = "Novo Alvo",
    Color = Color3.fromRGB(0, 255, 255),
    DisplayOrder = 8
})
```

### Atualizar Configurações

```lua
KoltESP:UpdateConfig(workspace.SomeModel, {
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
    DisplayOrder = 3,
    Types = {
        Distance = false,
        HighlightOutline = true
    }
})
```

### Controle Individual

```lua
-- Alternar visibilidade
KoltESP:ToggleIndividual(workspace.SomeModel, false)

-- Alterar propriedades
KoltESP:SetColor(workspace.SomeModel, Color3.fromRGB(0, 255, 0))
KoltESP:SetName(workspace.SomeModel, "Novo Nome")
KoltESP:SetDisplayOrder(workspace.SomeModel, 7)
KoltESP:SetTextOutline(workspace.SomeModel, true, Color3.fromRGB(0, 0, 0), 1)

-- Remover
KoltESP:Remove(workspace.SomeModel)
```

---

## Referência de API

### Métodos Principais

#### Add
```lua
KoltESP:Add(object, config)
```
Adiciona ESP a um objeto. Retorna `true` se bem-sucedido.

#### Remove
```lua
KoltESP:Remove(object)
```
Remove ESP de um objeto.

#### Clear
```lua
KoltESP:Clear()
```
Remove todos os ESPs.

#### Unload
```lua
KoltESP:Unload()
```
Descarrega completamente a biblioteca, limpando todos os recursos.

#### AddToPlayer
```lua
KoltESP:AddToPlayer(player, config)
```
Adiciona ESP ao character de um jogador.

#### RemoveFromPlayer
```lua
KoltESP:RemoveFromPlayer(player)
```
Remove ESP do character de um jogador.

### Métodos de Atualização

#### UpdateConfig
```lua
KoltESP:UpdateConfig(object, config)
```
Atualiza configurações de um ESP existente.

#### Readjustment
```lua
KoltESP:Readjustment(newObject, oldObject, config)
```
Move ESP de um objeto para outro.

#### ToggleIndividual
```lua
KoltESP:ToggleIndividual(object, enabled)
```
Ativa/desativa ESP individual.

### Métodos de Configuração Global

#### SetGlobalESPType
```lua
KoltESP:SetGlobalESPType(type, enabled)
```
Tipos: `ShowTracer`, `ShowName`, `ShowDistance`, `ShowHighlightFill`, `ShowHighlightOutline`

#### SetGlobalTracerOrigin
```lua
KoltESP:SetGlobalTracerOrigin(origin)
```
Origens: `Top`, `Center`, `Bottom`, `Left`, `Right`

#### SetGlobalHighlightTransparency
```lua
KoltESP:SetGlobalHighlightTransparency({Filled = 0.5, Outline = 0.3})
```

#### SetHighlightFolderName
```lua
KoltESP:SetHighlightFolderName(name)
```
Define nome da pasta de highlights no ReplicatedStorage.

---

## Exemplos Práticos

### ESP para Jogadores

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configuração inicial
KoltESP:SetHighlightFolderName("PlayerESPHighlights")
KoltESP:SetGlobalHighlightTransparency({Filled = 0.7, Outline = 0.2})
KoltESP:SetGlobalTracerOrigin("Top")
KoltESP.GlobalSettings.MaxDistance = 500

local function addPlayerESP(player)
    if player == game.Players.LocalPlayer then return end
    
    KoltESP:AddToPlayer(player, {
        Name = player.Name,
        DistancePrefix = "Dist: ",
        DistanceSuffix = "m",
        DisplayOrder = 10,
        Color = {
            Name = {144, 0, 255},
            Distance = {144, 0, 255},
            Tracer = {144, 0, 255},
            Highlight = {
                Filled = {144, 0, 255},
                Outline = {200, 0, 255}
            }
        },
        ColorDependency = function(esp, distance, pos3D)
            return distance > 100 and Color3.fromRGB(255, 165, 0) or nil
        end
    })
end

-- Adicionar para jogadores existentes
for _, player in pairs(game.Players:GetPlayers()) do
    addPlayerESP(player)
end

-- Eventos
game.Players.PlayerAdded:Connect(addPlayerESP)
game.Players.PlayerRemoving:Connect(function(player)
    KoltESP:RemoveFromPlayer(player)
end)

-- Tecla para descarregar
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F10 then
        KoltESP:Unload()
    end
end)
```

### ESP para Objetos Específicos

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

local function addPartESP(partName, config)
    for _, part in pairs(workspace:GetDescendants()) do
        if part.Name == partName and (part:IsA("BasePart") or part:IsA("Model")) then
            KoltESP:Add(part, config)
        end
    end
end

-- Baús
addPartESP("Chest", {
    Name = "Baú",
    DistancePrefix = "Dist: ",
    DistanceSuffix = "m",
    DisplayOrder = 5,
    Types = {
        Tracer = false,
        HighlightFill = true
    },
    Color = {
        Name = {255, 255, 0},
        Distance = {255, 255, 0},
        Highlight = {
            Filled = {255, 215, 0},
            Outline = {255, 255, 0}
        }
    }
})

-- Inimigos
addPartESP("Enemy", {
    Name = "Inimigo",
    DisplayOrder = 10,
    Types = {
        Distance = false,
        HighlightOutline = true
    },
    Color = {
        Tracer = {255, 0, 0},
        Highlight = {
            Filled = {200, 0, 0},
            Outline = {255, 0, 0}
        }
    },
    ColorDependency = function(esp, distance, pos3D)
        return distance < 50 and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 100, 0)
    end
})
```

---

## Estrutura de Configuração

### Config Completo

```lua
{
    -- Identificação
    Name = "Nome Personalizado",
    
    -- Visual
    Color = Color3.fromRGB(255, 255, 255), -- ou tabela detalhada
    Font = 3,              -- 0: UI, 1: System, 2: Plex, 3: Monospace
    Opacity = 0.8,
    LineThickness = 1.5,
    FontSize = 14,
    DisplayOrder = 0,
    
    -- Distância
    DistancePrefix = "Dist: ",
    DistanceSuffix = "m",
    MaxDistance = math.huge,
    MinDistance = 0,
    
    -- Tipos de ESP
    Types = {
        Tracer = true,
        Name = true,
        Distance = true,
        HighlightFill = true,
        HighlightOutline = true
    },
    
    -- Outline de texto
    TextOutlineEnabled = true,
    TextOutlineColor = Color3.fromRGB(0, 0, 0),
    TextOutlineThickness = 1,
    
    -- Recursos especiais
    Collision = false,
    ColorDependency = function(esp, distance, pos3D)
        return Color3.new(1, 1, 1)
    end
}
```

### Estrutura de Cores Detalhada

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

---

## Notas de Versão

### V1.6.5
- Otimização de performance no loop de renderização
- Correção de referência de câmera
- Remoção de containers desnecessários
- Novas personalizações por ESP (Font, Opacity, LineThickness, FontSize, MaxDistance, MinDistance)
- Sistema de pause/resume otimizado
- Função Unload segura

---

**Desenvolvido por Kolt (DH_SOARES)** | Versão 1.6.5 | Outubro 2025
