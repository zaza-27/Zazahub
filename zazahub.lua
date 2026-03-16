-- KRISPhub Kill Aura - Rayfield FIXED 2026
-- + Whitelist simple por NOMBRE DE USUARIO (Username)

local Whitelist = {
    -- Pon aquí los nombres de usuario exactos (case-sensitive)
    "Joel",             -- ejemplo: tu username
    "TuAmigo123",       -- otro ejemplo
    "ProGamerX",        -- agrega los que quieras
}

local function IsWhitelisted(player)
    if not player or not player.Name then return false end
    
    for _, whitelistedName in ipairs(Whitelist) do
        if player.Name == whitelistedName then
            return true
        end
    end
    
    return false
end

-- Solo los que estén en la lista pueden cargar/usar el script
local LocalPlayer = game.Players.LocalPlayer
if not IsWhitelisted(LocalPlayer) then
    warn("No estás en la whitelist de KRISPhub Kill Aura (por username). Script bloqueado.")
    return
end

-- Todo el script original a partir de aquí (sin ningún cambio)

local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    warn("Rayfield falló al cargar. Prueba otro executor o verifica internet.")
    return
end

local Window = Rayfield:CreateWindow({
    Name = "KRISPhub Kill Aura",
    LoadingTitle = "KRISPhub",
    LoadingSubtitle = "Kill Aura v3 - 45+ hits/s",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

local Tab = Window:CreateTab("Main", 4483362458)

local Section = Tab:CreateSection("Controles Kill Aura")

-- Variables
local Enabled = false
local UseClosestOnly = true
local SelectedTarget = nil
local AttackSpeed = 45   -- puedes subir a 50-55 si tu executor lo aguanta
local Range = 23.5
local MaxTargets = 6
local Prediction = 0.14

-- Remote (cámbialo si tu juego usa otro path)
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

if not HitRemote then
    Rayfield:Notify({
        Title = "Advertencia",
        Content = "No se encontró el remote 'Hit'. Aura no golpeará.",
        Duration = 8,
    })
end

-- Toggle principal
Tab:CreateToggle({
    Name = "Activar Kill Aura",
    CurrentValue = false,
    Callback = function(Value)
        Enabled = Value
        Rayfield:Notify({Title = "Kill Aura", Content = Value and "Activado (45 hits/s)" or "Desactivado", Duration = 3})
    end,
})

-- Toggle Closest Only
Tab:CreateToggle({
    Name = "Solo el más cercano (ignora objetivo)",
    CurrentValue = true,
    Callback = function(Value)
        UseClosestOnly = Value
    end,
})

-- Dropdown jugadores
local PlayerOptions = {"Ninguno"}
local function RefreshPlayers()
    PlayerOptions = {"Ninguno"}
    for _, plr in game.Players:GetPlayers() do
        if plr ~= game.Players.LocalPlayer then
            table.insert(PlayerOptions, plr.Name .. " (" .. (plr.DisplayName or plr.Name) .. ")")
        end
    end
end

RefreshPlayers()
game.Players.PlayerAdded:Connect(RefreshPlayers)
game.Players.PlayerRemoving:Connect(RefreshPlayers)

Tab:CreateDropdown({
    Name = "Objetivo Específico (si Closest OFF)",
    Options = PlayerOptions,
    CurrentOption = {"Ninguno"},
    Callback = function(Option)
        if Option == "Ninguno" then
            SelectedTarget = nil
            return
        end
        local name = Option:match("^([^%s]+)")
        SelectedTarget = game.Players:FindFirstChild(name)
    end,
})

-- Sliders
Tab:CreateSlider({
    Name = "Velocidad de Golpes",
    Range = {20, 60},
    Increment = 1,
    Suffix = "hits/s",
    CurrentValue = 45,
    Callback = function(Value)
        AttackSpeed = Value
    end,
})

Tab:CreateSlider({
    Name = "Rango Máximo",
    Range = {15, 35},
    Increment = 0.5,
    Suffix = "studs",
    CurrentValue = 23.5,
    Callback = function(Value)
        Range = Value
    end,
})

Tab:CreateButton({
    Name = "Refrescar Lista Jugadores",
    Callback = function()
        RefreshPlayers()
        Rayfield:Notify({Title = "Lista Actualizada", Content = #PlayerOptions-1 .. " jugadores detectados", Duration = 4})
    end,
})

-- Motor principal
local lastHit = 0
game:GetService("RunService").Heartbeat:Connect(function()
    if not Enabled or not HitRemote then return end

    local now = tick()
    if now - lastHit < (1 / AttackSpeed) then return end
    lastHit = now

    local char = game.Players.LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local myPos = root.Position
    local targets = {}

    if UseClosestOnly then
        local closestDist = math.huge
        local closest = nil

        for _, plr in game.Players:GetPlayers() do
            if plr == game.Players.LocalPlayer then continue end
            local tchar = plr.Character
            if not tchar then continue end
            local thrp = tchar:FindFirstChild("HumanoidRootPart")
            local thum = tchar:FindFirstChild("Humanoid")
            if not thrp or not thum or thum.Health <= 0 then continue end

            local dist = (thrp.Position - myPos).Magnitude
            if dist < closestDist and dist <= Range then
                closestDist = dist
                closest = {Hum = thum, Pos = thrp.Position + thrp.AssemblyLinearVelocity * Prediction}
            end
        end

        if closest then table.insert(targets, closest) end
    else
        -- Objetivo + multi si no hay
        if SelectedTarget and SelectedTarget.Character then
            local tchar = SelectedTarget.Character
            local thrp = tchar:FindFirstChild("HumanoidRootPart")
            local thum = tchar:FindFirstChild("Humanoid")
            if thrp and thum and thum.Health > 0 then
                local dist = (thrp.Position - myPos).Magnitude
                if dist <= Range then
                    table.insert(targets, {Hum = thum, Pos = thrp.Position + thrp.AssemblyLinearVelocity * Prediction})
                end
            end
        end

        if #targets == 0 then
            for _, plr in game.Players:GetPlayers() do
                if plr == game.Players.LocalPlayer then continue end
                local tchar = plr.Character
                if not tchar then continue end
                local thrp = tchar:FindFirstChild("HumanoidRootPart")
                local thum = tchar:FindFirstChild("Humanoid")
                if not thrp or not thum or thum.Health <= 0 then continue end

                local dist = (thrp.Position - myPos).Magnitude
                if dist <= Range then
                    table.insert(targets, {Hum = thum, Pos = thrp.Position + thrp.AssemblyLinearVelocity * Prediction})
                    if #targets >= MaxTargets then break end
                end
            end
        end
    end

    for _, tgt in targets do
        task.spawn(function()
            pcall(HitRemote.InvokeServer, HitRemote, tgt.Hum, tgt.Pos)
        end)
    end
end)

Rayfield:Notify({
    Title = "Listo",
    Content = "Kill Aura cargado | Prueba con 35-45 hits/s primero",
    Duration = 6,
})
