--// Enhanced Universal Hub 2026 - KILL AURA FIX
local Services = {
    RS = game:GetService("RunService"),
    PL = game:GetService("Players"),
    WS = game:GetService("Workspace"),
}

local lp = Services.PL.LocalPlayer

-- ====================== --
-- WHITELIST FIJA
-- ====================== --
local whitelistedUsers = { "CXCHXRRX_27", "Rarita_RmC4", "Rojas123728" }
local function hasPermission()
    for _, name in ipairs(whitelistedUsers) do if lp.Name == name then return true end end
    return false
end
if not hasPermission() then lp:Kick("Acceso Denegado") return end

-- ====================== --
-- CONFIGURACIÓN PURE COMBAT
-- ====================== --
local cfg = {
    KillAura = false,
    AuraRange = 25,
    AttackSpeed = 25, -- Ráfaga agresiva
    TargetMode = "Todos (Cercano)",
    SelectedPlayer = "Ninguno"
}

-- Buscador de Remotos de Daño (Optimizado)
local function GetDamageRemote()
    local names = {"Hit", "Attack", "Combat", "Damage", "Swing", "Punch", "Remote", "Slash"}
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
-- LÓGICA DE ATAQUE (SIN HITBOX)
-- ====================== --
local function ExecuteAttack(target)
    if not target or not target.Character then return end
    local char = target.Character
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    
    if not hum or hum.Health <= 0 or not hrp then return end
    
    local remote = GetDamageRemote()
    if tool then tool:Activate() end 

    -- Ráfaga de daño directo al servidor
    for i = 1, cfg.AttackSpeed do
        task.spawn(function()
            if remote then
                -- Diferentes formatos de argumentos para asegurar que el golpe cuente
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

-- ====================== --
-- BUSCADOR DE OBJETIVO CERCANO
-- ====================== --
local function GetClosest()
    local target = nil
    local dist = cfg.AuraRange
    local myHRP = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    for _, v in pairs(Services.PL:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local eHum = v.Character:FindFirstChildOfClass("Humanoid")
            if eHum and eHum.Health > 0 then
                local mag = (myHRP.Position - v.Character.HumanoidRootPart.Position).Magnitude
                if mag < dist then
                    dist = mag
                    target = v
                end
            end
        end
    end
    return target
end

-- ====================== --
-- BUCLE MAESTRO
-- ====================== --
Services.RS.Heartbeat:Connect(function()
    if not cfg.KillAura or not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end

    local target = nil
    if cfg.TargetMode == "Solo Seleccionado" then
        local p = Services.PL:FindFirstChild(cfg.SelectedPlayer)
        if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (lp.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d <= cfg.AuraRange then target = p end
        end
    else
        target = GetClosest()
    end

    if target then
        ExecuteAttack(target)
    end
end)

-- ====================== --
-- UI (RAYFIELD)
-- ====================== --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Kill Aura V10 - Final Fix",
    LoadingTitle = "Iniciando Sistema de Combate...",
    ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Combate")

-- Función para la lista de jugadores
local function UpdateList()
    local tbl = {"Ninguno"}
    for _, v in pairs(Services.PL:GetPlayers()) do
        if v ~= lp then table.insert(tbl, v.Name) end
    end
    return tbl
end

MainTab:CreateToggle({
    Name = "Activar Kill Aura",
    CurrentValue = false,
    Callback = function(Value) cfg.KillAura = Value end,
})

MainTab:CreateSlider({
    Name = "Rango de Ataque",
    Range = {5, 50},
    Increment = 1,
    CurrentValue = 25,
    Callback = function(Value) cfg.AuraRange = Value end,
})

local PlayerDropdown = MainTab:CreateDropdown({
    Name = "Lista de Jugadores (Objetivo)",
    Options = UpdateList(),
    CurrentOption = {"Ninguno"},
    Callback = function(Option) cfg.SelectedPlayer = Option[1] end,
})

MainTab:CreateDropdown({
    Name = "Modo de Aura",
    Options = {"Todos (Cercano)", "Solo Seleccionado"},
    CurrentOption = {"Todos (Cercano)"},
    Callback = function(Option) cfg.TargetMode = Option[1] end,
})

MainTab:CreateButton({
    Name = "Refrescar Lista de Jugadores",
    Callback = function()
        PlayerDropdown:Set(UpdateList())
    end,
})

Rayfield:Notify({
    Title = "Limpieza Completada",
    Content = "ESP y Hitbox eliminados. Kill Aura optimizado.",
    Duration = 5,
})
