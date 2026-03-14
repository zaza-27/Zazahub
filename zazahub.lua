--// Enhanced Universal Hub 2026 - PURE KILL AURA PRO
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
if not hasPermission() then lp:Kick("No autorizado") return end

-- ====================== --
-- CONFIGURACIÓN DE COMBATE
-- ====================== --
local cfg = {
    KillAura = false,
    AuraRange = 25,
    AttackSpeed = 20, -- Ráfaga optimizada
    TargetMode = "Todos (Cercano)",
    SelectedPlayer = "Ninguno"
}

-- Buscador de Remotos Ultra-Rápido
local CachedRemote = nil
local function GetDamageRemote()
    if CachedRemote and CachedRemote.Parent then return CachedRemote end
    local names = {"Hit", "Attack", "Combat", "Damage", "Swing", "Punch"}
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            for _, n in pairs(names) do
                if v.Name:find(n) or v.Name:lower():find(n:lower()) then
                    CachedRemote = v
                    return v
                end
            end
        end
    end
    return nil
end

-- ====================== --
-- FUNCIÓN DE ATAQUE (NO COOLDOWN)
-- ====================== --
local function Attack(target)
    if not target or not target.Character then return end
    local hum = target.Character:FindFirstChildOfClass("Humanoid")
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    
    if not hum or hum.Health <= 0 then return end
    local remote = GetDamageRemote()
    
    -- Activar herramienta físicamente
    if tool then tool:Activate() end 

    -- Enviar ráfaga de daño al servidor
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

-- ====================== --
-- BUSCADOR DE OBJETIVO CERCANO
-- ====================== --
local function GetClosestPlayer()
    local closest = nil
    local shortestDist = cfg.AuraRange
    local myHRP = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    
    if not myHRP then return nil end

    for _, v in pairs(Services.PL:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local eHum = v.Character:FindFirstChildOfClass("Humanoid")
            if eHum and eHum.Health > 0 then
                local dist = (myHRP.Position - v.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = v
                end
            end
        end
    end
    return closest
end

-- ====================== --
-- BUCLE MAESTRO DE COMBATE
-- ====================== --
Services.RS.Heartbeat:Connect(function()
    if not cfg.KillAura or not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end

    local target = nil

    if cfg.TargetMode == "Solo Seleccionado" then
        -- Buscar específicamente al jugador seleccionado en el Dropdown
        local p = Services.PL:FindFirstChild(cfg.SelectedPlayer)
        if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (lp.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if dist <= cfg.AuraRange then
                target = p
            end
        end
    else
        -- Modo "Todos" concentrado en el más cercano para evitar lag masivo
        target = GetClosestPlayer()
    end

    if target then
        Attack(target)
    end
end)

-- ====================== --
-- UI (RAYFIELD)
-- ====================== --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Kill Aura Pro V9",
    LoadingTitle = "Cargando Motor de Combate...",
    ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Combate")

-- Función para refrescar la lista de nombres
local function GetPlayerList()
    local names = {"Ninguno"}
    for _, v in pairs(Services.PL:GetPlayers()) do
        if v ~= lp then table.insert(names, v.Name) end
    end
    return names
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
    Name = "Fijar Objetivo (Target)",
    Options = GetPlayerList(),
    CurrentOption = {"Ninguno"},
    MultipleOptions = false,
    Callback = function(Option)
        cfg.SelectedPlayer = Option[1]
    end,
})

MainTab:CreateDropdown({
    Name = "Modo de Selección",
    Options = {"Todos (Cercano)", "Solo Seleccionado"},
    CurrentOption = {"Todos (Cercano)"},
    MultipleOptions = false,
    Callback = function(Option)
        cfg.TargetMode = Option[1]
    end,
})

MainTab:CreateButton({
    Name = "Actualizar Lista de Jugadores",
    Callback = function()
        PlayerDropdown:Set(GetPlayerList())
    end,
})

Rayfield:Notify({
    Title = "Aura Lista",
    Content = "ESP eliminado. Kill Aura enfocado en estabilidad y velocidad.",
    Duration = 5,
})
