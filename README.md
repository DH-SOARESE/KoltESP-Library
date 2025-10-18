# 📦 Kolt ESP Library V1.7

Uma biblioteca ESP (Extra Sensory Perception) minimalista, eficiente e altamente customizável para Roblox, desenvolvida por **Kolt (DH_SOARES)**. Projetada para oferecer um sistema de ESP robusto e responsivo, com foco em performance, facilidade de uso e gerenciamento otimizado de recursos. Esta versão introduz melhorias em organização, correções em APIs, otimizações de performance, remoção de Humanoid desnecessário para collision, suporte aprimorado para collision e adição de mais opções de configuração.

## ✨ Características

- 🎯 **ESP Completo**: Suporte a Tracer, Nome, Distância e Highlight (preenchimento e outline).
- 🌈 **Modo Arco-íris**: Cores dinâmicas que mudam automaticamente.
- 🎨 **Customização Avançada de Cores**: Suporte a cores individuais por elemento (Name, Distance, Tracer, Highlight) via tabela ou Color3.
- ⚡ **Performance Otimizada**: Sistema de auto-remoção de objetos inválidos, verificação de duplicatas, atualizações eficientes por frame, e armazenamento centralizado de Highlights em uma pasta no ReplicatedStorage. Otimizações adicionais no loop de renderização e cálculo de posições.
- 📱 **Responsivo**: Adapta-se a diferentes resoluções, com posicionamento preciso mesmo em distâncias próximas (1-10 metros).
- 🔧 **Fácil de Usar**: API intuitiva com métodos para gerenciamento avançado de ESPs.
- 🆕 **ESP Collision (Opcional e Individual)**: Ajusta transparência de parts invisíveis para melhor detecção de colisões, sem necessidade de Humanoid.
- 🆕 **Customização de Distância**: Suporte a `DistancePrefix` e `DistanceSuffix` para personalizar a exibição da distância (ex: "Dist: 10m").
- 🆕 **Transparências de Highlight Configuráveis**: Ajuste global para transparências de preenchimento e outline via `SetGlobalHighlightTransparency`.
- 🆕 **Pasta Central para Highlights**: Armazena Highlights em uma pasta no ReplicatedStorage (nome configurável via `SetHighlightFolderName`), usando `Adornee` para vincular ao alvo.
- 🆕 **Novos Métodos**: Inclui `Readjustment`, `ToggleIndividual`, `SetColor`, `SetName`, `SetDisplayOrder`, `SetTextOutline`, `UpdateConfig`, `SetGlobalHighlightTransparency`, `SetHighlightFolderName`, `Unload`, `EnableAll`, `DisableAll`, `SetGlobalTextOutline`, `SetFov` e melhorias em `FovEsp`.
- 🆕 **Sistema de Camadas para Drawings**: Cada ESP tem um `DisplayOrder` individual (ZIndex para Tracer, Name, Distance), permitindo sobreposição de elementos.
- 🆕 **Otimização de Highlights**: Highlights são criados uma vez por ESP e atualizados eficientemente, evitando recriação constante.
- 🆕 **Função de Descarregamento**: Método `Unload` limpa a biblioteca, desconecta eventos e remove recursos.
- 🆕 **Controle Global de Visibilidade**: Funções `EnableAll` e `DisableAll` para habilitar/desabilitar todos os ESPs.
- 🆕 **Tipos Individuais de ESP**: Cada ESP pode configurar tipos específicos (Tracer, Name, Distance, HighlightFill, HighlightOutline), respeitando configurações globais.
- 🆕 **Fallback para Centro do Modelo**: Usa o centro do modelo como referência se não houver partes visíveis, com cálculo otimizado usando Magnitude.
- 🆕 **Propriedades de Outline para Textos**: Configurável global e individualmente (habilitado, cor, espessura).
- 🆕 **Dependência de Cor Dinâmica**: Função personalizada para calcular cores com base em variáveis como distância ou posição.
- 🆕 **Restart on Respawn**: Recria objetos Drawing automaticamente ao respawn do jogador local.
- 🆕 **ESP FOV**: Limita a renderização a um campo de visão definido, com círculo visual (`Drawing Circle`) opcional e configurações aprimoradas.
- 🆕 **Personalizações Individuais**: Suporte a `Font`, `Opacity`, `LineThickness`, `FontSize`, `MaxDistance` e `MinDistance` por ESP.
- 🐛 **Correções e Melhorias (V1.7)**:
  - **Organização Melhorada**: Refatoração de funções auxiliares e APIs para maior clareza e manutenção.
  - **Correções em APIs**: Ajustes em `ToggleIndividual` para toggle opcional, `SetName` atualiza texto imediatamente, e correções em colisões.
  - **Otimizações de Performance**: Remoção de Humanoid desnecessário, uso dinâmico de partes visíveis, cálculos mais eficientes no loop de renderização.
  - **Suporte Aprimorado para Collision**: Ajuste de transparência para 0.98 em parts >=0.99, com restauração precisa.
  - **Adição de Opções**: Novos clamps em configurações globais (ex: FontSize 8-36, LineThickness 0.5-5), método `SetFov` para controle detalhado.
  - **Outras Correções**: Formatação de distância para inteiro (`math.floor`), delay em `AddToPlayer` para carregamento, e melhorias em FOV.

## 🚀 Instalação

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARES/KoltESP-Library/refs/heads/main/Library.lua"))()
```

**Nota**: Corrigido o nome do repositório para DH-SOARES (anteriormente DH-SOARESE).

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
- **Nome**: Exibe o nome do objeto, centralizado, com outline configurável.
- **Distância**: Mostra a distância em metros com formatação precisa (ex: "Dist: 10m"), com prefixo/sufixo customizáveis.
- **Highlight**: Contorno e preenchimento colorido ao redor do objeto, com transparências ajustáveis globalmente.

### 🎮 Origens do Tracer
- `Top` - Topo da tela.
- `Center` - Centro da tela.
- `Bottom` - Parte inferior da tela (padrão).
- `Left` - Lateral esquerda.
- `Right` - Lateral direita.

**Nota**: A origem do Tracer é global e não configurável individualmente.

### 🆕 Opção de Collision
- Ativada via `Collision = true` na configuração.
- Ajusta transparência de parts com valor >=0.99 para 0.98.
- Restaura transparências originais ao remover o ESP.

### 🆕 Propriedades de Distância
- **DistancePrefix**: Prefixo antes do valor da distância (ex: "Dist:").
- **DistanceSuffix**: Sufixo após o valor da distância (ex: "m").
- **TextOutlineEnabled**: Habilita/desabilita outline para textos.
- **TextOutlineColor**: Cor do outline.
- **TextOutlineThickness**: Espessura do outline (armazenada para uso futuro, clamp 1-3 globalmente).

### 🆕 Gerenciamento de Highlights
- Highlights armazenados em uma pasta no ReplicatedStorage (padrão: "Highlight Folder").
- Nome da pasta configurável via `SetHighlightFolderName`.
- Transparências globais ajustáveis via `SetGlobalHighlightTransparency`.
- Otimização: Highlights atualizados in-place, sem recriação.

### 🆕 Sistema de Camadas (DisplayOrder)
- Define o ZIndex para Tracer, Name e Distance.
- Valores mais altos são renderizados sobre valores mais baixos.
- Configurável via `DisplayOrder` ao adicionar/atualizar ESP.

### 🆕 Sistema de Tipos Individuais
- Configura tipos específicos (Tracer, Name, Distance, HighlightFill, HighlightOutline) por ESP.
- Respeita configurações globais (ex: se `ShowTracer = false` globalmente, não aparece).

### 🆕 Fallback para Centro do Modelo
- Usa o centro do bounding box do modelo como referência se não houver partes visíveis, com cálculo otimizado.

### 🆕 Dependência de Cor Dinâmica
- Configurável via `ColorDependency = function(esp, distance, pos3D)`.
- Calcula cores dinamicamente com base em distância ou posição.

### 🆕 Restart on Respawn
- Recria objetos Drawing ao respawn do jogador local.

### 🆕 ESP FOV
- Limita visibilidade a um ângulo de visão definido.
- Suporte a círculo visual via `Drawing Circle`, configurável com `SetFov`.

### 🆕 Personalizações Individuais
- Suporte a `Font`, `Opacity`, `LineThickness`, `FontSize`, `MaxDistance` e `MinDistance` por ESP.

## 🛠️ Uso Básico

### Adicionando ESP a um Objeto

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARES/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configurações iniciais
KoltESP:SetHighlightFolderName("MyESPHighlights")
KoltESP:SetGlobalHighlightTransparency({Filled = 0.6, Outline = 0.4})
KoltESP:SetGlobalTextOutline(true, Color3.fromRGB(0, 0, 0), 1)
KoltESP:SetFov(true, 90, true)

-- Adicionar ESP básico
KoltESP:Add(workspace.SomeModel)

-- Adicionar ESP com configurações avançadas
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
    Font = 3,  -- Monospace
    Opacity = 0.9,
    LineThickness = 2,
    FontSize = 16,
    MaxDistance = 500,
    MinDistance = 10,
    TextOutlineEnabled = true,
    TextOutlineColor = Color3.fromRGB(0, 0, 0),
    ColorDependency = function(esp, distance, pos3D)
        return distance < 50 and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
    end
})
```

## 🛠️ Gerenciamento Avançado

### Reajustando um ESP

```lua
KoltESP:Readjustment(workspace.NewModel, workspace.OldModel, {
    Name = "Novo Alvo",
    Color = Color3.fromRGB(0, 255, 255),
    Collision = false,
    DistancePrefix = "",
    DistanceSuffix = "m",
    DisplayOrder = 8,
    Types = { Tracer = true, HighlightFill = false },
    Font = 2,  -- Plex
    Opacity = 0.7,
    LineThickness = 1.5,
    FontSize = 14,
    MaxDistance = 1000,
    MinDistance = 0,
    TextOutlineEnabled = true,
    TextOutlineColor = Color3.fromRGB(50, 50, 50),
    ColorDependency = function(esp, distance, pos3D)
        return Color3.fromHSV(distance / 1000, 1, 1)
    end
})
```

### Atualizando Configurações

```lua
KoltESP:UpdateConfig(workspace.SomeModel, {
    Name = "Alvo Atualizado",
    Color = {
        Name = {255, 255, 0},
        Distance = {255, 255, 0},
        Tracer = {255, 215, 0},
        Highlight = { Filled = {255, 200, 0}, Outline = {255, 255, 0} }
    },
    Collision = false,
    DistancePrefix = "Dist: ",
    DistanceSuffix = "m",
    DisplayOrder = 3,
    Types = { Distance = false, HighlightOutline = true },
    Font = 3,
    Opacity = 0.8,
    LineThickness = 2,
    FontSize = 15,
    MaxDistance = 600,
    MinDistance = 5,
    TextOutlineEnabled = false,
    TextOutlineColor = Color3.fromRGB(100, 100, 100)
})
```

### Controlando ESP Individualmente

```lua
KoltESP:ToggleIndividual(workspace.SomeModel)  -- Toggle (sem argumento)
KoltESP:SetColor(workspace.SomeModel, Color3.fromRGB(0, 255, 0))
KoltESP:SetName(workspace.SomeModel, "Novo Nome")
KoltESP:SetDisplayOrder(workspace.SomeModel, 7)
KoltESP:SetTextOutline(workspace.SomeModel, true, Color3.fromRGB(0, 0, 0), 1)
```

### Removendo ou Descarregando

```lua
KoltESP:Remove(workspace.SomeModel)
KoltESP:Clear()
KoltESP:Unload()
```

## 🎨 Configurações Globais

### Habilitando/Desabilitando Componentes

```lua
KoltESP:SetGlobalESPType("ShowTracer", true)
KoltESP:SetGlobalESPType("ShowName", true)
KoltESP:SetGlobalESPType("ShowDistance", true)
KoltESP:SetGlobalESPType("ShowHighlightFill", true)
KoltESP:SetGlobalESPType("ShowHighlightOutline", true)
```

### Personalizando Aparência

```lua
KoltESP:SetGlobalTracerOrigin("Bottom")
KoltESP:SetGlobalRainbow(true)
KoltESP:SetGlobalOpacity(0.8)
KoltESP:SetGlobalFontSize(16)
KoltESP:SetGlobalLineThickness(2)
KoltESP:SetGlobalHighlightTransparency({Filled = 0.5, Outline = 0.3})
KoltESP:SetGlobalTextOutline(true, Color3.fromRGB(0, 0, 0), 1)
KoltESP:SetGlobalFont(3)  -- Monospace
```

### Controle de Distância e FOV

```lua
KoltESP.GlobalSettings.MaxDistance = 1000
KoltESP.GlobalSettings.MinDistance = 0
KoltESP:SetFov(true, 120, true)  -- Habilitado, FOV 120, círculo visível
```

### Controle Global de Visibilidade

```lua
KoltESP:EnableAll()
KoltESP:DisableAll()
```

## 📖 Exemplos Práticos

### 🧑‍🤝‍🧑 ESP para Jogadores

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARES/KoltESP-Library/refs/heads/main/Library.lua"))()

KoltESP:SetHighlightFolderName("PlayerESPHighlights")
KoltESP:SetGlobalHighlightTransparency({Filled = 0.7, Outline = 0.2})
KoltESP:SetGlobalTextOutline(true, Color3.fromRGB(0, 0, 0), 1)
KoltESP:SetFov(true, 90, true)
KoltESP:SetGlobalTracerOrigin("Top")
KoltESP:SetGlobalRainbow(false)
KoltESP:SetGlobalOpacity(0.8)
KoltESP:SetGlobalFontSize(16)
KoltESP:SetGlobalLineThickness(2)
KoltESP:SetGlobalFont(3)
KoltESP.GlobalSettings.MaxDistance = 500
KoltESP.GlobalSettings.MinDistance = 10

local function addPlayerESP(player)
    KoltESP:AddToPlayer(player, {
        Name = player.Name,
        Collision = false,
        DistancePrefix = "Dist: ",
        DistanceSuffix = "m",
        DisplayOrder = 10,
        Types = { Tracer = true, Name = true, Distance = true, HighlightFill = false, HighlightOutline = true },
        Color = {
            Name = {144, 0, 255},
            Distance = {144, 0, 255},
            Tracer = {144, 0, 255},
            Highlight = { Filled = {144, 0, 255}, Outline = {200, 0, 255} }
        },
        Font = 3,
        Opacity = 0.9,
        LineThickness = 2,
        FontSize = 16,
        MaxDistance = 600,
        MinDistance = 5,
        TextOutlineEnabled = true,
        TextOutlineColor = Color3.fromRGB(0, 0, 0),
        ColorDependency = function(esp, distance, pos3D)
            return distance > 100 and Color3.fromRGB(255, 165, 0) or nil
        end
    })
end

for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
        addPlayerESP(player)
    end
end

game.Players.PlayerAdded:Connect(addPlayerESP)
game.Players.PlayerRemoving:Connect(function(player)
    KoltESP:RemoveFromPlayer(player)
end)

game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F10 then
        KoltESP:Unload()
    end
end)
```

### 🎯 ESP para Objetos Específicos

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARES/KoltESP-Library/refs/heads/main/Library.lua"))()

KoltESP:SetHighlightFolderName("ObjectESPHighlights")
KoltESP:SetGlobalHighlightTransparency({Filled = 0.5, Outline = 0.3})
KoltESP:SetGlobalTextOutline(false, Color3.fromRGB(255, 255, 255), 2)
KoltESP:SetFov(true, 60, false)

local function addPartESP(partName, espName, colorTable, collision, prefix, suffix, displayOrder, types, font, opacity, lineThickness, fontSize, maxDistance, minDistance, textOutlineEnabled, textOutlineColor)
    for _, part in pairs(workspace:GetDescendants()) do
        if part.Name == partName and (part:IsA("BasePart") or part:IsA("Model")) then
            KoltESP:Add(part, {
                Name = espName or part.Name,
                Collision = collision or false,
                DistancePrefix = prefix or "",
                DistanceSuffix = suffix or "m",
                DisplayOrder = displayOrder or 0,
                Types = types or { Tracer = true, Name = true, Distance = true, HighlightFill = true, HighlightOutline = true },
                Color = colorTable or {
                    Name = {255, 255, 0},
                    Distance = {255, 255, 0},
                    Tracer = {255, 215, 0},
                    Highlight = { Filled = {255, 215, 0}, Outline = {255, 255, 0} }
                },
                Font = font or 3,
                Opacity = opacity or 0.8,
                LineThickness = lineThickness or 1.5,
                FontSize = fontSize or 14,
                MaxDistance = maxDistance or math.huge,
                MinDistance = minDistance or 0,
                TextOutlineEnabled = textOutlineEnabled,
                TextOutlineColor = textOutlineColor,
                ColorDependency = function(esp, distance, pos3D)
                    return Color3.fromRGB(255, 255 - distance * 2, 0)
                end
            })
        end
    end
end

addPartESP("Chest", "💰 Baú", nil, true, "Dist: ", "m", 5, { Tracer = false, HighlightFill = true }, 3, 0.9, 2, 16, 500, 10, true, Color3.fromRGB(0, 0, 0))
addPartESP("Enemy", "👹 Inimigo", { Tracer = {255, 0, 0}, Highlight = { Filled = {200, 0, 0}, Outline = {255, 0, 0} } }, false, "", "", 10, { Distance = false, HighlightOutline = true }, 2, 0.8, 1.5, 14, 1000, 0, false, Color3.fromRGB(255, 255, 255))
addPartESP("PowerUp", "⚡ Power-Up", nil, true, "", " metros", 2, { Name = true, HighlightFill = false }, 3, 0.7, 1, 12, 300, 5, true, Color3.fromRGB(50, 50, 50))
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
    Font = 3,  -- 0: UI, 1: System, 2: Plex, 3: Monospace
    AutoRemoveInvalid = true,
    HighlightTransparency = { Filled = 0.5, Outline = 0.3 },
    TextOutlineEnabled = true,
    TextOutlineColor = Color3.fromRGB(0, 0, 0),
    TextOutlineThickness = 1,
    FovEnabled = false,
    Fov = 90,
    FovCircleEnabled = false
}
```

### Estrutura de Configuração
```lua
{
    Name = "Nome Personalizado",
    Collision = true/false,
    DistancePrefix = "Dist: ",
    DistanceSuffix = "m",
    DisplayOrder = 0,
    Types = { Tracer = true/false, Name = true/false, Distance = true/false, HighlightFill = true/false, HighlightOutline = true/false },
    Font = 0/1/2/3,
    Opacity = 0.8,
    LineThickness = 1.5,
    FontSize = 14,
    MaxDistance = math.huge,
    MinDistance = 0,
    TextOutlineEnabled = true/false,
    TextOutlineColor = Color3.fromRGB(0, 0, 0),
    TextOutlineThickness = 1,
    ColorDependency = function(esp, distance, pos3D) return Color3.new(...) end,
    Color = { ... } -- Tabela de cores ou Color3 único
}
```

### Estrutura de Cores
```lua
Color = {
    Name = {255, 255, 255},
    Distance = {255, 255, 255},
    Tracer = {0, 255, 0},
    Highlight = { Filled = {100, 144, 0}, Outline = {0, 255, 0} }
}
```

## 🎮 Controles

```lua
KoltESP:EnableAll()
KoltESP:DisableAll()
print("ESP ativo:", KoltESP.Enabled)
print("Objetos rastreados:", #KoltESP.Objects)
```

**Desenvolvido por Kolt (DH_SOARES)** | Versão 1.7 | Última atualização: Outubro 2025

---

Este README foi atualizado e organizado para a versão 1.7, com seções mais claras, correções de typos (como no URL do repositório) e reflexo das mudanças no código. Se precisar de mais ajustes, é só avisar!
