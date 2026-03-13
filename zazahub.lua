--// Enhanced Universal Hub 2026 - Stable Whitelist Edition
local Services = {
    RS = game:GetService("RunService"),
    PL = game:GetService("Players"),
    WS = game:GetService("Workspace"),
}

local lp = Services.PL.LocalPlayer

-- ====================== --
-- WHITELIST FIJA (MANUAL)
-- ====================== --
-- Añade aquí los nombres de usuario exactos que quieres permitir
local whitelistedUsers = { 
    "CXCHXRRX_27", 
    "Rarita_RmC4",
    "UsuarioExtra1",
    "UsuarioExtra2"
}

local function hasPermission()
    for _, name in ipairs(whitelistedUsers) do
        if lp.Name == name then return true end
    end
    return false
end

-- Verificación inmediata
if not hasPermission() then
    lp:Kick("Acceso Denegado: No estás en la lista de permitidos.")
    return
end

-- ====================== --
-- CONFIGURACIÓN ESTABLE
-- ====================== --
local cfg = {
    KillAura = false,
    AuraRange = 25,
    AttackSpeed = 18, -- Velocidad equilibrada para no crashear
    HitboxSize = 20,
    TargetMode = "Todos",
    SelectedPlayer = nil,
    WaitTime = 0.05
}

local CachedRemote = nil
local function GetAttackRemote()
    if CachedRemote and CachedRemote.Parent then return CachedRemote end
    local names = {"hit", "combat", "attack", "swing", "punch", "damage", "slash"}
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

    local remote = GetAttackRemote()
    if tool then tool:Activate() end
    
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
end

-- ====================== --
-- BUCLE PRINCIPAL
-- ====================== --
task.spawn(function()
    while true do
        task.wait(cfg.WaitTime)
        
        if cfg.KillAura and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local myHRP = lp.Character.HumanoidRootPart
            
            for _, v in pairs(Services.PL:GetPlayers()) do
                if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    
                    local isTarget = false
                    if cfg.TargetMode == "Todos" then
                        isTarget = true
                    elseif cfg.TargetMode == "Solo Seleccionado" and v.Name == cfg.SelectedPlayer then
                        isTarget = true
                    end

                    if isTarget then
                        local enemyHRP = v.Character.HumanoidRootPart
                        local enemyHum = v.Character:FindFirstChild("Humanoid")
                        
                        if enemyHum and enemyHum.Health > 0 then
                            local dist = (myHRP.Position - enemyHRP.Position).Magnitude
                            if dist <= cfg.AuraRange then
                                -- Optimización: Solo cambiar tamaño si es necesario
                                if enemyHRP.Size.X ~= cfg.HitboxSize then
                                    enemyHRP.Size = Vector3.new(cfg.HitboxSize, cfg.HitboxSize, cfg.HitboxSize)
                                    enemyHRP.CanCollide = false
                                end
                                KillShot(v)
                            end
                        end
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
    Name = "Enhanced Hub STABLE",
    LoadingTitle = "Verificando Whitelist...",
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
    Name = "Kill Aura Activo",
    CurrentValue = false,
    Callback = function(Value) cfg.KillAura = Value end,
})

local TargetDropdown = CombatTab:CreateDropdown({
    Name = "Objetivo Específico",
    Options = UpdatePlayerList(),
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
    Name = "Actualizar Lista de Jugadores",
    Callback = function() 
        TargetDropdown:Set(UpdatePlayerList())
    end,
})

Rayfield:Notify({
    Title = "Acceso Concedido",
    Content = "Bienvenido, " .. lp.Name,
    Duration = 5,
})
