-- [[ KRISPhub Kill Aura V6.1 - SMOOTH OVERCLOCK ]] --

local Whitelist = { 
    "CXCHXRRX_27", 
    "Rarita_RmC4", 
    game.Players.LocalPlayer.Name 
}

local function IsWhitelisted(player)
    for _, name in ipairs(Whitelist) do
        if player.Name == name then return true end
    end
    return false
end

if not IsWhitelisted(game.Players.LocalPlayer) then return end

local success, Rayfield = pcall(function() 
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))() 
end)

local Window = Rayfield:CreateWindow({
    Name = "KRISPhub V6.1 | FLUID SPEED",
    LoadingTitle = "Optimizando Rendimiento...",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

local Tab = Window:CreateTab("Main", 4483362458)

local Enabled = false
local UseClosestOnly = false
local SelectedTarget = nil
local Range = 40.0
local BurstPower = 15 -- Reducido a 15 para evitar congelamientos, pero sigue siendo letal

local HitRemote
pcall(function()
    HitRemote = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("CombatService"):WaitForChild("RF"):WaitForChild("Hit")
end)

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
    Name = "HARD LOCK (OBJETIVO)",
    Options = PlayerOptions,
    CurrentOption = {"Ninguno"},
    Callback = function(Option)
        local name = type(Option) == "table" and Option[1] or Option
        if name == "Ninguno" then
            SelectedTarget = nil
        else
            SelectedTarget = game.Players:FindFirstChild(name)
        end
    end,
})

Tab:CreateButton({
    Name = "Refrescar Lista",
    Callback = function() 
        RefreshPlayers()
        PlayerDropdown:Set(PlayerOptions)
    end,
})

Tab:CreateSlider({
    Name = "Rango de Alcance",
    Range = {10, 40},
    Increment = 1,
    CurrentValue = 40,
    Callback = function(Value) Range = Value end,
})

-- [[ MOTOR OPTIMIZADO PARA EVITAR CONGELAMIENTOS ]] --
game:GetService("RunService").Heartbeat:Connect(function()
    if not Enabled or not HitRemote then return end
    
    local char = game.Players.LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local targetData = nil

    -- Selección eficiente de un solo objetivo para ahorrar recursos
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
    elseif UseClosestOnly then
        local closestDist = Range
        for _, plr in game.Players:GetPlayers() do
            if plr == game.Players.LocalPlayer then continue end
            local tchar = plr.Character
            if tchar and tchar:FindFirstChild("Humanoid") and tchar:FindFirstChild("HumanoidRootPart") then
                local dist = (tchar.HumanoidRootPart.Position - root.Position).Magnitude
                if dist <= closestDist then
                    closestDist = dist
                    targetData = {Hum = tchar.Humanoid, Pos = tchar.HumanoidRootPart.Position}
                end
            end
        end
    end

    -- Si hay objetivo, enviamos la ráfaga de forma asíncrona pero ligera
    if targetData then
        task.spawn(function()
            for i = 1, BurstPower do 
                -- Intentamos golpear; si falla por lag, el pcall evita que el juego se cierre
                pcall(function() 
                    HitRemote:InvokeServer(targetData.Hum, targetData.Pos) 
                end)
            end
        end)
    end
end)

Rayfield:Notify({Title = "KRISPhub V6.1", Content = "Optimización de fluidez activa. Cero congelamientos.", Duration = 5})
