--// Enhanced Universal Hub 2026 - God Mode Extreme
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
-- CONFIGURACIÓN EXTREMA
-- ====================== --
local cfg = {
    KillAura = false,
    AuraRange = 25,
    AttackSpeed = 25, -- Ráfaga masiva
    TargetMode = "Todos",
    SelectedPlayer = nil,
    ESP = false
}

-- Buscador de Remotos
local CachedRemote = nil
local function GetAttackRemote()
    if CachedRemote and CachedRemote.Parent then return CachedRemote end
    local names = {"Hit", "Attack", "Combat", "Damage", "Swing"}
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
-- LÓGICA DE ATAQUE FLASH
-- ====================== --
local function Attack(target)
    local char = target.Character
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    
    if not hum or hum.Health <= 0 then return end

    local remote = GetAttackRemote()
    if tool then tool:Activate() end 

    task.spawn(function()
        for i = 1, cfg.AttackSpeed do
            if remote then
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
-- SISTEMA ESP (WALLHACK)
-- ====================== --
local function CreateESP(player)
    if player.Character and not player.Character:FindFirstChild("Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "Highlight"
        highlight.Parent = player.Character
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.Enabled = cfg.ESP
    end
end

-- ====================== --
-- BUCLE PRINCIPAL
-- ====================== --
Services.RS.Stepped:Connect(function()
    -- Control de Kill Aura
    if cfg.KillAura and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local myHRP = lp.Character.HumanoidRootPart
        for _, v in pairs(Services.PL:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local isValid = (cfg.TargetMode == "Todos") or (cfg.TargetMode == "Solo Seleccionado" and v.Name == cfg.SelectedPlayer)
                
                if isValid then
                    local enemyHRP = v.Character.HumanoidRootPart
                    local enemyHum = v.Character:FindFirstChildOfClass("Humanoid")
                    if enemyHum and enemyHum.Health > 0 then
                        local dist = (myHRP.Position - enemyHRP.Position).Magnitude
                        if dist <= cfg.AuraRange then
                            Attack(v)
                        end
                    end
                end
            end
        end
    end

    -- Control de ESP
    for _, v in pairs(Services.PL:GetPlayers()) do
        if v ~= lp and v.Character then
            local hl = v.Character:FindFirstChild("Highlight")
            if cfg.ESP then
                if not hl then CreateESP(v) else hl.Enabled = true end
            else
                if hl then hl.Enabled = false end
            end
        end
    end
end)

-- ====================== --
-- UI (RAYFIELD)
-- ====================== --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Hub V5 - ULTRA SPEED",
    LoadingTitle = "Iniciando Módulos...",
    ConfigurationSaving = { Enabled = false }
})

local CombatTab = Window:CreateTab("Combate")
local VisualTab = Window:CreateTab("Visuales")

CombatTab:CreateToggle({
    Name = "Kill Aura Ultra-Rápido",
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
    Name = "Fijar Objetivo",
    Options = {"Ninguno"},
    CurrentOption = {"Ninguno"},
    Callback = function(Option) cfg.SelectedPlayer = Option[1] end,
})

CombatTab:CreateDropdown({
    Name = "Modo",
    Options = {"Todos", "Solo Seleccionado"},
    CurrentOption = {"Todos"},
    Callback = function(Option) cfg.TargetMode = Option[1] end,
})

CombatTab:CreateButton({
    Name = "Refrescar Jugadores",
    Callback = function()
        local p = {"Ninguno"}
        for _, v in pairs(Services.PL:GetPlayers()) do if v ~= lp then table.insert(p, v.Name) end end
        TargetDrop:Set(p)
    end,
})

VisualTab:CreateToggle({
    Name = "ESP Jugadores (Wallhack)",
    CurrentValue = false,
    Callback = function(Value) cfg.ESP = Value end,
})

Rayfield:Notify({
    Title = "Configuración Aplicada",
    Content = "Velocidad de ataque máxima y ESP activado.",
    Duration = 5,
})
 
