# 📦 Kolt ESP Library V1.6.5

Biblioteca ESP minimalista e eficiente para Roblox, desenvolvida por **Kolt (DH_SOARES)**. Foco em performance, customização e robustez, com suporte a tracers, nomes, distâncias, highlights e limitações por FOV. Atualizações incluem remoção de propriedades obsoletas, adição de prefixo/sufixo para distância, mais opções de personalização (fonte, opacidade, espessura de linha por ESP) e otimização geral.

## Características Principais

- Suporte completo a Tracer, Nome, Distância e Highlight (preenchimento/outline).
- Modo arco-íris e dependência dinâmica de cores.
- Customização avançada: cores por elemento, outline de texto, camadas (DisplayOrder).
- Performance otimizada: auto-remoção de inválidos, armazenamento centralizado de highlights.
- Collision opcional por ESP, com ajuste de transparência.
- Limitação por FOV com círculo visual.
- Suporte a respawn e gerenciamento global (enable/disable).
- APIs para reajuste, atualização e controle individual.

## Instalação

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()
```

## Uso Básico

Exemplo simples de adição de ESP com customizações:

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configurações globais opcionais
KoltESP:SetGlobalHighlightTransparency({Filled = 0.6, Outline = 0.4})
KoltESP:SetGlobalTextOutline(true, Color3.fromRGB(0, 0, 0), 1)
KoltESP:FovEsp(true, 90)  -- Ativa FOV com círculo

-- Adiciona ESP a um alvo com customizações
KoltESP:Add(workspace.SomeModel, {
    Name = "Alvo",
    Color = Color3.fromRGB(255, 0, 0),
    Collision = true,
    DistancePrefix = "<",
    DistanceSuffix = "m>",
    DisplayOrder = 5,
    Types = {Tracer = true, Name = true, Distance = true, HighlightFill = false, HighlightOutline = true},
    TextOutlineEnabled = true,
    TextOutlineColor = Color3.fromRGB(0, 0, 0),
    Opacity = 0.9,
    LineThickness = 2,
    FontSize = 16,
    Font = 3,  -- Monospace
    MaxDistance = 500,
    MinDistance = 10,
    ColorDependency = function(esp, distance) return distance < 50 and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0) end
})

-- Controle
KoltESP:ToggleIndividual(workspace.SomeModel, false)  -- Desabilita
KoltESP:Remove(workspace.SomeModel)  -- Remove
```

## Propriedades Globais (GlobalSettings)

Acessíveis via `KoltESP.GlobalSettings`:

- `TracerOrigin`: Origem do tracer ("Bottom", "Top", "Center", "Left", "Right").
- `ShowTracer`: Habilita tracers globalmente (true/false).
- `ShowHighlightFill`: Habilita preenchimento de highlight (true/false).
- `ShowHighlightOutline`: Habilita outline de highlight (true/false).
- `ShowName`: Habilita nomes (true/false).
- `ShowDistance`: Habilita distâncias (true/false).
- `RainbowMode`: Modo arco-íris (true/false).
- `MaxDistance`: Distância máxima para visibilidade (número).
- `MinDistance`: Distância mínima (número).
- `Opacity`: Opacidade global (0-1).
- `LineThickness`: Espessura de linhas (número).
- `FontSize`: Tamanho da fonte (número).
- `Font`: Fonte (0: UI, 1: System, 2: Plex, 3: Monospace).
- `AutoRemoveInvalid`: Remove ESPs inválidos automaticamente (true/false).
- `HighlightTransparency`: {Filled: número (0-1), Outline: número (0-1)}.
- `TextOutlineEnabled`: Outline de texto (true/false).
- `TextOutlineColor`: Cor do outline (Color3).
- `TextOutlineThickness`: Espessura do outline (número).
- `FovEnabled`: Limite por FOV (true/false).
- `Fov`: Valor do FOV em graus (número).
- `FovCircleEnabled`: Mostra círculo de FOV (true/false).

## Propriedades por ESP (Config ao Adicionar/Atualizar)

Passadas como tabela em `Add` ou `UpdateConfig`:

- `Name`: Nome exibido (string).
- `Collision`: Ativa collision (true/false).
- `DistancePrefix`: Prefixo para distância (string).
- `DistanceSuffix`: Sufixo para distância (string).
- `DisplayOrder`: Camada de renderização (número, ZIndex).
- `Types`: {Tracer: true/false, Name: true/false, Distance: true/false, HighlightFill: true/false, HighlightOutline: true/false}.
- `TextOutlineEnabled`: Outline de texto (true/false).
- `TextOutlineColor`: Cor do outline (Color3).
- `TextOutlineThickness`: Espessura do outline (número).
- `ColorDependency`: Função(esp, distance, pos3D) retornando Color3.
- `Color`: Color3 único ou tabela {Name: {R,G,B}, Distance: {R,G,B}, Tracer: {R,G,B}, Highlight: {Filled: {R,G,B}, Outline: {R,G,B}}}.
- `Opacity`: Opacidade (0-1).
- `LineThickness`: Espessura de linhas (número).
- `FontSize`: Tamanho da fonte (número).
- `Font`: Fonte (0-3).
- `MaxDistance`: Distância máxima (número).
- `MinDistance`: Distância mínima (número).

## Métodos Principais

- `Add(target, config)`: Adiciona ESP.
- `Remove(target)`: Remove ESP.
- `Clear()`: Limpa todos.
- `Unload()`: Descarrega biblioteca.
- `EnableAll()` / `DisableAll()`: Habilita/desabilita global.
- `ToggleIndividual(target, enabled)`: Habilita/desabilita individual.
- `UpdateConfig(target, newConfig)`: Atualiza config.
- `Readjustment(newTarget, oldTarget, newConfig)`: Reajusta para novo alvo.
- `SetColor(target, color)`: Define cor.
- `SetName(target, newName)`: Define nome.
- `SetDisplayOrder(target, order)`: Define camada.
- `SetTextOutline(target, enabled, color, thickness)`: Define outline de texto.
- `SetGlobalESPType(type, enabled)`: Define tipo global.
- `SetGlobalRainbow(enable)`: Ativa arco-íris.
- `SetGlobalOpacity(value)`: Define opacidade.
- `SetGlobalFontSize(size)`: Define tamanho de fonte.
- `SetGlobalLineThickness(thick)`: Define espessura.
- `SetGlobalFont(font)`: Define fonte.
- `SetGlobalTextOutline(enabled, color, thickness)`: Define outline global.
- `SetGlobalHighlightTransparency(trans)`: Define transparências de highlight.
- `FovEsp(enabled, fov)`: Configura FOV.
- `SetHighlightFolderName(name)`: Define pasta de highlights.

**Desenvolvido por Kolt (DH_SOARES)** | Versão 1.6.5 | Última atualização: Outubro 2025
