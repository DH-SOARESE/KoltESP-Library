# 📦 Kolt ESP Library V1.6

Uma biblioteca ESP (Extra Sensory Perception) minimalista, eficiente e altamente customizável para Roblox, desenvolvida por **Kolt (DH_SOARES)**. Projetada para oferecer um sistema de ESP robusto e responsivo, com foco em performance, facilidade de uso e gerenciamento otimizado de recursos. Esta versão introduz melhorias em robustez, customização visual e funcionalidades avançadas, incluindo dependência dinâmica de cores, suporte a respawn do jogador local e limitação por campo de visão (FOV) com círculo visual opcional.

## ✨ Características

- 🎯 **ESP Completo**: Suporte a Tracer, Nome, Distância e Highlight (preenchimento e outline).
- 🌈 **Modo Arco-íris**: Cores dinâmicas que mudam automaticamente.
- 🎨 **Customização Avançada de Cores**: Suporte a cores individuais por elemento (Name, Distance, Tracer, Highlight) via tabela ou Color3.
- ⚡ **Performance Otimizada**: Sistema de auto-remoção de objetos inválidos, verificação de duplicatas, atualizações eficientes por frame e armazenamento centralizado de Highlights em uma pasta no ReplicatedStorage para reduzir clutter no workspace.
- 📱 **Responsivo**: Adapta-se a diferentes resoluções, com posicionamento preciso mesmo em distâncias próximas (1-10 metros).
- 🔧 **Fácil de Usar**: API intuitiva com métodos para gerenciamento avançado de ESPs.
- 🆕 **ESP Collision (Opcional e Individual)**: Cria um Humanoid "Kolt ESP" no alvo e ajusta transparência de parts invisíveis (de 1 para 0.99) para melhor detecção de colisões ou visibilidade.
- 🆕 **Customização de Textos**: Propriedades individuais para containers de nome (ex: `{Nome}`) e distância (ex: `<10.5.metros>`), com sufixos configuráveis.
- 🆕 **Transparências de Highlight Configuráveis**: Ajuste global para transparências de preenchimento e outline via `SetGlobalHighlightTransparency`.
- 🆕 **Pasta Central para Highlights**: Armazena todos os Highlights em uma pasta no ReplicatedStorage (nome configurável via `SetHighlightFolderName`), usando `Adornee` para vincular ao alvo.
- 🆕 **Novos Métodos**: Inclui `Readjustment` para mudar o alvo de um ESP, `ToggleIndividual`, `SetColor`, `SetName`, `UpdateConfig`, `SetGlobalHighlightTransparency`, `SetHighlightFolderName`, `SetDisplayOrder`, `Unload`, `EnableAll`, `DisableAll`, `SetTextOutline`, `SetGlobalTextOutline` e `FovEsp` para maior controle.
- 🆕 **Sistema de Camadas para Drawings**: Cada ESP tem um `DisplayOrder` individual (ZIndex para Tracer, Name e Distance), permitindo que elementos com valores mais altos sejam renderizados sobre os de valores mais baixos.
- 🆕 **Otimização de Highlights**: Highlights são criados uma vez por ESP e atualizados eficientemente no loop de render (cores, transparências e visibilidade), sem recriação constante para melhorar a performance.
- 🆕 **Função de Descarregamento**: Método `Unload` para limpar completamente a biblioteca, desconectar eventos e remover recursos.
- 🆕 **Controle Global de Visibilidade**: Funções `EnableAll` e `DisableAll` para habilitar/desabilitar todos os ESPs simultaneamente sem removê-los.
- 🆕 **Tipos Individuais de ESP**: Cada ESP pode configurar tipos específicos (Tracer, Name, Distance, HighlightFill, HighlightOutline), respeitando configurações globais (se globalmente desativado, individual não pode ativar).
- 🆕 **Fallback para Centro do Modelo**: Se o alvo não tiver partes com transparência < 1, seleciona o centro do modelo como ponto de referência.
- 🆕 **Propriedades de Outline para Textos**: Configurável global e individualmente (habilitado, cor, espessura) para os textos de nome e distância.
- 🆕 **Dependência de Cor Dinâmica**: Permite definir uma função personalizada para calcular a cor do ESP individualmente com base em variáveis como distância ou posição.
- 🆕 **Restart on Respawn**: Recria automaticamente os objetos Drawing ao respawn do jogador local para prevenir perda de referências.
- 🆕 **ESP FOV**: Limita a renderização do ESP a um campo de visão definido (FOV), com opção para exibir um círculo visual na tela.
- 🐛 **Correções e Melhorias**: Evita duplicatas no método `Add`, otimiza gerenciamento de transparência, melhora a modularidade do código, adiciona criação lazy da pasta de highlights, garante atualizações eficientes sem reconstrução desnecessária e aprimora a estabilidade geral.

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
- **Nome**: Exibe o nome do objeto, centralizado, com container personalizável (ex: `{Nome}`) e outline configurável.
- **Distância**: Mostra a distância em metros com formatação precisa (ex: `<10.5.metros>`), com sufixo e container customizáveis, e outline configurável.
- **Highlight**: Contorno e preenchimento colorido ao redor do objeto, com transparências ajustáveis globalmente e atualizações eficientes sem recriação.

### 🎮 Origens do Tracer
- `Top` - Topo da tela.
- `Center` - Centro da tela.
- `Bottom` - Parte inferior da tela (padrão).
- `Left` - Lateral esquerda.
- `Right` - Lateral direita.

**Nota**: A origem do Tracer é global e não pode ser configurada individualmente para evitar problemas visuais.

### 🆕 Opção de Collision
- Ativada individualmente via `Collision = true` na configuração.
- Cria um Humanoid chamado "Kolt ESP" no alvo (se não existir).
- Ajusta temporariamente a transparência de parts com valor 1 para 0.99.
- Restaura transparências originais e remove Humanoid ao remover o ESP.

### 🆕 Propriedades Individuais para Textos
- **NameContainer**: Tabela com `Start` e `End` para envolver o nome (padrão: vazio).
- **DistanceSuffix**: Sufixo após o valor da distância (padrão: vazio).
- **DistanceContainer**: Tabela com `Start` e `End` para envolver a distância (padrão: vazio).
- **TextOutlineEnabled**: Habilita/desabilita outline para textos (padrão: true).
- **TextOutlineColor**: Cor do outline (padrão: preto).
- **TextOutlineThickness**: Espessura do outline (armazenada para uso futuro; padrão: 1).

### 🆕 Gerenciamento de Highlights
- Todos os Highlights são armazenados em uma pasta no ReplicatedStorage (padrão: "KoltESPHighlights").
- Use `Adornee` para vincular o Highlight ao alvo sem parentá-lo diretamente.
- Nome da pasta configurável via `SetHighlightFolderName("NovoNome")`.
- Transparências globais: `HighlightTransparency = {Filled = 0.5, Outline = 0.3}` (ajustável via API; não configurável individualmente).
- Otimização: Highlights são atualizados in-place no loop de render, evitando recriação para melhor performance.

### 🆕 Sistema de Camadas (DisplayOrder)
- Aplicado aos elementos Drawing (Tracer, Name, Distance).
- Cada ESP tem um `DisplayOrder` individual (padrão: 0), que define o ZIndex.
- Valores mais altos (ex: 10) são renderizados sobre valores mais baixos (ex: 1).
- Configurável ao adicionar/atualizar ESP e via API `SetDisplayOrder`.

### 🆕 Sistema de Tipos Individuais
- Cada ESP pode desativar tipos específicos (Tracer, Name, Distance, HighlightFill, HighlightOutline) via `Types = {Tracer = false, ...}`.
- Lógica: Se globalmente desativado (ex: `ShowTracer = false`), o tipo não aparece, independentemente da configuração individual.
- Se globalmente ativado, a configuração individual decide (padrão: true).
- Isso permite controle fino sem sobrecarregar configurações globais.

### 🆕 Fallback para Centro do Modelo
- Se não houver partes visíveis (transparência < 0.99), usa o centro do bounding box do modelo como posição de referência para evitar falhas no posicionamento.

### 🆕 Dependência de Cor Dinâmica
- Configurável individualmente via `ColorDependency = function(esp, distance, pos3D) return Color3.new(...) end`.
- A função é chamada a cada frame e pode retornar uma cor baseada em lógica personalizada (ex: mudar cor com base na distância).
- Se definida, sobrepõe as cores estáticas (exceto no modo arco-íris).

### 🆕 Restart on Respawn
- Automaticamente recria os objetos Drawing (Tracer, Name, Distance) ao respawn do jogador local para manter a funcionalidade sem perda de referências.

### 🆕 ESP FOV
- Limita a visibilidade do ESP a um ângulo de visão definido (FOV em graus).
- Opção para exibir um círculo visual na tela representando o FOV.
- Configurável via `FovEsp(_, enabled, EspFov)`, onde `enabled` ativa o limite e o círculo, e `EspFov` define o valor (padrão: 90).

### 🆕 APIs Avançadas
- **Readjustment**: Altera o alvo de um ESP existente, aplicando nova configuração.
- **ToggleIndividual**: Habilita/desabilita um ESP específico sem removê-lo.
- **SetColor**: Define uma cor única para todos os elementos de um ESP.
- **SetName**: Altera o nome exibido de um ESP.
- **SetDisplayOrder**: Define o DisplayOrder (ZIndex) de um ESP específico.
- **SetTextOutline**: Define propriedades de outline de texto para um ESP específico.
- **UpdateConfig**: Atualiza configurações de um ESP existente (nome, cores, containers, DisplayOrder, Types, outline de texto, etc.) sem mudar o alvo.
- **SetGlobalHighlightTransparency**: Ajusta transparências globais de Highlight.
- **SetHighlightFolderName**: Define o nome da pasta central para Highlights.
- **SetGlobalTextOutline**: Ajusta propriedades globais de outline de texto.
- **Unload**: Descarrega completamente a biblioteca, desconectando eventos e limpando recursos.
- **EnableAll/DisableAll**: Habilita/desabilita todos os ESPs globalmente.
- **FovEsp**: Ativa/desativa o limite de FOV e o círculo visual, com valor opcional.

## 🛠️ Uso Básico

### Adicionando ESP a um Objeto

```lua
-- Carregar a biblioteca
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Definir nome da pasta de highlights (opcional, antes de adicionar ESPs)
ModelESP:SetHighlightFolderName("MyESPHighlights")

-- Ajustar transparências globais de highlights (opcional)
ModelESP:SetGlobalHighlightTransparency({Filled = 0.6, Outline = 0.4})

-- Ajustar outline global de textos (opcional)
ModelESP:SetGlobalTextOutline(true, Color3.fromRGB(0, 0, 0), 1)

-- Ativar limite de FOV com círculo (opcional)
ModelESP:FovEsp("Show Esp Fov", true, 90)

-- Adicionar ESP básico
ModelESP:Add(workspace.SomeModel)

-- Adicionar ESP com nome, cor única, Collision, customização de textos, DisplayOrder, tipos individuais, outline de texto e dependência de cor
ModelESP:Add(workspace.SomeModel, {
    Name = "Alvo Especial",
    Color = Color3.fromRGB(255, 0, 0),
    Collision = true,
    NameContainer = {Start = "{", End = "}"},
    DistanceSuffix = ".metros",
    DistanceContainer = {Start = "<", End = ">"},
    DisplayOrder = 5,  -- Renderizado sobre ESPs com DisplayOrder menor
    Types = {
        Tracer = true,
        Name = true,
        Distance = true,
        HighlightFill = false,  -- Desativa preenchimento individualmente
        HighlightOutline = true
    },
    TextOutlineEnabled = true,
    TextOutlineColor = Color3.fromRGB(0, 0, 0),
    TextOutlineThickness = 1,
    ColorDependency = function(esp, distance, pos3D)
        if distance < 50 then
            return Color3.fromRGB(255, 0, 0)  -- Vermelho se próximo
        else
            return Color3.fromRGB(0, 255, 0)  -- Verde se distante
        end
    end
})

-- Adicionar ESP com cores personalizadas por elemento, DisplayOrder alto e outline customizado
ModelESP:Add(workspace.SomeModel, {
    Name = "Alvo Especial",
    Collision = true,
    NameContainer = {Start = "[", End = "]"},
    DistanceSuffix = "m",
    DistanceContainer = {Start = "(", End = ")"},
    DisplayOrder = 10,
    Types = {
        Tracer = false,  -- Desativa tracer individualmente
        HighlightFill = true,
        HighlightOutline = false
    },
    Color = {
        Name = {255, 255, 255},
        Distance = {255, 255, 255},
        Tracer = {0, 255, 0},
        Highlight = {
            Filled = {100, 144, 0},
            Outline = {0, 255, 0}
        }
    },
    TextOutlineEnabled = false,  -- Desativa outline para este ESP
    TextOutlineColor = Color3.fromRGB(255, 255, 255)
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
    DistanceContainer = {Start = "(", End = ")"},
    DisplayOrder = 8,
    Types = {
        Tracer = true,
        HighlightFill = false
    },
    TextOutlineEnabled = true,
    TextOutlineColor = Color3.fromRGB(50, 50, 50),
    TextOutlineThickness = 2,
    ColorDependency = function(esp, distance, pos3D)
        return Color3.fromHSV(distance / 1000, 1, 1)  -- Cor baseada em distância
    end
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
    DistanceSuffix = ".metros",
    DisplayOrder = 3,  -- Atualiza a camada de renderização
    Types = {
        Distance = false,  -- Desativa distância individualmente
        HighlightOutline = true
    },
    TextOutlineEnabled = false,
    TextOutlineColor = Color3.fromRGB(100, 100, 100),
    ColorDependency = nil  -- Remove dependência de cor
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

-- Alterar apenas o DisplayOrder
ModelESP:SetDisplayOrder(workspace.SomeModel, 7)

-- Alterar propriedades de outline de texto
ModelESP:SetTextOutline(workspace.SomeModel, true, Color3.fromRGB(0, 0, 0), 1)
```

### Removendo ou Descarregando ESP

```lua
-- Remover ESP de um objeto específico (restaura transparências e remove Humanoid)
ModelESP:Remove(workspace.SomeModel)

-- Limpar todos os ESPs
ModelESP:Clear()

-- Descarregar completamente a biblioteca
ModelESP:Unload()
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
ModelESP:SetGlobalHighlightTransparency({Filled = 0.5, Outline = 0.3}) -- Ajusta transparências de highlights
ModelESP:SetGlobalTextOutline(true, Color3.fromRGB(0, 0, 0), 1) -- Ajusta outline global de textos
```

### Controle de Distância e FOV

```lua
ModelESP.GlobalSettings.MaxDistance = 1000
ModelESP.GlobalSettings.MinDistance = 0

-- Ativar FOV com círculo e definir valor
ModelESP:FovEsp("Show Esp Fov", true, 120)
```

### Controle Global de Visibilidade

```lua
-- Habilitar todos os ESPs
ModelESP:EnableAll()

-- Desabilitar todos os ESPs
ModelESP:DisableAll()
```

## 📖 Exemplos Práticos

### 🧑‍🤝‍🧑 ESP para Jogadores com Cores Personalizadas, Camadas, Tipos Individuais, Outline de Texto e Dependência de Cor

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configura pasta e transparências
ModelESP:SetHighlightFolderName("PlayerESPHighlights")
ModelESP:SetGlobalHighlightTransparency({Filled = 0.7, Outline = 0.2})

-- Configura outline global
ModelESP:SetGlobalTextOutline(true, Color3.fromRGB(0, 0, 0), 1)

-- Ativar FOV
ModelESP:FovEsp("Show Esp Fov", true, 90)

-- Configurações globais
ModelESP:SetGlobalTracerOrigin("Top")
ModelESP:SetGlobalRainbow(false)  -- Desativado para usar dependência de cor
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
            DisplayOrder = 10,  -- Alta prioridade para jogadores
            Types = {
                Tracer = true,
                Name = true,
                Distance = true,
                HighlightFill = false,  -- Sem preenchimento para jogadores
                HighlightOutline = true
            },
            Color = {
                Name = {144, 0, 255},
                Distance = {144, 0, 255},
                Tracer = {144, 0, 255},
                Highlight = {
                    Filled = {144, 0, 255},
                    Outline = {200, 0, 255}
                }
            },
            TextOutlineEnabled = true,
            TextOutlineColor = Color3.fromRGB(0, 0, 0),
            TextOutlineThickness = 1,
            ColorDependency = function(esp, distance, pos3D)
                if distance > 100 then
                    return Color3.fromRGB(255, 165, 0)  -- Laranja se distante
                end
                return nil  -- Usa cor padrão se não
            end
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

-- Exemplo de descarregamento
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F10 then
        ModelESP:Unload()
    end
end)
```

### 🎯 ESP para Objetos Específicos com Collision, Camadas, Tipos Individuais, Outline de Texto e FOV

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configura pasta e transparências
ModelESP:SetHighlightFolderName("ObjectESPHighlights")
ModelESP:SetGlobalHighlightTransparency({Filled = 0.5, Outline = 0.3})

-- Configura outline global
ModelESP:SetGlobalTextOutline(false, Color3.fromRGB(255, 255, 255), 2)

-- Ativar FOV sem círculo
ModelESP:FovEsp("Show Esp Fov", true, 60)  -- Limita a 60 graus, mas sem mostrar o círculo (altere para true para mostrar)

-- Função para adicionar ESP a partes por nome
local function addPartESP(partName, espName, colorTable, collision, nameContainer, distanceSuffix, distanceContainer, displayOrder, types, textOutlineEnabled, textOutlineColor, textOutlineThickness, colorDependency)
    for _, part in pairs(workspace:GetDescendants()) do
        if part.Name == partName and (part:IsA("BasePart") or part:IsA("Model")) then
            ModelESP:Add(part, {
                Name = espName or part.Name,
                Collision = collision or false,
                NameContainer = nameContainer or {Start = "[", End = "]"},
                DistanceSuffix = distanceSuffix or "m",
                DistanceContainer = distanceContainer or {Start = "(", End = ")"},
                DisplayOrder = displayOrder or 0,
                Types = types or {
                    Tracer = true,
                    Name = true,
                    Distance = true,
                    HighlightFill = true,
                    HighlightOutline = true
                },
                Color = colorTable or {
                    Name = {255, 255, 0},
                    Distance = {255, 255, 0},
                    Tracer = {255, 255, 0},
                    Highlight = {
                        Filled = {255, 215, 0},
                        Outline = {255, 255, 0}
                    }
                },
                TextOutlineEnabled = textOutlineEnabled,
                TextOutlineColor = textOutlineColor,
                TextOutlineThickness = textOutlineThickness,
                ColorDependency = colorDependency
            })
        end
    end
end

-- Exemplos de uso com diferentes DisplayOrders, Types, Outlines e Dependência de Cor
addPartESP("Chest", "💰 Baú", {
    Name = {255, 255, 255},
    Distance = {255, 255, 255},
    Tracer = {255, 215, 0},
    Highlight = {
        Filled = {255, 215, 0},
        Outline = {255, 255, 255}
    }
}, true, {Start = "{", End = "}"}, ".m", {Start = "<", End = ">"}, 5, {
    Tracer = false,  -- Sem tracer para baús
    HighlightFill = true
}, true, Color3.fromRGB(0, 0, 0), 1, function(esp, distance, pos3D)
    return Color3.fromRGB(255, 255 - distance * 2, 0)  -- Amarelo fading com distância
end)

addPartESP("Enemy", "👹 Inimigo", {
    Name = {255, 255, 255},
    Distance = {255, 255, 255},
    Tracer = {255, 0, 0},
    Highlight = {
        Filled = {200, 0, 0},
        Outline = {255, 0, 0}
    }
}, false, nil, nil, nil, 10, {  -- Alta camada para inimigos
    Distance = false,
    HighlightOutline = true
}, false, Color3.fromRGB(255, 255, 255), 2)

addPartESP("PowerUp", "⚡ Power-Up", {
    Name = {255, 255, 255},
    Distance = {255, 255, 255},
    Tracer = {0, 255, 255},
    Highlight = {
        Filled = {0, 200, 200},
        Outline = {0, 255, 255}
    }
}, true, {Start = "[", End = "]"}, " metros", {Start = "(", End = ")"}, 2, {
    Name = true,
    HighlightFill = false
}, true, Color3.fromRGB(50, 50, 50), 1)
```

### 🔍 ESP por Path Específico com Reajuste Dinâmico, Camadas, Tipos, Outline de Texto e Dependência de Cor

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configura pasta e transparências
ModelESP:SetHighlightFolderName("DynamicESPHighlights")
ModelESP:SetGlobalHighlightTransparency({Filled = 0.4, Outline = 0.2})

-- Configura outline global
ModelESP:SetGlobalTextOutline(true, Color3.fromRGB(0, 0, 0), 1)

-- Ativar FOV
ModelESP:FovEsp("Show Esp Fov", true, 90)

-- Configuração de alvos
local targets = {
    {
        path = "workspace.Map.Treasures",
        name = "💎 Tesouro",
        collision = true,
        nameContainer = {Start = "[", End = "]"},
        distanceSuffix = "m",
        distanceContainer = {Start = "(", End = ")"},
        displayOrder = 4,
        types = {
            Tracer = true,
            HighlightFill = false
        },
        color = {
            Name = {255, 255, 255},
            Distance = {255, 255, 255},
            Tracer = {255, 0, 255},
            Highlight = {
                Filled = {200, 0, 200},
                Outline = {255, 0, 255}
            }
        },
        textOutlineEnabled = true,
        textOutlineColor = Color3.fromRGB(0, 0, 0),
        textOutlineThickness = 1,
        colorDependency = function(esp, distance, pos3D)
            return Color3.fromRGB(0, 255 - distance, 255 - distance)  -- Azul fading com distância
        end
    },
    {
        path = "workspace.Enemies",
        name = "⚔️ Inimigo",
        collision = false,
        nameContainer = {Start = "{", End = "}"},
        distanceSuffix = ".m",
        distanceContainer = {Start = "<", End = ">"},
        displayOrder = 9,
        types = {
            Distance = true,
            HighlightOutline = false
        },
        color = {
            Name = {255, 255, 255},
            Distance = {255, 255, 255},
            Tracer = {255, 100, 100},
            Highlight = {
                Filled = {200, 50, 50},
                Outline = {255, 100, 100}
            }
        },
        textOutlineEnabled = false,
        textOutlineColor = Color3.fromRGB(255, 255, 255),
        textOutlineThickness = 2
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
                    DisplayOrder = target.displayOrder,
                    Types = target.types,
                    Color = target.color,
                    TextOutlineEnabled = target.textOutlineEnabled,
                    TextOutlineColor = target.textOutlineColor,
                    TextOutlineThickness = target.textOutlineThickness,
                    ColorDependency = target.colorDependency
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
            DisplayOrder = 6,
            Types = {
                Tracer = false,
                HighlightFill = true
            },
            Color = {
                Name = {255, 255, 255},
                Distance = {255, 255, 255},
                Tracer = {0, 255, 255},
                Highlight = {
                    Filled = {0, 200, 200},
                    Outline = {0, 255, 255}
                }
            },
            TextOutlineEnabled = true,
            TextOutlineColor = Color3.fromRGB(0, 0, 0),
            TextOutlineThickness = 1,
            ColorDependency = function(esp, distance, pos3D)
                return Color3.fromRGB(math.min(255, distance * 10), 0, 0)  -- Vermelho intensificando com distância
            end
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
    AutoRemoveInvalid = true,
    HighlightTransparency = {
        Filled = 0.5,
        Outline = 0.3
    },
    TextOutlineEnabled = true,
    TextOutlineColor = Color3.fromRGB(0, 0, 0),
    TextOutlineThickness = 1,
    FovEnabled = false,
    Fov = 90,
    FovCircleEnabled = false
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
    DisplayOrder = 0,  -- Número inteiro para camada de renderização
    Types = {
        Tracer = true/false,
        Name = true/false,
        Distance = true/false,
        HighlightFill = true/false,
        HighlightOutline = true/false
    },
    TextOutlineEnabled = true/false,
    TextOutlineColor = Color3.fromRGB(0, 0, 0),
    TextOutlineThickness = 1,
    ColorDependency = function(esp, distance, pos3D) return Color3.new(...) end,  -- Função opcional para cor dinâmica
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
-- Habilitar/desabilitar a biblioteca globalmente
ModelESP:EnableAll()
ModelESP:DisableAll()

-- Verificar status
print("ESP ativo:", ModelESP.Enabled)
print("Objetos rastreados:", #ModelESP.Objects)
```

**Desenvolvido por Kolt (DH_SOARES)** | Versão 1.6 | Última atualização: Outubro 2025
