# 📦 Kolt ESP Library V1.2

Uma biblioteca ESP simples, eficiente e responsiva para Roblox, focada em configurações fáceis e intuitivas sem complicações no código.

**👤 Autor:** DH_SOARES  
**🎨 Estilo:** Minimalista, eficiente e orientado a objetos

---

## 🚀 Links Rápidos para Tipos de ESP

- [🎯 **Tracer ESP**](#-tracer-esp) - Linhas conectando da tela ao alvo
- [🔍 **Highlight ESP**](#-highlight-esp) - Destaque colorido nos objetos
- [📦 **Box ESP**](#-box-esp) - Caixas delimitadoras 2D
- [📝 **Text ESP**](#-text-esp) - Nome e distância dos alvos
- [🌈 **Rainbow Mode**](#-rainbow-mode) - Cores arco-íris animadas

---

## 📥 Instalação

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/Kolt-DOORS/refs/heads/main/Kolt%20ESP-LIBRARY.lua"))()
```

## ⚡ Uso Básico

### Adicionando ESP a um Objeto

```lua
-- ESP básico
ModelESP:Add(workspace.Part)

-- ESP com configurações personalizadas
ModelESP:Add(workspace.Model, {
    Name = "Alvo Importante",
    Color = Color3.fromRGB(255, 0, 0),
    BoxColor = Color3.fromRGB(0, 255, 0),
    TracerColor = Color3.fromRGB(0, 0, 255)
})
```

### Removendo ESP

```lua
-- Remove ESP de um objeto específico
ModelESP:Remove(workspace.Part)

-- Remove todos os ESPs
ModelESP:Clear()
```

---

## 🎯 Tracer ESP

Linhas que conectam da tela até o alvo, com múltiplas opções de origem e empilhamento.

### Configurações de Origem

```lua
-- Definir origem global dos tracers
ModelESP:SetGlobalTracerOrigin("Bottom")    -- Parte inferior (padrão)
ModelESP:SetGlobalTracerOrigin("Top")       -- Parte superior
ModelESP:SetGlobalTracerOrigin("Center")    -- Centro da tela
ModelESP:SetGlobalTracerOrigin("Left")      -- Lateral esquerda
ModelESP:SetGlobalTracerOrigin("Right")     -- Lateral direita
```

### Empilhamento e Referências

```lua
-- Agrupar origens dos tracers (evita sobreposição)
ModelESP:SetGlobalTracerStack(true)

-- Usar múltiplas referências da tela (cantos da box)
ModelESP:SetGlobalTracerScreenRefs(true)

-- Controlar visibilidade
ModelESP:SetGlobalESPType("ShowTracer", true)
```

---

## 🔍 Highlight ESP

Sistema de destaque que cria contornos e preenchimentos coloridos nos objetos.

```lua
-- Controlar componentes do highlight
ModelESP:SetGlobalESPType("ShowHighlightFill", true)      -- Preenchimento
ModelESP:SetGlobalESPType("ShowHighlightOutline", true)   -- Contorno

-- Ajustar transparências
ModelESP:SetGlobalHighlightFillTransparency(0.85)        -- 0 = opaco, 1 = invisível
ModelESP:SetGlobalHighlightOutlineTransparency(0.65)

-- ESP personalizado com highlight específico
ModelESP:Add(workspace.Model, {
    Name = "VIP",
    Color = Color3.fromRGB(255, 215, 0),
    HighlightOutlineColor = Color3.fromRGB(255, 0, 0),
    HighlightOutlineTransparency = 0.3,
    FilledTransparency = 0.7
})
```

---

## 📦 Box ESP

Caixas delimitadoras 2D que envolvem os objetos na tela.

```lua
-- Ativar/desativar boxes
ModelESP:SetGlobalESPType("ShowBox", true)

-- Configurar espessura e transparência
ModelESP:SetGlobalBoxThickness(2)
ModelESP:SetGlobalBoxTransparency(0.5)

-- Tipo de box
ModelESP.GlobalSettings.BoxType = "Dynamic"  -- Usa bounds reais (padrão)
ModelESP.GlobalSettings.BoxType = "Fixed"    -- Tamanho fixo 50x50

-- Padding da box
ModelESP.GlobalSettings.BoxPadding = 5
```

---

## 📝 Text ESP

Exibe nome e distância dos alvos acima dos objetos.

```lua
-- Controlar textos
ModelESP:SetGlobalESPType("ShowName", true)
ModelESP:SetGlobalESPType("ShowDistance", true)

-- Configurar fonte
ModelESP:SetGlobalFontSize(16)

-- ESP com nome personalizado
ModelESP:Add(workspace.Player, {
    Name = "👑 Boss Final",
    Color = Color3.fromRGB(255, 0, 255)
})
```

---

## 🌈 Rainbow Mode

Modo que anima as cores em padrão arco-íris.

```lua
-- Ativar modo rainbow
ModelESP:SetGlobalRainbow(true)

-- Desativar modo rainbow
ModelESP:SetGlobalRainbow(false)
```

---

## ⚙️ Configurações Globais

### Controle de Distância

```lua
-- Definir distâncias mínima e máxima
ModelESP.GlobalSettings.MaxDistance = 500
ModelESP.GlobalSettings.MinDistance = 10
```

### Opacidade e Espessuras

```lua
-- Opacidade geral
ModelESP:SetGlobalOpacity(0.8)

-- Espessuras
ModelESP:SetGlobalLineThickness(2)    -- Tracers
ModelESP:SetGlobalBoxThickness(1.5)   -- Boxes
```

### Configurações Avançadas

```lua
-- Empilhamento de tracers
ModelESP.GlobalSettings.TracerStack = true
ModelESP.GlobalSettings.TracerPadding = 2  -- Distância entre tracers empilhados

-- Remoção automática de objetos inválidos
ModelESP.GlobalSettings.AutoRemoveInvalid = true

-- Usar referências múltiplas da tela
ModelESP.GlobalSettings.TracerScreenRefs = true
```

### Temas de Cores

```lua
-- Personalizar tema padrão
ModelESP.Theme = {
    PrimaryColor = Color3.fromRGB(130, 200, 255),      -- Cor principal
    SecondaryColor = Color3.fromRGB(255, 255, 255),    -- Cor secundária
    OutlineColor = Color3.fromRGB(0, 0, 0),            -- Cor do contorno
}
```

---

## 🔧 Controle Principal

```lua
-- Ativar/desativar toda a library
ModelESP.Enabled = true   -- Liga
ModelESP.Enabled = false  -- Desliga

-- Forçar atualização de todas as configurações
ModelESP:UpdateGlobalSettings()
```

---

## 💡 Exemplos Práticos

### ESP Básico para NPCs

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/Kolt-DOORS/refs/heads/main/Kolt%20ESP-LIBRARY.lua"))()

-- Encontrar e adicionar ESP a todos os NPCs
for _, npc in pairs(workspace:GetChildren()) do
    if npc:FindFirstChildOfClass("Humanoid") then
        ModelESP:Add(npc, {
            Name = "🤖 " .. npc.Name,
            Color = Color3.fromRGB(0, 255, 0)
        })
    end
end
```

### ESP Avançado com Múltiplas Configurações

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/Kolt-DOORS/refs/heads/main/Kolt%20ESP-LIBRARY.lua"))()

-- Configurar settings globais
ModelESP:SetGlobalTracerOrigin("Bottom")
ModelESP:SetGlobalTracerStack(true)
ModelESP:SetGlobalFontSize(14)
ModelESP:SetGlobalOpacity(0.9)

-- ESP para diferentes tipos de objetos
local importantParts = {"Door", "Key", "Chest"}
for _, partName in pairs(importantParts) do
    local part = workspace:FindFirstChild(partName)
    if part then
        ModelESP:Add(part, {
            Name = "⭐ " .. partName,
            Color = Color3.fromRGB(255, 215, 0),
            TracerColor = Color3.fromRGB(255, 0, 0),
            BoxColor = Color3.fromRGB(0, 255, 255)
        })
    end
end
```

### ESP com Rainbow e Filtros

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/Kolt-DOORS/refs/heads/main/Kolt%20ESP-LIBRARY.lua"))()

-- Ativar modo rainbow
ModelESP:SetGlobalRainbow(true)

-- Configurar distância máxima
ModelESP.GlobalSettings.MaxDistance = 200

-- Adicionar ESP apenas para objetos próximos
for _, obj in pairs(workspace:GetChildren()) do
    if obj:IsA("Model") or obj:IsA("BasePart") then
        ModelESP:Add(obj)
    end
end
```

---

## 🎮 Compatibilidade

- ✅ Funciona com Models e BaseParts
- ✅ Remove automaticamente objetos inválidos
- ✅ Sistema de renderização otimizado por frame
- ✅ Suporte completo para Drawing API
- ✅ Configurações persistem durante a execução

---

## 📝 Changelog V1.3

- **🆕 Tracer melhorado** com origem agrupada e múltiplas referências
- **🆕 Sistema de empilhamento** para evitar sobreposição de tracers
- **🆕 Referências de tela** usando cantos da box para tracers mais precisos
- **🔧 Otimizações** no sistema de renderização
- **🎨 Interface simplificada** para configurações globais

---

*Biblioteca desenvolvida com foco na simplicidade e eficiência. Para dúvidas ou sugestões, entre em contato com DH_SOARES.*
