🔍 Kolt ESP Library

Uma biblioteca ESP minimalista e eficiente para Roblox, desenvolvida com foco em performance e personalização. Carregue facilmente via loadstring e adicione elementos visuais avançados aos seus alvos.

✨ Características

· Design Moderno: Interface limpa e elementos visuais elegantes
· Alta Performance: Otimizada com sistema de cache e atualização por frame
· Personalizável: Múltiplas configurações globais e individuais
· Fácil Integração: API intuitiva com exemplos claros
· Rainbow Mode: Cores dinâmicas e efeitos gradiente
· Estatísticas em Tempo Real: Monitoramento de performance

📦 Instalação

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/main/Library.lua"))()
```

🚀 Começando Rápido

```lua
-- Inicializar a biblioteca (automático)
print("KoltESP carregada:", KoltESP.Enabled)

-- Adicionar ESP para um jogador
local player = game.Players:FindFirstChild("JogadorAlvo")
if player and player.Character then
    KoltESP:Add(player.Character, {
        Name = player.Name,
        Color = Color3.fromRGB(255, 100, 100)
    })
end

-- Adicionar ESP para uma parte específica
KoltESP:Add(workspace.Part, {
    Name = "Parte Importante",
    Color = Color3.fromRGB(100, 255, 100)
})
```

⚙️ Configurações Globais

```lua
-- Configurar origem do tracer
KoltESP:SetGlobalTracerOrigin("Bottom") -- Opções: Top, Center, Bottom, Left, Right, Mouse

-- Ativar/desativar elementos
KoltESP:SetGlobalESPType("ShowTracer", true)
KoltESP:SetGlobalESPType("ShowHighlightFill", true)
KoltESP:SetGlobalESPType("ShowHighlightOutline", true)
KoltESP:SetGlobalESPType("ShowName", true)
KoltESP:SetGlobalESPType("ShowDistance", true)

-- Efeitos visuais
KoltESP:SetGlobalRainbow(true) -- Modo arco-íris
KoltESP:SetGlobalOpacity(0.8) -- Transparência (0-1)

-- Configurações de distância
KoltESP:SetMaxDistance(1000) -- Distância máxima de renderização
KoltESP:SetMinDistance(0)    -- Distância mínima de renderização

-- Ajustes de fonte
KoltESP:SetGlobalFontSize(14)
KoltESP:SetGlobalFont(Drawing.Fonts.Monospace)

-- Espessuras
KoltESP:SetGlobalLineThickness(1.5)
KoltESP:SetGlobalHighlightOutlineTransparency(0.65)
KoltESP:SetGlobalHighlightFillTransparency(0.85)
```

🎯 Uso Avançado

Adicionando ESP com Configurações Personalizadas

```lua
KoltESP:Add(workspace.Enemy, {
    Name = "Chefe Final",
    Color = Color3.fromRGB(255, 50, 50),
    TracerColor = Color3.fromRGB(255, 0, 0), -- Cor personalizada para o tracer
    HighlightOutlineColor = Color3.fromRGB(200, 0, 0),
    HighlightOutlineTransparency = 0.3,
    FilledTransparency = 0.7,
    NameFont = Drawing.Fonts.UI,
    DistanceFont = Drawing.Fonts.System,
    NameContainer = "⟪⟫", -- Containers personalizados
    DistanceContainer = "❬❭",
    DistanceSuffix = " studs",
    HighlightOutlineThickness = 2,
    
    -- Função de atualização personalizada
    CustomUpdate = function(esp, screenPos, distance, color, visible)
        if distance > 500 then
            esp.nameText.Color = Color3.fromRGB(255, 150, 150)
            esp.tracerLine.Transparency = 0.5
        end
    end
})
```

Alterando o Alvo de uma ESP Existente

```lua
-- Mudar o alvo de uma ESP (útil quando personagens respawnam)
local oldCharacter = workspace.OldCharacter
local newCharacter = workspace.NewCharacter

KoltESP:SetTarget(oldCharacter, newCharacter)
```

Estatísticas e Monitoramento

```lua
-- Obter estatísticas de performance
local stats = KoltESP:GetStats()
print(string.format("Objetos: %d/%d visíveis | Frame: %.2fms", 
    stats.visibleObjects, stats.totalObjects, stats.frameTime))
```

Gerenciamento de Múltiplos ESPs

```lua
-- Adicionar ESP para todos os jogadores
for _, player in ipairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer and player.Character then
        KoltESP:Add(player.Character, {
            Name = player.Name,
            Color = Color3.fromRGB(100, 200, 255)
        })
    end
end

-- Remover ESP específico
KoltESP:Remove(workspace.Part)

-- Limpar todos os ESPs
KoltESP:Clear()
```

🎨 Temas e Cores

```lua
-- Modificar tema padrão
KoltESP.Theme = {
    PrimaryColor = Color3.fromRGB(130, 200, 255),
    SecondaryColor = Color3.fromRGB(255, 255, 255),
    ErrorColor = Color3.fromRGB(255, 100, 100),
    GradientColor = Color3.fromRGB(100, 150, 255),
}

-- Usar cor gradiente dinâmica
KoltESP:Add(workspace.Item, {
    Name = "Item Raro",
    Color = KoltESP.Theme.GradientColor,
    CustomUpdate = function(esp, screenPos, distance, color, visible)
        local time = tick()
        esp.tracerLine.Color = getGradientColor(time, Color3.fromRGB(100, 200, 255))
        esp.nameText.Color = getGradientColor(time + 1, Color3.fromRGB(100, 200, 255))
    end
})
```

📊 Propriedades dos Elementos ESP

Cada objeto ESP criado possui os seguintes elementos:

Tracer Line

· Tipo: Drawing Line
· Propósito: Lina que conecta a origem configurada até o alvo
· Configurável: Cor, espessura, transparência e visibilidade
· Origens disponíveis: Top, Center, Bottom, Left, Right, Mouse

Name Text

· Tipo: Drawing Text
· Propósito: Exibir o nome do alvo
· Configurável: Fonte, tamanho, cor, container personalizado
· Posição: Acima do alvo (30 pixels)

Distance Text

· Tipo: Drawing Text
· Propósito: Exibir distância até o alvo
· Configurável: Fonte, tamanho, cor, sufixo, container personalizado
· Posição: Abaixo do alvo (5 pixels)

Highlight

· Tipo: Instance Highlight
· Propósito: Realçar o alvo no mundo 3D
· Configurável: Cores de preenchimento e contorno, transparências
· Modos: Preenchimento, contorno ou ambos

⚡ Performance Tips

```lua
-- Para muitos objetos, ajuste as distâncias de renderização
KoltESP:SetMaxDistance(500) -- Reduzir distância máxima
KoltESP:SetGlobalESPType("ShowHighlightFill", false) -- Desativar preenchimento

-- Atualizar configurações globais de uma vez
KoltESP.GlobalSettings.Opacity = 0.6
KoltESP.GlobalSettings.FontSize = 12
KoltESP:UpdateGlobalSettings()
```

🗑️ Cleanup

```lua
-- Descarregar completamente a biblioteca
KoltESP:Unload()

-- Verificar se foi descarregada
print("KoltESP carregada:", KoltESP ~= nil)
```

📝 Notas

· A biblioteca é auto-inicializada ao ser carregada
· Objetos inválidos são automaticamente removidos quando AutoRemoveInvalid está ativo
· Use CustomUpdate para lógica personalizada baseada em distância ou outros fatores
· O sistema de cache melhora performance com múltiplos objetos

🐛 Solução de Problemas

```lua
-- Verificar se um alvo é válido
local target = workspace.SomePart
if target and target:IsA("BasePart") or target:IsA("Model") then
    KoltESP:Add(target, {Name = "Alvo Válido"})
else
    warn("Alvo inválido para ESP")
end

-- Verificar estatísticas para problemas de performance
local stats = KoltESP:GetStats()
if stats.frameTime > 5 then -- Mais de 5ms por frame
    print("AVISO: Performance pode estar afetada")
end
```

---

Desenvolvido por DH_SOARES | Versão 1.5 Enhanced | Estilo Minimalista e Eficiente
