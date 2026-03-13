-- Zaza Hub by Zaza

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- CONFIG
local KillAura = false
local Range = 35
local Speed = 0.3
local TargetPlayer = nil

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

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0,260,0,220)
Frame.Position = UDim2.new(0.4,0,0.4,0)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "Zaza Hub - by Zaza"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1

-- KILLAURA BOTON
local Toggle = Instance.new("TextButton")
Toggle.Parent = Frame
Toggle.Size = UDim2.new(0.8,0,0,40)
Toggle.Position = UDim2.new(0.1,0,0.25,0)
Toggle.Text = "Kill Aura OFF"
Toggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
Toggle.TextColor3 = Color3.new(1,1,1)

-- TARGET BOTON
local TargetButton = Instance.new("TextButton")
TargetButton.Parent = Frame
TargetButton.Size = UDim2.new(0.8,0,0,40)
TargetButton.Position = UDim2.new(0.1,0,0.5,0)
TargetButton.Text = "Target: Closest"
TargetButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
TargetButton.TextColor3 = Color3.new(1,1,1)

-- TEXTO RANGO
local RangeLabel = Instance.new("TextLabel")
RangeLabel.Parent = Frame
RangeLabel.Size = UDim2.new(0.6,0,0,30)
RangeLabel.Position = UDim2.new(0.2,0,0.75,0)
RangeLabel.Text = "Range: "..Range
RangeLabel.TextColor3 = Color3.new(1,1,1)
RangeLabel.BackgroundTransparency = 1

-- BOTON MENOS
local Minus = Instance.new("TextButton")
Minus.Parent = Frame
Minus.Size = UDim2.new(0,40,0,30)
Minus.Position = UDim2.new(0.05,0,0.75,0)
Minus.Text = "-"

-- BOTON MAS
local Plus = Instance.new("TextButton")
Plus.Parent = Frame
Plus.Size = UDim2.new(0,40,0,30)
Plus.Position = UDim2.new(0.85,-40,0.75,0)
Plus.Text = "+"

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
local Min = Instance.new("TextButton")
Min.Parent = Frame
Min.Size = UDim2.new(0,30,0,30)
Min.Position = UDim2.new(1,-35,0,0)
Min.Text = "-"

local Mini = Instance.new("Frame")
Mini.Parent = ScreenGui
Mini.Size = UDim2.new(0,120,0,40)
Mini.Position = UDim2.new(1,-130,1,-60)
Mini.BackgroundColor3 = Color3.fromRGB(20,20,20)
Mini.Visible = false
Mini.Active = true
Mini.Draggable = true

local Open = Instance.new("TextButton")
Open.Parent = Mini
Open.Size = UDim2.new(1,0,1,0)
Open.Text = "Zaza Hub"

Min.MouseButton1Click:Connect(function()
Frame.Visible = false
Mini.Visible = true
end)

Open.MouseButton1Click:Connect(function()
Frame.Visible = true
Mini.Visible = false
end)

-- ACTIVAR KILLAURA
Toggle.MouseButton1Click:Connect(function()

KillAura = not KillAura

if KillAura then
Toggle.Text = "Kill Aura ON"
else
Toggle.Text = "Kill Aura OFF"
end

end)

-- CAMBIAR TARGET
local index = 1
TargetButton.MouseButton1Click:Connect(function()

local players = Players:GetPlayers()

index = index + 1
if index > #players then
index = 1
end

if players[index] == LocalPlayer then
index = index + 1
end

TargetPlayer = players[index]

if TargetPlayer then
TargetButton.Text = "Target: "..TargetPlayer.Name
else
TargetButton.Text = "Target: Closest"
end

end)

-- KILL AURA
RunService.Heartbeat:Connect(function()

if not KillAura then return end
if not LocalPlayer.Character then return end

local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
if not myHRP then return end

local target = TargetPlayer
local dist = Range

if not target then

for _,player in pairs(Players:GetPlayers()) do

if player ~= LocalPlayer and player.Character then

local hrp = player.Character:FindFirstChild("HumanoidRootPart")
local hum = player.Character:FindFirstChild("Humanoid")

if hrp and hum and hum.Health > 0 then

local mag = (hrp.Position - myHRP.Position).Magnitude

if mag < dist then
dist = mag
target = player
end

end
end
end

end

if target and target.Character then

local hum = target.Character:FindFirstChild("Humanoid")

if hum and HitRemote then
pcall(function()
HitRemote:InvokeServer(hum, myHRP.Position)
end)
end

end

task.wait(Speed)

end)
