# Kolt ESP Library V1.8

Biblioteca ESP (Extra Sensory Perception) minimalista e eficiente para Roblox, desenvolvida por **Kolt (DH_SOARES)**. Sistema robusto focado em performance, facilidade de uso e gerenciamento otimizado de recursos.

## Novidade Principal da V1.8 - Sistema de Keys (Identificadores String)

Agora você pode usar **strings como identificador** em vez de passar a instância diretamente:

```lua
KoltESP:Add("EspBanana", { ... })  -- procura automaticamente workspace.EspBanana
KoltESP:UpdateConfig("EspBanana", { ... })
KoltESP:Remove("EspBanana")
KoltESP:Readjustment("EspBanana", novoModel)  -- quando o model respawna
```

E o target atual fica acessível globalmente:

```lua
getgenv().ESP["EspBanana"]  -- retorna o Model/Part atual
-- ou
KoltESP.ESP["EspBanana"]
```

Isso permite **Readjustment** perfeito em jogos com respawn/destruction de models.

## Características Principais

- ESP Completo: Tracer, Nome, Distância e Highlight (fill + outline)
- Performance otimizada + AutoRemoveInvalid (não remove se tiver key)
- Suporte a **keys string** ou instância direta
- DisplayOrder individual
- Highlights em pasta centralizada
- Rainbow mode
- Collision (mostra partes invisíveis)
- ColorDependency (cor baseada em distância/posição)
- AddToRegistry com suporte a variáveis dinâmicas
- Todas as funções aceitam **string key OU instance**

## Instalação

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Variáveis globais criadas automaticamente
-- getgenv().KoltESP (a própria library)
-- getgenv().ESP["SuaKey"] = target atual
```

## Uso Básico com Keys (Recomendado)

```lua
KoltESP:Add("EspBanana", {
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

-- Quando o model for destruído e respawnar:
KoltESP:Readjustment("EspBanana", workspace.EspBanana)  -- ou workspace:FindFirstChild("EspBanana")

-- Atualizar config
KoltESP:UpdateConfig("EspBanana", {
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
    Types = { Distance = false }
})
```

## Uso Clássico (com Instância

```lua
local target = workspace.SomeModel
KoltESP:Add(target, { Name = "Alvo" })
KoltESP:UpdateConfig(target, { ... })
KoltESP:Remove(target)
```

## Configurações Globais (igual antes)

```lua
KoltESP:SetGlobalTracerOrigin("Bottom")
KoltESP:SetGlobalRainbow(true)
KoltESP:SetGlobalOpacity(0.8)
KoltESP:SetGlobalFontSize(16)
KoltESP:SetGlobalLineThickness(2)
KoltESP:SetGlobalTextOutline(true, Color3.new(0,0,0))

KoltESP:SetGlobalESPType("ShowTracer", true)
-- etc...
```

## AddToRegistry (funciona com key ou instance)

```lua
local corVip = Color3.fromRGB(255, 215, 0)

KoltESP:AddToRegistry("VipPlayer", {
    TextColor = corVip,
    TracerColor = corVip,
    HighlightColor = corVip
})

-- Depois muda a variável e registra novamente → atualiza automaticamente
corVip = Color3.fromRGB(0, 255, 255)
KoltESP:AddToRegistry("VipPlayer", { TextColor = corVip, HighlightColor = corVip })
```

## Referência de API Atualizada

Todas as funções abaixo aceitam **string key** ou **instance**:

| Função                     | Parâmetros                             | Descrição |
|----------------------------|----------------------------------------|----------|
| `Add(keyOrInstance, config)`| string ou Model/BasePart, tabela config | Adiciona ESP (cria key se usar string) |
| `Remove(keyOrInstance)`     | string ou instance                     | Remove ESP |
| `UpdateConfig(keyOrInstance, config)` | string ou instance, config      | Atualiza config sem recriar |
| `Readjustment(key, newTarget, config?)` | string, new Model/BasePart, config opcional | Transfere ESP para novo target (ideal para respawn) |
| `GetESP(keyOrInstance)`     | string ou instance                     | Retorna tabela ESP |
| `SetColor(keyOrInstance, color)` | ...                               | Cor única |
| `SetName(keyOrInstance, name)`   |                                   | Muda nome |
| `SetDisplayOrder(keyOrInstance, num)` |                              | ZIndex |
| `AddToRegistry(keyOrInstance, colorTable)` |                           | Registro de cores |

## Exemplo Prático para Personagens com Respawn

```lua
local function addPlayerESP(player)
    if player == game.Players.LocalPlayer then return end

    local key = "Player_"..player.UserId

    local function setup(char)
        KoltESP:Readjustment(key, char, {
            Name = player.DisplayName .. " ["..player.Name.."]",
            Color = Color3.fromRGB(255,0,255),
            Collision = true
        })
    end

    if player.Character then setup(player.Character) end

    player.CharacterAdded:Connect(setup)
    player.CharacterRemoving:Connect(function()
        -- não precisa remover, Readjustment cuida
    end)
end

for _, plr in pairs(game.Players:GetPlayers()) do
    addPlayerESP(plr)
end
game.Players.PlayerAdded:Connect(addPlayerESP)
```

## Notas de Versão

### V1.8 (19 de Novembro de 2025)
- **Sistema de Keys** → uso com strings como identificador
- `ESP["key"]` global para acessar target atual
- `Readjustment(key, newTarget)` simplificado
- Todas as funções aceitam key ou instance
- AutoRemoveInvalid **não remove** objetos com key (permite respawn)
- AddToRegistry agora aceita key
- Performance ainda mais otimizada no loop

### Versões anteriores
- V1.7: Remoção de AddToPlayer, foco em uso manual, otimização extrema
- V1.6.5: Customizações individuais por ESP, pause/resume, Unload

**Desenvolvido por Kolt (DH_SOARES)** | Versão 1.8 | 19 de Novembro de 2025

Pronto! README atualizado para a versão atual da library com o sistema de keys. Pode copiar e colar diretamente no GitHub.
