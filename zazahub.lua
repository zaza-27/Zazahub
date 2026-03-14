--// Enhanced Universal Hub 2026 - Multi-Target Stable
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

if not hasPermission() then lp:Kick("Acceso Denegado.") return end

-- ====================== --
-- CONFIGURACIÓN
-- ====================== --
local cfg = {
    KillAura = false,
    AuraRange = 25,
    AttackSpeed = 5, -- Ajustado para permitir multi-target sin lag
    TargetMode = "Todos",
    SelectedPlayer = "Ninguno",
    ESP = false,
    HitboxSize = 30
}

local originalHitboxSizes = {}

-- Buscador de Remotos
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

-- ====================== --
-- FUNCIÓN DE ATAQUE
-- ====================== --
local function Attack(target)
    if not target or not target.Character then return end
    local hum = target.Character:FindFirstChildOfClass("Humanoid")
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    
    if not hum or hum.Health <= 0 then return end

    local remote = GetDamageRemote()
    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    if tool then tool:Activate() end 

    -- Ataque optimizado para múltiples objetivos
    task.spawn(function()
        if remote then
            for i = 1, cfg.AttackSpeed do
                local args = {[1] = hum, [2] = hrp.Position}
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(unpack(args))
                else
                    pcall(function() remote:InvokeServer(unpack(args)) end)
                end
            end
        end
    end)
end

-- ====================== --
-- BUCLE MAESTRO (MULTI-TARGET)
-- ====================== --
Services.RS.Heartbeat:Connect(function()
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
    local myHRP = lp.Character.HumanoidRootPart

    for _, v in pairs(Services.PL:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local enemyHRP = v.Character.HumanoidRootPart
            local enemyHum = v.Character:FindFirstChildOfClass("Humanoid")

            -- Manejo de Hitboxes
            if cfg.KillAura then
                if not originalHitboxSizes[enemyHRP] then originalHitboxSizes[enemyHRP] = enemyHRP.Size end
                enemyHRP.Size = Vector3.new(cfg.HitboxSize, cfg.HitboxSize, cfg.HitboxSize)
                enemyHRP.CanCollide = false
            elseif originalHitboxSizes[enemyHRP] then
                enemyHRP.Size = originalHitboxSizes[enemyHRP]
                originalHitboxSizes[enemyHRP] = nil
            end

            -- Lógica del Kill Aura (Multi-Target)
            if cfg.KillAura and enemyHum and enemyHum.Health > 0 then
                local dist = (myHRP.Position - enemyHRP.Position).Magnitude
                
                if dist <= cfg.AuraRange then
                    if cfg.TargetMode == "Todos" then
                        Attack(v)
                    elseif cfg.TargetMode == "Solo Seleccionado" and v.Name == cfg.SelectedPlayer then
                        Attack(v)
                    end
                end
            end

            -- ESP
            local hl = v.Character:FindFirstChild("Highlight")
            if cfg.ESP then
                if not hl then
                    hl = Instance.new("Highlight", v.Character)
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                end
                hl.Enabled = true
            elseif hl then hl.Enabled = false end
        end
    end
end)

-- ====================== --
-- UI (RAYFIELD)
-- ====================== --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Enhanced Hub 2026",
    LoadingTitle = "Modo Multi-Target...",
    ConfigurationSaving = { Enabled = false }
})

local CombatTab = Window:CreateTab("Combat")
local VisualTab = Window:CreateTab("Visuals")

local function GetPlayerNames()
    local p = {"Ninguno"}
    for _, v in pairs(Services.PL:GetPlayers()) do
        if v ~= lp then table.insert(p, v.Name) end
    end
    return p
end

CombatTab:CreateToggle({
    Name = "Kill Aura Activo",
    CurrentValue = false,
    Callback = function(Value) cfg.KillAura = Value end,
})

CombatTab:CreateSlider({
    Name = "Rango del Aura",
    Range = {5, 100},
    Increment = 1,
    CurrentValue = 25,
    Callback = function(Value) cfg.AuraRange = Value end,
})

local TargetDrop = CombatTab:CreateDropdown({
    Name = "Fijar Objetivo",
    Options = GetPlayerNames(),
    CurrentOption = {"Ninguno"},
    MultipleOptions = false,
    Callback = function(Option) cfg.SelectedPlayer = Option[1] end,
})

CombatTab:CreateDropdown({
    Name = "Modo de Aura",
    Options = {"Todos", "Solo Seleccionado"},
    CurrentOption = {"Todos"},
    MultipleOptions = false,
    Callback = function(Option) cfg.TargetMode = Option[1] end,
})

CombatTab:CreateButton({
    Name = "Actualizar Lista",
    Callback = function()
        TargetDrop:Set(GetPlayerNames())
    end,
})

VisualTab:CreateToggle({
    Name = "ESP Jugadores",
    CurrentValue = false,
    Callback = function(Value) cfg.ESP = Value end,
})

Rayfield:Notify({Title = "Actualizado", Content = "Atacando a todos en rango.", Duration = 5})
