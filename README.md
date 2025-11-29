# Kolt ESP Library V2.0

Biblioteca ESP (Extra Sensory Perception) de alta performance para Roblox, desenvolvida por **Kolt Hub**.  
Foco total em estabilidade, precisão e controle granular — sem recursos desnecessários.

## Características Principais

- Tracer, Nome, Distância e Highlight (Fill + Outline)
- Sistema de distância com opção **Decimal** (ex: `123.4` ou `123`)
- Respeito rigoroso a `MaxDistance` e `MinDistance`
- Performance otimizada com cache inteligente e fade in/out
- Suporte completo a Model e BasePart
- Modo Rainbow global
- Collision ESP (revela partes invisíveis)
- Dependência dinâmica de cor (`ColorDependency`)
- DisplayOrder individual
- Highlights organizados em pasta dedicada
- Registro de cores por objeto (`AddToRegistry`)
- Arrow off-screen com configuração completa

## Instalação

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/main/Library.lua"))()
```

## Configurações Globais Disponíveis

| Configuração                     | Tipo             | Valor Padrão        | Descrição |
|----------------------------------|------------------|---------------------|-----------|
| `Enabled`                        | boolean          | `true`              | Ativa/desativa toda a biblioteca |
| `Tracer`, `Name`, `Distance`     | boolean          | `true`              | Liga/desliga componentes globais |
| `Filled`, `Outline`              | boolean          | `true`              | Highlight fill e outline |
| `Arrow`                          | boolean          | `false`             | Seta off-screen |
| `Decimal`                        | boolean          | `false`             | Distância com decimal (ex: 123.4) |
| `MaxDistance` / `MinDistance`    | number           | `math.huge` / `0`   | Limites de visibilidade |
| `TracerOrigin`                   | string           | `"Bottom"`          | `Top`, `Center`, `Bottom`, `Left`, `Right` |
| `Opacity`                        | number           | `0.8`               | 0–1 |
| `LineThickness`                  | number           | `1`                 | Espessura do tracer |
| `FontSize`                       | number           | `14`                | Tamanho da fonte |
| `Font`                           | number           | `3`                 | 0=UI, 1=System, 2=Plex, 3=Monospace |
| `RainbowMode`                    | boolean          | `false`             | Cores arco-íris |
| `TextOutlineEnabled`             | boolean          | `true`              | Contorno no texto |
| `TextOutlineColor`               | Color3           | `Color3.new(0,0,0)` | Cor do contorno |
| `ArrowConfig.Image`              | number           | `11552476728`       | ID da imagem da seta |
| `ArrowConfig.Size`               | UDim2            | `UDim2.new(0,40,0,40)` | Tamanho da seta |
| `ArrowConfig.Radius`             | number           | `90`                | Distância do centro da tela |
| `ArrowConfig.RotationOffset`     | number           | `270`               | Ajuste de rotação |

## API Principal

### Adicionar / Atualizar ESP
```lua
KoltESP:Add(target, config)            -- Model ou BasePart
KoltESP:UpdateConfig(target, config)
KoltESP:Readjustment(newTarget, oldTarget, config)
```

### Configuração Individual (em `config`)
```lua
{
    Name = "Jogador",
    Decimal = true,                    -- Mostra distância com decimal
    DistancePrefix = "[",
    DistanceSuffix = "m]",
    MaxDistance = 1000,
    MinDistance = 0,
    DisplayOrder = 10,
    Opacity = 0.9,
    LineThickness = 2,
    FontSize = 16,
    Font = 3,
    Collision = true,                  -- Revela partes invisíveis
    Color = Color3 ou tabela detalhada,
    Types = {                          -- Todos true por padrão
        Tracer = true,
        Name = true,
        Distance = true,
        HighlightFill = true,
        HighlightOutline = true
    },
    ColorDependency = function(esp, distance, pos3D) -- cor dinâmica
        return distance < 100 and Color3.new(1,0,0) or Color3.new(0,1,0)
    end
}
```

### Métodos de Controle Individual
```lua
KoltESP:SetColor(target, Color3)
KoltESP:SetName(target, "Novo Nome")
KoltESP:SetDisplayOrder(target, number)
KoltESP:SetTextOutline(target, enabled, Color3)

KoltESP:Remove(target)
KoltESP:GetESP(target) → retorna tabela de config
```

### Registro de Cores (Atualização Automática)
```lua
KoltESP:AddToRegistry(target, {
    TextColor = Color3,
    DistanceColor = Color3,
    TracerColor = Color3,
    HighlightColor = Color3
})
```

### Configurações Globais (Principais)
```lua
KoltESP.EspSettings.Decimal = true                 -- Distância com decimal globalmente
KoltESP.EspSettings.MaxDistance = 1500
KoltESP.EspSettings.MinDistance = 5

KoltESP:SetGlobalESPType("Tracer", false)          -- Desliga tracer global
KoltESP:SetGlobalTracerOrigin("Bottom")
KoltESP:SetGlobalRainbow(true)
KoltESP:SetGlobalOpacity(0.8)
KoltESP:SetGlobalFontSize(16)
KoltESP:SetGlobalLineThickness(2)
KoltESP:SetGlobalTextOutline(true, Color3.new(0,0,0))

-- Arrow
KoltESP.EspSettings.Arrow = true
KoltESP:SetGlobalArrowImage(11552476728)
KoltESP:SetGlobalArrowSize(50)
KoltESP:SetGlobalArrowRadius(100)
KoltESP:SetGlobalArrowRotation(270)
```

### Limpeza
```lua
KoltESP:Remove(target)
KoltESP:Clear()        -- Remove tudo
KoltESP:Toggle(false)  -- Pausa tudo (mantém objetos)
```
```

**Desenvolvido por Kolt Hub**  
 **Versão 2.0**
 ```
