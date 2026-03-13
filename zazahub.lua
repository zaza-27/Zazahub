--// Enhanced Universal Hub 2026 - Target Edition
local Services = {
    RS = game:GetService("RunService"),
    PL = game:GetService("Players"),
    WS = game:GetService("Workspace"),
}

local lp = Services.PL.LocalPlayer
local cam = Services.WS.CurrentCamera

-- ====================== --
-- WHITELIST
-- ====================== --
local whitelistedUsers = { "CXCHXRRX_27", "Rarita_RmC4" }
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
    AttackSpeed = 35, 
    HitboxSize = 25,
    TargetMode = "Todos", -- "Todos" o "Seleccionado"
    SelectedPlayer = nil,
    WaitTime = 0.01
}

local CachedRemote = nil
local function GetAttackRemote()
    if CachedRemote then return CachedRemote end
    local names = {"hit", "combat", "attack", "swing", "punch", "damage"}
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            for _, name in pairs(names) do
                if v.Name:lower():find(name) then 
                    CachedRemote = v
                    return v 
                end
            end
        end
    end
    return nil
end

-- ====================== --
-- LÓGICA DE ATAQUE
-- ====================== --
local function KillShot(target)
    if not target or not target.Character then return end
    local hum = target.Character:FindFirstChild("Humanoid")
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    
    if not hum or hum.Health <= 0 then return end

    for i = 1, cfg.AttackSpeed do
        task.spawn(function()
            if tool then tool:Activate() end
            local remote = GetAttackRemote()
            if remote then
                local args = {[1] = hum, [2] = hrp.Position}
                if remote:IsA("RemoteEvent") then remote:FireServer(unpack(args))
                else pcall(function() remote:InvokeServer(unpack(args)) end) end
            end
        end)
    end
end

-- ====================== --
-- UI (RAYFIELD)
-- ====================== --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Enhanced Hub TARGET",
    LoadingTitle = "Cargando Sistema de Objetivos...",
    ConfigurationSaving = { Enabled = false }
})

local CombatTab = Window:CreateTab("Combat")

-- Dropdown de Jugadores
local PlayerList = {}
local function UpdatePlayerList()
    PlayerList = {"Ninguno"}
    for _, v in pairs(Services.PL:GetPlayers()) do
        if v ~= lp then table.insert(PlayerList, v.Name) end
    end
    return PlayerList
end

CombatTab:CreateToggle({
    Name = "Kill Aura Activo",
    CurrentValue = false,
    Callback = function(Value) cfg.KillAura = Value end,
})

local TargetDropdown = CombatTab:CreateDropdown({
    Name = "Seleccionar Objetivo",
    Options = UpdatePlayerList(),
    CurrentOption = {"Ninguno"},
    MultipleOptions = false,
    Callback = function(Option)
        cfg.SelectedPlayer = Option[1]
    end,
})

CombatTab:CreateDropdown({
    Name = "Modo de Objetivo",
    Options = {"Todos", "Solo Seleccionado"},
    CurrentOption = {"Todos"},
    MultipleOptions = false,
    Callback = function(Option)
        cfg.TargetMode = Option[1]
    end,
})

CombatTab:CreateButton({
    Name = "Refrescar Lista de Jugadores",
    Callback = function()
        TargetDropdown:Set(UpdatePlayerList())
    end,
})

-- ====================== --
-- BUCLE FLASH CON FILTRO
-- ====================== --
task.spawn(function()
    while true do
        task.wait(cfg.WaitTime)
        if cfg.KillAura and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local myHRP = lp.Character.HumanoidRootPart
            
            for _, v in pairs(Services.PL:GetPlayers()) do
                if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    
                    -- Filtro de Objetivo
                    local canAttack = false
                    if cfg.TargetMode == "Todos" then
                        canAttack = true
                    elseif cfg.TargetMode == "Solo Seleccionado" and v.Name == cfg.SelectedPlayer then
                        canAttack = true
                    end

                    if canAttack then
                        local enemyHRP = v.Character.HumanoidRootPart
                        local enemyHum = v.Character:FindFirstChild("Humanoid")
                        
                        if enemyHum and enemyHum.Health > 0 then
                            local dist = (myHRP.Position - enemyHRP.Position).Magnitude
                            if dist <= cfg.AuraRange then
                                enemyHRP.Size = Vector3.new(cfg.HitboxSize, cfg.HitboxSize, cfg.HitboxSize)
                                KillShot(v)
                            end
                        end
                    end
                end
            end
        end
    end
end)

Rayfield:Notify({
    Title = "Sistema de Objetivos",
    Content = "Usa el Dropdown para fijar a un jugador.",
    Duration = 5,
})
