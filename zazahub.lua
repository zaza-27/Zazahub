--// Enhanced Universal Hub 2026 - V13 SPEED OVERLOAD
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
-- CONFIGURACIÓN EXTREMA
-- ====================== --
local cfg = {
    KillAura = false,
    AuraRange = 25,
    AttackSpeed = 40, -- Aumentado a 40 ráfagas por frame
    TargetMode = "Todos (Cercano)",
    SelectedPlayer = "Ninguno"
}

-- Memoria Rápida de Remotos
local CachedRemotes = {}
local function UpdateRemoteCache()
    table.clear(CachedRemotes)
    local names = {"Hit", "Attack", "Combat", "Damage", "Swing", "Punch", "Slash", "Apply"}
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            for _, n in pairs(names) do
                if v.Name:find(n) or v.Name:lower():find(n:lower()) then
                    table.insert(CachedRemotes, v)
                end
            end
        end
    end
end
UpdateRemoteCache()

-- ====================== --
-- MOTOR DE ATAQUE VELOCIDAD LUZ
-- ====================== --
local function Attack(target)
    if not target or not target.Character then return end
    local char = target.Character
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    
    if not hum or hum.Health <= 0 or not hrp then return end
    
    if tool then tool:Activate() end 

    -- Ejecución de ráfaga sin delay
    task.spawn(function()
        for i = 1, cfg.AttackSpeed do
            for _, remote in ipairs(CachedRemotes) do
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        -- Enviamos 3 formatos de daño en un solo micro-segundo
                        remote:FireServer(hum, hrp.Position)
                        remote:FireServer(char, hrp)
                        remote:FireServer(hum)
                    else
                        remote:InvokeServer(hum, hrp.Position)
                    end
                end)
            end
            
            -- Si la herramienta tiene remotos propios, dispararlos también
            if tool then
                for _, v in ipairs(tool:GetChildren()) do
                    if v:IsA("RemoteEvent") then v:FireServer(hum, hrp.Position) end
                end
            end
        end
    end)
end

-- ====================== --
-- SELECCIÓN DE OBJETIVO (OPTIMIZADA)
-- ====================== --
local function GetClosestPlayer()
    local closest = nil
    local shortestDist = cfg.AuraRange
    local myPos = lp.Character.HumanoidRootPart.Position

    for _, v in ipairs(Services.PL:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (myPos - v.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortestDist then
                local hum = v.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    shortestDist = dist
                    closest = v
                end
            end
        end
    end
    return closest
end

-- ====================== --
-- BUCLE RENDERSTEPPED (MÁXIMA VELOCIDAD)
-- ====================== --
Services.RS.RenderStepped:Connect(function()
    if not cfg.KillAura or not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end

    if cfg.TargetMode == "Solo Seleccionado" then
        local target = Services.PL:FindFirstChild(cfg.SelectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (lp.Character.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude
            if dist <= cfg.AuraRange then Attack(target) end
        end
    else
        local closest = GetClosestPlayer()
        if closest then Attack(closest) end
    end
end)

-- ====================== --
-- UI (RAYFIELD)
-- ====================== --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Kill Aura V13 - GOD SPEED",
    LoadingTitle = "Eliminando Cooldown de Daño...",
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
    Name = "Kill Aura ULTRA-FAST",
    CurrentValue = false,
    Callback = function(Value) cfg.KillAura = Value end,
})

CombatTab:CreateSlider({
    Name = "Rango de Ataque",
    Range = {5, 50},
    Increment = 1,
    CurrentValue = 25,
    Callback = function(Value) cfg.AuraRange = Value end,
})

local TargetDrop = CombatTab:CreateDropdown({
    Name = "Objetivo Específico",
    Options = GetPlayerNames(),
    CurrentOption = {"Ninguno"},
    Callback = function(Option) cfg.SelectedPlayer = Option[1] end,
})

CombatTab:CreateDropdown({
    Name = "Modo de Selección",
    Options = {"Todos (Cercano)", "Solo Seleccionado"},
    CurrentOption = {"Todos (Cercano)"},
    Callback = function(Option) cfg.TargetMode = Option[1] end,
})

CombatTab:CreateButton({
    Name = "Refrescar Jugadores",
    Callback = function() TargetDrop:Set(GetPlayerNames()) end,
})

CombatTab:CreateButton({
    Name = "Recargar Remotos (Update)",
    Callback = function() UpdateRemoteCache() end,
})

Rayfield:Notify({
    Title = "Modo Overload",
    Content = "Velocidad de golpes aumentada al límite del motor gráfico.",
    Duration = 5,
})
