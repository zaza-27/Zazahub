-- [[ KRISPhub Kill Aura - PRIVATE BLINDED EDITION 2026 ]] --

-- CONFIGURACIÓN DE SEGURIDAD (Solo estos usuarios pueden entrar)
local UsuariosPermitidos = { 
    "CXCHXRRX_27", 
    "Rarita_RmC4",
    -- Agrega más aquí si lo necesitas
}

local function VerificarAcceso()
    local lp = game.Players.LocalPlayer
    for _, nombre in ipairs(UsuariosPermitidos) do
        if lp.Name == nombre then return true end
    end
    return false
end

-- Bloqueo de seguridad: Si no está en la lista, el script se autodestruye
if not VerificarAcceso() then
    warn("!!! KRISPhub SECURITY: ACCESO DENEGADO !!!")
    return 
end

-- Carga de Rayfield
local success, Rayfield = pcall(function() 
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))() 
end)

if not success or not Rayfield then return end

local Window = Rayfield:CreateWindow({
    Name = "KRISPhub Kill Aura | PRIVATE",
    LoadingTitle = "Verificando Credenciales...",
    LoadingSubtitle = "Acceso Concedido",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

local Tab = Window:CreateTab("Main", 4483362458)
local Section = Tab:CreateSection("Controles Kill Aura")

-- Variables Restauradas
local Enabled = false
local UseClosestOnly = true
local SelectedTarget = nil
local AttackSpeed = 85 -- Hits originales
local Range = 40.0     -- Rango original
local MaxTargets = 6
local Prediction = 0.14

-- Localización del Remote
local HitRemote
pcall(function()
    HitRemote = game:GetService("ReplicatedStorage")
    :WaitForChild("Packages", 8)
    :WaitForChild("Knit", 6)
    :WaitForChild("Services", 6)
    :WaitForChild("CombatService", 6)
    :WaitForChild("RF", 6)
    :WaitForChild("Hit", 6)
end)

-- Toggle Principal
Tab:CreateToggle({
    Name = "Activar Kill Aura",
    CurrentValue = false,
    Callback = function(Value)
        Enabled = Value
        Rayfield:Notify({Title = "Kill Aura", Content = Value and "Activado ("..AttackSpeed.." hits/s)" or "Desactivado", Duration = 3})
    end,
})

-- Toggle Closest Only
Tab:CreateToggle({
    Name = "Solo el más cercano",
    CurrentValue = true,
    Callback = function(Value) UseClosestOnly = Value end,
})

-- Dropdown Jugadores
local PlayerOptions = {"Ninguno"}
local function RefreshPlayers()
    PlayerOptions = {"Ninguno"}
    for _, plr in game.Players:GetPlayers() do
        if plr ~= game.Players.LocalPlayer then
            table.insert(PlayerOptions, plr.Name)
        end
    end
end
RefreshPlayers()

local PlayerDropdown = Tab:CreateDropdown({
    Name = "Objetivo Específico",
    Options = PlayerOptions,
    CurrentOption = {"Ninguno"},
    Callback = function(Option)
        local name = (type(Option) == "table" and Option[1]) or Option
        if name == "Ninguno" then
            SelectedTarget = nil
        else
            SelectedTarget = game.Players:FindFirstChild(name)
        end
    end,
})

Tab:CreateButton({
    Name = "Refrescar Lista Jugadores",
    Callback = function() 
        RefreshPlayers()
        PlayerDropdown:Set(PlayerOptions)
    end,
})

-- Sliders
Tab:CreateSlider({
    Name = "Velocidad de Golpes",
    Range = {20, 85},
    Increment = 1,
    Suffix = "hits/s",
    CurrentValue = 85,
    Callback = function(Value) AttackSpeed = Value end,
})

Tab:CreateSlider({
    Name = "Rango Máximo",
    Range = {15, 40},
    Increment = 0.5,
    Suffix = "studs",
    CurrentValue = 40,
    Callback = function(Value) Range = Value end,
})

-- Motor de Ataque (Versión Estable V7)
local lastHit = 0
game:GetService("RunService").Heartbeat:Connect(function()
    if not Enabled or not HitRemote then return end
    
    local now = tick()
    if now - lastHit < (1 / AttackSpeed) then return end
    lastHit = now

    local lp = game.Players.LocalPlayer
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local targets = {}

    -- Selección de Objetivo
    if not UseClosestOnly and SelectedTarget and SelectedTarget.Character then
        local tchar = SelectedTarget.Character
        local thum = tchar:FindFirstChild("Humanoid")
        local thrp = tchar:FindFirstChild("HumanoidRootPart")
        if thum and thum.Health > 0 and thrp then
            if (thrp.Position - root.Position).Magnitude <= Range then
                table.insert(targets, {Hum = thum, Pos = thrp.Position + (thrp.AssemblyLinearVelocity * Prediction)})
            end
        end
    end

    if #targets == 0 then
        local closestDist = Range
        local closest = nil
        for _, plr in game.Players:GetPlayers() do
            if plr == lp then continue end
            local tchar = plr.Character
            local thum = tchar and tchar:FindFirstChild("Humanoid")
            local thrp = tchar and tchar:FindFirstChild("HumanoidRootPart")
            if thum and thum.Health > 0 and thrp then
                local dist = (thrp.Position - root.Position).Magnitude
                if dist <= closestDist then
                    closestDist = dist
                    closest = {Hum = thum, Pos = thrp.Position + (thrp.AssemblyLinearVelocity * Prediction)}
                end
            end
        end
        if closest then table.insert(targets, closest) end
    end

    -- Ejecución de ráfaga
    for _, tgt in targets do
        task.spawn(function()
            pcall(HitRemote.InvokeServer, HitRemote, tgt.Hum, tgt.Pos)
        end)
    end
end)

Rayfield:Notify({
    Title = "Autenticación Exitosa",
    Content = "Whitelist Blindada Activa. Bienvenido de nuevo.",
    Duration = 5
})
