--// Enhanced Universal Hub 2026 - Ultra Speed Version
local Services = {
    RS = game:GetService("RunService"),
    PL = game:GetService("Players"),
    WS = game:GetService("Workspace"),
}
local lp = Services.PL.LocalPlayer

-- ====================== --
-- CONFIGURACIÓN DE PODER
-- ====================== --
local cfg = {
    KillAura = false,
    AuraRange = 25,
    AttackSpeed = 10, -- Cuántas veces atacar por cada ciclo (Aumentar para instakill)
    HitboxSize = 20
}

-- ====================== --
-- BUSCADOR DE REMOTES (Mejorado)
-- ====================== --
local function GetAttackRemote()
    -- Prioridad de búsqueda de remotos de daño comunes
    local names = {"hit", "combat", "attack", "swing", "punch", "damage"}
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            for _, name in pairs(names) do
                if v.Name:lower():find(name) then return v end
            end
        end
    end
    return nil
end

-- ====================== --
-- FUNCIÓN DE ATAQUE RAPID (MULTISHOT)
-- ====================== --
local function FastAttack(target)
    if not target or not target.Character then return end
    local hum = target.Character:FindFirstChild("Humanoid")
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    
    if not hum or hum.Health <= 0 then return end

    -- Ejecutar múltiples ataques en un solo instante
    for i = 1, cfg.AttackSpeed do
        task.spawn(function()
            -- 1. Activa la herramienta (físico)
            if tool then tool:Activate() end
            
            -- 2. Spam de Remotos (lógico)
            local remote = GetAttackRemote()
            if remote then
                local args = {
                    [1] = hum,
                    [2] = hrp.Position
                }
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(unpack(args))
                else
                    pcall(function() remote:InvokeServer(unpack(args)) end)
                end
            end
        end)
    end
end

-- ====================== --
-- BUCLE MAESTRO (ULTRA FAST)
-- ====================== --
task.spawn(function()
    while task.wait(0.05) do -- Ciclo mucho más rápido que Heartbeat
        if cfg.KillAura and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local myPos = lp.Character.HumanoidRootPart.Position
            
            for _, v in pairs(Services.PL:GetPlayers()) do
                if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    local enemyHRP = v.Character.HumanoidRootPart
                    local dist = (myPos - enemyHRP.Position).Magnitude
                    
                    if dist <= cfg.AuraRange then
                        -- Agrandar hitbox para asegurar el hit
                        enemyHRP.Size = Vector3.new(cfg.HitboxSize, cfg.HitboxSize, cfg.HitboxSize)
                        enemyHRP.CanCollide = false
                        
                        -- Ataque de ráfaga
                        FastAttack(v)
                    end
                end
            end
        end
    end
end)

-- ====================== --
-- INTEGRACIÓN UI (Rayfield)
-- ====================== --
-- [Usa el mismo código de Rayfield que ya tienes para los Toggles]
-- Solo asegúrate de que el Toggle de "Kill Aura" cambie cfg.KillAura = Value
