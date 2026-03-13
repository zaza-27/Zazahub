--// UNIVERSAL HUB SCRIPT

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- CONFIG
local KillAura = false
local Range = 35
local Speed = 0.1
local TargetPlayer = nil
local AttackAll = false

-- Buscar remote de ataque
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

-- Encontrar jugador más cercano
local function GetClosestPlayer()

    local closest = nil
    local dist = Range

    for _,player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then

            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChild("Humanoid")

            if hrp and hum and hum.Health > 0 then

                if TargetPlayer and player.Name ~= TargetPlayer then
                    continue
                end

                local mag = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude

                if mag < dist then
                    dist = mag
                    closest = player
                end

            end
        end
    end

    return closest
end

-- Kill Aura Loop
RunService.Heartbeat:Connect(function()

    if not KillAura then return end
    if not LocalPlayer.Character then return end
    if not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    if not HitRemote then return end

    if AttackAll then

        for _,player in pairs(Players:GetPlayers()) do

            if player ~= LocalPlayer and player.Character then

                local hum = player.Character:FindFirstChild("Humanoid")

                if hum and hum.Health > 0 then

                    pcall(function()
                        HitRemote:InvokeServer(hum, LocalPlayer.Character.HumanoidRootPart.Position)
                    end)

                end
            end
        end

    else

        local target = GetClosestPlayer()

        if target and target.Character then

            local hum = target.Character:FindFirstChild("Humanoid")

            if hum then

                pcall(function()
                    HitRemote:InvokeServer(hum, LocalPlayer.Character.HumanoidRootPart.Position)
                end)

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
        Size = UDim2.new(0,100,0,30) -- BOTON MAS PEQUEÑO
    },
})

-- TAB COMBAT
local CombatTab = Window:Tab({
    Title = "Combat",
    Icon = "solar:sword-bold"
})

CombatTab:Section({
    Title = "Kill Aura"
})

-- Toggle KillAura
CombatTab:Toggle({

    Title = "Activar Kill Aura",

    Callback = function(state)
        KillAura = state
    end

})

-- Slider Rango
CombatTab:Slider({

    Title = "Rango",

    Value = Range,
    Min = 10,
    Max = 100,
    Step = 1,

    Callback = function(value)
        Range = value
    end

})

-- Slider Velocidad
CombatTab:Slider({

    Title = "Velocidad de Golpe",

    Value = Speed,
    Min = 0.05,
    Max = 1,
    Step = 0.01,

    Callback = function(value)
        Speed = value
    end

})

-- Target por nombre
CombatTab:Textbox({

    Title = "Nombre del jugador",

    Placeholder = "Escribe el nombre",

    Callback = function(text)

        if text == "" then
            TargetPlayer = nil
        else
            TargetPlayer = text
        end

    end

})

-- Pegar a todos
CombatTab:Toggle({

    Title = "Pegar a todos",

    Callback = function(state)
        AttackAll = state
    end

})

WindUI:Notify({
    Title = "Zaza Hub cargado",
    Content = "Kill Aura listo | Speed 0.1 | Range 35",
    Duration = 5
})
