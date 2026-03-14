--// Enhanced Universal Hub 2026 - GOD SPEED EDITION
local Services = {
    RS = game:GetService("RunService"),
    PL = game:GetService("Players"),
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
-- CONFIGURACIÓN ULTRA-EXTREMA
-- ====================== --
local cfg = {
    KillAura = false,
    AuraRange = 25,
    AttackPower = 40, -- Ráfaga de 40 ataques por frame
    TargetMode = "Todos (Cercano)",
    SelectedPlayer = "Ninguno"
}

-- Anclaje de Remotos para Velocidad Luz
local CachedRemotes = {}
local function RefreshRemotes()
    table.clear(CachedRemotes)
    local names = {"Hit", "Attack", "Combat", "Damage", "Swing", "Punch", "Slash"}
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
RefreshRemotes()

-- ====================== --
-- MOTOR DE ATAQUE INSTANTÁNEO
-- ====================== --
local function InstantAttack(target)
    local char = target.Character
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    
    if not hum or hum.Health <= 0 then return end
    if tool then tool:Activate() end 

    -- Ejecución masiva en paralelo (Ignora el lag del servidor)
    for i = 1, cfg.AttackPower do
        task.spawn(function()
            for _, remote in ipairs(CachedRemotes) do
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(hum, hrp.Position)
                    remote:FireServer(hum) -- Doble hit para asegurar
                end
            end
        end)
    end
end

-- ====================== --
-- BUSCADOR DE OBJETIVOS (VELOCIDAD LUZ)
-- ====================== --
local function GetTarget()
    if cfg.TargetMode == "Solo Seleccionado" then
        local p = Services.PL:FindFirstChild(cfg.SelectedPlayer)
        if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (lp.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if dist <= cfg.AuraRange then return p end
        end
    else
        local closest = nil
        local dist = cfg.AuraRange
        for _, v in ipairs(Services.PL:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local mag = (lp.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                if mag < dist then
                    local h = v.Character:FindFirstChildOfClass("Humanoid")
                    if h and h.Health > 0 then
                        dist = mag
                        closest = v
                    end
                end
            end
        end
        return closest
    end
    return nil
end

-- ====================== --
-- BUCLE RENDER (EL MÁS RÁPIDO POSIBLE)
-- ====================== --
Services.RS.RenderStepped:Connect(function()
    if cfg.KillAura and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local target = GetTarget()
        if target then
            InstantAttack(target)
        end
    end
end)

-- ====================== --
-- UI (RAYFIELD)
-- ====================== --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "GOD SPEED HUB 2026",
    LoadingTitle = "Eliminando Cooldowns...",
    ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Combat")

local function GetNames()
    local t = {"Ninguno"}
    for _, v in pairs(Services.PL:GetPlayers()) do if v ~= lp then table.insert(t, v.Name) end end
    return t
end

MainTab:CreateToggle({
    Name = "ACTIVAR MODO DIOS (Kill Aura)",
    CurrentValue = false,
    Callback = function(Value) cfg.KillAura = Value end,
})

MainTab:CreateSlider({
    Name = "Rango de Aniquilación",
    Range = {5, 50}, Increment = 1, CurrentValue = 25,
    Callback = function(Value) cfg.AuraRange = Value end,
})

local TargetDrop = MainTab:CreateDropdown({
    Name = "Objetivo Seleccionado",
    Options = GetNames(),
    CurrentOption = {"Ninguno"},
    Callback = function(Option) cfg.SelectedPlayer = Option[1] end,
})

MainTab:CreateDropdown({
    Name = "Modo",
    Options = {"Todos (Cercano)", "Solo Seleccionado"},
    CurrentOption = {"Todos (Cercano)"},
    Callback = function(Option) cfg.TargetMode = Option[1] end,
})

MainTab:CreateButton({
    Name = "Actualizar Jugadores",
    Callback = function() TargetDrop:Set(GetNames()) end,
})

MainTab:CreateButton({
    Name = "Recargar Remotos (Si no matas)",
    Callback = function() RefreshRemotes() end,
})

Rayfield:Notify({
    Title = "Modo God Speed",
    Content = "Velocidad de ataque ajustada al máximo del motor gráfico.",
    Duration = 5,
})
