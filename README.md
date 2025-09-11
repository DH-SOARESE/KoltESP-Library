# 📦 Kolt ESP Library V1.4 Enhanced

Uma biblioteca ESP (Extra Sensory Perception) avançada e otimizada para Roblox, criada por **DH_SOARES**. Design minimalista, eficiente e responsivo com funcionalidades modernas.

## ✨ Características

- 🎨 **Design Moderno**: Interface minimalista e responsiva
- 🚀 **Performance Otimizada**: Sistema de cache inteligente
- 🌈 **Efeitos Visuais**: Modo arco-íris e gradientes
- 🎯 **SetTarget Individual**: Redefinir alvos específicos
- 📊 **Estatísticas em Tempo Real**: Monitoramento de performance
- 🔄 **Auto-limpeza**: Remove objetos inválidos automaticamente

## 🚀 Instalação Rápida

```lua
-- Carregamento via loadstring
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()
```

## 📋 Índice

- [Instalação](#-instalação-rápida)
- [Uso Básico](#-uso-básico)
- [Configurações Globais](#-configurações-globais)
- [Funcionalidades Avançadas](#-funcionalidades-avançadas)
- [Exemplos Práticos](#-exemplos-práticos)
- [API Completa](#-api-completa)
- [Estatísticas](#-estatísticas)

## 🎯 Uso Básico

### Adicionando ESP Simples

```lua
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- ESP básico em um modelo
ESP:Add(workspace.Model)

-- ESP em uma parte específica
ESP:Add(workspace.Part)

-- ESP usando caminho de string
ESP:Add("Workspace.Model.HumanoidRootPart")
```

### ESP com Configurações Personalizadas

```lua
-- ESP personalizado
ESP:Add(workspace.Target, {
    Color = Color3.fromRGB(255, 100, 100),
    Name = "Inimigo",
    ShowTracer = true,
    ShowHighlight = true,
    ShowName = true,
    ShowDistance = true,
    TracerOrigin = "Center"
})
```

## ⚙️ Configurações Globais

### Configurações de Visualização

```lua
-- Ativar/desativar elementos globalmente
ESP:SetGlobalESPType("ShowTracer", true)
ESP:SetGlobalESPType("ShowHighlightFill", true)
ESP:SetGlobalESPType("ShowHighlightOutline", true)
ESP:SetGlobalESPType("ShowName", true)
ESP:SetGlobalESPType("ShowDistance", true)

-- Origem dos tracers
ESP:SetGlobalTracerOrigin("Bottom") -- Top, Center, Bottom, Left, Right, Mouse
```

### Configurações Visuais

```lua
-- Modo arco-íris
ESP:SetGlobalRainbow(true)

-- Transparência global
ESP:SetGlobalOpacity(0.8)

-- Espessura das linhas
ESP:SetGlobalLineThickness(2.0)

-- Transparência do highlight
ESP:SetGlobalHighlightOutlineTransparency(0.5)
ESP:SetGlobalHighlightFillTransparency(0.8)
```

### Configurações de Fonte

```lua
-- Tamanho da fonte
ESP:SetGlobalFontSize(16)

-- Tipo de fonte
ESP:SetGlobalFont(Drawing.Fonts.Monospace) -- UI, System, Plex, Monospace
```

### Configurações de Distância

```lua
-- Distância máxima para mostrar ESP
ESP:SetMaxDistance(1000)

-- Distância mínima
ESP:SetMinDistance(10)

-- Taxa de atualização (FPS)
ESP:SetUpdateRate(60)
```

## 🔧 Funcionalidades Avançadas

### SetTarget - Redefinir Alvo Individual

```lua
-- Mudar o alvo de um ESP específico
local oldTarget = workspace.OldModel
local newTarget = workspace.NewModel

ESP:Add(oldTarget, {
    Name = "Alvo Original",
    Color = Color3.fromRGB(255, 0, 0)
})

-- Redefinir o alvo
ESP:SetTarget(oldTarget, newTarget)
```

### Remoção Seletiva

```lua
-- Remover ESP específico
ESP:Remove(workspace.Target)

-- Limpar todos os ESPs
ESP:Clear()

-- Descarregar completamente a biblioteca
ESP:Unload()
```

## 💡 Exemplos Práticos

### ESP para Todos os Jogadores

```lua
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configurar ESP global
ESP:SetGlobalRainbow(true)
ESP:SetGlobalTracerOrigin("Bottom")
ESP:SetGlobalFontSize(14)

-- Adicionar ESP para todos os jogadores
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer and player.Character then
        ESP:Add(player.Character, {
            Name = player.Name,
            Color = Color3.fromRGB(0, 255, 0),
            ShowDistance = true,
            ShowName = true
        })
    end
end

-- Adicionar ESP para novos jogadores
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        wait(1) -- Esperar o personagem carregar
        ESP:Add(character, {
            Name = player.Name,
            Color = Color3.fromRGB(0, 255, 0),
            ShowDistance = true,
            ShowName = true
        })
    end)
end)
```

### ESP para Itens Específicos

```lua
-- ESP para baús ou itens
local chests = workspace.Items:GetChildren()

for _, chest in pairs(chests) do
    if chest.Name:find("Chest") then
        ESP:Add(chest, {
            Name = "Baú",
            Color = Color3.fromRGB(255, 215, 0),
            ShowTracer = true,
            ShowHighlight = true,
            TracerOrigin = "Center"
        })
    end
end
```

### ESP com Filtro de Distância

```lua
-- ESP que só aparece em determinada distância
ESP:SetMaxDistance(500) -- Só mostra ESP até 500 studs
ESP:SetMinDistance(50)  -- Só mostra ESP a partir de 50 studs

-- Adicionar múltiplos alvos
local targets = {
    workspace.Target1,
    workspace.Target2,
    "Workspace.Folder.ImportantPart"
}

for _, target in pairs(targets) do
    ESP:Add(target, {
        Color = Color3.fromRGB(255, 100, 255),
        ShowDistance = true,
        ShowName = true
    })
end
```

### Sistema de Cores Dinâmicas

```lua
-- ESP com cores baseadas na distância
local function addDynamicESP(target, name)
    ESP:Add(target, {
        Name = name,
        Color = Color3.fromRGB(255, 0, 0), -- Vermelho base
        ShowAll = true,
        UpdateColor = function(distance)
            if distance < 100 then
                return Color3.fromRGB(255, 0, 0) -- Vermelho (perto)
            elseif distance < 300 then
                return Color3.fromRGB(255, 255, 0) -- Amarelo (médio)
            else
                return Color3.fromRGB(0, 255, 0) -- Verde (longe)
            end
        end
    })
end
```

## 📊 Monitoramento e Estatísticas

```lua
-- Obter estatísticas em tempo real
local function showStats()
    local stats = ESP:GetStats()
    
    print("📊 Estatísticas do ESP:")
    print("Total de objetos:", stats.totalObjects)
    print("Objetos visíveis:", stats.visibleObjects)
    print("Tempo de frame:", stats.frameTime, "ms")
    print("Última atualização:", stats.lastUpdate)
    print("Tamanho do cache:", stats.cacheSize)
    print("ESP habilitado:", stats.enabled)
end

-- Mostrar estatísticas a cada 5 segundos
spawn(function()
    while true do
        wait(5)
        showStats()
    end
end)
```

## 🎨 Temas e Personalização

### Configuração de Tema

```lua
-- Acessar configurações de tema
local theme = ESP.Theme

-- Personalizar cores do tema
theme.PrimaryColor = Color3.fromRGB(130, 200, 255)
theme.SecondaryColor = Color3.fromRGB(255, 255, 255)
theme.ErrorColor = Color3.fromRGB(255, 100, 100)
theme.GradientColor = Color3.fromRGB(100, 150, 255)
```

### Origens de Tracer Disponíveis

```lua
-- Diferentes origens para os tracers
local origins = {
    "Top",      -- Topo da tela
    "Center",   -- Centro da tela
    "Bottom",   -- Parte inferior da tela
    "Left",     -- Lado esquerdo
    "Right",    -- Lado direito
    "Mouse"     -- Posição do mouse
}

-- Alternar entre origens
for _, origin in pairs(origins) do
    ESP:SetGlobalTracerOrigin(origin)
    wait(2) -- Demonstração
end
```

## 🛠️ API Completa

### Métodos Principais

| Método | Descrição | Parâmetros |
|--------|-----------|------------|
| `ESP:Add(target, config)` | Adiciona ESP ao alvo | `target`: Objeto ou string, `config`: Tabela opcional |
| `ESP:Remove(target)` | Remove ESP do alvo | `target`: Objeto alvo |
| `ESP:SetTarget(old, new)` | Redefine alvo de ESP | `old`: Alvo atual, `new`: Novo alvo |
| `ESP:Clear()` | Remove todos os ESPs | Nenhum |
| `ESP:Unload()` | Descarrega biblioteca | Nenhum |

### Configurações Globais

| Método | Descrição | Valor |
|--------|-----------|-------|
| `ESP:SetGlobalTracerOrigin(origin)` | Define origem dos tracers | String: "Top", "Center", etc. |
| `ESP:SetGlobalESPType(type, enabled)` | Ativa/desativa tipo de ESP | String + Boolean |
| `ESP:SetGlobalRainbow(enable)` | Ativa modo arco-íris | Boolean |
| `ESP:SetGlobalOpacity(value)` | Define transparência | Number (0-1) |
| `ESP:SetGlobalFontSize(size)` | Define tamanho da fonte | Number (min: 8) |
| `ESP:SetMaxDistance(distance)` | Define distância máxima | Number |

### Configurações de ESP Individual

```lua
local config = {
    Color = Color3.fromRGB(255, 255, 255),  -- Cor do ESP
    Name = "Nome Custom",                    -- Nome exibido
    ShowTracer = true,                      -- Mostrar linha
    ShowHighlight = true,                   -- Mostrar highlight
    ShowName = true,                        -- Mostrar nome
    ShowDistance = true,                    -- Mostrar distância
    TracerOrigin = "Bottom",                -- Origem da linha
    Opacity = 0.8,                         -- Transparência
    LineThickness = 1.5                     -- Espessura da linha
}
```

## 🔍 Resolução de Problemas

### Problemas Comuns

**ESP não aparece:**
```lua
-- Verificar se o alvo é válido
if ESP:Add(target) then
    print("ESP adicionado com sucesso")
else
    print("Falha ao adicionar ESP - alvo inválido")
end
```

**Performance ruim:**
```lua
-- Reduzir taxa de atualização
ESP:SetUpdateRate(30)

-- Limitar distância máxima
ESP:SetMaxDistance(500)

-- Verificar estatísticas
local stats = ESP:GetStats()
print("Objetos visíveis:", stats.visibleObjects)
```

**Limpar tudo:**
```lua
-- Remover todos os ESPs e descarregar
ESP:Unload()
```

## 📈 Otimização e Performance

### Configurações Recomendadas

```lua
-- Para melhor performance
ESP:SetUpdateRate(30)           -- FPS moderado
ESP:SetMaxDistance(1000)        -- Limitar distância
ESP.GlobalSettings.UseOcclusion = false  -- Desativar oclusão

-- Para melhor qualidade visual
ESP:SetUpdateRate(60)           -- FPS alto
ESP:SetGlobalOpacity(0.9)       -- Opacidade alta
ESP:SetGlobalLineThickness(2.0) -- Linhas mais grossas
```

## 🤝 Suporte e Contribuição

- **Autor**: DH_SOARES
- **Versão**: 1.4 Enhanced
- **Repositório**: [GitHub](https://github.com/DH-SOARESE/KoltESP-Library)

### Exemplo de Uso Completo

```lua
-- Script completo de exemplo
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configurações iniciais
ESP:SetGlobalRainbow(true)
ESP:SetGlobalTracerOrigin("Bottom")
ESP:SetGlobalFontSize(14)
ESP:SetMaxDistance(800)

-- Adicionar ESP para jogadores
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer and player.Character then
        ESP:Add(player.Character, {
            Name = player.Name .. " [Player]",
            ShowDistance = true
        })
    end
end

-- Adicionar ESP para NPCs (exemplo)
for _, npc in pairs(workspace.NPCs:GetChildren()) do
    ESP:Add(npc, {
        Name = "NPC",
        Color = Color3.fromRGB(255, 100, 100),
        ShowHighlight = true
    })
end

print("🎯 Kolt ESP carregado com sucesso!")
print("📊 Estatísticas:", ESP:GetStats().totalObjects, "objetos rastreados")
```

---

**🌟 Kolt ESP Library - A solução definitiva para ESP em Roblox!**
