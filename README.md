# 📦 Kolt ESP Library V1.5 Enhanced

Uma biblioteca ESP (Extra Sensory Perception) moderna e eficiente para Roblox, com design minimalista e alta performance.

## ✨ Características

- 🎨 **Design Moderno**: Interface clean e responsiva
- ⚡ **Alta Performance**: Sistema de cache otimizado e renderização eficiente
- 🌈 **Modo Arco-íris**: Efeitos visuais dinâmicos
- 🎯 **ESP Personalizável**: Tracers, highlights, nomes e distâncias
- 🔧 **Configuração Global**: Ajustes centralizados para todos os ESPs
- 📊 **Sistema de Estatísticas**: Monitoramento de performance
- 🛡️ **Validação Robusta**: Tratamento de erros e alvos inválidos

## 🚀 Instalação

```lua
-- Carregue a biblioteca via loadstring
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()
```

## 📋 Uso Básico

### Adicionando ESP Simples

```lua
-- ESP básico em um jogador
KoltESP:Add(game.Players.SomePlayer.Character)

-- ESP em uma parte específica
KoltESP:Add(workspace.SomePart)

-- ESP com configuração personalizada
KoltESP:Add(game.Players.LocalPlayer.Character, {
    Name = "Eu Mesmo",
    Color = Color3.fromRGB(0, 255, 0),
    TracerColor = Color3.fromRGB(255, 0, 0)
})
```

### Configurações Globais

```lua
-- Ativar modo arco-íris
KoltESP:SetGlobalRainbow(true)

-- Ajustar opacidade global
KoltESP:SetGlobalOpacity(0.7)

-- Definir origem dos tracers
KoltESP:SetGlobalTracerOrigin("Center")

-- Configurar distâncias
KoltESP:SetMaxDistance(500)
KoltESP:SetMinDistance(10)
```

## 🎯 Propriedades de Configuração

### Configuração Individual (config)

| Propriedade | Tipo | Padrão | Descrição |
|-------------|------|---------|-----------|
| `Name` | string | Target.Name | Nome exibido no ESP |
| `Color` | Color3 | Theme.PrimaryColor | Cor principal do ESP |
| `TracerColor` | Color3 | Color | Cor específica do tracer |
| `HighlightOutlineColor` | Color3 | Theme.OutlineColor | Cor do contorno do highlight |
| `HighlightOutlineTransparency` | number | 0.65 | Transparência do contorno |
| `FilledTransparency` | number | 0.85 | Transparência do preenchimento |
| `NameFont` | Font | Drawing.Fonts.Monospace | Fonte do nome |
| `DistanceFont` | Font | Drawing.Fonts.Monospace | Fonte da distância |
| `NameContainer` | string | "[]" | Caracteres ao redor do nome |
| `DistanceContainer` | string | "()" | Caracteres ao redor da distância |
| `DistanceSuffix` | string | "m" | Sufixo da distância |
| `HighlightOutlineThickness` | number | 1 | Espessura do contorno |
| `CustomUpdate` | function | nil | Função personalizada de atualização |

### Configurações Globais (GlobalSettings)

| Propriedade | Tipo | Padrão | Descrição |
|-------------|------|---------|-----------|
| `TracerOrigin` | string | "Bottom" | Origem dos tracers |
| `ShowTracer` | boolean | true | Mostrar linhas tracer |
| `ShowHighlightFill` | boolean | true | Mostrar preenchimento |
| `ShowHighlightOutline` | boolean | true | Mostrar contorno |
| `ShowName` | boolean | true | Mostrar nome |
| `ShowDistance` | boolean | true | Mostrar distância |
| `RainbowMode` | boolean | false | Modo arco-íris |
| `MaxDistance` | number | math.huge | Distância máxima |
| `MinDistance` | number | 0 | Distância mínima |
| `Opacity` | number | 0.8 | Opacidade geral |
| `LineThickness` | number | 1.5 | Espessura das linhas |
| `FontSize` | number | 14 | Tamanho da fonte |
| `UpdateRate` | number | 60 | Taxa de atualização (FPS) |
| `UseOcclusion` | boolean | false | Usar oclusão |
| `AutoRemoveInvalid` | boolean | true | Remover alvos inválidos |

### Origens de Tracer Disponíveis

- `"Top"` - Topo da tela
- `"Center"` - Centro da tela
- `"Bottom"` - Parte inferior da tela
- `"Left"` - Lado esquerdo
- `"Right"` - Lado direito
- `"Mouse"` - Posição do mouse

## 🔧 Métodos da API

### Gerenciamento de ESP

```lua
-- Adicionar ESP
KoltESP:Add(target, config)

-- Remover ESP específico
KoltESP:Remove(target)

-- Redefinir alvo de um ESP existente
KoltESP:SetTarget(oldTarget, newTarget)

-- Limpar todos os ESPs
KoltESP:Clear()

-- Descarregar completamente a biblioteca
KoltESP:Unload()
```

### Configurações Globais

```lua
-- Configurar origem dos tracers
KoltESP:SetGlobalTracerOrigin("Center")

-- Ativar/desativar tipos de ESP
KoltESP:SetGlobalESPType("ShowTracer", true)
KoltESP:SetGlobalESPType("ShowHighlightFill", false)

-- Configurações visuais
KoltESP:SetGlobalRainbow(true)
KoltESP:SetGlobalOpacity(0.7)
KoltESP:SetGlobalFontSize(16)
KoltESP:SetGlobalFont(Drawing.Fonts.UI)
KoltESP:SetGlobalLineThickness(2)

-- Configurações de transparência
KoltESP:SetGlobalHighlightOutlineTransparency(0.5)
KoltESP:SetGlobalHighlightFillTransparency(0.8)

-- Configurações de distância
KoltESP:SetMaxDistance(300)
KoltESP:SetMinDistance(5)

-- Taxa de atualização
KoltESP:SetUpdateRate(30)
```

### Estatísticas

```lua
-- Obter estatísticas da biblioteca
local stats = KoltESP:GetStats()
print("Objetos totais:", stats.totalObjects)
print("Objetos visíveis:", stats.visibleObjects)
print("Tempo de frame:", stats.frameTime, "ms")
```

## 📝 Exemplos Avançados

### ESP para Todos os Jogadores

```lua
-- Adicionar ESP para todos os jogadores
for _, player in pairs(game.Players:GetPlayers()) do
    if player.Character then
        KoltESP:Add(player.Character, {
            Name = player.Name,
            Color = player.TeamColor.Color,
            NameContainer = "<>",
            DistanceContainer = "||"
        })
    end
end
```

### ESP Personalizado com Função de Atualização

```lua
KoltESP:Add(workspace.SomePart, {
    Name = "Alvo Especial",
    Color = Color3.fromRGB(255, 215, 0),
    CustomUpdate = function(esp, screenPos, distance, color, visible)
        -- Lógica personalizada aqui
        if distance < 50 then
            esp.nameText.Color = Color3.fromRGB(255, 0, 0)
        end
    end
})
```

### Configuração Completa

```lua
-- Configuração avançada
KoltESP:SetGlobalTracerOrigin("Center")
KoltESP:SetGlobalRainbow(true)
KoltESP:SetGlobalOpacity(0.9)
KoltESP:SetGlobalFontSize(18)
KoltESP:SetGlobalLineThickness(2.5)
KoltESP:SetMaxDistance(400)
KoltESP:SetMinDistance(20)
KoltESP:SetUpdateRate(45)

-- Desativar highlights, manter apenas tracers e texto
KoltESP:SetGlobalESPType("ShowHighlightFill", false)
KoltESP:SetGlobalESPType("ShowHighlightOutline", false)
```

## 🛠️ Solução de Problemas

### Problemas Comuns

**ESP não aparece:**
- Verifique se o alvo é válido
- Confirme se está dentro da distância configurada
- Verifique se o ESP está habilitado: `KoltESP.Enabled = true`

**Performance baixa:**
- Reduza a taxa de atualização: `KoltESP:SetUpdateRate(30)`
- Desative recursos desnecessários
- Use `SetMaxDistance()` para limitar alcance

**Alvos inválidos:**
- A biblioteca remove automaticamente alvos inválidos se `AutoRemoveInvalid = true`
- Use `KoltESP:Clear()` para limpar todos os ESPs

## 📊 Informações Técnicas

- **Versão:** 1.5 Enhanced
- **Autor:** DH_SOARES
- **Dependências:** RunService, Players, Drawing API
- **Performance:** ~60 FPS com dezenas de alvos
- **Cache:** Sistema otimizado para posições de modelo

## 🎨 Tema de Cores

```lua
KoltESP.Theme = {
    PrimaryColor = Color3.fromRGB(130, 200, 255),
    SecondaryColor = Color3.fromRGB(255, 255, 255),
    ErrorColor = Color3.fromRGB(255, 100, 100),
    GradientColor = Color3.fromRGB(100, 150, 255),
}
```

## 📄 Licença

Esta biblioteca é fornecida "como está" para uso educacional e de desenvolvimento. Use por sua própria conta e risco.

---

**Desenvolvido com ❤️ por DH_SOARES**
