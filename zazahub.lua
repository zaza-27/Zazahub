--// Enhanced Universal Hub 2026 - FINAL HYBRID VERSION
local Services = {
    RS = game:GetService("RunService"),
    PL = game:GetService("Players"),
    WS = game:GetService("Workspace"),
}

local lp = Services.PL.LocalPlayer

-- ====================== --
-- WHITELIST ACTUALIZADA
-- ====================== --
local whitelistedUsers = { "CXCHXRRX_27", "Rarita_RmC4", "Rojas123728" }
local function hasPermission()
    for _, name in ipairs(whitelistedUsers) do if lp.Name == name then return true end end
    return false
end
if not hasPermission() then lp:Kick("No autorizado") return end

-- ====================== --
-- CONFIGURACIÓN (Tus datos originales)
-- ====================== --
local cfg = {
    KillAura = false,
    AuraRange = 25,
    AttackSpeed = 20, 
    TargetMode = "Todos (Cercano)",
    SelectedPlayer = "Ninguno"
}

-- Tu buscador de remotos original
local function GetDamageRemote()
    local names = {"Hit", "Attack", "Combat", "Damage", "Swing", "Punch"}
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

-- Tu función de ataque original (Rápida)
local function Attack(target)
    if not target or not target.Character then return end
    local hum = target.Character:FindFirstChildOfClass("Humanoid")
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    
    if not hum or hum.Health <= 0 then return end
    local remote = GetDamageRemote()
    if tool then tool:Activate() end 

    for i = 1, cfg.AttackSpeed do
        task.spawn(function()
            if remote then
                local args = {[1] = hum, [2] = hrp.Position}
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(unpack(args))
                else
                    pcall(function() remote:InvokeServer(unpack(args)) end)
                end
            end
        end)
    end
end

-- Lógica para encontrar al más cercano (Evita el lag del modo "Todos")
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
-- BUCLE MAESTRO (Basado en tu original)
-- ====================== --
Services.RS.Heartbeat:Connect(function()
    if not cfg.KillAura or not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end

    if cfg.TargetMode == "Solo Seleccionado" then
        -- Modo Objetivo Específico
        local target = Services.PL:FindFirstChild(cfg.SelectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (lp.Character.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude
            if dist <= cfg.AuraRange then
                Attack(target)
            end
        end
    else
        -- Modo Todos (Optimizado para no dar lag atacando solo al más cercano)
        local closest = GetClosestPlayer()
        if closest then
            Attack(closest)
        end
    end
end)

-- ====================== --
-- UI (Rayfield con tu Lista de Jugadores)
-- ====================== --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Enhanced Hub 2026 - V11",
    LoadingTitle = "Cargando Configuración Estable...",
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
    Name = "Kill Aura Activo",
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
    Name = "Fijar Objetivo (Lista)",
    Options = GetPlayerNames(),
    CurrentOption = {"Ninguno"},
    MultipleOptions = false,
    Callback = function(Option) cfg.SelectedPlayer = Option[1] end,
})

CombatTab:CreateDropdown({
    Name = "Modo de Aura",
    Options = {"Todos (Cercano)", "Solo Seleccionado"},
    CurrentOption = {"Todos (Cercano)"},
    MultipleOptions = false,
    Callback = function(Option) cfg.TargetMode = Option[1] end,
})

CombatTab:CreateButton({
    Name = "Actualizar Lista de Jugadores",
    Callback = function()
        TargetDrop:Set(GetPlayerNames())
    end,
})

Rayfield:Notify({
    Title = "Hub Restaurado",
    Content = "Se han reintegrado tus datos de ataque originales.",
    Duration = 5,
})
