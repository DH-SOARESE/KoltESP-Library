# KoltESP Library 1.1

Uma biblioteca elegante e orientada a objetos para ESP em Roblox, com carregamento dinâmico via `loadstring`. Suporta múltiplos tipos de ESP e é altamente configurável tanto globalmente quanto por objeto.  
Desenvolvida para facilitar visualização e destaque de entidades no ambiente de jogo.

---

## 🚀 Como usar

Carregue a biblioteca diretamente via `loadstring`:

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/main/Library.lua"))()
```

Crie um ESP para um alvo:

```lua
local esp = KoltESP.new(target)
esp:AddESP({type = "Name", name = "Jogador"})
esp:AddESP({type = "Distance", Suffix = " m"})
```

Configuração global:

```lua
KoltESP.SetESP({
    ESPColor = Color3.fromRGB(0, 255, 255),
    TracerOrigin = "Center",
    RainbowMode = true,
    MaxDistance = 300
})
```

Remover ESP:

```lua
esp:Destroy()
```

Descarregar todos ESPs:

```lua
KoltESP.Unload()
```

---

## ✨ Tipos de ESP e suas propriedades

A library suporta os seguintes tipos de ESP, cada um com suas propriedades customizáveis.

| Tipo                | Propriedades disponíveis | Descrição                                       |
|---------------------|-------------------------|-------------------------------------------------|
| **Tracer**          | `TracerOrigin`<br>`TracerVisible` | Origem da linha: `"Top"`, `"Center"`, `"Bottom"`<br>Mostrar/ocultar linha |
| **Name**            | `NameVisible`<br>`name` | Mostrar/ocultar nome<br>Texto do nome            |
| **Distance**        | `DistanceVisible`<br>`Suffix`<br>`DistanceContainer` | Mostrar/ocultar distância<br>Sufixo customizável<br>Container para formatar o valor |
| **HighlightOutline**| `HighlightOutlineVisible`<br>`OutlineOpacity` | Mostrar/ocultar contorno<br>Opacidade do contorno|
| **HighlightFill**   | `HighlightFillVisible`<br>`FillOpacity` | Mostrar/ocultar preenchimento<br>Opacidade do preenchimento|

### Exemplos de configuração individual

```lua
-- Adicionar nome personalizado
esp:AddESP({type = "Name", name = "NPC"})

-- Adicionar distância com sufixo customizado
esp:AddESP({type = "Distance", Suffix = " km"})

-- Exemplo com DistanceContainer
KoltESP.SetESP({DistanceContainer = "[{value}]"}) -- Use para envolver o valor da distância
```

---

## 🛠️ Configurações Globais

Sete opções podem ser alteradas para todos os ESPs simultaneamente via `KoltESP.SetESP`:

```lua
KoltESP.SetESP({
    TracerOrigin = "Bottom",      -- "Top", "Center", "Bottom"
    TracerVisible = true,
    NameVisible = true,
    DistanceVisible = true,
    HighlightOutlineVisible = true,
    HighlightFillVisible = true,
    OutlineOpacity = 0.5,
    FillOpacity = 0.5,
    RainbowMode = false,
    ESPColor = Color3.fromRGB(255, 0, 0),
    MaxDistance = math.huge,
    MinDistance = 0,
    DistanceContainer = ""
})
```

---

## 🎨 Modo Arco-Íris

Basta ativar `RainbowMode` para colorir todos os ESPs dinamicamente:

```lua
KoltESP.SetESP({RainbowMode = true})
```

---

## 📚 API Resumida

- `KoltESP.new(target)` — Cria um novo ESP para o alvo
- `esp:AddESP(config)` — Adiciona propriedades individuais (Name, Distance, etc)
- `KoltESP.SetESP(config)` — Define configurações globais
- `esp:Destroy()` — Remove e limpa o ESP individual
- `KoltESP.Unload()` — Remove todos os ESPs

---

## 💡 Dicas

- O ESP funciona para `Model` ou `BasePart`. Recomenda-se que o modelo tenha `PrimaryPart` definido.
- Para personalização máxima, combine configurações globais e individuais.
- O `DistanceContainer` pode ser usado para criar formatos personalizados (ex: `"[{value}]"`).

---

## 🤝 Suporte

Dúvidas? Fale com [DH-SOARESE](https://github.com/DH-SOARESE).
