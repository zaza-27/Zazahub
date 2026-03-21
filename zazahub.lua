local MyUser = game:GetService("Players").LocalPlayer.Name
local AccesoPrivado = {
    ["CXCHXRRX_27"] = true,
    ["Rarita_RmC4"] = true,
    ["Lhyyyyy_7"] = true,
    ["aupyiaiumb"] = true,
    ["ale_vasquez20"] = true,
    ["Pedrin_zxm"] = true,
    ["bruno123456770"] = true
}

if not AccesoPrivado[MyUser] then 
    warn("ACCESO DENEGADO")
    return 
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Zazahub V13.2 | GOD MODE",
    LoadingTitle = "Cargando Hyper-Hits...",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

local Tab = Window:CreateTab("Combat", 4483362458)

local Enabled = false
local UseClosestOnly = false
local SelectedTarget = nil
local AttackSpeed = 250
local Range = 55.0      
local Prediction = 0.18 

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

Tab:CreateButton({
    Name = "Actualizar Lista",
    Callback = function() 
        RefreshList()
        Drop:Set(PlayerOptions) 
    end
})

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

    if SelectedTarget and SelectedTarget.Character and SelectedTarget.Character:FindFirstChild("Humanoid") then
        local thum = SelectedTarget.Character.Humanoid
        local thrp = SelectedTarget.Character:FindFirstChild("HumanoidRootPart")
        if thum.Health > 0 and thrp and (thrp.Position - root.Position).Magnitude <= Range then
            target = {Hum = thum, Pos = thrp.Position + (thrp.AssemblyLinearVelocity * Prediction)}
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

    if target then
        task.spawn(function()
            pcall(function() HitRemote:InvokeServer(target.Hum, target.Pos) end)
            task.wait()
            pcall(function() HitRemote:InvokeServer(target.Hum, target.Pos) end)
            task.wait()
            pcall(function() HitRemote:InvokeServer(target.Hum, target.Pos) end)
            task.wait()
            pcall(function() HitRemote:InvokeServer(target.Hum, target.Pos) end)
        end)
    end
end)

Rayfield:Notify({Title = "Zazahub V13.2", Content = "Hyper-Hits Activos.", Duration = 4})
