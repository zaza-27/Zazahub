--// Enhanced Universal Hub 2026 Corregido
local Services = {
    RS = game:GetService("RunService"),
    PL = game:GetService("Players"),
    UIS = game:GetService("UserInputService"),
    WS = game:GetService("Workspace"),
}

local lp = Services.PL.LocalPlayer
local cam = Services.WS.CurrentCamera

-- ====================== --
-- WHITELIST (Mantenida)
-- ====================== --
local whitelistedUsers = { "CXCHXRRX_27", "Rarita_RmC4" }
local function hasPermission()
    for _, name in ipairs(whitelistedUsers) do if lp.Name == name then return true end end
    return false
end
if not hasPermission() then lp:Kick("No autorizado") return end

-- ====================== --
-- CONFIGURACIÓN
-- ====================== --
local cfg = {
    KillAura = false,
    AuraRange = 20,
    HitboxSize = 15,
    ShowHitbox = false,
    Aimbot = false,
    Speed = false,
    SpeedValue = 30
}

-- ====================== --
-- LÓGICA DE ATAQUE REAL
-- ====================== --
local function GetAttackRemote()
    -- Intenta encontrar cualquier Remote que parezca de combate
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            if v.Name:lower():find("hit") or v.Name:lower():find("attack") or v.Name:lower():find("swing") then
                return v
            end
        end
    end
    return nil
end

local function Atacar(target)
    if not target or not target.Character then return end
    local tool = lp.Character:FindFirstChildOfClass("Tool")
    
    -- 1. Intentar usar la herramienta (Simular Click)
    if tool then
        tool:Activate()
    end

    -- 2. Intentar disparar remotos encontrados automáticamente
    local remote = GetAttackRemote()
    if remote then
        local args = {
            [1] = target.Character:FindFirstChild("Humanoid"),
            [2] = target.Character:FindFirstChild("HumanoidRootPart").Position
        }
        if remote:IsA("RemoteEvent") then
            remote:FireServer(unpack(args))
        else
            pcall(function() remote:InvokeServer(unpack(args)) end)
        end
    end
end

-- ====================== --
-- UI (RAYFIELD)
-- ====================== --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({ Name = "Enhanced Hub V2", LoadingTitle = "Cargando Fix..." })

local CombatTab = Window:CreateTab("Combat")

CombatTab:CreateToggle({
    Name = "Kill Aura Agresivo",
    CurrentValue = false,
    Callback = function(Value)
        cfg.KillAura = Value
    end,
})

CombatTab:CreateSlider({
    Name = "Rango de Ataque",
    Range = {5, 50}, Increment = 1, CurrentValue = 20,
    Callback = function(Value) cfg.AuraRange = Value end,
})

-- ====================== --
-- BUCLE PRINCIPAL (HEARTBEAT)
-- ====================== --
Services.RS.Heartbeat:Connect(function()
    if not cfg.KillAura or not lp.Character then return end
    
    local myHRP = lp.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    for _, v in pairs(Services.PL:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("Humanoid") then
            local enemyHRP = v.Character:FindFirstChild("HumanoidRootPart")
            local enemyHum = v.Character:FindFirstChild("Humanoid")
            
            if enemyHRP and enemyHum.Health > 0 then
                local dist = (myHRP.Position - enemyHRP.Position).Magnitude
                
                if dist <= cfg.AuraRange then
                    -- Intentar hacer daño
                    Atacar(v)
                    
                    -- Modificar Hitbox en tiempo real si está activado
                    if cfg.HitboxSize > 2 then
                        enemyHRP.Size = Vector3.new(cfg.HitboxSize, cfg.HitboxSize, cfg.HitboxSize)
                        enemyHRP.CanCollide = false
                    end
                end
            end
        end
    end
end)

-- Resto de funciones (Aimbot/Speed) mantenidas...
-- (Para ahorrar espacio no repetí el Fly/Speed, pero usa la misma lógica de arriba)
