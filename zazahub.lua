-- [[ KRISPhub Kill Aura V13 - TARGET LOCK & FIX AUTO ]] --

-- 1. LISTA PRIVADA (Sustituye por los nombres exactos)
local AccesoPrivado = {
    ["CXCHXRRX_27"] = true,
    ["Rarita_RmC4"] = true,
}

-- 2. BLOQUEO TOTAL
if not AccesoPrivado[game:GetService("Players").LocalPlayer.Name] then
    warn("ACCESO DENEGADO: Usuario no autorizado.")
    return 
end

local success, Rayfield = pcall(function() 
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))() 
end)

local Window = Rayfield:CreateWindow({
    Name = "KRISPhub V13 | TARGET FIX",
    LoadingTitle = "Cargando Configuración Privada...",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

local Tab = Window:CreateTab("Main", 4483362458)

-- Variables de Combate
local Enabled = false
local UseClosestOnly = false -- Desactivado por defecto
local SelectedTarget = nil
local AttackSpeed = 85 
local Range = 40.0     
local Prediction = 0.14

local HitRemote
pcall(function()
    HitRemote = game:GetService("ReplicatedStorage"):WaitForChild("Packages", 5):WaitForChild("Knit", 5):WaitForChild("Services", 5):WaitForChild("CombatService", 5):WaitForChild("RF", 5):WaitForChild("Hit", 5)
end)

Tab:CreateToggle({
    Name = "ACTIVAR KILL AURA",
    CurrentValue = false,
    Callback = function(Value) Enabled = Value end,
})

Tab:CreateToggle({
    Name = "Modo Automático (Solo si no hay objetivo)",
    CurrentValue = false,
    Callback = function(Value) UseClosestOnly = Value end,
})

local PlayerOptions = {"Ninguno"}
local function Refresh()
    PlayerOptions = {"Ninguno"}
    for _, plr in game.Players:GetPlayers() do
        if plr ~= game.Players.LocalPlayer then table.insert(PlayerOptions, plr.Name) end
    end
end
Refresh()

local Drop = Tab:CreateDropdown({
    Name = "FIJAR OBJETIVO (HARD LOCK)",
    Options = PlayerOptions,
    CurrentOption = {"Ninguno"},
    Callback = function(Option)
        local name = (type(Option) == "table" and Option[1]) or Option
        if name == "Ninguno" then
            SelectedTarget = nil
        else
            SelectedTarget = game.Players:FindFirstChild(name)
            Rayfield:Notify({Title = "Objetivo Fijado", Content = "Atacando solo a: "..name, Duration = 3})
        end
    end,
})

Tab:CreateButton({Name = "Actualizar Lista", Callback = function() Refresh(); Drop:Set(PlayerOptions) end})

Tab:CreateSlider({
    Name = "Rango",
    Range = {10, 45},
    Increment = 1,
    CurrentValue = 40,
    Callback = function(Value) Range = Value end,
})

-- [[ MOTOR DE ATAQUE V13 (CORREGIDO) ]] --
game:GetService("RunService").Heartbeat:Connect(function()
    if not Enabled or not HitRemote then return end
    
    local now = tick()
    if now - (getgenv().lastHit or 0) < (1 / AttackSpeed) then return end
    getgenv().lastHit = now

    local lp = game.Players.LocalPlayer
    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local target = nil

    -- LÓGICA DE PRIORIDAD ABSOLUTA
    if SelectedTarget then
        -- Si hay un objetivo en el Dropdown, EL SCRIPT SOLO MIRARÁ A ESE OBJETIVO
        if SelectedTarget.Character and SelectedTarget.Character:FindFirstChild("Humanoid") then
            local thum = SelectedTarget.Character.Humanoid
            local thrp = SelectedTarget.Character:FindFirstChild("HumanoidRootPart")
            
            if thum.Health > 0 and thrp then
                local dist = (thrp.Position - root.Position).Magnitude
                if dist <= Range then
                    target = {Hum = thum, Pos = thrp.Position + (thrp.AssemblyLinearVelocity * Prediction)}
                end
            else
                -- Si el objetivo muere o no está en rango, NO HACE NADA (Evita el cambio automático)
                target = nil
            end
        end
    elseif UseClosestOnly then
        -- EL MODO AUTOMÁTICO SOLO FUNCIONA SI NO HAS SELECCIONADO A NADIE EN EL DROPDOWN
        local dist = Range
        for _, plr in game.Players:GetPlayers() do
            if plr == lp then continue end
            local char = plr.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local m = (char.HumanoidRootPart.Position - root.Position).Magnitude
                if m <= dist then
                    dist = m
                    target = {Hum = char.Humanoid, Pos = char.HumanoidRootPart.Position + (char.HumanoidRootPart.AssemblyLinearVelocity * Prediction)}
                end
            end
        end
    end

    if target then
        task.spawn(function()
            pcall(HitRemote.InvokeServer, HitRemote, target.Hum, target.Pos)
        end)
    end
end)

Rayfield:Notify({Title = "KRISPhub V13", Content = "Fijación de objetivo corregida.", Duration = 4})
