--// Enhanced Universal Hub 2026 - ULTIMATE FIX
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
    AttackSpeed = 40, 
    TargetMode = "Todos (Cercano)",
    SelectedPlayer = "Ninguno"
}

-- ====================== --
-- MOTOR DE ATAQUE MULTI-MÉTODO
-- ====================== --
local function GetRemotes()
    local found = {}
    local names = {"Hit", "Attack", "Combat", "Damage", "Swing", "Punch", "Slash", "Apply"}
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            for _, n in pairs(names) do
                if v.Name:find(n) or v.Name:lower():find(n:lower()) then
                    table.insert(found, v)
                end
            end
        end
    end
    return found
end

local function Attack(target)
    if not target or not target.Character then return end
    local char = target.Character
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    
    if not hum or hum.Health <= 0 or not hrp then return end
    
    local remotes = GetRemotes()
    if tool then tool:Activate() end -- Intento de click físico

    task.spawn(function()
        for i = 1, cfg.AttackSpeed do
            -- Intentamos disparar todos los remotos encontrados con varios formatos
            for _, remote in pairs(remotes) do
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(hum, hrp.Position)
                        remote:FireServer(char, hrp)
                        remote:FireServer(hum)
                    else
                        remote:InvokeServer(hum, hrp.Position)
                    end
                end)
            end
            
            -- Método especial: Si la herramienta tiene su propio remoto
            if tool then
                for _, v in pairs(tool:GetDescendants()) do
                    if v:IsA("RemoteEvent") then
                        v:FireServer(hum, hrp.Position)
                    end
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
-- BUCLE PRINCIPAL
-- ====================== --
Services.RS.Heartbeat:Connect(function()
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
    Name = "Kill Aura V13 - FINAL",
    LoadingTitle = "Inyectando Multi-Method Aura...",
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
    Name = "Kill Aura (Multi-Method)",
    CurrentValue = false,
    Callback = function(Value) cfg.KillAura = Value end,
})

CombatTab:CreateSlider({
    Name = "Rango",
    Range = {5, 50},
    Increment = 1,
    CurrentValue = 25,
    Callback = function(Value) cfg.AuraRange = Value end,
})

local TargetDrop = CombatTab:CreateDropdown({
    Name = "Seleccionar Objetivo",
    Options = GetPlayerNames(),
    CurrentOption = {"Ninguno"},
    Callback = function(Option) cfg.SelectedPlayer = Option[1] end,
})

CombatTab:CreateDropdown({
    Name = "Modo",
    Options = {"Todos (Cercano)", "Solo Seleccionado"},
    CurrentOption = {"Todos (Cercano)"},
    Callback = function(Option) cfg.TargetMode = Option[1] end,
})

CombatTab:CreateButton({
    Name = "Refrescar Lista",
    Callback = function() TargetDrop:Set(GetPlayerNames()) end,
})

Rayfield:Notify({
    Title = "Sistema Listo",
    Content = "Atacando vía Remotos, Tools y Handlers simultáneamente.",
    Duration = 5,
})
