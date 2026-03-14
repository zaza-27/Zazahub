--// Enhanced Universal Hub 2026 - Final Stable Version (Hitbox Enhanced)
local Services = {
    RS = game:GetService("RunService"),
    PL = game:GetService("Players"),
    WS = game:GetService("Workspace"),
}

local lp = Services.PL.LocalPlayer

-- ====================== --
-- WHITELIST ACTUALIZADA
-- ====================== --
local whitelistedUsers = { 
    "CXCHXRRX_27", 
    "Rarita_RmC4", 
    "Rojas123728" 
}

local function hasPermission()
    for _, name in ipairs(whitelistedUsers) do 
        if lp.Name == name then return true end 
    end
    return false
end

if not hasPermission() then 
    lp:Kick("Acceso Denegado: No estás en la whitelist.") 
    return 
end

-- ====================== --
-- CONFIGURACIÓN
-- ====================== --
local cfg = {
    KillAura = false,
    AuraRange = 25,
    AttackSpeed = 20, 
    TargetMode = "Todos",
    SelectedPlayer = "Ninguno",
    ESP = false,
    HitboxSize = 30 -- Tamaño de la hitbox implementado
}

local originalHitboxSizes = {}

-- Buscador de Remotos de Daño
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
    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    
    if not hum or hum.Health <= 0 then return end

    local remote = GetDamageRemote()
    if tool then tool:Activate() end 

    -- Ráfaga de daño rápida
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
-- MANEJO DE HITBOXES (NUEVO)
-- ====================== --
local function UpdateHitboxes()
    for _, v in pairs(Services.PL:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = v.Character.HumanoidRootPart
            if cfg.KillAura then
                if not originalHitboxSizes[hrp] then
                    originalHitboxSizes[hrp] = hrp.Size
                end
                hrp.Size = Vector3.new(cfg.HitboxSize, cfg.HitboxSize, cfg.HitboxSize)
                hrp.CanCollide = false
            else
                if originalHitboxSizes[hrp] then
                    hrp.Size = originalHitboxSizes[hrp]
                end
            end
        end
    end
end

-- ====================== --
-- BUCLE MAESTRO
-- ====================== --
Services.RS.Heartbeat:Connect(function()
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
    local myHRP = lp.Character.HumanoidRootPart

    -- Ejecutar actualización de hitboxes continuamente si el Aura está activa
    UpdateHitboxes()

    for _, v in pairs(Services.PL:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local enemyHRP = v.Character.HumanoidRootPart
            local enemyHum = v.Character:FindFirstChildOfClass("Humanoid")

            -- Lógica del Kill Aura
            if cfg.KillAura and enemyHum and enemyHum.Health > 0 then
                local canAttack = false
                if cfg.TargetMode == "Todos" then
                    canAttack = true
                elseif cfg.TargetMode == "Solo Seleccionado" and v.Name == cfg.SelectedPlayer then
                    canAttack = true
                end

                if canAttack then
                    local dist = (myHRP.Position - enemyHRP.Position).Magnitude
                    if dist <= cfg.AuraRange then
                        Attack(v)
                    end
                end
            end

            -- Lógica del ESP (Highlight)
            local hl = v.Character:FindFirstChild("Highlight")
            if cfg.ESP then
                if not hl then
                    hl = Instance.new("Highlight", v.Character)
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.5
                end
                hl.Enabled = true
            elseif hl then
                hl.Enabled = false
            end
        end
    end
end)

-- ====================== --
-- UI (RAYFIELD)
-- ====================== --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Enhanced Hub 2026",
    LoadingTitle = "Verificando Credenciales...",
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
    Callback = function(Value) 
        cfg.KillAura = Value 
        if not Value then UpdateHitboxes() end -- Restaurar hitboxes al apagar
    end,
})

CombatTab:CreateSlider({
    Name = "Rango del Aura",
    Range = {5, 50},
    Increment = 1,
    CurrentValue = 25,
    Callback = function(Value) cfg.AuraRange = Value end,
})

CombatTab:CreateSlider({
    Name = "Tamaño de Hitbox",
    Range = {2, 100},
    Increment = 1,
    CurrentValue = 30,
    Callback = function(Value) cfg.HitboxSize = Value end,
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
    Name = "Actualizar Lista de Jugadores",
    Callback = function()
        TargetDrop:Set(GetPlayerNames())
    end,
})

VisualTab:CreateToggle({
    Name = "ESP Jugadores",
    CurrentValue = false,
    Callback = function(Value) cfg.ESP = Value end,
})

Rayfield:Notify({
    Title = "Whitelist Cargada",
    Content = "Bienvenido " .. lp.Name .. " (Rojas123728 añadido)",
    Duration = 5,
})
