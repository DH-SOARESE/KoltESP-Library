# KoltESP Library v1.0

Uma biblioteca ESP (Extra Sensory Perception) completa e fácil de usar para Roblox, projetada para destacar objetos no jogo com tracers, nomes, distâncias e highlights.

## 📋 Características

- ✅ **Tracer Lines** - Linhas conectando objetos à tela
- ✅ **Name Display** - Exibição de nomes personalizados
- ✅ **Distance Display** - Mostra a distância até o objeto
- ✅ **3D Highlights** - Destaque visual dos objetos
- ✅ **Configuração Global** - Controle centralizado de todas as features
- ✅ **Performance Otimizada** - Sistema de rendering eficiente
- ✅ **Fácil de Usar** - API simples e intuitiva

## 🚀 Instalação

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()
```

## 📖 Como Usar

### Exemplo Básico

```lua
-- Carregar a library
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Adicionar ESP a um jogador
local target = KoltESP:Add(game.Players.SomePlayer.Character, {
    EspColor = {255, 0, 0}, -- Vermelho
    EspName = { DisplayName = "Inimigo", Container = " [ALVO]" },
    EspDistance = { Container = "%dm", Suffix = " away" }
})
```

### Exemplo Avançado

```lua
-- Configurar ESP para todos os jogadores
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
        KoltESP:Add(player.Character, {
            EspColor = {0, 255, 255}, -- Ciano
            EspName = { 
                DisplayName = player.DisplayName, 
                Container = " [" .. player.Name .. "]" 
            },
            EspDistance = { Container = "[%d]", Suffix = "m" },
            Colors = {
                EspTracer = {255, 255, 0}, -- Tracer amarelo
                EspNameColor = {255, 255, 255}, -- Nome branco
                EspDistanceColor = {0, 255, 0}, -- Distância verde
                EspHighlight = {
                    Outline = {255, 0, 0}, -- Contorno vermelho
                    Filled = {255, 0, 0}   -- Preenchimento vermelho
                }
            }
        })
    end
end

-- ESP para objetos específicos (ex: partes importantes do mapa)
KoltESP:Add("Workspace.ImportantPart", {
    EspColor = {255, 255, 0},
    EspName = { DisplayName = "Objetivo", Container = " ⭐" },
    EspDistance = { Container = "Distância: %d", Suffix = " studs" }
})
```

## ⚙️ Configuração Global

```lua
-- Modificar configurações globais
KoltESP.Config.Tracer.Visible = true      -- Mostrar tracers
KoltESP.Config.Tracer.Origin = "Bottom"   -- Origem: "Top", "Center", "Bottom"
KoltESP.Config.Tracer.Thickness = 2       -- Espessura da linha

KoltESP.Config.Name.Visible = true        -- Mostrar nomes
KoltESP.Config.Distance.Visible = true    -- Mostrar distâncias

-- Configurar highlights
KoltESP.Config.Highlight.Outline = true   -- Contorno ativo
KoltESP.Config.Highlight.Filled = false   -- Preenchimento desativo
KoltESP.Config.Highlight.Transparency = {
    Outline = 0.2,  -- Transparência do contorno
    Filled = 0.7    -- Transparência do preenchimento
}

-- Limites de distância
KoltESP.Config.DistanceMax = 500  -- Distância máxima (studs)
KoltESP.Config.DistanceMin = 10   -- Distância mínima (studs)
```

## 🎨 Propriedades de Configuração

### Configuração por Target

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| `EspColor` | `{r, g, b}` | Cor padrão do ESP (0-255) |
| `EspName` | `table` | Configuração do nome |
| `EspName.DisplayName` | `string` | Nome a ser exibido |
| `EspName.Container` | `string` | Texto adicional após o nome |
| `EspDistance` | `table` | Configuração da distância |
| `EspDistance.Container` | `string` | Formato da distância (use %d) |
| `EspDistance.Suffix` | `string` | Sufixo após a distância |
| `Colors` | `table` | Cores específicas por componente |

### Cores Específicas (Colors)

```lua
Colors = {
    EspTracer = {255, 0, 0},           -- Cor do tracer
    EspNameColor = {255, 255, 255},    -- Cor do nome
    EspDistanceColor = {0, 255, 0},    -- Cor da distância
    EspHighlight = {
        Outline = {255, 0, 0},         -- Cor do contorno
        Filled = {0, 0, 255}           -- Cor do preenchimento
    }
}
```

## 🛠️ Métodos Disponíveis

### Adicionar Target
```lua
local target = KoltESP:Add(pathOrObject, config)
```
- **pathOrObject**: Instância do objeto ou caminho string (ex: "Workspace.Part")
- **config**: Tabela de configuração
- **Retorna**: Referência do target criado

### Remover Target
```lua
KoltESP.Remove(target)
```

### Limpar Todos os Targets
```lua
KoltESP.Clear()
```

### Pausar/Retomar
```lua
KoltESP.Pause(true)   -- Pausar
KoltESP.Pause(false)  -- Retomar
```

### Descarregar Completamente
```lua
KoltESP.Unload() -- Remove tudo e para o rendering
```

## 📝 Exemplos Práticos

### ESP para Itens de Loot
```lua
-- Adicionar ESP a todos os itens valiosos
for _, item in pairs(workspace.Loot:GetChildren()) do
    if item:IsA("BasePart") then
        KoltESP:Add(item, {
            EspColor = {255, 215, 0}, -- Dourado
            EspName = { DisplayName = "💰 " .. item.Name, Container = "" },
            EspDistance = { Container = "[%dm]", Suffix = "" }
        })
    end
end
```

### ESP para Veículos
```lua
for _, vehicle in pairs(workspace.Vehicles:GetChildren()) do
    KoltESP:Add(vehicle, {
        EspColor = {128, 0, 128}, -- Roxo
        EspName = { DisplayName = "🚗 Veículo", Container = "" },
        EspDistance = { Container = "%d", Suffix = "m" },
        Colors = {
            EspTracer = {255, 0, 255},
            EspHighlight = {
                Outline = {128, 0, 128},
                Filled = {128, 0, 128}
            }
        }
    })
end
```

### Monitoramento Automático de Jogadores
```lua
-- Função para adicionar ESP quando jogador spawnar
local function onPlayerAdded(player)
    if player == game.Players.LocalPlayer then return end
    
    local function onCharacterAdded(character)
        wait(1) -- Esperar o personagem carregar
        KoltESP:Add(character, {
            EspColor = {255, 100, 100},
            EspName = { 
                DisplayName = player.DisplayName, 
                Container = " [Lv." .. (player.leaderstats and player.leaderstats.Level.Value or "?") .. "]" 
            },
            EspDistance = { Container = "%dm", Suffix = "" }
        })
    end
    
    if player.Character then onCharacterAdded(player.Character) end
    player.CharacterAdded:Connect(onCharacterAdded)
end

-- Aplicar a jogadores existentes
for _, player in pairs(game.Players:GetPlayers()) do
    onPlayerAdded(player)
end

-- Aplicar a novos jogadores
game.Players.PlayerAdded:Connect(onPlayerAdded)
```

## ⚠️ Notas Importantes

- A library usa o serviço `Drawing` e `Highlight` do Roblox
- Certifique-se de que o exploit suporte essas APIs
- O rendering é otimizado e roda no `RenderStepped`
- Objetos fora dos limites de distância são automaticamente ocultados
- Use `KoltESP.Unload()` antes de recarregar scripts para evitar vazamentos de memória

## 🔧 Troubleshooting

**ESP não aparece:**
- Verifique se o objeto ainda existe no jogo
- Confirme se está dentro dos limites de distância
- Teste com `KoltESP.Config.DistanceMax = 999999`

**Performance ruim:**
- Reduza o número de targets ativos
- Aumente `DistanceMin` e diminua `DistanceMax`
- Use `KoltESP.Pause(true)` quando não precisar

**Cores não funcionam:**
- Use valores RGB de 0-255: `{255, 0, 0}` para vermelho
- Verifique se a tabela `Colors` está formatada corretamente

---

**Versão:** 1.0  
**Autor:** KoltESP Team  
**Licença:** Open Source

Para suporte ou sugestões, abra uma issue no repositório GitHub.
