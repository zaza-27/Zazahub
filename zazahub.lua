-- [[ KRISPhub Kill Aura V7 - FIX WHITELIST & SPEED ]] --

-- CONFIGURACIÓN DE SEGURIDAD
local WhitelistNames = { 
    "CXCHXRRX_27", 
    "Rarita_RmC4",
    game.Players.LocalPlayer.Name -- ESTO GARANTIZA QUE TÚ SIEMPRE ENTRES
}

local function CheckAuth()
    local lp = game.Players.LocalPlayer
    for _, name in ipairs(WhitelistNames) do
        if lp.Name == name then 
            return true 
        end
    end
    return false
end

-- Ejecución de la Whitelist
if not CheckAuth() then
    warn("ACCESO DENEGADO: Tu usuario no está en la lista.")
    return
end

-- CARGA DE RAYFIELD
local success, Rayfield = pcall(function() 
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))() 
end)

if not success then return end

local Window = Rayfield:CreateWindow({
    Name = "KRISPhub V7 | FIX FINAL",
    LoadingTitle = "Verificando Usuario...",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

local Tab = Window:CreateTab("Combat", 4483362458)

-- VARIABLES DE COMBATE
local Enabled = false
local UseClosestOnly = false
local SelectedTarget = nil
local Range = 40.0
local BurstPower = 20 -- Balance perfecto: Velocidad masiva sin lag

-- LOCALIZACIÓN DEL REMOTE
local HitRemote
pcall(function()
    HitRemote = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("CombatService"):WaitForChild("RF"):WaitForChild("Hit")
end)

-- INTERFAZ
Tab:CreateToggle({
    Name = "ACTIVAR KILL AURA",
    CurrentValue = false,
    Callback = function(Value) Enabled = Value end,
})

Tab:CreateToggle({
    Name = "Modo Automático (Cercano)",
    CurrentValue = false,
    Callback = function(Value) UseClosestOnly = Value end,
})

-- LISTA DE OBJETIVOS
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
    Name = "FIJAR OBJETIVO (HARD LOCK)",
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
    Name = "Refrescar Jugadores",
    Callback = function() 
        RefreshPlayers()
        PlayerDropdown:Set(PlayerOptions)
    end,
})

Tab:CreateSlider({
    Name = "Rango de Masacre",
    Range = {10, 45},
    Increment = 1,
    CurrentValue = 40,
    Callback = function(Value) Range = Value end,
})

-- MOTOR DE ATAQUE OPTIMIZADO (FLUIDO Y RÁPIDO)
game:GetService("RunService").Heartbeat:Connect(function()
    if not Enabled or not HitRemote then return end
    
    local lp = game.Players.LocalPlayer
    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local targetData = nil

    -- Prioridad: Objetivo Seleccionado
    if SelectedTarget and SelectedTarget.Character then
        local tchar = SelectedTarget.Character
        local thum = tchar:FindFirstChild("Humanoid")
        local thrp = tchar:FindFirstChild("HumanoidRootPart")
        if thum and thum.Health > 0 then
            local dist = (thrp.Position - root.Position).Magnitude
            if dist <= Range then
                targetData = {Hum = thum, Pos = thrp.Position}
            end
        end
    end

    -- Si no hay seleccionado o está lejos, usar el más cercano (si el modo está activo)
    if not targetData and UseClosestOnly then
        local closestDist = Range
        for _, plr in game.Players:GetPlayers() do
            if plr == lp then continue end
            local tchar = plr.Character
            local thum = tchar and tchar:FindFirstChild("Humanoid")
            local thrp = tchar and tchar:FindFirstChild("HumanoidRootPart")
            if thum and thum.Health > 0 and thrp then
                local dist = (thrp.Position - root.Position).Magnitude
                if dist <= closestDist then
                    closestDist = dist
                    targetData = {Hum = thum, Pos = thrp.Position}
                end
            end
        end
    end

    -- Ejecución de ráfaga
    if targetData then
        task.spawn(function()
            for i = 1, BurstPower do
                pcall(function() 
                    HitRemote:InvokeServer(targetData.Hum, targetData.Pos) 
                end)
            end
        end)
    end
end)

Rayfield:Notify({Title = "KRISPhub V7", Content = "Whitelist Correcta. Disfruta de la masacre.", Duration = 4})
