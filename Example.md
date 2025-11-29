# Exemplos Práticos - KoltESP Library v2.0

## Índice
1. [ESP Básico para Jogadores](#esp-básico-para-jogadores)
2. [ESP Avançado com Sistema de Times](#esp-avançado-com-sistema-de-times)
3. [ESP para Objetos do Mundo](#esp-para-objetos-do-mundo)
4. [Sistema de Cores Dinâmicas](#sistema-de-cores-dinâmicas)
5. [ESP Multi-Categoria Completo](#esp-multi-categoria-completo)
6. [Sistema de Rastreamento com Filtros](#sistema-de-rastreamento-com-filtros)
7. [Dicas e Boas Práticas](#dicas-e-boas-práticas)

---

## ESP Básico para Jogadores

Sistema simples e eficiente de ESP para todos os jogadores no servidor.

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configuração global do ESP
KoltESP:SetHighlightFolderName("PlayerESPHighlights")
KoltESP:SetGlobalHighlightTransparency({Filled = 0.7, Outline = 0.2})
KoltESP:SetGlobalTracerOrigin("Bottom")  -- Opções: "Top", "Center", "Bottom", "Left", "Right"
KoltESP.EspSettings.MaxDistance = 500
KoltESP.EspSettings.MinDistance = 10

local playerConnections = {}

local function addPlayerESP(player)
    if player == game.Players.LocalPlayer then return end
    
    local function setupCharacter(character)
        if not character then return end
        task.wait(0.1)
        
        KoltESP:Add(character, {
            Name = player.Name,
            DistancePrefix = "📍 ",
            DistanceSuffix = "m",
            DisplayOrder = 10,
            Opacity = 0.8,
            LineThickness = 2,
            FontSize = 14,
            Font = 2,  -- 0=Legacy, 1=Arial, 2=ArialBold, 3=SourceSans
            Color = {
                Name = {144, 0, 255},
                Distance = {144, 0, 255},
                Tracer = {144, 0, 255},
                Highlight = {
                    Filled = {144, 0, 255},
                    Outline = {200, 0, 255}
                }
            },
            -- Sistema de alerta por distância
            ColorDependency = function(esp, distance, pos3D)
                if distance < 50 then
                    return Color3.fromRGB(255, 0, 0)  -- Vermelho (muito perto)
                elseif distance < 100 then
                    return Color3.fromRGB(255, 165, 0)  -- Laranja (perto)
                end
                return nil  -- Mantém cor padrão (longe)
            end
        })
    end
    
    if player.Character then
        setupCharacter(player.Character)
    end
    
    local charAdded = player.CharacterAdded:Connect(setupCharacter)
    local charRemoving = player.CharacterRemoving:Connect(function(oldChar)
        KoltESP:Remove(oldChar)
    end)
    
    playerConnections[player] = {charAdded, charRemoving}
end

-- Adiciona ESP para jogadores existentes
for _, player in pairs(game.Players:GetPlayers()) do
    addPlayerESP(player)
end

-- Monitora entrada de novos jogadores
game.Players.PlayerAdded:Connect(addPlayerESP)

-- Limpa recursos quando jogadores saem
game.Players.PlayerRemoving:Connect(function(player)
    if playerConnections[player] then
        for _, connection in pairs(playerConnections[player]) do
            connection:Disconnect()
        end
        playerConnections[player] = nil
    end
    if player.Character then
        KoltESP:Remove(player.Character)
    end
end)
```

---

## ESP Avançado com Sistema de Times

Sistema completo com cores diferentes para aliados, inimigos e jogadores neutros.

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configuração global
KoltESP:SetHighlightFolderName("TeamESPHighlights")
KoltESP:SetGlobalHighlightTransparency({Filled = 0.6, Outline = 0.3})
KoltESP:SetGlobalTracerOrigin("Center")
KoltESP.EspSettings.MaxDistance = 1000

local playerConnections = {}
local localPlayer = game.Players.LocalPlayer

-- Cores por tipo de jogador
local COLORS = {
    Ally = {
        Name = {0, 255, 0},
        Distance = {0, 255, 0},
        Tracer = {0, 255, 0},
        Highlight = {Filled = {0, 200, 0}, Outline = {0, 255, 0}}
    },
    Enemy = {
        Name = {255, 0, 0},
        Distance = {255, 0, 0},
        Tracer = {255, 0, 0},
        Highlight = {Filled = {200, 0, 0}, Outline = {255, 0, 0}}
    },
    Neutral = {
        Name = {255, 255, 0},
        Distance = {255, 255, 0},
        Tracer = {255, 255, 0},
        Highlight = {Filled = {200, 200, 0}, Outline = {255, 255, 0}}
    }
}

-- Determina relação entre jogadores
local function getPlayerRelation(player)
    if not localPlayer.Team or not player.Team then
        return "Neutral"
    end
    return player.Team == localPlayer.Team and "Ally" or "Enemy"
end

-- Atualiza cores baseado no time
local function updatePlayerColors(player)
    if not player.Character then return end
    
    local relation = getPlayerRelation(player)
    local colors = COLORS[relation]
    
    KoltESP:UpdateConfig(player.Character, {
        Name = player.Name .. " [" .. relation .. "]",
        Color = colors
    })
end

local function addPlayerESP(player)
    if player == localPlayer then return end
    
    local function setupCharacter(character)
        if not character then return end
        task.wait(0.1)
        
        local relation = getPlayerRelation(player)
        local colors = COLORS[relation]
        
        KoltESP:Add(character, {
            Name = player.Name .. " [" .. relation .. "]",
            DistancePrefix = "📍 ",
            DistanceSuffix = "m",
            DisplayOrder = relation == "Enemy" and 15 or 10,
            FontSize = 14,
            Font = 2,
            TextOutlineEnabled = true,
            TextOutlineColor = Color3.fromRGB(0, 0, 0),
            Color = colors,
            Types = {
                Tracer = true,
                Name = true,
                Distance = true,
                HighlightFill = true,
                HighlightOutline = true
            },
            -- Prioriza inimigos próximos
            ColorDependency = function(esp, distance, pos3D)
                if relation == "Enemy" and distance < 75 then
                    return Color3.fromRGB(255, 100, 0)  -- Laranja (alerta máximo)
                end
                return nil
            end
        })
    end
    
    if player.Character then
        setupCharacter(player.Character)
    end
    
    local charAdded = player.CharacterAdded:Connect(setupCharacter)
    local charRemoving = player.CharacterRemoving:Connect(function(oldChar)
        KoltESP:Remove(oldChar)
    end)
    
    -- Atualiza ESP quando o time muda
    local teamChanged = player:GetPropertyChangedSignal("Team"):Connect(function()
        updatePlayerColors(player)
    end)
    
    playerConnections[player] = {charAdded, charRemoving, teamChanged}
end

-- Setup inicial
for _, player in pairs(game.Players:GetPlayers()) do
    addPlayerESP(player)
end

game.Players.PlayerAdded:Connect(addPlayerESP)

game.Players.PlayerRemoving:Connect(function(player)
    if playerConnections[player] then
        for _, connection in pairs(playerConnections[player]) do
            connection:Disconnect()
        end
        playerConnections[player] = nil
    end
    if player.Character then
        KoltESP:Remove(player.Character)
    end
end)

-- Atualiza todos quando o time local muda
localPlayer:GetPropertyChangedSignal("Team"):Connect(function()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer then
            updatePlayerColors(player)
        end
    end
end)
```

---

## ESP para Objetos do Mundo

Sistema otimizado para rastrear múltiplos tipos de objetos no workspace.

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configuração global
KoltESP:SetHighlightFolderName("WorldObjectsESP")
KoltESP:SetGlobalTracerOrigin("Bottom")
KoltESP.EspSettings.MaxDistance = 300

local trackedObjects = {}

-- Configurações por tipo de objeto
local OBJECT_CONFIGS = {
    Chest = {
        config = {
            Name = "Baú",
            DistancePrefix = "📦 ",
            DistanceSuffix = "m",
            DisplayOrder = 8,
            FontSize = 13,
            Types = {
                Tracer = false,
                Name = true,
                Distance = true,
                HighlightFill = true,
                HighlightOutline = true
            },
            Color = {
                Name = {255, 215, 0},
                Distance = {255, 215, 0},
                Highlight = {
                    Filled = {255, 215, 0},
                    Outline = {255, 255, 0}
                }
            }
        },
        filter = function(obj)
            return obj:IsA("Model") and obj:FindFirstChild("Lid")
        end
    },
    
    Enemy = {
        config = {
            Name = "Inimigo",
            DistancePrefix = "⚔️ ",
            DistanceSuffix = "m",
            DisplayOrder = 10,
            FontSize = 14,
            Types = {
                Tracer = true,
                Name = true,
                Distance = true,
                HighlightFill = true,
                HighlightOutline = true
            },
            Color = {
                Name = {255, 0, 0},
                Distance = {255, 0, 0},
                Tracer = {255, 0, 0},
                Highlight = {
                    Filled = {200, 0, 0},
                    Outline = {255, 0, 0}
                }
            },
            ColorDependency = function(esp, distance, pos3D)
                if distance < 50 then
                    return Color3.fromRGB(255, 0, 0)
                elseif distance < 100 then
                    return Color3.fromRGB(255, 100, 0)
                end
                return nil
            end
        },
        filter = function(obj)
            return obj:IsA("Model") and obj:FindFirstChild("Humanoid")
        end
    },
    
    Collectible = {
        config = {
            Name = "Item",
            DistancePrefix = "✨ ",
            DistanceSuffix = "m",
            DisplayOrder = 5,
            FontSize = 12,
            Types = {
                Tracer = false,
                Name = true,
                Distance = true,
                HighlightFill = true,
                HighlightOutline = false
            },
            Color = {
                Name = {0, 255, 255},
                Distance = {0, 255, 255},
                Highlight = {
                    Filled = {0, 200, 255},
                    Outline = {0, 255, 255}
                }
            }
        },
        filter = function(obj)
            return obj:IsA("BasePart") and obj.Size.Magnitude < 5
        end
    },
    
    Vehicle = {
        config = {
            Name = "Veículo",
            DistancePrefix = "🚗 ",
            DistanceSuffix = "m",
            DisplayOrder = 6,
            FontSize = 13,
            Types = {
                Tracer = true,
                Name = true,
                Distance = true,
                HighlightFill = true,
                HighlightOutline = true
            },
            Color = {
                Name = {100, 255, 100},
                Distance = {100, 255, 100},
                Tracer = {100, 255, 100},
                Highlight = {
                    Filled = {50, 255, 50},
                    Outline = {0, 255, 0}
                }
            }
        },
        filter = function(obj)
            return obj:IsA("Model") and (obj:FindFirstChild("VehicleSeat") or obj:FindFirstChild("Seat"))
        end
    }
}

-- Adiciona ESP a um objeto específico
local function addObjectESP(object, objectType)
    if trackedObjects[object] then return end
    
    local typeData = OBJECT_CONFIGS[objectType]
    if not typeData then return end
    
    -- Aplica filtro adicional se existir
    if typeData.filter and not typeData.filter(object) then
        return
    end
    
    KoltESP:Add(object, typeData.config)
    trackedObjects[object] = objectType
end

-- Processa objetos existentes
local function scanWorkspace()
    for objectType, _ in pairs(OBJECT_CONFIGS) do
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == objectType or (obj:IsA("Model") and obj.Name:find(objectType)) then
                addObjectESP(obj, objectType)
            end
        end
    end
end

-- Monitora novos objetos
workspace.DescendantAdded:Connect(function(descendant)
    task.wait(0.1)
    
    for objectType, _ in pairs(OBJECT_CONFIGS) do
        if descendant.Name == objectType or (descendant:IsA("Model") and descendant.Name:find(objectType)) then
            addObjectESP(descendant, objectType)
            break
        end
    end
end)

-- Remove ESP quando objeto é destruído
workspace.DescendantRemoving:Connect(function(descendant)
    if trackedObjects[descendant] then
        KoltESP:Remove(descendant)
        trackedObjects[descendant] = nil
    end
end)

-- Executa scan inicial
scanWorkspace()

-- API para adicionar novos tipos dinamicamente
local function registerObjectType(typeName, config, filterFunc)
    OBJECT_CONFIGS[typeName] = {
        config = config,
        filter = filterFunc
    }
    scanWorkspace()
end

-- Exemplo de uso da API
--[[
registerObjectType("CustomItem", {
    Name = "Item Customizado",
    DistancePrefix = "🎁 ",
    DistanceSuffix = "m",
    DisplayOrder = 7,
    Color = {
        Name = {255, 0, 255},
        Highlight = {Filled = {200, 0, 200}, Outline = {255, 0, 255}}
    }
}, function(obj)
    return obj:IsA("BasePart") and obj:GetAttribute("IsCustomItem")
end)
]]
```

---

## Sistema de Cores Dinâmicas

Sistema avançado de gerenciamento de cores com registro persistente e atualização em tempo real.

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configuração
KoltESP:SetHighlightFolderName("DynamicColorESP")
KoltESP.EspSettings.MaxDistance = 400

-- Sistema de cores dinâmicas
local ColorManager = {
    presets = {
        amarelo = Color3.fromRGB(255, 255, 0),
        ciano = Color3.fromRGB(0, 255, 255),
        magenta = Color3.fromRGB(255, 0, 255),
        verde = Color3.fromRGB(0, 255, 0),
        vermelho = Color3.fromRGB(255, 0, 0),
        azul = Color3.fromRGB(0, 0, 255)
    },
    currentPreset = "amarelo",
    registeredObjects = {},
    cycleIndex = 1
}

-- Registra objeto para gerenciamento de cores
function ColorManager:Register(object, initialColor)
    if not object then return end
    
    local color = initialColor or self.presets[self.currentPreset]
    
    KoltESP:AddToRegistry(object, {
        TextColor = color,
        DistanceColor = color,
        TracerColor = color,
        HighlightColor = color
    })
    
    table.insert(self.registeredObjects, object)
end

-- Atualiza cor de todos os objetos registrados
function ColorManager:UpdateAll(newColor)
    for _, obj in pairs(self.registeredObjects) do
        if obj and obj.Parent then
            KoltESP:AddToRegistry(obj, {
                TextColor = newColor,
                DistanceColor = newColor,
                TracerColor = newColor,
                HighlightColor = newColor
            })
        end
    end
end

-- Alterna entre presets de cores
function ColorManager:CyclePreset()
    local presetNames = {}
    for name, _ in pairs(self.presets) do
        table.insert(presetNames, name)
    end
    
    self.cycleIndex = (self.cycleIndex % #presetNames) + 1
    self.currentPreset = presetNames[self.cycleIndex]
    
    local newColor = self.presets[self.currentPreset]
    self:UpdateAll(newColor)
    
    print("🎨 Cor alterada para:", self.currentPreset)
end

-- Cria gradiente de cores baseado na distância
function ColorManager:GetDistanceGradient(distance, maxDist)
    local ratio = math.clamp(distance / maxDist, 0, 1)
    
    -- Verde (perto) -> Amarelo (médio) -> Vermelho (longe)
    if ratio < 0.5 then
        local t = ratio * 2
        return Color3.new(t, 1, 0)  -- Verde para Amarelo
    else
        local t = (ratio - 0.5) * 2
        return Color3.new(1, 1 - t, 0)  -- Amarelo para Vermelho
    end
end

-- Exemplo de uso com objetos
local function setupDynamicESP()
    -- Baús com cores dinâmicas
    for _, chest in pairs(workspace:GetDescendants()) do
        if chest.Name == "Chest" and chest:IsA("Model") then
            KoltESP:Add(chest, {
                Name = "Baú Dinâmico",
                DistancePrefix = "📦 ",
                DistanceSuffix = "m",
                DisplayOrder = 5,
                Types = {
                    Tracer = false,
                    HighlightFill = true,
                    HighlightOutline = true
                },
                Color = {
                    Name = {255, 255, 0},
                    Distance = {255, 255, 0},
                    Highlight = {
                        Filled = {255, 215, 0},
                        Outline = {255, 255, 0}
                    }
                },
                -- Gradiente de cor baseado na distância
                ColorDependency = function(esp, distance, pos3D)
                    return ColorManager:GetDistanceGradient(distance, 300)
                end
            })
            
            ColorManager:Register(chest)
        end
    end
    
    -- Inimigos com sistema de alerta
    for _, enemy in pairs(workspace:GetDescendants()) do
        if enemy.Name == "Enemy" and enemy:IsA("Model") then
            KoltESP:Add(enemy, {
                Name = "Inimigo",
                DistancePrefix = "⚔️ ",
                DistanceSuffix = "m",
                DisplayOrder = 10,
                Types = {
                    Tracer = true,
                    HighlightFill = true,
                    HighlightOutline = true
                },
                Color = {
                    Name = {255, 0, 0},
                    Distance = {255, 0, 0},
                    Tracer = {255, 0, 0},
                    Highlight = {
                        Filled = {200, 0, 0},
                        Outline = {255, 0, 0}
                    }
                },
                ColorDependency = function(esp, distance, pos3D)
                    -- Sistema de 3 níveis de alerta
                    if distance < 30 then
                        return Color3.fromRGB(255, 0, 0)  -- Perigo crítico
                    elseif distance < 60 then
                        return Color3.fromRGB(255, 100, 0)  -- Alerta
                    elseif distance < 100 then
                        return Color3.fromRGB(255, 165, 0)  -- Atenção
                    end
                    return nil
                end
            })
            
            ColorManager:Register(enemy, Color3.fromRGB(255, 0, 0))
        end
    end
end

-- Sistema de alternância automática de cores
task.spawn(function()
    while task.wait(5) do  -- Alterna a cada 5 segundos
        ColorManager:CyclePreset()
    end
end)

-- Sistema manual de troca de cores (bind de tecla)
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.C then  -- Pressione C para trocar cores
        ColorManager:CyclePreset()
    end
end)

-- Executa setup
setupDynamicESP()

-- Monitora novos objetos
workspace.DescendantAdded:Connect(function(descendant)
    task.wait(0.1)
    
    if descendant.Name == "Chest" and descendant:IsA("Model") then
        KoltESP:Add(descendant, {
            Name = "Baú Dinâmico",
            DistancePrefix = "📦 ",
            DistanceSuffix = "m",
            DisplayOrder = 5,
            Color = {Name = {255, 255, 0}, Highlight = {Filled = {255, 215, 0}, Outline = {255, 255, 0}}}
        })
        ColorManager:Register(descendant)
    end
end)
```

---

## ESP Multi-Categoria Completo

Sistema robusto com múltiplas categorias, filtros avançados e gerenciamento inteligente de recursos.

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configuração global otimizada
KoltESP:SetHighlightFolderName("MultiCategoryESP")
KoltESP:SetGlobalHighlightTransparency({Filled = 0.5, Outline = 0.3})
KoltESP:SetGlobalTracerOrigin("Bottom")
KoltESP:SetGlobalTextOutline(true, Color3.fromRGB(0, 0, 0))
KoltESP.EspSettings.MaxDistance = 800
KoltESP.EspSettings.ESPFadeTime = 0.5  -- Fade suave ao sair de vista

-- Sistema de categorias completo
local Categories = {
    -- Categoria: Armas
    Weapons = {
        enabled = true,
        objects = {"Sword", "Gun", "Rifle", "Knife", "Bow"},
        config = {
            Name = "Arma",
            DistancePrefix = "🔫 ",
            DistanceSuffix = "m",
            DisplayOrder = 7,
            FontSize = 12,
            MaxDistance = 150,
            Types = {
                Tracer = false,
                Name = true,
                Distance = true,
                HighlightFill = true,
                HighlightOutline = false
            },
            Color = {
                Name = {255, 100, 100},
                Distance = {255, 100, 100},
                Highlight = {
                    Filled = {255, 50, 50},
                    Outline = {255, 0, 0}
                }
            }
        },
        filter = function(obj)
            return obj:IsA("Tool") or (obj:IsA("Model") and obj:FindFirstChildOfClass("Tool"))
        end
    },
    
    -- Categoria: Veículos
    Vehicles = {
        enabled = true,
        objects = {"Car", "Boat", "Helicopter", "Bike", "Plane"},
        config = {
            Name = "Veículo",
            DistancePrefix = "🚗 ",
            DistanceSuffix = "m",
            DisplayOrder = 6,
            FontSize = 13,
            MaxDistance = 500,
            Types = {
                Tracer = true,
                Name = true,
                Distance = true,
                HighlightFill = true,
                HighlightOutline = true
            },
            Color = {
                Name = {100, 255, 100},
                Distance = {100, 255, 100},
                Tracer = {100, 255, 100},
                Highlight = {
                    Filled = {50, 255, 50},
                    Outline = {0, 255, 0}
                }
            }
        },
        filter = function(obj)
            if not obj:IsA("Model") then return false end
            return obj:FindFirstChildOfClass("VehicleSeat") or 
                   obj:FindFirstChild("Engine") or 
                   obj:FindFirstChild("Throttle")
        end
    },
    
    -- Categoria: Recursos
    Resources = {
        enabled = true,
        objects = {"Tree", "Rock", "Bush", "OreNode", "Mineral"},
        config = {
            Name = "Recurso",
            DistancePrefix = "🌳 ",
            DistanceSuffix = "m",
            DisplayOrder = 3,
            FontSize = 11,
            MaxDistance = 200,
            Types = {
                Tracer = false,
                Name = true,
                Distance = true,
                HighlightFill = false,
                HighlightOutline = true
            },
            Color = {
                Name = {139, 69, 19},
                Distance = {139, 69, 19},
                Highlight = {
                    Filled = {101, 67, 33},
                    Outline = {139, 69, 19}
                }
            }
        },
        filter = function(obj)
            if obj:IsA("Model") then
                return obj:FindFirstChild("Health") or obj:GetAttribute("Resource")
            end
            return obj:IsA("BasePart") and obj.Size.Magnitude > 5
        end
    },
    
    -- Categoria: Itens Valiosos
    Valuables = {
        enabled = true,
        objects = {"Diamond", "Gold", "Treasure", "Gem", "Rare"},
        config = {
            Name = "Valioso",
            DistancePrefix = "💎 ",
            DistanceSuffix = "m",
            DisplayOrder = 9,
            FontSize = 14,
            MaxDistance = 300,
            Types = {
                Tracer = true,
                Name = true,
                Distance = true,
                HighlightFill = true,
                HighlightOutline = true
            },
            Color = {
                Name = {255, 215, 0},
                Distance = {255, 215, 0},
                Tracer = {255, 215, 0},
                Highlight = {
                    Filled = {255, 215, 0},
                    Outline = {255, 255, 0}
                }
            },
            ColorDependency = function(esp, distance, pos3D)
                -- Pulsa entre dourado e branco para itens valiosos
                local pulse = (math.sin(tick() * 3) + 1) / 2
                return Color3.fromRGB(
                    255,
                    215 + (40 * pulse),
                    0 + (255 * pulse)
                )
            end
        },
        filter = function(obj)
            return obj:GetAttribute("Rarity") == "Legendary" or 
                   obj:GetAttribute("IsValuable") == true
        end
    },
    
    -- Categoria: NPCs/Inimigos
    NPCs = {
        enabled = true,
        objects = {"Enemy", "NPC", "Boss", "Monster"},
        config = {
            Name = "NPC",
            DistancePrefix = "👹 ",
            DistanceSuffix = "m",
            DisplayOrder = 12,
            FontSize = 14,
            MaxDistance = 600,
            Types = {
                Tracer = true,
                Name = true,
                Distance = true,
                HighlightFill = true,
                HighlightOutline = true
            },
            Color = {
                Name = {255, 0, 0},
                Distance = {255, 0, 0},
                Tracer = {255, 0, 0},
                Highlight = {
                    Filled = {200, 0, 0},
                    Outline = {255, 0, 0}
                }
            },
            ColorDependency = function(esp, distance, pos3D)
                -- Sistema de alerta em 4 níveis
                if distance < 25 then
                    return Color3.fromRGB(255, 0, 0)  -- Crítico
                elseif distance < 50 then
                    return Color3.fromRGB(255, 50, 0)  -- Perigo
                elseif distance < 100 then
                    return Color3.fromRGB(255, 100, 0)  -- Alerta
                elseif distance < 200 then
                    return Color3.fromRGB(255, 165, 0)  -- Atenção
                end
                return nil
            end
        },
        filter = function(obj)
            ```lua
            if not obj:IsA("Model") then return false end
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if not humanoid then return false end
            -- Ignora jogadores
            return not game.Players:GetPlayerFromCharacter(obj)
        end
    },
    
    -- Categoria: Pontos de Interesse
    POI = {
        enabled = true,
        objects = {"Shop", "Vendor", "Teleporter", "SafeZone", "SpawnPoint"},
        config = {
            Name = "POI",
            DistancePrefix = "📍 ",
            DistanceSuffix = "m",
            DisplayOrder = 4,
            FontSize = 12,
            MaxDistance = 1000,
            Types = {
                Tracer = false,
                Name = true,
                Distance = true,
                HighlightFill = true,
                HighlightOutline = true
            },
            Color = {
                Name = {0, 200, 255},
                Distance = {0, 200, 255},
                Highlight = {
                    Filled = {0, 150, 255},
                    Outline = {0, 200, 255}
                }
            }
        },
        filter = function(obj)
            return obj:GetAttribute("POI") == true or 
                   obj:FindFirstChild("ShopPrompt") or
                   obj:FindFirstChild("InteractPrompt")
        end
    }
}

-- Sistema de rastreamento de objetos
local TrackedObjects = {}
local CategoryStats = {}

-- Inicializa estatísticas
for categoryName, _ in pairs(Categories) do
    CategoryStats[categoryName] = {
        total = 0,
        visible = 0,
        lastUpdate = 0
    }
end

-- Filtragem inteligente de objetos
local function shouldTrackObject(object)
    -- Ignora objetos muito pequenos (otimização)
    if object:IsA("BasePart") then
        if object.Size.Magnitude < 1 then return false end
        if object.Transparency > 0.95 then return false end
    end
    
    -- Ignora objetos em pastas específicas
    local parent = object.Parent
    while parent do
        if parent.Name == "IgnoreESP" or parent.Name == "Effects" then
            return false
        end
        parent = parent.Parent
    end
    
    return true
end

-- Adiciona ESP para objeto de uma categoria
local function addCategoryESP(object, categoryName)
    if TrackedObjects[object] then return end
    if not shouldTrackObject(object) then return end
    
    local category = Categories[categoryName]
    if not category or not category.enabled then return end
    
    -- Aplica filtro customizado
    if category.filter and not category.filter(object) then return end
    
    -- Cria cópia da config para não modificar o original
    local config = {}
    for k, v in pairs(category.config) do
        if type(v) == "table" then
            config[k] = {}
            for k2, v2 in pairs(v) do
                config[k][k2] = v2
            end
        else
            config[k] = v
        end
    end
    
    -- Adiciona informação da categoria ao nome
    config.Name = config.Name .. " (" .. object.Name .. ")"
    
    KoltESP:Add(object, config)
    TrackedObjects[object] = categoryName
    CategoryStats[categoryName].total += 1
end

-- Processa workspace por categoria
local function scanCategory(categoryName)
    local category = Categories[categoryName]
    if not category or not category.enabled then return end
    
    local count = 0
    for _, objectName in ipairs(category.objects) do
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == objectName or (obj.Name:find(objectName) and not TrackedObjects[obj]) then
                addCategoryESP(obj, categoryName)
                count += 1
            end
        end
    end
    
    print(string.format("✅ Categoria '%s': %d objetos encontrados", categoryName, count))
end

-- Scan completo do workspace
local function scanAllCategories()
    print("🔍 Iniciando scan de categorias...")
    for categoryName, _ in pairs(Categories) do
        scanCategory(categoryName)
    end
    print("✅ Scan completo!")
end

-- Monitora novos objetos
workspace.DescendantAdded:Connect(function(descendant)
    task.wait(0.1)
    
    for categoryName, category in pairs(Categories) do
        if not category.enabled then continue end
        
        for _, objectName in ipairs(category.objects) do
            if descendant.Name == objectName or descendant.Name:find(objectName) then
                addCategoryESP(descendant, categoryName)
                break
            end
        end
    end
end)

-- Remove ESP quando objeto é destruído
workspace.DescendantRemoving:Connect(function(descendant)
    if TrackedObjects[descendant] then
        local categoryName = TrackedObjects[descendant]
        KoltESP:Remove(descendant)
        TrackedObjects[descendant] = nil
        
        if CategoryStats[categoryName] then
            CategoryStats[categoryName].total -= 1
        end
    end
end)

-- Sistema de toggle de categorias
local function toggleCategory(categoryName, enabled)
    local category = Categories[categoryName]
    if not category then return end
    
    category.enabled = enabled
    
    if not enabled then
        -- Remove todos ESP da categoria
        for object, catName in pairs(TrackedObjects) do
            if catName == categoryName then
                KoltESP:Remove(object)
                TrackedObjects[object] = nil
            end
        end
        CategoryStats[categoryName].total = 0
        print(string.format("🔴 Categoria '%s' desativada", categoryName))
    else
        -- Re-escaneia categoria
        scanCategory(categoryName)
        print(string.format("🟢 Categoria '%s' ativada", categoryName))
    end
end

-- Sistema de atualização de estatísticas
task.spawn(function()
    while task.wait(2) do
        for categoryName, stats in pairs(CategoryStats) do
            stats.visible = 0
            stats.lastUpdate = tick()
        end
        
        for object, categoryName in pairs(TrackedObjects) do
            if object and object.Parent then
                local esp = KoltESP:GetESP(object)
                if esp and esp.tracerLine and esp.tracerLine.Visible then
                    CategoryStats[categoryName].visible += 1
                end
            end
        end
    end
end)

-- API: Obter estatísticas
local function getStats()
    print("\n📊 Estatísticas de ESP:")
    print(string.rep("=", 50))
    for categoryName, stats in pairs(CategoryStats) do
        print(string.format("  %s: %d total | %d visíveis", 
            categoryName, stats.total, stats.visible))
    end
    print(string.rep("=", 50) .. "\n")
end

-- API: Limpar categoria específica
local function clearCategory(categoryName)
    if not Categories[categoryName] then return end
    
    for object, catName in pairs(TrackedObjects) do
        if catName == categoryName then
            KoltESP:Remove(object)
            TrackedObjects[object] = nil
        end
    end
    CategoryStats[categoryName].total = 0
    print(string.format("🧹 Categoria '%s' limpa", categoryName))
end

-- Controles via teclado
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- F1: Toggle categoria Weapons
    if input.KeyCode == Enum.KeyCode.F1 then
        toggleCategory("Weapons", not Categories.Weapons.enabled)
    
    -- F2: Toggle categoria Vehicles
    elseif input.KeyCode == Enum.KeyCode.F2 then
        toggleCategory("Vehicles", not Categories.Vehicles.enabled)
    
    -- F3: Toggle categoria Resources
    elseif input.KeyCode == Enum.KeyCode.F3 then
        toggleCategory("Resources", not Categories.Resources.enabled)
    
    -- F4: Toggle categoria Valuables
    elseif input.KeyCode == Enum.KeyCode.F4 then
        toggleCategory("Valuables", not Categories.Valuables.enabled)
    
    -- F5: Toggle categoria NPCs
    elseif input.KeyCode == Enum.KeyCode.F5 then
        toggleCategory("NPCs", not Categories.NPCs.enabled)
    
    -- F6: Toggle categoria POI
    elseif input.KeyCode == Enum.KeyCode.F6 then
        toggleCategory("POI", not Categories.POI.enabled)
    
    -- F9: Mostrar estatísticas
    elseif input.KeyCode == Enum.KeyCode.F9 then
        getStats()
    
    -- F10: Rescan completo
    elseif input.KeyCode == Enum.KeyCode.F10 then
        print("🔄 Reescaneando todas as categorias...")
        scanAllCategories()
    
    -- F11: Limpar tudo
    elseif input.KeyCode == Enum.KeyCode.F11 then
        print("🧹 Limpando todos os ESP...")
        KoltESP:Clear()
        TrackedObjects = {}
        for categoryName, _ in pairs(CategoryStats) do
            CategoryStats[categoryName].total = 0
            CategoryStats[categoryName].visible = 0
        end
    
    -- F12: Toggle modo arco-íris
    elseif input.KeyCode == Enum.KeyCode.F12 then
        KoltESP.EspSettings.RainbowMode = not KoltESP.EspSettings.RainbowMode
        print("🌈 Modo Arco-íris:", KoltESP.EspSettings.RainbowMode and "Ativado" or "Desativado")
    end
end)

-- Executa scan inicial
scanAllCategories()

-- Exibe controles
print("\n⌨️ Controles:")
print("  F1-F6: Toggle categorias")
print("  F9: Mostrar estatísticas")
print("  F10: Rescan completo")
print("  F11: Limpar tudo")
print("  F12: Toggle modo arco-íris\n")

-- Retorna API pública
return {
    ToggleCategory = toggleCategory,
    ScanCategory = scanCategory,
    ScanAll = scanAllCategories,
    ClearCategory = clearCategory,
    GetStats = getStats,
    Categories = Categories,
    TrackedObjects = TrackedObjects,
    CategoryStats = CategoryStats
}
```

---

## Sistema de Rastreamento com Filtros

Sistema sofisticado com filtros avançados, priorização e detecção de colisões.

```lua
local KoltESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/KoltESP-Library/refs/heads/main/Library.lua"))()

-- Configuração otimizada
KoltESP:SetHighlightFolderName("AdvancedTrackingESP")
KoltESP:SetGlobalHighlightTransparency({Filled = 0.6, Outline = 0.2})
KoltESP:SetGlobalTracerOrigin("Bottom")
KoltESP.EspSettings.MaxDistance = 1000
KoltESP.EspSettings.ESPFadeTime = 0.3

-- Sistema de filtros avançados
local FilterSystem = {
    -- Filtro por tamanho
    sizeFilter = function(object, minSize, maxSize)
        if not object:IsA("BasePart") then return true end
        local magnitude = object.Size.Magnitude
        return magnitude >= (minSize or 0) and magnitude <= (maxSize or math.huge)
    end,
    
    -- Filtro por transparência
    transparencyFilter = function(object, maxTransparency)
        if not object:IsA("BasePart") then return true end
        return object.Transparency <= (maxTransparency or 0.9)
    end,
    
    -- Filtro por distância
    distanceFilter = function(object, maxDistance)
        local camera = workspace.CurrentCamera
        if not camera then return true end
        
        local position
        if object:IsA("Model") then
            local cf, _ = object:GetBoundingBox()
            position = cf.Position
        elseif object:IsA("BasePart") then
            position = object.Position
        else
            return true
        end
        
        return (camera.CFrame.Position - position).Magnitude <= maxDistance
    end,
    
    -- Filtro por atributo
    attributeFilter = function(object, attributeName, expectedValue)
        local value = object:GetAttribute(attributeName)
        if expectedValue == nil then
            return value ~= nil
        end
        return value == expectedValue
    end,
    
    -- Filtro por hierarquia
    hierarchyFilter = function(object, allowedParents)
        local parent = object.Parent
        while parent do
            if table.find(allowedParents, parent.Name) then
                return true
            end
            parent = parent.Parent
        end
        return false
    end,
    
    -- Filtro por propriedades customizadas
    propertyFilter = function(object, checks)
        for propertyName, expectedValue in pairs(checks) do
            local success, actualValue = pcall(function()
                return object[propertyName]
            end)
            
            if not success or actualValue ~= expectedValue then
                return false
            end
        end
        return true
    end
}

-- Sistema de priorização
local PrioritySystem = {
    levels = {
        Critical = {priority = 100, color = Color3.fromRGB(255, 0, 0)},
        High = {priority = 75, color = Color3.fromRGB(255, 100, 0)},
        Medium = {priority = 50, color = Color3.fromRGB(255, 255, 0)},
        Low = {priority = 25, color = Color3.fromRGB(0, 255, 0)},
        Info = {priority = 10, color = Color3.fromRGB(0, 200, 255)}
    },
    
    -- Calcula prioridade baseado em múltiplos fatores
    calculate = function(object, distance, health, rarity)
        local score = 0
        
        -- Fator distância (quanto mais perto, maior prioridade)
        if distance < 50 then
            score += 40
        elseif distance < 100 then
            score += 30
        elseif distance < 200 then
            score += 20
        else
            score += 10
        end
        
        -- Fator saúde (inimigos com pouca vida são prioridade)
        if health then
            if health < 25 then
                score += 30
            elseif health < 50 then
                score += 20
            else
                score += 10
            end
        end
        
        -- Fator raridade
        if rarity then
            if rarity == "Legendary" then
                score += 30
            elseif rarity == "Epic" then
                score += 20
            elseif rarity == "Rare" then
                score += 10
            end
        end
        
        return score
    end,
    
    -- Retorna nível de prioridade
    getLevel = function(score)
        if score >= 80 then return "Critical"
        elseif score >= 60 then return "High"
        elseif score >= 40 then return "Medium"
        elseif score >= 20 then return "Low"
        else return "Info"
        end
    end
}

-- Configuração de rastreamento avançado
local TrackingConfig = {
    -- Inimigos com detecção de saúde
    Enemies = {
        enabled = true,
        filters = {
            function(obj) return FilterSystem.sizeFilter(obj, 3, 50) end,
            function(obj) return FilterSystem.transparencyFilter(obj, 0.5) end,
            function(obj)
                if not obj:IsA("Model") then return false end
                local humanoid = obj:FindFirstChildOfClass("Humanoid")
                return humanoid ~= nil and not game.Players:GetPlayerFromCharacter(obj)
            end
        },
        setup = function(object)
            local humanoid = object:FindFirstChildOfClass("Humanoid")
            local health = humanoid and (humanoid.Health / humanoid.MaxHealth * 100) or 100
            local distance = (workspace.CurrentCamera.CFrame.Position - object:GetPivot().Position).Magnitude
            
            local priorityScore = PrioritySystem.calculate(object, distance, health)
            local priorityLevel = PrioritySystem.getLevel(priorityScore)
            local levelData = PrioritySystem.levels[priorityLevel]
            
            KoltESP:Add(object, {
                Name = string.format("%s [❤️%.0f%%]", object.Name, health),
                DistancePrefix = "⚔️ ",
                DistanceSuffix = "m",
                DisplayOrder = 10 + levelData.priority,
                FontSize = 13,
                MaxDistance = 500,
                Collision = true,  -- Mostra todas as colisões
                Types = {
                    Tracer = true,
                    Name = true,
                    Distance = true,
                    HighlightFill = true,
                    HighlightOutline = true
                },
                Color = {
                    Name = {levelData.color.R * 255, levelData.color.G * 255, levelData.color.B * 255},
                    Distance = {levelData.color.R * 255, levelData.color.G * 255, levelData.color.B * 255},
                    Tracer = {levelData.color.R * 255, levelData.color.G * 255, levelData.color.B * 255},
                    Highlight = {
                        Filled = {levelData.color.R * 200, levelData.color.G * 200, levelData.color.B * 200},
                        Outline = {levelData.color.R * 255, levelData.color.G * 255, levelData.color.B * 255}
                    }
                },
                ColorDependency = function(esp, dist, pos3D)
                    local hum = object:FindFirstChildOfClass("Humanoid")
                    if not hum then return nil end
                    
                    local healthPercent = hum.Health / hum.MaxHealth
                    
                    -- Verde -> Amarelo -> Vermelho baseado na saúde
                    if healthPercent > 0.6 then
                        return Color3.fromRGB(0, 255, 0)
                    elseif healthPercent > 0.3 then
                        return Color3.fromRGB(255, 255, 0)
                    else
                        return Color3.fromRGB(255, 0, 0)
                    end
                end
            })
            
            -- Atualiza nome quando saúde muda
            if humanoid then
                humanoid.HealthChanged:Connect(function()
                    local newHealth = (humanoid.Health / humanoid.MaxHealth * 100)
                    KoltESP:SetName(object, string.format("%s [❤️%.0f%%]", object.Name, newHealth))
                end)
            end
        end
    },
    
    -- Itens raros com sistema de raridade
    RareItems = {
        enabled = true,
        filters = {
            function(obj) return FilterSystem.sizeFilter(obj, 1, 20) end,
            function(obj) return FilterSystem.attributeFilter(obj, "Rarity") end
        },
        setup = function(object)
            local rarity = object:GetAttribute("Rarity") or "Common"
            local distance = (workspace.CurrentCamera.CFrame.Position - (object:IsA("Model") and object:GetPivot().Position or object.Position)).Magnitude
            
            local priorityScore = PrioritySystem.calculate(object, distance, nil, rarity)
            local priorityLevel = PrioritySystem.getLevel(priorityScore)
            local levelData = PrioritySystem.levels[priorityLevel]
            
            local rarityColors = {
                Common = {200, 200, 200},
                Uncommon = {100, 255, 100},
                Rare = {0, 150, 255},
                Epic = {200, 0, 255},
                Legendary = {255, 215, 0}
            }
            
            local color = rarityColors[rarity] or {255, 255, 255}
            
            KoltESP:Add(object, {
                Name = string.format("%s [%s]", object.Name, rarity),
                DistancePrefix = "✨ ",
                DistanceSuffix = "m",
                DisplayOrder = 5 + levelData.priority,
                FontSize = rarity == "Legendary" and 15 or 12,
                MaxDistance = 400,
                Types = {
                    Tracer = rarity == "Legendary" or rarity == "Epic",
                    Name = true,
                    Distance = true,
                    HighlightFill = true,
                    HighlightOutline = true
                },
                Color = {
                    Name = color,
                    Distance = color,
                    Tracer = color,
                    Highlight = {
                        Filled = {color[1] * 0.8, color[2] * 0.8, color[3] * 0.8},
                        Outline = color
                    }
                },
                ColorDependency = rarity == "Legendary" and function(esp, dist, pos3D)
                    -- Efeito pulsante para lendários
                    local pulse = (math.sin(tick() * 4) + 1) / 2
                    return Color3.fromRGB(
                        255,
                        215 + (40 * pulse),
                        0 + (100 * pulse)
                    )
                end or nil
            })
        end
    },
    
    -- Veículos com detecção de ocupação
    Vehicles = {
        enabled = true,
        filters = {
            function(obj)
                if not obj:IsA("Model") then return false end
                return obj:FindFirstChildOfClass("VehicleSeat") ~= nil
            end,
            function(obj) return FilterSystem.distanceFilter(obj, 800) end
        },
        setup = function(object)
            local seat = object:FindFirstChildOfClass("VehicleSeat")
            local occupied = seat and seat.Occupant ~= nil
            
            KoltESP:Add(object, {
                Name = object.Name .. (occupied and " [Ocupado]" or " [Livre]"),
                DistancePrefix = "🚗 ",
                DistanceSuffix = "m",
                DisplayOrder = 6,
                FontSize = 13,
                MaxDistance = 800,
                Types = {
                    Tracer = not occupied,
                    Name = true,
                    Distance = true,
                    HighlightFill = true,
                    HighlightOutline = not occupied
                },
                Color = occupied and {
                    Name = {150, 150, 150},
                    Distance = {150, 150, 150},
                    Highlight = {Filled = {100, 100, 100}, Outline = {150, 150, 150}}
                } or {
                    Name = {100, 255, 100},
                    Distance = {100, 255, 100},
                    Tracer = {100, 255, 100},
                    Highlight = {Filled = {50, 255, 50}, Outline = {0, 255, 0}}
                }
            })
            
            -- Monitora mudança de ocupação
            if seat then
                seat:GetPropertyChangedSignal("Occupant"):Connect(function()
                    local isOccupied = seat.Occupant ~= nil
                    KoltESP:UpdateConfig(object, {
                        Name = object.Name .. (isOccupied and " [Ocupado]" or " [Livre]"),
                        Types = {
                            Tracer = not isOccupied,
                            HighlightOutline = not isOccupied
                        },
                        Color = isOccupied and {
                            Name = {150, 150, 150},
                            Highlight = {Filled = {100, 100, 100}, Outline = {150, 150, 150}}
                        } or {
                            Name = {100, 255, 100},
                            Tracer = {100, 255, 100},
                            Highlight = {Filled = {50, 255, 50}, Outline = {0, 255, 0}}
                        }
                    })
                end)
            end
        end
    }
}

-- Processa objetos com sistema de filtros
local function processObject(object, configName)
    local config = TrackingConfig[configName]
    if not config or not config.enabled then return false end
    
    -- Aplica todos os filtros
    for _, filter in ipairs(config.filters) do
        if not filter(object) then
            return false
        end
    end
    
    -- Setup do ESP
    config.setup(object)
    return true
end

-- Scan do workspace
local function scanWorkspace()
    print("🔍 Iniciando scan avançado...")
    local counts = {}
    
    for configName, config in pairs(TrackingConfig) do
        if config.enabled then
            counts[configName] = 0
        end
    end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        for configName, _ in pairs(TrackingConfig) do
            if processObject(obj, configName) then
                counts[configName] += 1
                break
            end
        end
    end
    
    print("\n📊 Resultados do scan:")
    for configName, count in pairs(counts) do
        print(string.format("  %s: %d objetos", configName, count))
    end
    print()
end

-- Monitora novos objetos
workspace.DescendantAdded:Connect(function(descendant)
    task.wait(0.1)
    for configName, _ in pairs(TrackingConfig) do
        if processObject(descendant, configName) then
            break
        end
    end
end)

-- Executa scan inicial
scanWorkspace()

-- Controles de teclado
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.R then
        print("🔄 Reescaneando...")
        KoltESP:Clear()
        scanWorkspace()
    end
end)

print("⌨️ Pressione R para rescanear")
```

---

## Dicas e Boas Práticas

### 🎯 Performance e Otimização

**1. Gerenciamento de Distância**
```lua
-- Evite valores muito altos de MaxDistance
KoltESP.EspSettings.MaxDistance = 500  -- ✅ Bom
KoltESP.EspSettings.MaxDistance = 10000  -- ❌ Pode causar lag

-- Use MinDistance para ignorar objetos muito próximos
KoltESP.EspSettings.MinDistance = 10
```

**2. Filtragem Inteligente**
```lua
-- Sempre filtre objetos desnecessários ANTES de adicionar ESP
local function shouldTrack(obj)
    -- Ignora objetos invisíveis
    if obj:IsA("BasePart") and obj.Transparency > 0.9 then
        return false
    end
    
    -- Ignora objetos muito pequenos
    if obj:IsA("BasePart") and obj.Size.Magnitude < 2 then
        return false
    end
    
    return true
end
```

**3. Uso de Collision**
```lua
-- Use Collision=true apenas quando necessário
KoltESP:Add(enemy, {
    Collision = true  -- Mostra TODAS as partes (mais pesado)
})

-- Por padrão, use Collision=false
KoltESP:Add(chest, {
    Collision = false  -- Apenas partes visíveis (mais leve)
})
```

### 🎨 Organização de Código

**1. Separação por Módulos**
```lua
-- Crie módulos separados para diferentes sistemas
local PlayerESP = {}
local ItemESP = {}
local VehicleESP = {}

-- Cada módulo tem suas próprias funções
function PlayerESP:Init()
    -- Setup de jogadores
end

function ItemESP:Init()
    -- Setup de itens
end
```

**2. Configurações Centralizadas**
```lua
-- Mantenha todas as configurações em um lugar
local CONFIG = {
    PLAYER_MAX_DIST = 500,
    ITEM_MAX_DIST = 200,
    VEHICLE_MAX_DIST = 800,
    
    COLORS = {
        ALLY = Color3.fromRGB(0, 255, 0),
        ENEMY = Color3.fromRGB(255, 0, 0),
        NEUTRAL = Color3.fromRGB(255, 255, 0)
    }
}
```

**3. Limpeza de Recursos**
```lua
-- Sempre limpe conexões e ESPs ao remover objetos
local connections = {}

local function cleanup()
    for _, conn in pairs(connections) do
        conn:Disconnect()
    end
    connections = {}
    KoltESP:Clear()
end
```

### 🎮 UX e Usabilidade

**1. Feedback Visual**
```lua
-- Use DisplayOrder para priorizar elementos importantes
KoltESP:Add(boss, {
    DisplayOrder = 20  -- Renderiza na frente
})

KoltESP:Add(resource, {
    DisplayOrder = 5  -- Renderiza atrás
})
```

**2. Sistema de Cores Intuitivo**
```lua
-- Verde = Seguro/Aliado
-- Amarelo = Neutro/Atenção
-- Laranja = Alerta
-- Vermelho = Perigo/Inimigo

ColorDependency = function(esp, distance, pos3D)
    if distance < 30 then return Color3.fromRGB(255, 0, 0)
    elseif distance < 60 then return Color3.fromRGB(255, 165, 0)
    elseif distance < 100 then return Color3.fromRGB(255, 255, 0)
    end
    return Color3.fromRGB(0, 255, 0)
end
```

**3. Informações Relevantes**
```lua
-- Adicione emojis e informações úteis
DistancePrefix = "⚔️ "  -- Identifica tipo visual
Name = "Boss [❤️75%]"  -- Mostra saúde
DistanceSuffix = "m"  -- Unidade clara
```

### 🔧 APIs Úteis

**1. Atualização Dinâmica**
```lua
-- Use UpdateConfig para mudanças em tempo real
KoltESP:UpdateConfig(target, {
    Name = "Novo Nome",
    Color = {
        Name = {255, 0, 0},
        Distance = {255, 0, 0}
    }
})

-- Use Readjustment para trocar o alvo mantendo a mesma config
KoltESP:Readjustment(newTarget, oldTarget, newConfig)
```

**2. Gerenciamento de Cores**
```lua
-- SetColor: Define cor única para todos os elementos
KoltESP:SetColor(target, Color3.fromRGB(255, 0, 0))

-- AddToRegistry: Registra cores dinâmicas
KoltESP:AddToRegistry(target, {
    TextColor = dynamicColor,
    HighlightColor = dynamicColor
})

-- Atualize a variável e reaplique ao registro
dynamicColor = Color3.fromRGB(0, 255, 255)
KoltESP:AddToRegistry(target, {
    TextColor = dynamicColor
})
```

**3. Controle de Visibilidade**
```lua
-- Desabilita globalmente sem remover ESPs
KoltESP:Disable()

-- Reabilita
KoltESP:Enable()

-- Toggle de tipos específicos
KoltESP:SetGlobalESPType("Tracer", false)  -- Desativa tracers
KoltESP:SetGlobalESPType("Name", false)    -- Desativa nomes
KoltESP:SetGlobalESPType("Distance", false) -- Desativa distâncias
```

### 🚀 Recursos Avançados

**1. Sistema de Fade**
```lua
-- Fade suave quando objetos saem de vista
KoltESP.EspSettings.ESPFadeTime = 0.5  -- 0.5 segundos de fade

-- Desabilita fade (transição instantânea)
KoltESP.EspSettings.ESPFadeTime = 0
```

**2. Modo Arco-íris**
```lua
-- Ativa modo arco-íris global
KoltESP:SetGlobalRainbow(true)

-- Todas as cores ficarão em ciclo automático
-- Útil para destaque visual ou estética
```

**3. Configuração de Setas (Arrows)**
```lua
-- Customiza setas para objetos fora da tela
KoltESP:SetGlobalArrowImage(11552476728)  -- ID da imagem
KoltESP:SetGlobalArrowRotation(270)       -- Offset de rotação
KoltESP:SetGlobalArrowSize(50)            -- Tamanho em pixels
KoltESP:SetGlobalArrowRadius(100)         -- Distância do centro
```

**4. Origem de Tracers**
```lua
-- Define de onde as linhas de tracer saem
KoltESP:SetGlobalTracerOrigin("Top")     -- Topo da tela
KoltESP:SetGlobalTracerOrigin("Center")  -- Centro da tela
KoltESP:SetGlobalTracerOrigin("Bottom")  -- Base da tela (padrão)
KoltESP:SetGlobalTracerOrigin("Left")    -- Esquerda
KoltESP:SetGlobalTracerOrigin("Right")   -- Direita
```

### 📊 Debugging e Monitoramento

**1. Sistema de Logs**
```lua
-- Implemente logging para debug
local function logESP(action, target, details)
    local timestamp = os.date("%H:%M:%S")
    print(string.format("[%s] ESP %s: %s - %s", 
        timestamp, 
        action, 
        target.Name, 
        details or ""))
end

-- Use nos pontos críticos
KoltESP:Add(target, config)
logESP("ADD", target, "Configurado com sucesso")

KoltESP:Remove(target)
logESP("REMOVE", target, "Removido da lista")
```

**2. Monitoramento de Performance**
```lua
-- Conte objetos ativos
local function getActiveESPCount()
    return #KoltESP.Objects
end

-- Monitore periodicamente
task.spawn(function()
    while task.wait(5) do
        local count = getActiveESPCount()
        if count > 100 then
            warn("⚠️ Muitos ESPs ativos:", count)
        end
    end
end)
```

**3. Validação de Objetos**
```lua
-- Valide objetos antes de adicionar ESP
local function validateObject(obj)
    if not obj then
        warn("Objeto é nil")
        return false
    end
    
    if not obj.Parent then
        warn("Objeto sem parent:", obj.Name)
        return false
    end
    
    if not (obj:IsA("Model") or obj:IsA("BasePart")) then
        warn("Tipo de objeto inválido:", obj.ClassName)
        return false
    end
    
    return true
end

-- Use antes de adicionar
if validateObject(target) then
    KoltESP:Add(target, config)
end
```

### 🎓 Padrões Recomendados

**1. Estrutura de Projeto Completo**
```lua
-- ==========================================
-- CONFIGURAÇÃO INICIAL
-- ==========================================
local KoltESP = loadstring(game:HttpGet("..."))()

KoltESP:SetHighlightFolderName("MyGameESP")
KoltESP:SetGlobalHighlightTransparency({Filled = 0.6, Outline = 0.3})
KoltESP:SetGlobalTracerOrigin("Bottom")
KoltESP.EspSettings.MaxDistance = 500
KoltESP.EspSettings.ESPFadeTime = 0.3

-- ==========================================
-- CONSTANTES
-- ==========================================
local COLORS = {
    ENEMY = Color3.fromRGB(255, 0, 0),
    ALLY = Color3.fromRGB(0, 255, 0),
    NEUTRAL = Color3.fromRGB(255, 255, 0)
}

local DISTANCES = {
    PLAYERS = 500,
    ITEMS = 200,
    VEHICLES = 800
}

-- ==========================================
-- ESTADO GLOBAL
-- ==========================================
local State = {
    trackedObjects = {},
    connections = {},
    enabled = true
}

-- ==========================================
-- FUNÇÕES AUXILIARES
-- ==========================================
local function validateObject(obj)
    -- Validação
end

local function shouldTrack(obj)
    -- Filtragem
end

local function cleanup()
    -- Limpeza
end

-- ==========================================
-- SISTEMAS PRINCIPAIS
-- ==========================================
local PlayerESP = {}
function PlayerESP:Init()
    -- Implementação
end

local ItemESP = {}
function ItemESP:Init()
    -- Implementação
end

-- ==========================================
-- EVENTOS
-- ==========================================
workspace.DescendantAdded:Connect(function(obj)
    -- Handler
end)

game.Players.PlayerAdded:Connect(function(player)
    -- Handler
end)

-- ==========================================
-- CONTROLES
-- ==========================================
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    -- Keybinds
end)

-- ==========================================
-- INICIALIZAÇÃO
-- ==========================================
PlayerESP:Init()
ItemESP:Init()

print("✅ ESP System loaded successfully")
```

**2. Sistema de Cache**
```lua
-- Cache para evitar recálculos desnecessários
local Cache = {
    distances = {},
    colors = {},
    lastUpdate = {}
}

local CACHE_LIFETIME = 0.5  -- Segundos

local function getCachedDistance(object)
    local now = tick()
    local cached = Cache.distances[object]
    
    if cached and (now - Cache.lastUpdate[object]) < CACHE_LIFETIME then
        return cached
    end
    
    -- Recalcula
    local camera = workspace.CurrentCamera
    local position = object:IsA("Model") and object:GetPivot().Position or object.Position
    local distance = (camera.CFrame.Position - position).Magnitude
    
    Cache.distances[object] = distance
    Cache.lastUpdate[object] = now
    
    return distance
end
```

**3. Sistema de Eventos Customizados**
```lua
-- Crie seu próprio sistema de eventos
local ESPEvents = {
    listeners = {}
}

function ESPEvents:On(eventName, callback)
    if not self.listeners[eventName] then
        self.listeners[eventName] = {}
    end
    table.insert(self.listeners[eventName], callback)
end

function ESPEvents:Fire(eventName, ...)
    if not self.listeners[eventName] then return end
    for _, callback in ipairs(self.listeners[eventName]) do
        task.spawn(callback, ...)
    end
end

-- Use para criar hooks
ESPEvents:On("ESP_Added", function(target, config)
    print("✅ ESP adicionado:", target.Name)
end)

ESPEvents:On("ESP_Removed", function(target)
    print("❌ ESP removido:", target.Name)
end)

-- Dispare nos pontos apropriados
KoltESP:Add(target, config)
ESPEvents:Fire("ESP_Added", target, config)
```

### ⚡ Otimizações Extremas

**1. Pooling de Objetos**
```lua
-- Reutilize ESPs ao invés de criar novos
local ESPPool = {
    available = {},
    active = {}
}

function ESPPool:Get(target, config)
    local esp = table.remove(self.available)
    
    if esp then
        -- Reutiliza ESP existente
        KoltESP:Readjustment(target, esp.Target, config)
    else
        -- Cria novo ESP
        KoltESP:Add(target, config)
    end
    
    self.active[target] = true
end

function ESPPool:Return(target)
    if not self.active[target] then return end
    
    table.insert(self.available, {Target = target})
    self.active[target] = nil
end
```

**2. Throttling de Updates**
```lua
-- Limite atualizações frequentes
local lastUpdate = {}
local UPDATE_INTERVAL = 0.1  -- Segundos

local function throttledUpdate(target, updateFunc)
    local now = tick()
    
    if not lastUpdate[target] or (now - lastUpdate[target]) >= UPDATE_INTERVAL then
        updateFunc()
        lastUpdate[target] = now
    end
end

-- Uso
throttledUpdate(enemy, function()
    local health = enemy.Humanoid.Health
    KoltESP:SetName(enemy, string.format("Enemy [❤️%.0f%%]", health))
end)
```

**3. Spatial Partitioning**
```lua
-- Divida o mundo em regiões para processamento eficiente
local Regions = {}
local REGION_SIZE = 100

local function getRegionKey(position)
    local x = math.floor(position.X / REGION_SIZE)
    local y = math.floor(position.Y / REGION_SIZE)
    local z = math.floor(position.Z / REGION_SIZE)
    return string.format("%d,%d,%d", x, y, z)
end

local function updateNearbyRegions()
    local camera = workspace.CurrentCamera
    local playerRegion = getRegionKey(camera.CFrame.Position)
    
    -- Processa apenas regiões próximas
    for regionKey, objects in pairs(Regions) do
        if isRegionNearby(regionKey, playerRegion) then
            for _, obj in ipairs(objects) do
                -- Processa objeto
            end
        end
    end
end
```

### 🎯 Casos de Uso Específicos

**1. ESP para Boss Fights**
```lua
local function setupBossESP(boss)
    local humanoid = boss:FindFirstChildOfClass("Humanoid")
    
    KoltESP:Add(boss, {
        Name = "🔥 BOSS 🔥",
        DistancePrefix = "⚔️ ",
        DistanceSuffix = "m",
        DisplayOrder = 100,  -- Máxima prioridade
        FontSize = 18,
        MaxDistance = 1000,
        Collision = true,
        Types = {
            Tracer = true,
            Name = true,
            Distance = true,
            HighlightFill = true,
            HighlightOutline = true
        },
        Color = {
            Name = {255, 0, 0},
            Distance = {255, 0, 0},
            Tracer = {255, 0, 0},
            Highlight = {Filled = {255, 0, 0}, Outline = {255, 100, 0}}
        },
        ColorDependency = function(esp, distance, pos3D)
            -- Efeito pulsante vermelho
            local pulse = (math.sin(tick() * 5) + 1) / 2
            return Color3.fromRGB(255, 0 + (100 * pulse), 0)
        end
    })
    
    -- Atualiza fase do boss
    humanoid.HealthChanged:Connect(function()
        local healthPercent = (humanoid.Health / humanoid.MaxHealth) * 100
        local phase = healthPercent > 66 and "Fase 1" or healthPercent > 33 and "Fase 2" or "Fase 3"
        KoltESP:SetName(boss, string.format("🔥 BOSS [%s - ❤️%.0f%%]", phase, healthPercent))
    end)
end
```

**2. ESP para Loot Drops**
```lua
local function setupLootESP(loot)
    local rarity = loot:GetAttribute("Rarity") or "Common"
    local value = loot:GetAttribute("Value") or 0
    
    -- Aumenta tamanho e prioridade baseado no valor
    local fontSize = 12 + math.min(value / 100, 6)
    local displayOrder = 5 + math.min(value / 50, 10)
    
    KoltESP:Add(loot, {
        Name = string.format("%s ($%d)", loot.Name, value),
        DistancePrefix = "💰 ",
        DistanceSuffix = "m",
        DisplayOrder = displayOrder,
        FontSize = fontSize,
        MaxDistance = 300,
        Types = {
            Tracer = value > 500,  -- Tracer apenas para itens valiosos
            Name = true,
            Distance = true,
            HighlightFill = true,
            HighlightOutline = true
        },
        Color = {
            Name = {255, 215, 0},
            Distance = {255, 215, 0},
            Tracer = {255, 215, 0},
            Highlight = {Filled = {255, 215, 0}, Outline = {255, 255, 0}}
        },
        ColorDependency = value > 1000 and function(esp, distance, pos3D)
            -- Efeito especial para itens muito valiosos
            local pulse = (math.sin(tick() * 6) + 1) / 2
            return Color3.fromRGB(
                255,
                215 + (40 * pulse),
                0 + (150 * pulse)
            )
        end or nil
    })
    
    -- Remove ESP quando coletado
    loot.AncestryChanged:Connect(function()
        if not loot.Parent then
            KoltESP:Remove(loot)
        end
    end)
end
```

**3. ESP para Zonas de Perigo**
```lua
local function setupDangerZoneESP(zone)
    KoltESP:Add(zone, {
        Name = "⚠️ ZONA DE PERIGO ⚠️",
        DistancePrefix = "",
        DistanceSuffix = "m",
        DisplayOrder = 15,
        FontSize = 16,
        MaxDistance = 500,
        Types = {
            Tracer = true,
            Name = true,
            Distance = true,
            HighlightFill = true,
            HighlightOutline = true
        },
        Color = {
            Name = {255, 0, 0},
            Distance = {255, 0, 0},
            Tracer = {255, 0, 0},
            Highlight = {Filled = {255, 0, 0}, Outline = {255, 100, 0}}
        },
        ColorDependency = function(esp, distance, pos3D)
            -- Alerta intensifica quando próximo
            if distance < 50 then
                local flash = math.sin(tick() * 10) > 0
                return flash and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 0)
            elseif distance < 100 then
                return Color3.fromRGB(255, 100, 0)
            end
            return Color3.fromRGB(255, 165, 0)
        end
    })
end
```

### 📝 Checklist de Implementação

Antes de finalizar seu sistema de ESP, verifique:

- [ ] **Performance**
  - [ ] MaxDistance configurado apropriadamente
  - [ ] Filtros aplicados antes de adicionar ESP
  - [ ] Sistema de limpeza de recursos implementado
  - [ ] Cache usado para operações custosas

- [ ] **Organização**
  - [ ] Código separado em módulos lógicos
  - [ ] Configurações centralizadas
  - [ ] Nomes de variáveis descritivos
  - [ ] Comentários em partes complexas

- [ ] **Funcionalidade**
  - [ ] ESPs removidos quando objetos são destruídos
  - [ ] Conexões desconectadas ao limpar
  - [ ] Eventos de atualização funcionando
  - [ ] Sistema de priorização implementado

- [ ] **UX**
  - [ ] Cores intuitivas e consistentes
  - [ ] Informações relevantes exibidas
  - [ ] Controles de teclado documentados
  - [ ] Feedback visual apropriado

- [ ] **Segurança**
  - [ ] Validação de objetos antes de usar
  - [ ] Try-catch em operações críticas
  - [ ] Verificação de nil/parent
  - [ ] Logs de erro implementados

---

## 📚 Recursos Adicionais

### Funções Úteis da Library

```lua
-- Gestão básica
KoltESP:Add(target, config)           -- Adiciona ESP
KoltESP:Remove(target)                -- Remove ESP
KoltESP:Clear()                       -- Remove todos ESPs
KoltESP:GetESP(target)                -- Obtém ESP de um target

-- Atualização
KoltESP:UpdateConfig(target, config)  -- Atualiza config
KoltESP:Readjustment(new, old, cfg)   -- Troca target

-- APIs de cor
KoltESP:SetColor(target, color)       -- Define cor única
KoltESP:SetName(target, name)         -- Define nome
KoltESP:AddToRegistry(target, colors) -- Registra cores dinâmicas

-- Configurações globais
KoltESP:Toggle(true)                      -- Ativa/Desativa ESP
KoltESP:SetGlobalTracerOrigin(origin) -- Define origem tracers
KoltESP:SetGlobalRainbow(bool)        -- Ativa modo arco-íris
KoltESP:SetGlobalOpacity(value)       -- Define opacidade
KoltESP:SetGlobalFontSize(size)       -- Define tamanho fonte
KoltESP:SetGlobalLineThickness(thick) -- Define espessura linha
KoltESP:SetGlobalFont(font)           -- Define fonte (0-3)
KoltESP:SetGlobalTextOutline(bool, color) -- Outline de texto

-- Highlights
KoltESP:SetHighlightFolderName(name)  -- Nome da pasta
KoltESP:SetGlobalHighlightTransparency(trans) -- Transparências

-- Arrows
KoltESP:SetGlobalArrowImage(id)       -- Imagem da seta
KoltESP:SetGlobalArrowRotation(deg)   -- Rotação offset
KoltESP:SetGlobalArrowSize(size)      -- Tamanho
KoltESP:SetGlobalArrowRadius(radius)  -- Raio do centro
```

### Configurações Disponíveis

```lua
-- EspSettings
KoltESP.EspSettings = {
    Enabled = true,              -- ESP ativo
    MaxDistance = math.huge,     -- Distância máxima
    MinDistance = 0,             -- Distância mínima
    TracerOrigin = "Bottom",     -- Origem tracers
    Tracer = true,               -- Mostrar tracers
    Name = true,                 -- Mostrar nomes
    Distance = true,             -- Mostrar distância
    Outline = true,              -- Highlight outline
    Filled = true,               -- Highlight preenchido
    Arrow = true,                -- Setas fora de tela
    LineThickness = 4,           -- Espessura linhas
    Opacity = 0.8,               -- Opacidade
    FontSize = 14,               -- Tamanho fonte
    Font = 3,                    -- Tipo fonte (0-3)
    TextOutlineEnabled = true,   -- Outline texto
    TextOutlineColor = Color3.fromRGB(0,0,0),
    ESPFadeTime = 0,             -- Tempo de fade
    RainbowMode = false,         -- Modo arco-íris
}
```
