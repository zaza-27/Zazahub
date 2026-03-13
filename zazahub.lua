-- ⚡ Zaza Hub (Transparente)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- CONFIG
local KillAura = false
local Range = 35
local Speed = 0.3
local TargetPlayer = nil
local AttackAll = false

-- HIT REMOTE
local HitRemote = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("Knit")
    :WaitForChild("Services")
    :WaitForChild("CombatService")
    :WaitForChild("RF")
    :WaitForChild("Hit")

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,320,0,300)
Frame.Position = UDim2.new(0.4,0,0.3,0)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.BackgroundTransparency = 0.25
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

-- TITULO
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,40)
Title.Text = "⚡ Zaza Hub"
Title.BackgroundColor3 = Color3.fromRGB(30,30,30)
Title.BackgroundTransparency = 0.2
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

-- BOTON KILLAURA
local Toggle = Instance.new("TextButton", Frame)
Toggle.Size = UDim2.new(0.8,0,0,35)
Toggle.Position = UDim2.new(0.1,0,0.2,0)
Toggle.Text = "Kill Aura OFF"
Toggle.BackgroundColor3 = Color3.fromRGB(50,50,50)
Toggle.BackgroundTransparency = 0.3
Toggle.TextColor3 = Color3.new(1,1,1)

-- INPUT NOMBRE
local TargetInput = Instance.new("TextBox", Frame)
TargetInput.Size = UDim2.new(0.8,0,0,30)
TargetInput.Position = UDim2.new(0.1,0,0.35,0)
TargetInput.PlaceholderText = "Nombre del jugador"
TargetInput.BackgroundColor3 = Color3.fromRGB(40,40,40)
TargetInput.BackgroundTransparency = 0.3
TargetInput.TextColor3 = Color3.new(1,1,1)

-- BOTON TARGET
local TargetButton = Instance.new("TextButton", Frame)
TargetButton.Size = UDim2.new(0.8,0,0,30)
TargetButton.Position = UDim2.new(0.1,0,0.48,0)
TargetButton.Text = "🎯 Usar Target"
TargetButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
TargetButton.BackgroundTransparency = 0.3
TargetButton.TextColor3 = Color3.new(1,1,1)

-- BOTON TODOS
local AllButton = Instance.new("TextButton", Frame)
AllButton.Size = UDim2.new(0.8,0,0,30)
AllButton.Position = UDim2.new(0.1,0,0.6,0)
AllButton.Text = "🌍 Pegar a todos"
AllButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
AllButton.BackgroundTransparency = 0.3
AllButton.TextColor3 = Color3.new(1,1,1)

-- TEXTO RANGO
local RangeLabel = Instance.new("TextLabel", Frame)
RangeLabel.Size = UDim2.new(0.6,0,0,30)
RangeLabel.Position = UDim2.new(0.2,0,0.75,0)
RangeLabel.Text = "Range: "..Range
RangeLabel.TextColor3 = Color3.new(1,1,1)
RangeLabel.BackgroundTransparency = 1

-- BOTON -
local Minus = Instance.new("TextButton", Frame)
Minus.Size = UDim2.new(0,40,0,30)
Minus.Position = UDim2.new(0.05,0,0.75,0)
Minus.Text = "-"
Minus.BackgroundColor3 = Color3.fromRGB(50,50,50)
Minus.BackgroundTransparency = 0.3

-- BOTON +
local Plus = Instance.new("TextButton", Frame)
Plus.Size = UDim2.new(0,40,0,30)
Plus.Position = UDim2.new(0.85,-40,0.75,0)
Plus.Text = "+"
Plus.BackgroundColor3 = Color3.fromRGB(50,50,50)
Plus.BackgroundTransparency = 0.3

Minus.MouseButton1Click:Connect(function()
    if Range > 10 then
        Range = Range - 5
        RangeLabel.Text = "Range: "..Range
    end
end)

Plus.MouseButton1Click:Connect(function()
    if Range < 100 then
        Range = Range + 5
        RangeLabel.Text = "Range: "..Range
    end
end)

-- MINIMIZAR
local Min = Instance.new("TextButton", Frame)
Min.Size = UDim2.new(0,30,0,30)
Min.Position = UDim2.new(1,-35,0,5)
Min.Text = "-"
Min.BackgroundColor3 = Color3.fromRGB(60,60,60)
Min.BackgroundTransparency = 0.3

-- MINI HUB
local Mini = Instance.new("Frame", ScreenGui)
Mini.Size = UDim2.new(0,80,0,35)
Mini.Position = UDim2.new(1,-90,1,-60)
Mini.BackgroundColor3 = Color3.fromRGB(25,25,25)
Mini.BackgroundTransparency = 0.3
Mini.Visible = false
Mini.Active = true
Mini.Draggable = true

local Open = Instance.new("TextButton", Mini)
Open.Size = UDim2.new(1,0,1,0)
Open.Text = "⚡Zaza"
Open.TextColor3 = Color3.new(1,1,1)
Open.BackgroundColor3 = Color3.fromRGB(35,35,35)
Open.BackgroundTransparency = 0.3

Min.MouseButton1Click:Connect(function()
    Frame.Visible = false
    Mini.Visible = true
end)

Open.MouseButton1Click:Connect(function()
    Frame.Visible = true
    Mini.Visible = false
end)

-- TOGGLE
Toggle.MouseButton1Click:Connect(function()
    KillAura = not KillAura
    Toggle.Text = KillAura and "Kill Aura ON" or "Kill Aura OFF"
end)

-- TARGET
TargetButton.MouseButton1Click:Connect(function()
    local name = TargetInput.Text
    if Players:FindFirstChild(name) then
        TargetPlayer = name
        AttackAll = false
    end
end)

-- TODOS
AllButton.MouseButton1Click:Connect(function()
    AttackAll = true
    TargetPlayer = nil
end)

-- ATAQUE
RunService.Heartbeat:Connect(function()

    if not KillAura then return end
    if not LocalPlayer.Character then return end

    local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    for _,player in pairs(Players:GetPlayers()) do

        if player ~= LocalPlayer and player.Character then

            local hum = player.Character:FindFirstChild("Humanoid")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")

            if hum and hrp and hum.Health > 0 then

                if TargetPlayer and player.Name ~= TargetPlayer then
                    continue
                end

                if (hrp.Position - myHRP.Position).Magnitude <= Range then
                    pcall(function()
                        HitRemote:InvokeServer(hum, myHRP.Position)
                    end)
                end

            end

        end

    end

    task.wait(Speed)

end)
