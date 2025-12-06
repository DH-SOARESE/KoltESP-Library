# Kolt ESP Library V2.1

Biblioteca ESP (Extra Sensory Perception) de alta performance para Roblox, desenvolvida por **Kolt Hub**.  
Foco total em estabilidade, precisão e controle granular — sem recursos desnecessários. Otimizada para jogos competitivos, com suporte a visualizações personalizadas e integração fácil.

## Novidades na V2.1
- Adicionada a função `:ThereisEsp(target)`: Verifica se já existe um ESP ativo para o alvo, retornando `true` ou `false`. Útil para evitar duplicatas ao adicionar ESP dinamicamente.
- Melhoria na documentação e exemplos de uso, com foco em cenários reais como verificação antes de adicionar ESP.
- Otimização geral de performance e correções menores para maior estabilidade.

## Novidades na V2.0
- Adicionado suporte a ponto central personalizado (`Center`) para maior precisão em alvos complexos.
- Otimização de performance com cache de posições e updates condicionais.
- Melhoria no sistema de fade-in para transições suaves.
- Expansão da API com métodos mais flexíveis para atualização e readjuste.

## Características Principais

- **Componentes Visuais**: Tracer, Nome, Distância, Highlight (Fill + Outline) e Arrow off-screen.
- **Distância Personalizada**: Opção para exibição com decimal (ex: `123.4` ou `123`), com prefixo/sufixo.
- **Limites de Visibilidade**: Respeito rigoroso a `MaxDistance` e `MinDistance`.
- **Performance Otimizada**: Cache inteligente, fade-in suave e atualizações por frame eficientes.
- **Suporte a Objetos**: Compatível com `Model` e `BasePart`, incluindo colisões invisíveis via `Collision`.
- **Modo Rainbow**: Cores dinâmicas globais.
- **Cor Dinâmica**: Dependência de cor baseada em distância ou posição (`ColorDependency`).
- **Personalização Avançada**: DisplayOrder individual, pasta dedicada para highlights e registro de cores por objeto.
- **Arrow Off-Screen**: Configuração completa de imagem, tamanho, raio e rotação.
- **Ponto Central Customizado**: Defina uma posição ou instância específica para o centro do ESP.
- **Verificação de Existência**: Use `:ThereisEsp()` para checar se um alvo já tem ESP antes de adicionar.

## Instalação

Carregue a biblioteca diretamente via HTTP:

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/main/Library.lua"))()
```

## Configurações Globais

Todas as configurações globais estão em `KoltESP.EspSettings`. Use os métodos `SetGlobal*` para atualizá-las dinamicamente.

| Configuração                     | Tipo             | Valor Padrão                  | Descrição |
|----------------------------------|------------------|-------------------------------|-----------|
| `Enabled`                        | boolean          | `true`                        | Ativa/desativa a biblioteca inteira. |
| `Tracer`, `Name`, `Distance`     | boolean          | `true`                        | Ativa/desativa componentes específicos. |
| `Filled`, `Outline`              | boolean          | `true`                        | Ativa fill e outline no highlight. |
| `Arrow`                          | boolean          | `false`                       | Ativa seta para alvos off-screen. |
| `Decimal`                        | boolean          | `false`                       | Exibe distância com uma casa decimal. |
| `MaxDistance` / `MinDistance`    | number           | `math.huge` / `0`             | Limites de distância para visibilidade. |
| `TracerOrigin`                   | string           | `"Bottom"`                    | Origem do tracer: `Top`, `Center`, `Bottom`, `Left`, `Right`. |
| `Opacity`                        | number           | `0.8`                         | Transparência geral (0–1). |
| `LineThickness`                  | number           | `1`                           | Espessura da linha do tracer. |
| `FontSize`                       | number           | `14`                          | Tamanho da fonte para textos. |
| `Font`                           | number           | `3`                           | Fonte: 0=UI, 1=System, 2=Plex, 3=Monospace. |
| `RainbowMode`                    | boolean          | `false`                       | Ativa modo de cores arco-íris dinâmicas. |
| `TextOutlineEnabled`             | boolean          | `true`                        | Ativa contorno nos textos. |
| `TextOutlineColor`               | Color3           | `Color3.new(0,0,0)`           | Cor do contorno dos textos. |
| `ESPFadeInTime`                  | number           | `0.5`                         | Tempo de fade-in em segundos. |
| `ArrowConfig.Image`              | number           | `11552476728`                 | ID do asset da imagem da seta. |
| `ArrowConfig.Size`               | UDim2            | `UDim2.new(0,40,0,40)`        | Tamanho da seta. |
| `ArrowConfig.Radius`             | number           | `90`                          | Raio de posicionamento da seta na tela. |
| `ArrowConfig.RotationOffset`     | number           | `270`                         | Offset de rotação da seta em graus. |
| `HighlightTransparency.Filled`   | number           | `0.5`                         | Transparência do fill no highlight. |
| `HighlightTransparency.Outline`  | number           | `0.3`                         | Transparência do outline no highlight. |

## API Principal

### Verificar Existência de ESP
```lua
local existe = KoltESP:ThereisEsp(target)  -- Retorna true se já existir ESP para o target
```
Exemplo:
```lua
if KoltESP:ThereisEsp(workspace.Banana) then
    print("Já existe ESP nessa banana!")
else
    KoltESP:Add(workspace.Banana, { Name = "Banana Especial" })
end
```

### Adicionar um ESP
```lua
KoltESP:Add(target, config)  -- target: Model ou BasePart; config: tabela opcional
```

Exemplo:
```lua
if not KoltESP:ThereisEsp(workspace.ModelAlvo) then
    KoltESP:Add(workspace.ModelAlvo, {
        Name = "Alvo Principal",
        Collision = true,
        Center = workspace.PartCentral  -- Ou Vector3.new(0,0,0)
    })
end
```

### Atualizar Configuração
```lua
KoltESP:UpdateConfig(target, newConfig)  -- Atualiza sem recriar
```

### Readjustar para Novo Alvo
```lua
KoltESP:Readjustment(newTarget, oldTarget, newConfig)  -- Transfere ESP para novo target
```

### Configuração Individual (`config`)
Tabela passada no `Add` ou `UpdateConfig`. Valores default herdam das globais.

```lua
{
    Name = "Nome do Alvo",             -- Texto exibido
    Decimal = true,                    -- Distância com decimal
    DistancePrefix = "[",              -- Prefixo da distância
    DistanceSuffix = "m]",             -- Sufixo da distância
    MaxDistance = 1000,                -- Máximo para visibilidade
    MinDistance = 0,                   -- Mínimo para visibilidade
    DisplayOrder = 10,                 -- Ordem de renderização (ZIndex)
    Opacity = 0.9,                     -- Transparência individual
    LineThickness = 2,                 -- Espessura do tracer
    FontSize = 16,                     -- Tamanho da fonte
    Font = 3,                          -- Tipo de fonte
    Collision = true,                  -- Revela partes invisíveis (Transparency=0.99)
    Center = Vector3 or Instance,      -- Ponto central customizado (nil usa método padrão)
    Color = Color3.new(1,0,0) or {     -- Cor única ou detalhada
        Name = {255,0,0},
        Distance = {0,255,0},
        Tracer = {0,0,255},
        Highlight = {
            Filled = {255,255,0},
            Outline = {255,0,255}
        }
    },
    Types = {                          -- Ativa/desativa componentes (default: true)
        Tracer = true,
        Name = true,
        Distance = true,
        HighlightFill = true,
        HighlightOutline = true
    },
    ColorDependency = function(esp, distance, pos3D)
        -- Função para cor dinâmica baseada em distância ou posição
        return distance < 100 and Color3.new(1,0,0) or Color3.new(0,1,0)
    end
}
```

## Métodos de Controle Individual

- `KoltESP:SetColor(target, Color3)`: Define cor única para todos os componentes.
- `KoltESP:SetName(target, "Novo Nome")`: Altera o nome exibido.
- `KoltESP:SetDisplayOrder(target, number)`: Ajusta a ordem de renderização.
- `KoltESP:SetTextOutline(target, enabled, Color3)`: Controla contorno de texto.
- `KoltESP:Remove(target)`: Remove ESP específico.
- `KoltESP:GetESP(target)`: Retorna a tabela de configuração do ESP.

## Registro de Cores
Registre cores persistentes por target, aplicadas automaticamente no `Add`.

```lua
KoltESP:AddToRegistry(target, {
    TextColor = Color3.new(1,0,0),
    DistanceColor = Color3.new(0,1,0),
    TracerColor = Color3.new(0,0,1),
    HighlightColor = Color3.new(1,1,0)
})
```

## Configurações Globais (Métodos)
Atualize as globais e aplique em todos os ESPs existentes.

```lua
KoltESP.EspSettings.Decimal = true
KoltESP.EspSettings.MaxDistance = 1500

KoltESP:SetGlobalESPType("Tracer", false)          -- Desliga globalmente
KoltESP:SetGlobalTracerOrigin("Center")
KoltESP:SetGlobalRainbow(true)
KoltESP:SetGlobalOpacity(0.8)
KoltESP:SetGlobalFontSize(16)
KoltESP:SetGlobalLineThickness(2)
KoltESP:SetGlobalTextOutline(true, Color3.new(0,0,0))
KoltESP:SetGlobalFont(3)
KoltESP:SetGlobalESPFadeInTime(1)                  -- Tempo de fade-in

-- Arrow Global
KoltESP.EspSettings.Arrow = true
KoltESP:SetGlobalArrowImage(11552476728)
KoltESP:SetGlobalArrowSize(50)
KoltESP:SetGlobalArrowRadius(100)
KoltESP:SetGlobalArrowRotation(270)

-- Highlight Transparência
KoltESP:SetGlobalHighlightTransparency({Filled = 0.6, Outline = 0.4})

-- Pasta de Highlights
KoltESP:SetHighlightFolderName("MyHighlights")
```

## Limpeza e Controle Geral
- `KoltESP:Clear()`: Remove todos os ESPs.
- `KoltESP:Toggle(false)`: Pausa a renderização (mantém objetos em memória).
- `KoltESP:ArrowOrder(number)`: Define ordem de display da tela de arrows.

**Desenvolvido por Kolt Hub**  
**Versão 2.1** - Atualizado em 06/12/2025
