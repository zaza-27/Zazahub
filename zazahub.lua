--// Zaza Hub

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- UI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- CONFIG
local KillAura = false
local Range = 35
local Speed = 0.2
local TargetPlayer = nil
local AttackAll = false

-- BUSCAR REMOTE
local HitRemote
pcall(function()
    HitRemote = ReplicatedStorage
        :WaitForChild("Packages")
        :WaitForChild("Knit")
        :WaitForChild("Services")
        :WaitForChild("CombatService")
        :WaitForChild("RF")
        :WaitForChild("Hit")
end)

-- KILL AURA LOOP
RunService.Heartbeat:Connect(function()

    if not KillAura then return end
    if not LocalPlayer.Character then return end

    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not HitRemote then return end

    -- PEGAR A TODOS
    if AttackAll then

        for _,player in pairs(Players:GetPlayers()) do

            if player ~= LocalPlayer and player.Character then

                local hum = player.Character:FindFirstChild("Humanoid")
                local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")

                if hum and targetHRP and hum.Health > 0 then

                    local dist = (targetHRP.Position - hrp.Position).Magnitude

                    if dist <= Range then
                        pcall(function()
                            HitRemote:InvokeServer(hum, hrp.Position)
                        end)
                    end

                end

            end
        end

    else

        -- SOLO OBJETIVO
        if TargetPlayer and TargetPlayer.Character then

            local hum = TargetPlayer.Character:FindFirstChild("Humanoid")
            local targetHRP = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")

            if hum and targetHRP and hum.Health > 0 then

                local dist = (targetHRP.Position - hrp.Position).Magnitude

                if dist <= Range then
                    pcall(function()
                        HitRemote:InvokeServer(hum, hrp.Position)
                    end)
                end

            end

        end

    end

    task.wait(Speed)

end)

-- CREAR HUB
local Window = WindUI:CreateWindow({
    Title = "Zaza Hub",
    Author = "Joel",
    Folder = "ZazaHub",
    Icon = "solar:sword-bold",

    OpenButton = {
        Title = "Hub",
        Draggable = true,
        Enabled = true,
        Size = UDim2.new(0,100,0,30)
    },
})

-- TAB
local CombatTab = Window:Tab({
    Title = "Combat",
    Icon = "solar:sword-bold"
})

CombatTab:Section({
    Title = "Kill Aura"
})

-- ACTIVAR AURA
CombatTab:Toggle({
    Title = "Activar Kill Aura",
    Callback = function(state)
        KillAura = state
    end
})

-- RANGO
CombatTab:Slider({
    Title = "Rango",
    Value = 35,
    Min = 10,
    Max = 150,
    Step = 1,
    Callback = function(value)
        Range = value
    end
})

-- VELOCIDAD
CombatTab:Slider({
    Title = "Velocidad",
    Value = 0.2,
    Min = 0.05,
    Max = 1,
    Step = 0.01,
    Callback = function(value)
        Speed = value
    end
})

-- PEGAR A TODOS
CombatTab:Toggle({
    Title = "Pegar a todos",
    Callback = function(state)
        AttackAll = state
    end
})

-- QUITAR OBJETIVO
CombatTab:Button({
    Title = "Quitar objetivo",
    Callback = function()
        TargetPlayer = nil
    end
})

-- LISTA DE JUGADORES
CombatTab:Section({
    Title = "Seleccionar jugador"
})

local function AddPlayer(player)

    if player == LocalPlayer then return end

    CombatTab:Button({
        Title = player.Name,
        Callback = function()
            TargetPlayer = player
        end
    })

end

for _,player in pairs(Players:GetPlayers()) do
    AddPlayer(player)
end

Players.PlayerAdded:Connect(function(player)
    AddPlayer(player)
end)

-- BOTON FLOTANTE
local FloatButton = Instance.new("TextButton")
FloatButton.Parent = game.CoreGui
FloatButton.Size = UDim2.new(0,50,0,50)
FloatButton.Position = UDim2.new(0.9,0,0.5,0)
FloatButton.Text = "⚡"
FloatButton.BackgroundColor3 = Color3.fromRGB(20,20,20)
FloatButton.TextScaled = true
FloatButton.Draggable = true

FloatButton.MouseButton1Click:Connect(function()

    KillAura = not KillAura

    if KillAura then
        FloatButton.Text = "⚡ON"
    else
        FloatButton.Text = "⚡OFF"
    end

end)

WindUI:Notify({
    Title = "Zaza Hub cargado",
    Content = "Kill Aura listo | Range 35 | Speed 0.2",
    Duration = 5
})
