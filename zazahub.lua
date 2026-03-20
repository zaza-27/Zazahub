-- [[ KRISPhub Kill Aura V13.2 - ULTRA COMPATIBLE ]] --

-- 1. CONFIGURACIÓN DE ACCESO (Whitelist Directa)
local MyUser = game:GetService("Players").LocalPlayer.Name
local AccesoPrivado = {
    ["CXCHXRRX_27"] = true,
    ["Rarita_RmC4"] = true,
    ["Lhyyyyy_7"] = true,
    ["aupyiaiumb"] = true,
    ["Rojas123728"] = true -- Tu usuario
}

-- Verificación de Seguridad
if not AccesoPrivado[MyUser] then
    warn("ACCESO DENEGADO PARA: " .. MyUser)
    return
end

-- 2. CARGA DE LA INTERFAZ (Método Seguro)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "KRISPhub V13.2 | PRIVATE",
    LoadingTitle = "Cargando Motor de Hits...",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

local Tab = Window:CreateTab("Main", 4483362458)

-- 3. VARIABLES DE COMBATE (VELOCIDAD Y RANGO MAXIMIZADOS)
local Enabled = false
local UseClosestOnly = false
local SelectedTarget = nil
local AttackSpeed = 120 -- Velocidad de ráfaga (Máxima estable)
local Range = 55.0      -- Rango de alcance (Máximo seguro)
local Prediction = 0.16 -- Precisión de seguimiento

-- Buscador de Remote (CombatService)
local HitRemote
pcall(function()
    HitRemote = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("CombatService"):WaitForChild("RF"):WaitForChild("Hit")
end)

-- 4. ELEMENTOS DE LA UI
Tab:CreateToggle({
    Name = "ACTIVAR KILL AURA",
    CurrentValue = false,
    Callback = function(Value) Enabled = Value end,
})

Tab:CreateToggle({
    Name = "Modo Automático",
    CurrentValue = false,
    Callback = function(Value) UseClosestOnly = Value end,
})

local PlayerOptions = {"Ninguno"}
local function RefreshList()
    PlayerOptions = {"Ninguno"}
    for _, plr in game.Players:GetPlayers() do
        if plr ~= game.Players.LocalPlayer then table.insert(PlayerOptions, plr.Name) end
    end
end
RefreshList()

local Drop = Tab:CreateDropdown({
    Name = "FIJAR OBJETIVO",
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

Tab:CreateButton({Name = "Actualizar Lista", Callback = function() RefreshList(); Drop:Set(PlayerOptions) end})

-- 5. MOTOR DE ATAQUE (SIN FALLOS)
game:GetService("RunService").Heartbeat:Connect(function()
    if not Enabled or not HitRemote then return end
    
    local now = tick()
    if now - (getgenv().lastHit or 0) < (1 / AttackSpeed) then return end
    getgenv().lastHit = now

    local lp = game.Players.LocalPlayer
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local target = nil

    -- Lógica de Prioridad de Objetivo
    if SelectedTarget and SelectedTarget.Character and SelectedTarget.Character:FindFirstChild("Humanoid") then
        local thum = SelectedTarget.Character.Humanoid
        local thrp = SelectedTarget.Character:FindFirstChild("HumanoidRootPart")
        
        if thum.Health > 0 and thrp then
            if (thrp.Position - root.Position).Magnitude <= Range then
                target = {Hum = thum, Pos = thrp.Position + (thrp.AssemblyLinearVelocity * Prediction)}
            end
        end
    elseif UseClosestOnly then
        local dist = Range
        for _, plr in game.Players:GetPlayers() do
            if plr == lp then continue end
            local pchar = plr.Character
            if pchar and pchar:FindFirstChild("Humanoid") and pchar.Humanoid.Health > 0 and pchar:FindFirstChild("HumanoidRootPart") then
                local m = (pchar.HumanoidRootPart.Position - root.Position).Magnitude
                if m <= dist then
                    dist = m
                    target = {Hum = pchar.Humanoid, Pos = pchar.HumanoidRootPart.Position + (pchar.HumanoidRootPart.AssemblyLinearVelocity * Prediction)}
                end
            end
        end
    end

    -- Ejecución de ráfaga de alta prioridad
    if target then
        task.spawn(function()
            pcall(function() HitRemote:InvokeServer(target.Hum, target.Pos) end)
        end)
    end
end)

Rayfield:Notify({Title = "KRISPhub V13.2", Content = "Listo para usar.", Duration = 3})
