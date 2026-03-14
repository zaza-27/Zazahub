--// Enhanced Universal Hub 2026 - Closest Target Edition
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
    TargetMode = "Todos",
    SelectedPlayer = "Ninguno",
    ESP = false,
    HitboxSize = 30
}

local originalHitboxSizes = {}

-- Buscador de Remotos de Daño
local function GetDamageRemote()
    local names = {"Hit", "Attack", "Combat", "Damage", "Swing", "Punch"}
    local found = nil
    pcall(function()
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                for _, n in pairs(names) do
                    if v.Name:find(n) or v.Name:lower():find(n:lower()) then
                        found = v
                        break
                    end
                end
            end
            if found then break end
        end
    end)
    return found
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

    if remote then
        local args = {[1] = hum, [2] = hrp.Position}
        if remote:IsA("RemoteEvent") then
            remote:FireServer(unpack(args))
        else
            pcall(function() remote:InvokeServer(unpack(args)) end)
        end
    end
end

-- ====================== --
-- BUCLE MAESTRO (Lógica de Cercanía)
-- ====================== --
Services.RS.Heartbeat:Connect(function()
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") or not cfg.KillAura then return end
    
    local myHRP = lp.Character.HumanoidRootPart
    local closestTarget = nil
    local shortestDist = cfg.AuraRange

    for _, v in pairs(Services.PL:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local enemyHRP = v.Character.HumanoidRootPart
            local enemyHum = v.Character:FindFirstChildOfClass("Humanoid")
            local dist = (myHRP.Position - enemyHRP.Position).Magnitude

            -- Actualizar Hitbox solo si el Aura está activa
            if not originalHitboxSizes[enemyHRP] then originalHitboxSizes[enemyHRP] = enemyHRP.Size end
            enemyHRP.Size = Vector3.new(cfg.HitboxSize, cfg.HitboxSize, cfg.HitboxSize)
            enemyHRP.CanCollide = false

            -- Buscar al más cercano dentro del rango
            if enemyHum and enemyHum.Health > 0 and dist <= cfg.AuraRange then
                if cfg.TargetMode == "Todos" then
                    if dist < shortestDist then
                        shortestDist = dist
                        closestTarget = v
                    end
                elseif cfg.TargetMode == "Solo Seleccionado" and v.Name == cfg.SelectedPlayer then
                    closestTarget = v
                end
            end

            -- Lógica del ESP
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

    -- ATACAR SOLO AL MÁS CERCANO (Previene el lag masivo)
    if closestTarget then
        Attack(closestTarget)
    end
end)

-- ====================== --
-- UI (RAYFIELD)
-- ====================== --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Enhanced Hub 2026",
    LoadingTitle = "Iniciando Kill Aura...",
    ConfigurationSaving = { Enabled = false }
})

local CombatTab = Window:CreateTab("Combat")
local VisualTab = Window:CreateTab("Visuals")

CombatTab:CreateToggle({
    Name = "Kill Aura Activo",
    CurrentValue = false,
    Callback = function(Value) cfg.KillAura = Value end,
})

CombatTab:CreateSlider({
    Name = "Rango de Ataque",
    Range = {5, 100},
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

CombatTab:CreateDropdown({
    Name = "Modo de Objetivo",
    Options = {"Todos", "Solo Seleccionado"},
    CurrentOption = {"Todos"},
    MultipleOptions = false,
    Callback = function(Option) cfg.TargetMode = Option[1] end,
})

VisualTab:CreateToggle({
    Name = "ESP Jugadores",
    CurrentValue = false,
    Callback = function(Value) cfg.ESP = Value end,
})

Rayfield:Notify({
    Title = "Aura Lista",
    Content = "Modo: Jugador más cercano",
    Duration = 5,
})
