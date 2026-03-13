--// Enhanced Universal Hub 2026 - Lag-Free Edition
local Services = {
    RS = game:GetService("RunService"),
    PL = game:GetService("Players"),
    WS = game:GetService("Workspace"),
}

local lp = Services.PL.LocalPlayer

-- ====================== --
-- WHITELIST FIJA
-- ====================== --
local whitelistedUsers = { 
    "CXCHXRRX_27", 
    "Rarita_RmC4"
}

local function hasPermission()
    for _, name in ipairs(whitelistedUsers) do
        if lp.Name == name then return true end
    end
    return false
end

if not hasPermission() then
    lp:Kick("Acceso Denegado.")
    return
end

-- ====================== --
-- CONFIGURACIÓN OPTIMIZADA
-- ====================== --
local cfg = {
    KillAura = false,
    AuraRange = 22,    -- Rango ajustado para mejor registro
    AttackSpeed = 8,   -- Menos golpes por ciclo pero más efectivos (evita lag)
    HitboxSize = 15,   -- Tamaño más estable
    TargetMode = "Todos",
    SelectedPlayer = nil,
    WaitTime = 0.08    -- Tiempo ideal para que el servidor no se sature
}

local CachedRemote = nil
local function GetAttackRemote()
    if CachedRemote and CachedRemote.Parent then return CachedRemote end
    -- Escaneo rápido de remotos comunes
    local potential = {"Hit", "Attack", "Combat", "Damage", "Swing", "Punch"}
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            for _, name in pairs(potential) do
                if v.Name:find(name) or v.Name:lower():find(name:lower()) then
                    CachedRemote = v
                    return v
                end
            end
        end
    end
    return nil
end

-- ====================== --
-- LÓGICA DE ATAQUE FLUIDA
-- ====================== --
local function KillShot(target)
    if not target or not target.Character then return end
    local char = target.Character
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    
    if not hum or hum.Health <= 0 or not hrp then return end

    local remote = GetAttackRemote()
    if tool then tool:Activate() end -- Simula el click físico
    
    if remote then
        -- Enviamos una ráfaga controlada para evitar "Network Lag"
        for i = 1, cfg.AttackSpeed do
            task.spawn(function()
                local args = {
                    [1] = hum,
                    [2] = hrp.Position,
                    [3] = hrp -- Algunos juegos piden la parte directamente
                }
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(unpack(args))
                elseif remote:IsA("RemoteFunction") then
                    pcall(function() remote:InvokeServer(unpack(args)) end)
                end
            end)
        end
    end
end

-- ====================== --
-- BUCLE DE PROCESAMIENTO
-- ====================== --
task.spawn(function()
    while task.wait(cfg.WaitTime) do
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
                        local enemyHum = v.Character:FindFirstChildOfClass("Humanoid")
                        
                        if enemyHum and enemyHum.Health > 0 then
                            local dist = (myHRP.Position - enemyHRP.Position).Magnitude
                            if dist <= cfg.AuraRange then
                                -- Expansión de hitbox ligera (menos lag)
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

-- ====================== --
-- UI (RAYFIELD)
-- ====================== --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Hub V2 - Lag-Free",
    LoadingTitle = "Optimizando...",
    ConfigurationSaving = { Enabled = false }
})

local CombatTab = Window:CreateTab("Combat")

local function UpdatePlayerList()
    local list = {"Ninguno"}
    for _, v in pairs(Services.PL:GetPlayers()) do
        if v ~= lp then table.insert(list, v.Name) end
    end
    return list
end

CombatTab:CreateToggle({
    Name = "Kill Aura Fluido",
    CurrentValue = false,
    Callback = function(Value) cfg.KillAura = Value end,
})

local TargetDropdown = CombatTab:CreateDropdown({
    Name = "Objetivo",
    Options = UpdatePlayerList(),
    CurrentOption = {"Ninguno"},
    MultipleOptions = false,
    Callback = function(Option) cfg.SelectedPlayer = Option[1] end,
})

CombatTab:CreateDropdown({
    Name = "Modo",
    Options = {"Todos", "Solo Seleccionado"},
    CurrentOption = {"Todos"},
    MultipleOptions = false,
    Callback = function(Option) cfg.TargetMode = Option[1] end,
})

CombatTab:CreateButton({
    Name = "Refrescar Jugadores",
    Callback = function() 
        TargetDropdown:Set(UpdatePlayerList())
    end,
})
