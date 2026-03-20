
-- [[ KRISPhub Kill Aura V13.1 - PRIVATE ACCESS ]] --

-- 1. LISTA PRIVADA ACTUALIZADA
local AccesoPrivado = {
    ["CXCHXRRX_27"] = true,
    ["Rarita_RmC4"] = true,
    ["Pedrin_zxmg"] = true,
    ["Lhyyyyy_7"] = true,
    ["aupyiaiumb"] = true, -- Nuevo usuario añadido
}

-- 2. BLOQUEO TOTAL (Solo usuarios autorizados)
if not AccesoPrivado[game:GetService("Players").LocalPlayer.Name] then
    warn("ACCESO DENEGADO: Usuario no autorizado para KRISPhub.")
    return 
end

local success, Rayfield = pcall(function() 
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))() 
end)

local Window = Rayfield:CreateWindow({
    Name = "KRISPhub V13.1 | PRIVATE",
    LoadingTitle = "Verificando Acceso Privado...",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

local Tab = Window:CreateTab("Main", 4483362458)

-- Variables de Combate (Configuración V7 Estable)
local Enabled = false
local UseClosestOnly = false
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

-- [[ MOTOR DE ATAQUE V13.1 (LÓGICA MEJORADA) ]] --
game:GetService("RunService").Heartbeat:Connect(function()
    if not Enabled or not HitRemote then return end
    
    local now = tick()
    if now - (getgenv().lastHit or 0) < (1 / AttackSpeed) then return end
    getgenv().lastHit = now

    local lp = game.Players.LocalPlayer
    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local target = nil

    -- 1. SI HAY UN OBJETIVO SELECCIONADO (Prioridad Absoluta)
    if SelectedTarget then
        if SelectedTarget.Character and SelectedTarget.Character:FindFirstChild("Humanoid") then
            local thum = SelectedTarget.Character.Humanoid
            local thrp = SelectedTarget.Character:FindFirstChild("HumanoidRootPart")
            
            -- Si el objetivo está vivo y en rango, le pega
            if thum.Health > 0 and thrp then
                local dist = (thrp.Position - root.Position).Magnitude
                if dist <= Range then
                    target = {Hum = thum, Pos = thrp.Position + (thrp.AssemblyLinearVelocity * Prediction)}
                end
            else
                -- Si muere o se sale de rango, el aura NO hace nada (Anti-cambio automático)
                target = nil
            end
        end
    -- 2. SI NO HAY OBJETIVO FIJO, USA EL MODO AUTOMÁTICO (Si está activo)
    elseif UseClosestOnly then
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

    -- Ejecución de ráfaga (Original V7)
    if target then
        task.spawn(function()
            pcall(HitRemote.InvokeServer, HitRemote, target.Hum, target.Pos)
        end)
    end
end)

Rayfield:Notify({Title = "KRISPhub V13.1", Content = "Acceso verificado para la lista privada.", Duration = 4})
