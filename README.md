# KoltESP-Library

<div align="center">
  <h2>📦 KoltESP V1.5 Enhanced</h2>
  <p>
    <strong>Autor:</strong> DH_SOARES<br>
    <strong>Estilo:</strong> Minimalista, eficiente, responsivo com design moderno<br>
    <strong>✨ Melhorias:</strong> Design aprimorado, SetTarget individual, cache otimizado, atualização sem delay (cada frame)
  </p>
</div>

---

## 💡 Introdução

KoltESP é uma biblioteca ESP (Extra Sensory Perception) para Roblox, desenvolvida para ser leve, elegante e extremamente personalizável. Ela permite destacar modelos, partes ou jogadores na tela, com propriedades visuais modernas, responsivas e sem atrasos perceptíveis, tornando-a ideal para projetos que exigem performance e estilo.

> **Carregamento via loadstring, sem dependências externas, pronta para uso:**

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/main/Library.lua"))()
```

---

## 🚀 Começando

### Instalação

Basta utilizar o código acima para carregar a biblioteca. Não é necessário instalar nada adicional.

### Exemplo Básico

```lua
-- Adicionando ESP a um jogador
KoltESP:Add(Players.LocalPlayer.Character, {
    Name = "Você",
    Color = Color3.fromRGB(255, 150, 100),
    ShowTracer = true,
    ShowHighlightFill = true,
    ShowHighlightOutline = true
})
```

---

## 🧩 Principais APIs e Métodos

### Adicionar ESP

```lua
KoltESP:Add(target, config)
```
- `target`: Modelo, BasePart ou caminho (string) até o alvo.
- `config`: Tabela opcional de propriedades personalizadas para o ESP.

### Redefinir Target de uma ESP

```lua
KoltESP:SetTarget(oldTarget, newTarget)
```

### Remover ESP individual

```lua
KoltESP:Remove(target)
```

### Limpar todos os ESPs

```lua
KoltESP:Clear()
```

### Descarregar completamente a biblioteca

```lua
KoltESP:Unload()
```

### Atualizar configurações globais

```lua
KoltESP:UpdateGlobalSettings()
```

---

## 🎨 Propriedades de ESP

Cada ESP individual aceita as seguintes propriedades no objeto de configuração:

| Propriedade                | Tipo             | Padrão                    | Descrição                                                                |
|---------------------------|------------------|---------------------------|--------------------------------------------------------------------------|
| `Name`                    | string           | Nome do alvo              | Nome exibido acima do ESP                                                |
| `Color`                   | Color3           | Theme.PrimaryColor        | Cor principal do ESP                                                     |
| `ShowTracer`              | boolean          | `true`                    | Exibe linha de tracer                                                    |
| `ShowHighlightFill`       | boolean          | `true`                    | Exibe preenchimento do Highlight                                         |
| `ShowHighlightOutline`    | boolean          | `true`                    | Exibe contorno do Highlight                                              |
| `ShowName`                | boolean          | `true`                    | Exibe texto do nome                                                      |
| `ShowDistance`            | boolean          | `true`                    | Exibe texto de distância                                                 |
| `Rainbow`                 | boolean          | `false`                   | Ativa modo arco-íris                                                     |
| `MaxDistance`             | number           | `math.huge`               | Distância máxima para exibir ESP                                         |
| `Opacity`                 | number           | `0.8`                     | Opacidade das linhas/desenhos                                            |
| `LineThickness`           | number           | `1.5`                     | Espessura da linha de tracer                                             |
| `HighlightOutlineTransparency` | number      | `0.65`                    | Transparência do contorno do Highlight                                   |
| `HighlightFillTransparency`    | number      | `0.85`                    | Transparência do preenchimento do Highlight                              |
| `FontSize`                | number           | `14`                      | Tamanho da fonte dos textos                                              |
| `NameFont`                | enum Drawing.Font| `Drawing.Fonts.Monospace` | Fonte do nome                                                            |
| `DistanceFont`            | enum Drawing.Font| `Drawing.Fonts.Monospace` | Fonte da distância                                                       |
| `DistanceContainer`       | string           | `"()"`                    | Container do texto de distância                                          |
| `DistanceSuffix`          | string           | `"m"`                     | Sufixo da distância                                                      |
| `AutoRemoveInvalid`       | boolean          | `true`                    | Remove ESP se alvo for inválido                                          |
| `UseOcclusion`            | boolean          | `false`                   | Não exibe ESP se alvo estiver oculto                                     |

---

## ⚙️ Configurações Globais

As configurações globais afetam todos os ESPs adicionados. Você pode modificá-las facilmente:

```lua
KoltESP:SetGlobalTracerOrigin("Bottom")           -- Opções: "Top", "Center", "Bottom", "Left", "Right", "Mouse"
KoltESP:SetGlobalESPType("ShowTracer", false)     -- Habilita/desabilita tipo global
KoltESP:SetGlobalRainbow(true)                    -- Ativa modo arco-íris globalmente
KoltESP:SetGlobalOpacity(0.5)                     -- Opacidade dos desenhos
KoltESP:SetGlobalFontSize(16)                     -- Tamanho da fonte
KoltESP:SetGlobalFont(Drawing.Fonts.UI)           -- Fonte dos textos
KoltESP:SetGlobalLineThickness(2)                 -- Espessura das linhas
KoltESP:SetGlobalHighlightOutlineTransparency(0.7)
KoltESP:SetGlobalHighlightFillTransparency(0.9)
KoltESP:SetMaxDistance(200)
KoltESP:SetMinDistance(10)
```

---

## 📊 Estatísticas

Obtenha informações rápidas sobre a performance e uso:

```lua
local stats = KoltESP:GetStats()
print(stats)
--[[
{
  totalObjects = ...;
  visibleObjects = ...;
  frameTime = ...;
  lastUpdate = ...;
  cacheSize = ...;
  enabled = ...;
}
]]
```

---

## 🌈 Temas e Cores

Controle visual dos ESPs:

```lua
-- Cores padrão do tema
KoltESP.Theme.PrimaryColor      -- Color3.fromRGB(130, 200, 255)
KoltESP.Theme.SecondaryColor    -- Color3.fromRGB(255, 255, 255)
KoltESP.Theme.ErrorColor        -- Color3.fromRGB(255, 100, 100)
KoltESP.Theme.GradientColor     -- Color3.fromRGB(100, 150, 255)
```

---

## 📝 Exemplo Avançado

```lua
-- Adiciona ESP com configurações avançadas
KoltESP:Add(workspace.Enemys.Enemy1, {
    Name = "Inimigo",
    Color = KoltESP.Theme.ErrorColor,
    Rainbow = true,
    ShowTracer = true,
    HighlightOutlineTransparency = 0.75,
    HighlightFillTransparency = 0.95,
    LineThickness = 2,
    FontSize = 18,
    DistanceSuffix = " studs",
    ShowDistance = true
})
```

---

## 🧹 Unload / Limpeza

Para descarregar completamente e remover todos os ESPs e conexões:

```lua
KoltESP:Unload()
```

---

## 🕹️ Observações

- A biblioteca se auto-inicializa ao ser carregada.
- Todas as funções e métodos são responsivos e otimizados para performance.
- Suporta targets dinâmicos, modelos, BaseParts e caminhos via string.
- Extremamente flexível e elegante para qualquer projeto Roblox.

---

<div align="center">
  <b>Desenvolvido por DH_SOARES • KoltESP V1.5 Enhanced</b>
</div>
