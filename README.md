# 🎯 KoltESP Library

> **Uma biblioteca ESP avançada e personalizável para Roblox**

## 📋 Índice

- [Instalação](#-instalação)
- [Uso Rápido](#-uso-rápido)
- [Documentação Completa](#-documentação-completa)
- [Exemplos Práticos](#-exemplos-práticos)
- [API Reference](#-api-reference)
- [Configurações Avançadas](#-configurações-avançadas)
- [Troubleshooting](#-troubleshooting)
- [Changelog](#-changelog)

---

## 🚀 Instalação

### Método 1: LoadString (Recomendado)
```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()
```

### Método 2: Cópia Local
Copie o código da biblioteca e execute diretamente no seu executor.

---

## ⚡ Uso Rápido

```lua
-- Carregar a library
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Exemplo básico - ESP em uma parte
KoltESP:Target("workspace.Part", "MinhaESP", {
    Default = {255, 0, 0}, -- Cor padrão: Vermelho
    Name = {Name = "Target Principal", Container = "[]"},
    Distance = {Container = "()", Suffix = "m"}
})

-- Ativar modo rainbow
KoltESP:RainbowMode(true)
```

---

## 📚 Documentação Completa

### 🎯 Sistema de Paths

A KoltESP utiliza um sistema inteligente de paths para localizar objetos:

```lua
-- Exemplos de paths válidos
"workspace.Part"                    -- Parte simples
"workspace.Model.HumanoidRootPart"  -- Parte dentro de modelo
"game.Players.PlayerName.Character" -- Character de jogador
"workspace.Folder.SubFolder.Item"   -- Objetos aninhados
```

### 🎨 Sistema de Cores

As cores são definidas usando valores RGB (0-255):

```lua
Color = {
    Tracer    = {255, 0, 0},     -- Vermelho
    Name      = {0, 255, 0},     -- Verde  
    Distancia = {0, 0, 255},     -- Azul
    Highlight = {
        Outline = {255, 255, 255}, -- Branco
        Filled  = {128, 0, 128}    -- Roxo
    }
}
```

### 🏷️ Personalização de Containers

```lua
Name = {
    Name = "Meu Target",
    Container = "||"  -- Resultado: |Meu Target|
}

Distance = {
    Container = "()",
    Suffix = ".m"     -- Resultado: (150.m)
}
```

---

## 💡 Exemplos Práticos

### Exemplo 1: ESP Básico para Jogadores
```lua
-- ESP para character de um jogador específico
KoltESP:Target("game.Players.PlayerName.Character", "PlayerESP", {
    Default = {0, 255, 0},
    Name = {Name = "PLAYER", Container = ">>"},
    Distance = {Container = "[", Suffix = "m]"},
    Color = {
        Tracer = {255, 255, 0},
        Name = {0, 255, 255},
        Distancia = {255, 255, 255}
    }
})
```

### Exemplo 2: ESP para Itens com Highlight
```lua
-- ESP para item com destaque visual
KoltESP:Target("workspace.ImportantItem", "ItemESP", {
    Default = {255, 165, 0},
    Name = {Name = "ITEM RARO", Container = "★★"},
    Distance = {Container = "(", Suffix = "m away)"},
    Color = {
        Highlight = {
            Outline = {255, 215, 0}, -- Dourado
            Filled = {255, 140, 0}   -- Laranja escuro
        }
    }
})

-- Configurar transparência do highlight
KoltESP:ConfigTransparency("Highlight", {
    Filled = 0.3,   -- 30% opaco
    Outline = 0.1   -- 10% opaco
})
```

### Exemplo 3: ESP Rainbow Avançado
```lua
-- ESP com modo rainbow e configurações avançadas
KoltESP:Target("workspace.RainbowTarget", "RainbowESP", {
    Name = {Name = "RAINBOW TARGET", Container = "◆◆"},
    Distance = {Container = "~", Suffix = "units~"}
})

-- Ativar rainbow e configurar limites
KoltESP:RainbowMode(true)
KoltESP.ConfigDistanceMax = 1000
KoltESP.ConfigDistanceMin = 10
```

### Exemplo 4: Sistema de ESP Múltiplo
```lua
-- Múltiplas ESPs com controle individual
local targets = {
    {path = "workspace.RedTarget", id = "Red", color = {255, 0, 0}},
    {path = "workspace.BlueTarget", id = "Blue", color = {0, 0, 255}},
    {path = "workspace.GreenTarget", id = "Green", color = {0, 255, 0}}
}

for _, target in ipairs(targets) do
    KoltESP:Target(target.path, target.id, {
        Default = target.color,
        Name = {Name = target.id:upper() .. " TARGET", Container = "||"},
        Distance = {Container = "(", Suffix = "m)"}
    })
end

-- Pausar apenas o target azul
KoltESP:Pause("Blue", true)
```

### Exemplo 5: ESP Temporário com Auto-Cleanup
```lua
-- ESP que se auto-remove após 30 segundos
KoltESP:Target("workspace.TemporaryItem", "TempESP", {
    Default = {255, 255, 0},
    Name = {Name = "TEMP ITEM", Container = "⏰⏰"},
    Distance = {Container = "[", Suffix = "m]"}
})

-- Auto-cleanup após 30 segundos
spawn(function()
    wait(30)
    KoltESP:Clear("TempESP")
    print("ESP temporário removido!")
end)
```

---

## 🔧 API Reference

### Função Principal

#### `KoltESP:Target(path, espId, config)`
Cria uma nova ESP para o objeto especificado.

**Parâmetros:**
- `path` (string): Caminho para o objeto (ex: "workspace.Part")
- `espId` (string): ID único para esta ESP
- `config` (table): Configurações da ESP

**Exemplo:**
```lua
KoltESP:Target("workspace.MyPart", "ESP1", {
    Default = {255, 0, 0},
    Name = {Name = "Minha Parte", Container = "[]"},
    Distance = {Container = "()", Suffix = "m"},
    Color = {
        Tracer = {255, 255, 0},
        Name = {0, 255, 0},
        Distancia = {255, 255, 255},
        Highlight = {
            Outline = {255, 255, 255},
            Filled = {0, 100, 255}
        }
    }
})
```

### Funções de Controle

#### `KoltESP:NewTarget(path, oldEspId, newEspId)`
Transfere uma ESP existente para um novo objeto.

```lua
-- Mover ESP de um objeto para outro
KoltESP:NewTarget("workspace.NewPart", "ESP1", "ESP2")
```

#### `KoltESP:Clear(espId?)`
Remove ESP(s) específica(s) ou todas.

```lua
KoltESP:Clear("ESP1")     -- Remove ESP específica
KoltESP:Clear()           -- Remove todas as ESPs
```

#### `KoltESP:Pause(espId?, state)`
Pausa/despausa ESP(s).

```lua
KoltESP:Pause("ESP1", true)   -- Pausa ESP específica
KoltESP:Pause(false)          -- Despausa todas as ESPs
```

### Funções de Configuração

#### `KoltESP:Config(component, settings)`
Configura visibilidade de componentes.

```lua
-- Configurar componentes individuais
KoltESP:Config("Name", {Visible = true})
KoltESP:Config("Distance", {Visible = false})
KoltESP:Config("Tracer", {Visible = true})
KoltESP:Config("Highlight", {Filled = true, Outline = false})
```

#### `KoltESP:RainbowMode(enabled)`
Ativa/desativa modo rainbow.

```lua
KoltESP:RainbowMode(true)   -- Ativar
KoltESP:RainbowMode(false)  -- Desativar
```

#### `KoltESP:ConfigTransparency(component, settings)`
Configura transparência do highlight.

```lua
KoltESP:ConfigTransparency("Highlight", {
    Filled = 0.5,   -- 50% transparente
    Outline = 0.2   -- 20% transparente
})
```

### Propriedades Globais

#### `KoltESP.ConfigDistanceMax`
Distância máxima para mostrar ESP (padrão: 400).

#### `KoltESP.ConfigDistanceMin`
Distância mínima para mostrar ESP (padrão: 5).

```lua
KoltESP.ConfigDistanceMax = 1000  -- 1000 studs
KoltESP.ConfigDistanceMin = 20    -- 20 studs
```

#### `KoltESP:Unload()`
Descarrega completamente a library.

```lua
KoltESP:Unload()  -- Remove tudo e limpa memória
```

---

## ⚙️ Configurações Avançadas

### Template de Configuração Completa
```lua
local configCompleta = {
    Default = {255, 255, 255},  -- Cor RGB padrão
    
    Name = {
        Name = "Nome Personalizado",  -- Nome a ser exibido
        Container = "[]"              -- Container ao redor do nome
    },
    
    Distance = {
        Container = "()",  -- Container ao redor da distância
        Suffix = "m"       -- Sufixo após a distância
    },
    
    Color = {
        Tracer = {255, 0, 0},        -- Cor da linha tracer
        Name = {0, 255, 0},          -- Cor do texto do nome
        Distancia = {0, 0, 255},     -- Cor do texto da distância
        
        Highlight = {
            Outline = {255, 255, 255},  -- Cor do contorno
            Filled = {128, 128, 128}    -- Cor do preenchimento
        }
    }
}

KoltESP:Target("workspace.MeuObjeto", "ESPAvancada", configCompleta)
```

### Configurações de Performance
```lua
-- Para melhor performance em mapas grandes
KoltESP.ConfigDistanceMax = 200  -- Reduzir distância máxima
KoltESP:Config("Tracer", {Visible = false})  -- Desabilitar tracers pesados

-- Para máxima qualidade visual
KoltESP.ConfigDistanceMax = 2000
KoltESP:ConfigTransparency("Highlight", {Filled = 0.1, Outline = 0.0})
```

---

## 🛠️ Troubleshooting

### Problemas Comuns

**❌ ESP não aparece:**
```lua
-- Verificar se o objeto existe
local obj = workspace:FindFirstChild("NomeDoObjeto")
if obj then
    print("Objeto encontrado!")
    KoltESP:Target("workspace.NomeDoObjeto", "teste", {Default = {255, 0, 0}})
else
    print("Objeto não encontrado!")
end
```

**❌ Performance baixa:**
```lua
-- Reduzir número de ESPs ativas
KoltESP.ConfigDistanceMax = 100  -- Menor distância
KoltESP:Config("Tracer", {Visible = false})  -- Desabilitar tracers
```

**❌ Cores não funcionam:**
```lua
-- Verificar formato RGB (0-255)
Color = {
    Name = {255, 0, 0}  -- ✅ Correto
    -- Name = {1, 0, 0}  -- ❌ Incorreto (0-1)
}
```

### Debug Mode
```lua
-- Função para debug
local function debugESP()
    print("=== DEBUG KOLTESP ===")
    print("ESPs ativas:", #ESPTargets)
    print("Rainbow ativo:", RainbowModeEnabled)
    print("Distância Max:", KoltESP.ConfigDistanceMax)
    print("Distância Min:", KoltESP.ConfigDistanceMin)
    
    for id, data in pairs(ESPTargets) do
        print(string.format("ESP[%s]: %s | Pausada: %s", 
            id, 
            data.Object.Name, 
            tostring(data.Paused)
        ))
    end
end

debugESP()
```

---

## 📝 Changelog

### v1.0 (Release Atual)
- ✅ Sistema de paths inteligente
- ✅ Suporte completo a Highlight
- ✅ Modo Rainbow dinâmico
- ✅ API de controle avançada
- ✅ Sistema de containers personalizáveis
- ✅ Configuração de transparência
- ✅ Otimizações de performance

---

## 📞 Suporte

- **GitHub Issues**: [Reportar Bug](https://github.com/DH-SOARESE/KoltESP-Library/issues)
- **Discussões**: [GitHub Discussions](https://github.com/DH-SOARESE/KoltESP-Library/discussions)

---

## 📄 Licença

Este projeto está licenciado sob a MIT License - veja o arquivo [LICENSE](LICENSE) para detalhes.

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor, leia o [CONTRIBUTING.md](CONTRIBUTING.md) para detalhes sobre nosso código de conduta e o processo para enviar pull requests.

---

## ⭐ Library Crua

Para visualizar o código fonte completo da library:

```lua
--[[
==============================
KoltESP Library v1.0
Advanced ESP System for Roblox
==============================

Carregamento:
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

Exemplo de Uso:
KoltESP:Target("workspace.Part", "ESP1", {
    Default = {255, 0, 0},
    Name = {Name = "Target", Container = "[]"},
    Distance = {Container = "()", Suffix = "m"}
})

Funcionalidades:
- ✅ Sistema de paths inteligente  
- ✅ Highlight com transparência
- ✅ Modo Rainbow dinâmico
- ✅ Controle de distância min/max
- ✅ API completa de controle
- ✅ Otimizado para performance
- ✅ Suporte a todos executores

GitHub: https://github.com/DH-SOARESE/KoltESP-Library
--]]

-- [CÓDIGO DA LIBRARY AQUI - 400+ linhas de código otimizado]
-- Acesse o link acima para ver o código completo!
```

**🔗 Link Direto:** https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua

---

<div align="center">

**🌟 Se este projeto te ajudou, deixe uma estrela no GitHub! 🌟**

[⬆ Voltar ao Topo](#-koltesp-library)

</div>
