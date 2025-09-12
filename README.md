# 📦 Kolt ESP Library V1.2

Uma biblioteca ESP (Extra Sensory Perception) minimalista, eficiente e responsiva para Roblox, desenvolvida por **DH_SOARES**.

## ✨ Características

- 🎯 **ESP Completo**: Tracer, Nome, Distância e Highlight
- 🌈 **Modo Arco-íris**: Cores dinâmicas que mudam automaticamente
- 🎨 **Altamente Customizável**: Configurações globais e individuais
- ⚡ **Performance Otimizada**: Sistema de auto-remoção de objetos inválidos
- 📱 **Responsivo**: Adapta-se a diferentes resoluções de tela
- 🔧 **Fácil de Usar**: API simples e intuitiva

## 🚀 Instalação

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()
```

## 📋 Funcionalidades

### 🎯 Componentes ESP
- **Tracer**: Linha do ponto de origem até o alvo
- **Nome**: Exibe o nome do objeto
- **Distância**: Mostra a distância em metros
- **Highlight**: Contorno colorido ao redor do objeto

### 🎮 Origens do Tracer
- `Top` - Topo da tela
- `Center` - Centro da tela
- `Bottom` - Parte inferior da tela (padrão)
- `Left` - Lateral esquerda
- `Right` - Lateral direita

## 🛠️ Uso Básico

### Adicionando ESP a um Objeto

```lua
-- Carregar a biblioteca
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Adicionar ESP básico
ModelESP:Add(workspace.SomeModel)

-- Adicionar ESP com configurações personalizadas
ModelESP:Add(workspace.SomeModel, {
    Name = "Alvo Especial",
    Color = Color3.fromRGB(255, 0, 0)
})
```

### Removendo ESP

```lua
-- Remover ESP de um objeto específico
ModelESP:Remove(workspace.SomeModel)

-- Limpar todos os ESPs
ModelESP:Clear()
```

## 🎨 Configurações Globais

### Habilitando/Desabilitando Componentes

```lua
-- Mostrar/ocultar tracers
ModelESP:SetGlobalESPType("ShowTracer", true)

-- Mostrar/ocultar nomes
ModelESP:SetGlobalESPType("ShowName", true)

-- Mostrar/ocultar distâncias
ModelESP:SetGlobalESPType("ShowDistance", true)

-- Mostrar/ocultar highlight fill
ModelESP:SetGlobalESPType("ShowHighlightFill", true)

-- Mostrar/ocultar highlight outline
ModelESP:SetGlobalESPType("ShowHighlightOutline", true)
```

### Personalizando Aparência

```lua
-- Definir origem do tracer
ModelESP:SetGlobalTracerOrigin("Bottom") -- Top, Center, Bottom, Left, Right

-- Ativar modo arco-íris
ModelESP:SetGlobalRainbow(true)

-- Ajustar opacidade (0-1)
ModelESP:SetGlobalOpacity(0.8)

-- Definir tamanho da fonte
ModelESP:SetGlobalFontSize(16)

-- Ajustar espessura da linha
ModelESP:SetGlobalLineThickness(2)
```

### Controle de Distância

```lua
-- Configurar distância máxima (em studs)
ModelESP.GlobalSettings.MaxDistance = 1000

-- Configurar distância mínima
ModelESP.GlobalSettings.MinDistance = 0
```

## 📖 Exemplos Práticos

### 🧑‍🤝‍🧑 ESP para Jogadores

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Função para adicionar ESP a todos os jogadores
local function addPlayerESP()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            ModelESP:Add(player.Character, {
                Name = player.Name,
                Color = Color3.fromRGB(0, 255, 0)
            })
        end
    end
end

-- Adicionar ESP aos jogadores atuais
addPlayerESP()

-- Adicionar ESP automaticamente para novos jogadores
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        wait(1) -- Aguardar o character carregar completamente
        ModelESP:Add(character, {
            Name = player.Name,
            Color = Color3.fromRGB(0, 255, 0)
        })
    end)
end)

-- Remover ESP quando jogador sair
game.Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        ModelESP:Remove(player.Character)
    end
end)
```

### 🎯 ESP para Objetos Específicos

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- ESP para partes específicas por nome
local function addPartESP(partName, espName, color)
    for _, part in pairs(workspace:GetDescendants()) do
        if part.Name == partName and part:IsA("BasePart") then
            ModelESP:Add(part, {
                Name = espName or part.Name,
                Color = color or Color3.fromRGB(255, 255, 0)
            })
        end
    end
end

-- Exemplos de uso
addPartESP("Chest", "💰 Baú", Color3.fromRGB(255, 215, 0))
addPartESP("Enemy", "👹 Inimigo", Color3.fromRGB(255, 0, 0))
addPartESP("PowerUp", "⚡ Power-Up", Color3.fromRGB(0, 255, 255))
```

### 🔍 ESP por Path Específico

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- ESP para objetos em caminhos específicos
local targets = {
    {path = "workspace.Map.Treasures", name = "💎 Tesouro", color = Color3.fromRGB(255, 0, 255)},
    {path = "workspace.Enemies", name = "⚔️ Inimigo", color = Color3.fromRGB(255, 100, 100)},
    {path = "workspace.Items", name = "📦 Item", color = Color3.fromRGB(100, 255, 100)}
}

for _, target in pairs(targets) do
    local success, obj = pcall(function()
        return game:GetService("PathfindingService"):FindPartOnRayWithWhitelist() -- Usar o path correto
    end)
    
    -- Exemplo mais direto:
    local obj = workspace:FindFirstChild("Map")
    if obj then
        obj = obj:FindFirstChild("Treasures")
        if obj then
            for _, child in pairs(obj:GetChildren()) do
                if child:IsA("Model") or child:IsA("BasePart") then
                    ModelESP:Add(child, {
                        Name = target.name,
                        Color = target.color
                    })
                end
            end
        end
    end
end
```

### 🌈 Configuração Avançada

```lua
local ModelESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configurar tema personalizado
ModelESP.Theme.PrimaryColor = Color3.fromRGB(130, 200, 255)
ModelESP.Theme.SecondaryColor = Color3.fromRGB(255, 255, 255)
ModelESP.Theme.OutlineColor = Color3.fromRGB(0, 0, 0)

-- Configurações avançadas
ModelESP:SetGlobalTracerOrigin("Center")
ModelESP:SetGlobalRainbow(true)
ModelESP:SetGlobalOpacity(0.9)
ModelESP:SetGlobalFontSize(18)
ModelESP:SetGlobalLineThickness(3)

-- Definir distâncias
ModelESP.GlobalSettings.MaxDistance = 500 -- 500 studs máximo
ModelESP.GlobalSettings.MinDistance = 10  -- 10 studs mínimo

-- Habilitar auto-remoção de objetos inválidos
ModelESP.GlobalSettings.AutoRemoveInvalid = true
```

## ⚙️ Configurações Disponíveis

### GlobalSettings
```lua
{
    TracerOrigin = "Bottom",        -- Origem do tracer
    ShowTracer = true,              -- Mostrar linha tracer
    ShowHighlightFill = true,       -- Mostrar preenchimento do highlight
    ShowHighlightOutline = true,    -- Mostrar contorno do highlight
    ShowName = true,                -- Mostrar nome
    ShowDistance = true,            -- Mostrar distância
    RainbowMode = false,            -- Modo arco-íris
    MaxDistance = math.huge,        -- Distância máxima
    MinDistance = 0,                -- Distância mínima
    Opacity = 0.8,                  -- Opacidade (0-1)
    LineThickness = 1.5,            -- Espessura da linha
    FontSize = 14,                  -- Tamanho da fonte
    AutoRemoveInvalid = true        -- Auto-remover objetos inválidos
}
```

## 🎮 Controles

```lua
-- Habilitar/desabilitar completamente
ModelESP.Enabled = true/false

-- Verificar status
print("ESP ativo:", ModelESP.Enabled)
print("Objetos rastreados:", #ModelESP.Objects)
```

## 📄 Licença

Esta biblioteca é fornecida como está, para uso educacional e de entretenimento em Roblox.

---

**Desenvolvido por DH_SOARES** | Versão 1.2
