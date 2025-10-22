# Kolt ESP Library V1.6.5

Biblioteca ESP (Extra Sensory Perception) minimalista, eficiente e responsiva para Roblox, desenvolvida por **Kolt Hub**. Projetada para alto desempenho, com gerenciamento otimizado de recursos, customizações avançadas e suporte a destaques visuais robustos.

## Características Principais

- **Componentes ESP Completos**: Suporte a Tracer (linhas de rastreamento), Nome, Distância e Highlight (preenchimento e outline).
- **Otimização de Performance**: Auto-remoção de objetos inválidos, verificação de duplicatas e atualizações eficientes no loop de renderização.
- **Customização Avançada**: Cores por elemento, fontes, opacidades, espessuras, origens de tracer e dependência dinâmica de cores baseada em distância ou posição.
- **Gerenciamento de Camadas**: DisplayOrder individual para controle de sobreposição entre ESPs.
- **Pause e Resume Otimizados**: Limpeza automática de drawings ao desativar e recriação ao ativar.
- **Highlights Centralizados**: Armazenados em uma pasta no ReplicatedStorage com Adornee para melhor organização.
- **Modo Rainbow**: Cores dinâmicas e automáticas para um efeito visual vibrante.
- **Modo Collision**: Destaque de todas as partes do alvo, incluindo transparentes.
- **Suporte a Jogadores**: Adição automática de ESP a characters com respawn e remoção segura.
- **Conexão de Tracers**: Todas as linhas de tracer se conectam a um ponto de referência invisível, garantindo que nenhuma ESP fique desconectada (melhoria para estabilidade em renderizações múltiplas).
- **Formato de Distância**: Opção para exibir distância como float (decimal) ou inteiro.

## Instalação

Carregue a biblioteca diretamente via HTTP:

```lua
local LibraryESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()
```

## Documentação

### Índice

1. [Uso Básico](#uso-básico)
2. [Configurações Globais](#configurações-globais)
3. [Gerenciamento Avançado](#gerenciamento-avançado)
4. [Referência de API](#referência-de-api)
5. [Exemplos Práticos](#exemplos-práticos)
6. [Estrutura de Configuração](#estrutura-de-configuração)
7. [Notas de Versão](#notas-de-versão)

---

## Uso Básico

### Adicionando ESP Simples

```lua
-- ESP básico com configurações padrão
LibraryESP:Add(workspace.SomeModel)

-- ESP com nome personalizado e distância em float
LibraryESP:Add(workspace.SomeModel, {
    Name = "Alvo Especial",
    DistanceFloat = true  -- Exibe distância como decimal (ex: 12.5)
})
```

### Adicionando ESP Completo

```lua
LibraryESP:Add(workspace.SomeModel, {
    Name = "Alvo Especial",
    Color = Color3.fromRGB(255, 0, 0),
    Collision = true,
    DistancePrefix = "Dist: ",
    DistanceSuffix = "m",
    DistanceFloat = false,  -- Exibe distância como inteiro (ex: 12)
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
-- Habilitar/desabilitar componentes globalmente
LibraryESP:SetGlobalESPType("ShowTracer", true)
LibraryESP:SetGlobalESPType("ShowName", true)
LibraryESP:SetGlobalESPType("ShowDistance", true)
LibraryESP:SetGlobalESPType("ShowHighlightFill", true)
LibraryESP:SetGlobalESPType("ShowHighlightOutline", true)
```

### Aparência

```lua
-- Origem do tracer (ponto inicial para todas as linhas)
LibraryESP:SetGlobalTracerOrigin("Bottom") -- Opções: Top, Center, Bottom, Left, Right

-- Estilo visual
LibraryESP:SetGlobalRainbow(true)  -- Ativa modo rainbow para cores dinâmicas
LibraryESP:SetGlobalOpacity(0.8)
LibraryESP:SetGlobalFontSize(16)
LibraryESP:SetGlobalLineThickness(2)
LibraryESP:SetGlobalFont(3) -- 0: UI, 1: System, 2: Plex, 3: Monospace

-- Transparência dos highlights
LibraryESP:SetGlobalHighlightTransparency({
    Filled = 0.5,
    Outline = 0.3
})

-- Contorno de texto
LibraryESP:SetGlobalTextOutline(true, Color3.fromRGB(0, 0, 0), 1)
```

### Distância

```lua
LibraryESP.GlobalSettings.MaxDistance = 1000
LibraryESP.GlobalSettings.MinDistance = 0
```

### Controle Geral

```lua
LibraryESP:EnableAll()  -- Ativa todos os ESPs e recria drawings
LibraryESP:DisableAll() -- Desativa todos os ESPs e limpa drawings
LibraryESP:Clear()      -- Remove todos os ESPs ativos
LibraryESP:Unload()     -- Descarrega a biblioteca, desconecta eventos e limpa todos os recursos (incluindo pasta de highlights)
```

---

## Gerenciamento Avançado

### Reajustar ESP

```lua
LibraryESP:Readjustment(workspace.NewModel, workspace.OldModel, {
    Name = "Novo Alvo",
    Color = Color3.fromRGB(0, 255, 255),
    DisplayOrder = 8,
    DistanceFloat = true
})
```

### Atualizar Configurações

```lua
LibraryESP:UpdateConfig(workspace.SomeModel, {
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
    },
    DistanceFloat = false
})
```

### Controle Individual

```lua
-- Alternar visibilidade
LibraryESP:ToggleIndividual(workspace.SomeModel, false)

-- Alterar propriedades
LibraryESP:SetColor(workspace.SomeModel, Color3.fromRGB(0, 255, 0))
LibraryESP:SetName(workspace.SomeModel, "Novo Nome")
LibraryESP:SetDisplayOrder(workspace.SomeModel, 7)
LibraryESP:SetTextOutline(workspace.SomeModel, true, Color3.fromRGB(0, 0, 0), 1)

-- Remover
LibraryESP:Remove(workspace.SomeModel)
```

---

## Referência de API

### Métodos Principais

- **Add(target, config)**: Adiciona ESP a um Model ou BasePart. Verifica duplicatas e aplica configurações.
- **Remove(target)**: Remove ESP específico e limpa recursos associados.
- **Clear()**: Remove todos os ESPs e limpa drawings/highlights.
- **Unload()**: Descarrega a biblioteca, desconecta RenderStepped, remove todos os ESPs e destrói pasta de highlights.
- **AddToPlayer(player, config)**: Adiciona ESP ao character do jogador com suporte a respawn (CharacterAdded/Removing).
- **RemoveFromPlayer(player)**: Remove ESP do jogador e desconecta eventos.

### Métodos de Atualização

- **UpdateConfig(target, newConfig)**: Atualiza configurações de um ESP existente sem recriar do zero.
- **Readjustment(newTarget, oldTarget, newConfig)**: Transfere ESP de um alvo para outro com novas configs.
- **ToggleIndividual(target, enabled)**: Ativa/desativa ESP individual.

### Métodos de Configuração Global

- **SetGlobalESPType(typeName, enabled)**: Controla visibilidade global de tipos (ShowTracer, ShowName, etc.).
- **SetGlobalTracerOrigin(origin)**: Define origem das linhas de tracer (Top, Center, etc.).
- **SetGlobalHighlightTransparency(trans)**: Define transparências para Filled e Outline.
- **SetHighlightFolderName(name)**: Altera nome da pasta de highlights no ReplicatedStorage.

### Outros

- **GetESP(target)**: Retorna o objeto ESP para um alvo específico (interno, mas acessível).
- **EnableAll() / DisableAll()**: Gerencia estado global com otimização de recursos.

---

## Exemplos Práticos

### ESP para Jogadores

```lua
local LibraryESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configuração inicial global
LibraryESP:SetHighlightFolderName("PlayerESPHighlights")
LibraryESP:SetGlobalHighlightTransparency({Filled = 0.7, Outline = 0.2})
LibraryESP:SetGlobalTracerOrigin("Top")
LibraryESP.GlobalSettings.MaxDistance = 500

local function addPlayerESP(player)
    if player == game.Players.LocalPlayer then return end
    
    LibraryESP:AddToPlayer(player, {
        Name = player.Name,
        DistancePrefix = "Dist: ",
        DistanceSuffix = "m",
        DistanceFloat = true,
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

-- Eventos para novos jogadores
game.Players.PlayerAdded:Connect(addPlayerESP)
game.Players.PlayerRemoving:Connect(function(player)
    LibraryESP:RemoveFromPlayer(player)
end)

-- Tecla para descarregar a biblioteca
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F10 then
        LibraryESP:Unload()
    end
end)
```

### ESP para Objetos Específicos

```lua
local LibraryESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

local function addPartESP(partName, config)
    for _, part in pairs(workspace:GetDescendants()) do
        if part.Name == partName and (part:IsA("BasePart") or part:IsA("Model")) then
            LibraryESP:Add(part, config)
        end
    end
end

-- Exemplo para Baús
addPartESP("Chest", {
    Name = "Baú",
    DistancePrefix = "Dist: ",
    DistanceSuffix = "m",
    DistanceFloat = false,
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

-- Exemplo para Inimigos
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

A configuração é passada como uma tabela Lua ao adicionar ou atualizar um ESP. Abaixo, uma tabela com todas as propriedades disponíveis, seus tipos, valores padrão e descrições.

| Propriedade              | Tipo                  | Padrão                  | Descrição |
|--------------------------|-----------------------|-------------------------|-----------|
| Name                     | string               | Nome do target         | Nome exibido no ESP. |
| Color                    | Color3 ou table      | Tema primário          | Cor única (Color3) ou tabela detalhada por elemento (Name, Distance, Tracer, Highlight.Filled, Highlight.Outline). Cada valor na tabela é {R, G, B}. |
| Font                     | number               | 3 (Monospace)          | Fonte do texto: 0 (UI), 1 (System), 2 (Plex), 3 (Monospace). |
| Opacity                  | number               | 0.8                    | Transparência geral (0 a 1). |
| LineThickness            | number               | 1.5                    | Espessura das linhas de tracer. |
| FontSize                 | number               | 14                     | Tamanho da fonte do texto. |
| DisplayOrder             | number               | 0                      | Ordem de renderização (ZIndex para sobreposição). |
| DistancePrefix           | string               | ""                     | Prefixo para o texto de distância (ex: "Dist: "). |
| DistanceSuffix           | string               | ""                     | Sufixo para o texto de distância (ex: "m"). |
| DistanceFloat            | boolean              | true                   | Se true, exibe distância como decimal (ex: 12.5); se false, como inteiro (ex: 12). |
| MaxDistance              | number               | math.huge              | Distância máxima para visibilidade. |
| MinDistance              | number               | 0                      | Distância mínima para visibilidade. |
| Types                    | table                | {Tracer=true, Name=true, Distance=true, HighlightFill=true, HighlightOutline=true} | Habilita/desabilita componentes individuais. |
| TextOutlineEnabled       | boolean              | true                   | Ativa contorno no texto. |
| TextOutlineColor         | Color3               | Color3.fromRGB(0,0,0) | Cor do contorno do texto. |
| TextOutlineThickness     | number               | 1                      | Espessura do contorno do texto. |
| Collision                | boolean              | false                  | Se true, destaca todas as partes, incluindo transparentes. |
| ColorDependency          | function             | nil                    | Função que retorna Color3 baseada em esp, distance e pos3D. |

### Exemplo de Configuração Completa

```lua
{
    Name = "Nome Personalizado",
    Color = Color3.fromRGB(255, 255, 255), -- Ou tabela detalhada
    Font = 3,
    Opacity = 0.8,
    LineThickness = 1.5,
    FontSize = 14,
    DisplayOrder = 0,
    DistancePrefix = "Dist: ",
    DistanceSuffix = "m",
    DistanceFloat = true,
    MaxDistance = math.huge,
    MinDistance = 0,
    Types = {
        Tracer = true,
        Name = true,
        Distance = true,
        HighlightFill = true,
        HighlightOutline = true
    },
    TextOutlineEnabled = true,
    TextOutlineColor = Color3.fromRGB(0, 0, 0),
    TextOutlineThickness = 1,
    Collision = false,
    ColorDependency = function(esp, distance, pos3D)
        return Color3.new(1, 1, 1)  -- Exemplo: cor branca dinâmica
    end
}
```

### Exemplo de Cores Detalhadas

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

### V1.6.5 (Outubro 2025)
- Adição da propriedade `DistanceFloat` para controle do formato de distância.
- Melhoria na conexão de tracers: Todas as linhas agora se conectam a um ponto de referência invisível para evitar desconexões em renderizações múltiplas.
- Otimização no loop de renderização com verificações mais eficientes.
- Correção na referência de câmera e remoção de containers desnecessários.
- Expansão de personalizações individuais (Font, Opacity, etc.).
- Função `Unload` agora limpa completamente todos os ESPs e pasta de highlights.
- Suporte aprimorado a pause/resume com gerenciamento de recursos.

---

**Desenvolvido por Kolt (DH_SOARES)** | Versão 1.6.5 | 22 de Outubro de 2025
