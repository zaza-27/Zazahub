--// Enhanced Universal Hub 2026 - Anti-Lag Edition
local Services = {
    RS = game:GetService("RunService"),
    PL = game:GetService("Players"),
    WS = game:GetService("Workspace"),
}

local lp = Services.PL.LocalPlayer

-- ====================== --
-- CONFIGURACIÓN OPTIMIZADA
-- ====================== --
local cfg = {
    KillAura = false,
    AuraRange = 25,
    AttackSpeed = 15, -- Reducido un poco para evitar el crash (sigue siendo muy rápido)
    HitboxSize = 20,
    TargetMode = "Todos",
    SelectedPlayer = nil,
    WaitTime = 0.05 -- Ajustado a 0.05 para estabilidad total
}

-- Limpieza de caché para evitar saturación
local CachedRemote = nil
local lastAttack = 0

local function GetAttackRemote()
    if CachedRemote and CachedRemote.Parent then return CachedRemote end
    local names = {"hit", "combat", "attack", "swing", "punch", "damage"}
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            for _, name in pairs(names) do
                if v.Name:lower():find(name) then 
                    CachedRemote = v
                    return v 
                end
            end
        end
    end
    return nil
end

-- ====================== --
-- LÓGICA DE ATAQUE ESTABLE
-- ====================== --
local function KillShot(target)
    if not target or not target.Character then return end
    local hum = target.Character:FindFirstChild("Humanoid")
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    
    if not hum or hum.Health <= 0 then return end

    -- En lugar de task.spawn masivo, usamos un bucle controlado
    local remote = GetAttackRemote()
    if tool then tool:Activate() end
    
    if remote then
        for i = 1, cfg.AttackSpeed do
            -- Enviamos los disparos de forma directa sin crear hilos innecesarios
            local args = {[1] = hum, [2] = hrp.Position}
            if remote:IsA("RemoteEvent") then
                remote:FireServer(unpack(args))
            else
                pcall(function() remote:InvokeServer(unpack(args)) end)
            end
        end
    end
end

-- ====================== --
-- BUCLE PRINCIPAL ANTI-CRASH
-- ====================== --
task.spawn(function()
    while true do
        task.wait(cfg.WaitTime) -- 0.05 es el punto dulce entre velocidad y estabilidad
        
        if cfg.KillAura and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local myHRP = lp.Character.HumanoidRootPart
            
            for _, v in pairs(Services.PL:GetPlayers()) do
                if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    
                    local isTarget = false
                    if cfg.TargetMode == "Todos" then
                        isTarget = true
                    elseif cfg.TargetMode == "Solo Seleccionado" and v.Name == cfg.SelectedPlayer then
                        isTarget = true
                    end

                    if isTarget then
                        local enemyHRP = v.Character.HumanoidRootPart
                        local enemyHum = v.Character:FindFirstChild("Humanoid")
                        
                        if enemyHum and enemyHum.Health > 0 then
                            local dist = (myHRP.Position - enemyHRP.Position).Magnitude
                            if dist <= cfg.AuraRange then
                                -- Solo agrandamos si es necesario para ahorrar CPU
                                if enemyHRP.Size.X ~= cfg.HitboxSize then
                                    enemyHRP.Size = Vector3.new(cfg.HitboxSize, cfg.HitboxSize, cfg.HitboxSize)
                                    enemyHRP.CanCollide = false
                                end
                                KillShot(v)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- (Aquí va tu código de Rayfield para los Toggles y Dropdowns)
