--// Enhanced Universal Hub 2026 - No Cooldown Edition
local Services = {
    RS = game:GetService("RunService"),
    PL = game:GetService("Players"),
    WS = game:GetService("Workspace"),
}

local lp = Services.PL.LocalPlayer

-- ====================== --
-- WHITELIST FIJA
-- ====================== --
local whitelistedUsers = { "CXCHXRRX_27", "Rarita_RmC4" }
local function hasPermission()
    for _, name in ipairs(whitelistedUsers) do if lp.Name == name then return true end end
    return false
end
if not hasPermission() then lp:Kick("Acceso Denegado") return end

-- ====================== --
-- CONFIGURACIÓN DE VELOCIDAD
-- ====================== --
local cfg = {
    KillAura = false,
    AuraRange = 25,
    AttackSpeed = 40,    -- Ráfaga masiva para eliminar el cooldown
    HitboxSize = 25,
    TargetMode = "Todos",
    SelectedPlayer = nil
}

local CachedRemote = nil
local function GetAttackRemote()
    if CachedRemote and CachedRemote.Parent then return CachedRemote end
    local names = {"Hit", "Attack", "Combat", "Damage", "Swing"}
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            for _, name in pairs(names) do
                if v.Name:find(name) or v.Name:lower():find(name:lower()) then
                    CachedRemote = v
                    return v
                end
            end
        end
    end
    return nil
end

-- ====================== --
-- ATAQUE SIN COOLDOWN (INSTANT)
-- ====================== --
local function FastAttack(target)
    if not target or not target.Character then return end
    local hum = target.Character:FindFirstChildOfClass("Humanoid")
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    
    if not hum or hum.Health <= 0 then return end

    local remote = GetAttackRemote()
    if tool then tool:Activate() end 

    -- Ejecución en paralelo para saltar el cooldown
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
-- BUCLE MAESTRO (ULTRA RÁPIDO)
-- ====================== --
Services.RS.Heartbeat:Connect(function()
    if not cfg.KillAura or not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local myHRP = lp.Character.HumanoidRootPart
    
    for _, v in pairs(Services.PL:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            
            -- Lógica de Objetivo igualada al Aura Global
            local isTarget = false
            if cfg.TargetMode == "Todos" then
                isTarget = true
            elseif cfg.TargetMode == "Solo Seleccionado" and v.Name == cfg.SelectedPlayer then
                isTarget = true
            end

            if isTarget then
                local enemyHRP = v.Character.HumanoidRootPart
                local enemyHum = v.Character:FindFirstChildOfClass("Humanoid")
                
                if enemyHum and enemyHum.Health > 0 then
                    local dist = (myHRP.Position - enemyHRP.Position).Magnitude
                    if dist <= cfg.AuraRange then
                        -- Forzar registro de hit
                        enemyHRP.Size = Vector3.new(cfg.HitboxSize, cfg.HitboxSize, cfg.HitboxSize)
                        enemyHRP.CanCollide = false
                        
                        FastAttack(v)
                    end
                end
            end
        end
    end
end)

-- ====================== --
-- UI (RAYFIELD)
-- ====================== --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Enhanced Hub V3 - NO CD",
    LoadingTitle = "Modo Agresivo Activado",
    ConfigurationSaving = { Enabled = false }
})

local CombatTab = Window:CreateTab("Combat")

local function UpdatePlayerList()
    local list = {"Ninguno"}
    for _, v in pairs(Services.PL:GetPlayers()) do
        if v ~= lp then table.insert(list, v.Name) end
    end
    return list
end

CombatTab:CreateToggle({
    Name = "Kill Aura (Sin Cooldown)",
    CurrentValue = false,
    Callback = function(Value) cfg.KillAura = Value end,
})

local TargetDropdown = CombatTab:CreateDropdown({
    Name = "Seleccionar Objetivo",
    Options = UpdatePlayerList(),
    CurrentOption = {"Ninguno"},
    MultipleOptions = false,
    Callback = function(Option) cfg.SelectedPlayer = Option[1] end,
})

CombatTab:CreateDropdown({
    Name = "Modo de Ataque",
    Options = {"Todos", "Solo Seleccionado"},
    CurrentOption = {"Todos"},
    MultipleOptions = false,
    Callback = function(Option) cfg.TargetMode = Option[1] end,
})

CombatTab:CreateButton({
    Name = "Refrescar Lista",
    Callback = function() TargetDropdown:Set(UpdatePlayerList()) end,
})

Rayfield:Notify({
    Title = "Modo Rapidez Total",
    Content = "El modo objetivo ahora usa ráfaga de 40 disparos.",
    Duration = 5,
})
