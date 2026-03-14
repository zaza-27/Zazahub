--// Enhanced Universal Hub 2026 - REPAIR EDITION
local Services = {
    RS = game:GetService("RunService"),
    PL = game:GetService("Players"),
    WS = game:GetService("Workspace"),
}

local lp = Services.PL.LocalPlayer

-- ====================== --
-- WHITELIST
-- ====================== --
local whitelistedUsers = { "CXCHXRRX_27", "Rarita_RmC4", "Rojas123728" }
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
    AuraRange = 25,
    AttackSpeed = 20, 
    TargetMode = "Todos (Cercano)",
    SelectedPlayer = "Ninguno"
}

-- Buscador de Remotos Mejorado (Tu lógica + Escaneo profundo)
local function GetDamageRemote()
    local names = {"Hit", "Attack", "Combat", "Damage", "Swing", "Punch", "PunchRemote", "SwordRemote"}
    -- Primero buscamos dentro de la herramienta equipada (lo más efectivo)
    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    if tool then
        for _, v in pairs(tool:GetDescendants()) do
            if v:IsA("RemoteEvent") then return v end
        end
    end
    -- Si no, buscamos en todo el juego
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            for _, n in pairs(names) do
                if v.Name:find(n) or v.Name:lower():find(n:lower()) then
                    return v
                end
            end
        end
    end
    return nil
end

-- ====================== --
-- FUNCIÓN DE ATAQUE FORZADA
-- ====================== --
local function Attack(target)
    if not target or not target.Character then return end
    local char = target.Character
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    
    if not hum or hum.Health <= 0 or not hrp then return end
    
    local remote = GetDamageRemote()
    
    -- Ataque Físico
    if tool then 
        tool:Activate() 
    end 

    -- Ataque por Remotos (Ráfaga)
    task.spawn(function()
        for i = 1, cfg.AttackSpeed do
            if remote then
                local args = {[1] = hum, [2] = hrp.Position}
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(unpack(args))
                elseif remote:IsA("RemoteFunction") then
                    pcall(function() remote:InvokeServer(unpack(args)) end)
                end
            else
                -- Intento de ataque genérico si no encuentra remoto
                if tool and tool:FindFirstChild("RemoteEvent") then
                    tool.RemoteEvent:FireServer(hum, hrp.Position)
                end
            end
        end
    end)
end

-- ====================== --
-- LÓGICA DE SELECCIÓN
-- ====================== --
local function GetClosestPlayer()
    local closest = nil
    local shortestDist = cfg.AuraRange
    for _, v in pairs(Services.PL:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (lp.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closest = v
            end
        end
    end
    return closest
end

-- ====================== --
-- BUCLE MAESTRO
-- ====================== --
Services.RS.Heartbeat:Connect(function()
    if not cfg.KillAura or not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end

    if cfg.TargetMode == "Solo Seleccionado" then
        local target = Services.PL:FindFirstChild(cfg.SelectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (lp.Character.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude
            if dist <= cfg.AuraRange then
                Attack(target)
            end
        end
    else
        local closest = GetClosestPlayer()
        if closest then
            Attack(closest)
        end
    end
end)

-- ====================== --
-- UI (RAYFIELD)
-- ====================== --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Kill Aura V12 - REPAIR",
    LoadingTitle = "Iniciando Motor de Daño...",
    ConfigurationSaving = { Enabled = false }
})

local function GetPlayerNames()
    local p = {"Ninguno"}
    for _, v in pairs(Services.PL:GetPlayers()) do
        if v ~= lp then table.insert(p, v.Name) end
    end
    return p
end

local CombatTab = Window:CreateTab("Combat")

CombatTab:CreateToggle({
    Name = "Activar Kill Aura",
    CurrentValue = false,
    Callback = function(Value) cfg.KillAura = Value end,
})

CombatTab:CreateSlider({
    Name = "Rango del Aura",
    Range = {5, 50},
    Increment = 1,
    CurrentValue = 25,
    Callback = function(Value) cfg.AuraRange = Value end,
})

local TargetDrop = CombatTab:CreateDropdown({
    Name = "Lista de Jugadores",
    Options = GetPlayerNames(),
    CurrentOption = {"Ninguno"},
    Callback = function(Option) cfg.SelectedPlayer = Option[1] end,
})

CombatTab:CreateDropdown({
    Name = "Modo de Aura",
    Options = {"Todos (Cercano)", "Solo Seleccionado"},
    CurrentOption = {"Todos (Cercano)"},
    Callback = function(Option) cfg.TargetMode = Option[1] end,
})

CombatTab:CreateButton({
    Name = "Refrescar Lista",
    Callback = function()
        TargetDrop:Set(GetPlayerNames())
    end,
})

Rayfield:Notify({
    Title = "Aura Reparada",
    Content = "Asegúrate de tener tu arma equipada para el primer hit.",
    Duration = 5,
})
