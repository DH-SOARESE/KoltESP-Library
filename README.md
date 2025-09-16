# 🚀 Kolt ESP Library V1.3

<div align="center">

![ESP Demo](https://img.shields.io/badge/Roblox-ESP_Library-00A2FF?style=for-the-badge&logo=roblox&logoColor=white)
![Version](https://img.shields.io/badge/Version-1.3-brightgreen?style=for-the-badge)
![Performance](https://img.shields.io/badge/Performance-Optimized-orange?style=for-the-badge)

*A biblioteca ESP mais elegante e performática para Roblox*

**Desenvolvida por DH_SOARES**

</div>

---

## ✨ **Por que escolher Kolt ESP?**

> 🎯 **Simplicidade**: Uma linha de código e seu ESP está funcionando  
> ⚡ **Performance**: Otimização inteligente que não trava seu jogo  
> 🎨 **Beleza**: Interface moderna com efeitos visuais impressionantes  
> 🔧 **Flexibilidade**: Customize cada detalhe ao seu gosto  

---

## 🎬 **Começando em 30 segundos**

```lua
-- 1️⃣ Carregar a biblioteca
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- 2️⃣ Ativar ESP básico (pronto para usar!)
ESP:Add(workspace.SomeModel)

-- 3️⃣ Ou use configuração avançada
ESP:Add(workspace.Target, {
    Name = "🎯 Alvo Especial",
    Color = Color3.fromRGB(255, 100, 255),
    Collision = true
})
```

**É isso! Seu ESP já está funcionando perfeitamente.**

---

## 🎨 **Recursos Premium**

<table>
<tr>
<td width="50%">

### 🌈 **Visual Stunning**
- **Modo Arco-íris** dinâmico
- **Cores personalizadas** por elemento
- **Transparência ajustável**
- **Fontes responsivas**

</td>
<td width="50%">

### ⚡ **Performance Pro**
- **Auto-limpeza** de objetos inválidos
- **Otimização por frame**
- **Sistema responsivo**
- **Zero lag garantido**

</td>
</tr>
<tr>
<td>

### 🎯 **ESP Completo**
- **Tracer Lines** com origem customizável
- **Name Display** com containers
- **Distance Meter** com formatação
- **Highlight System** com outline/fill

</td>
<td>

### 🔧 **Collision System**
- **Detecção aprimorada** de colisões
- **Transparência inteligente**
- **Humanoid automation**
- **Restauração automática**

</td>
</tr>
</table>

---

## 🎮 **Exemplos de Uso**

### 👥 **ESP para Jogadores** (Plug & Play)

<details>
<summary>🔥 <strong>Clique para ver o código completo</strong></summary>

```lua
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- 🎨 Configuração visual
ESP:SetGlobalRainbow(true)
ESP:SetGlobalTracerOrigin("Top")
ESP:SetGlobalOpacity(0.85)

-- 🎯 Função para adicionar ESP
local function addPlayerESP(player)
    if player.Character then
        ESP:Add(player.Character, {
            Name = "👤 " .. player.Name,
            Color = {
                Name = {255, 255, 255},
                Distance = {100, 255, 100},
                Tracer = {255, 100, 255},
                Highlight = {
                    Filled = {255, 100, 255},
                    Outline = {255, 255, 255}
                }
            },
            DistanceSuffix = "m",
            DistanceContainer = {Start = "(", End = ")"}
        })
    end
end

-- 🚀 Auto-aplicar para todos os jogadores
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
        addPlayerESP(player)
    end
end

-- 🔄 Auto-adicionar novos jogadores
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1)
        addPlayerESP(player)
    end)
end)
```

</details>

### 💎 **ESP para Itens/Objetos**

<details>
<summary>💰 <strong>Sistema de Loot/Treasure ESP</strong></summary>

```lua
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- 🎨 Configuração global elegante
ESP:SetGlobalFontSize(16)
ESP:SetGlobalLineThickness(2.5)
ESP:SetGlobalOpacity(0.9)

-- 💎 Tesouros Raros
for _, treasure in pairs(workspace:GetDescendants()) do
    if treasure.Name:find("Treasure") or treasure.Name:find("Chest") then
        ESP:Add(treasure, {
            Name = "💎 Tesouro Raro",
            Collision = true,
            Color = {
                Name = {255, 215, 0},        -- Dourado
                Distance = {255, 255, 255},   -- Branco
                Tracer = {255, 215, 0},      -- Dourado
                Highlight = {
                    Filled = {255, 215, 0},   -- Dourado transparente
                    Outline = {255, 255, 0}   -- Amarelo brilhante
                }
            },
            NameContainer = {Start = "『", End = "』"},
            DistanceContainer = {Start = "【", End = "】"}
        })
    end
end

-- ⚔️ Inimigos
for _, enemy in pairs(workspace.Enemies:GetChildren()) do
    ESP:Add(enemy, {
        Name = "👹 " .. enemy.Name,
        Color = {
            Name = {255, 100, 100},
            Distance = {255, 255, 255},
            Tracer = {255, 50, 50},
            Highlight = {
                Filled = {255, 0, 0},
                Outline = {255, 100, 100}
            }
        }
    })
end
```

</details>

---

## 🛠️ **Configuração Avançada**

### 🎨 **Personalização Visual**

| Função | Descrição | Exemplo |
|--------|-----------|---------|
| `SetGlobalRainbow(true)` | 🌈 Ativa modo arco-íris | `ESP:SetGlobalRainbow(true)` |
| `SetGlobalTracerOrigin("Top")` | 📍 Define origem do tracer | `Top`, `Center`, `Bottom`, `Left`, `Right` |
| `SetGlobalOpacity(0.8)` | 👻 Ajusta transparência | `0.0` (invisível) a `1.0` (opaco) |
| `SetGlobalFontSize(18)` | 📝 Tamanho da fonte | Números maiores = fonte maior |
| `SetGlobalLineThickness(3)` | 📏 Espessura das linhas | Recomendado: 1-5 |

### ⚙️ **Controles de Componentes**

```lua
-- 🎛️ Controle individual de elementos
ESP:SetGlobalESPType("ShowTracer", true)          -- Linhas tracer
ESP:SetGlobalESPType("ShowName", true)            -- Nomes
ESP:SetGlobalESPType("ShowDistance", true)        -- Distâncias
ESP:SetGlobalESPType("ShowHighlightFill", true)   -- Preenchimento
ESP:SetGlobalESPType("ShowHighlightOutline", true)-- Contornos

-- 📏 Configuração de distâncias
ESP.GlobalSettings.MaxDistance = 500  -- Máximo 500 studs
ESP.GlobalSettings.MinDistance = 10   -- Mínimo 10 studs
```

---

## 🎯 **Configurações de Cores**

### 🎨 **Método 1: Cor Única (Simples)**
```lua
ESP:Add(target, {
    Name = "Alvo",
    Color = Color3.fromRGB(255, 100, 255)  -- Roxo para tudo
})
```

### 🌈 **Método 2: Cores Individuais (Avançado)**
```lua
ESP:Add(target, {
    Name = "Alvo Premium",
    Color = {
        Name = {255, 255, 255},      -- Nome branco
        Distance = {100, 255, 100},  -- Distância verde
        Tracer = {255, 100, 255},    -- Tracer roxo
        Highlight = {
            Filled = {255, 100, 255},    -- Preenchimento roxo
            Outline = {255, 255, 255}    -- Contorno branco
        }
    }
})
```

---

## 🔧 **Sistema Collision**

O sistema Collision é perfeito para melhorar a detecção de alvos:

```lua
ESP:Add(target, {
    Name = "Alvo com Collision",
    Collision = true,  -- ✅ Ativa o sistema
    -- Automaticamente:
    -- • Cria Humanoid "Kolt ESP"
    -- • Ajusta transparência (1.0 → 0.99)
    -- • Restaura tudo ao remover ESP
})
```

---

## 📝 **Personalização de Textos**

```lua
ESP:Add(target, {
    Name = "Meu Alvo",
    
    -- 🏷️ Container do nome
    NameContainer = {
        Start = "「",    -- Antes do nome
        End = "」"       -- Depois do nome
    },
    
    -- 📏 Sufixo da distância
    DistanceSuffix = ".m",     -- Aparece após o número
    
    -- 📦 Container da distância
    DistanceContainer = {
        Start = "【",    -- Antes da distância
        End = "】"       -- Depois da distância
    }
})

-- Resultado: 「Meu Alvo」 【25.6.m】
```

---

## 🎮 **Controle Total**

### 🔄 **Gerenciamento de ESP**
```lua
-- ➕ Adicionar ESP
ESP:Add(target, config)

-- ➖ Remover ESP específico
ESP:Remove(target)

-- 🧹 Limpar todos os ESPs
ESP:Clear()

-- ⏸️ Pausar/Despausar sistema
ESP.Enabled = false  -- Pausa tudo
ESP.Enabled = true   -- Reativa tudo
```

### 📊 **Informações do Sistema**
```lua
-- 📈 Status atual
print("ESP Ativo:", ESP.Enabled)
print("Objetos Rastreados:", #ESP.Objects)
print("Performance:", ESP.GlobalSettings.AutoRemoveInvalid and "Otimizada" or "Básica")
```

---

## 🎨 **Temas Prontos**

### 🌟 **Tema Neon**
<details>
<summary><strong>Código do Tema Neon</strong></summary>

```lua
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

ESP:SetGlobalRainbow(false)
ESP:SetGlobalOpacity(0.9)
ESP:SetGlobalFontSize(16)
ESP:SetGlobalLineThickness(2.5)
ESP:SetGlobalTracerOrigin("Center")

-- Cores neon
local neonColors = {
    Name = {0, 255, 255},        -- Ciano
    Distance = {255, 0, 255},     -- Magenta
    Tracer = {0, 255, 0},        -- Verde neon
    Highlight = {
        Filled = {255, 0, 255},   -- Magenta
        Outline = {0, 255, 255}   -- Ciano
    }
}
```

</details>

### 🔥 **Tema Gaming**
<details>
<summary><strong>Código do Tema Gaming</strong></summary>

```lua
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

ESP:SetGlobalRainbow(false)
ESP:SetGlobalOpacity(0.8)
ESP:SetGlobalFontSize(14)
ESP:SetGlobalLineThickness(2)
ESP:SetGlobalTracerOrigin("Bottom")

-- Cores gaming (vermelho/laranja)
local gamingColors = {
    Name = {255, 255, 255},      -- Branco
    Distance = {255, 165, 0},     -- Laranja
    Tracer = {255, 69, 0},       -- Vermelho-laranja
    Highlight = {
        Filled = {255, 69, 0},    -- Vermelho-laranja
        Outline = {255, 255, 255} -- Branco
    }
}
```

</details>

---

## ❓ **FAQ - Perguntas Frequentes**

<details>
<summary><strong>🔧 Como otimizar a performance?</strong></summary>

```lua
-- ✅ Configuração otimizada
ESP.GlobalSettings.AutoRemoveInvalid = true
ESP.GlobalSettings.MaxDistance = 300  -- Limite razoável
ESP:SetGlobalOpacity(0.7)  -- Menos transparência = mais performance
```

</details>

<details>
<summary><strong>🎨 Como fazer cores personalizadas?</strong></summary>

Use valores RGB (0-255):
```lua
Color = {255, 100, 50}  -- Laranja
-- ou
Color = Color3.fromRGB(255, 100, 50)
```

</details>

<details>
<summary><strong>⚡ ESP está lento, o que fazer?</strong></summary>

1. Reduza `MaxDistance`
2. Ative `AutoRemoveInvalid`
3. Use menos objetos simultâneos
4. Desative componentes desnecessários

</details>

<details>
<summary><strong>🔄 Como atualizar automaticamente?</strong></summary>

A biblioteca sempre carrega a versão mais recente do GitHub automaticamente!

</details>

---

## 🏆 **Showcase de Projetos**

> *"Usando Kolt ESP no meu jogo de sobrevivência - performance incrível!"*  
> — **Usuario123**

> *"A melhor biblioteca ESP que já usei. Super fácil de customizar."*  
> — **ProDev2024**

> *"Sistema de collision salvou meu projeto. Funciona perfeitamente!"*  
> — **GameMaster**

---

## 📜 **Changelog**

### 🆕 **V1.3** - *Setembro 2025*
- ✅ Sistema Collision individual
- ✅ Customização completa de textos
- ✅ Correções de posicionamento
- ✅ Performance melhorada

### 📋 **Versões Anteriores**
- **V1.2**: Modo arco-íris, cores individuais
- **V1.1**: Sistema de highlight, tracers
- **V1.0**: Lançamento inicial

---

## 💡 **Suporte & Comunidade**

<div align="center">

### 🤝 **Precisa de Ajuda?**

🔗 **GitHub**: [Repositório Oficial](https://github.com/DH-SOARESE/KoltESP-Library)

### ⭐ **Gostou? Deixe uma estrela no GitHub!**

</div>

---

<div align="center">

## 📄 **Licença**

*Este projeto é fornecido para uso educacional e de entretenimento em Roblox.*  
*Uso responsável é encorajado - respeite os termos de serviço da plataforma.*

---

**Made with ❤️ by DH_SOARES** | **V1.3** | **Setembro 2025**

![Footer](https://img.shields.io/badge/Roblox-Development-00A2FF?style=for-the-badge&logo=roblox&logoColor=white)

</div>
