print("Zaza Hub cargado")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local KillAura = false
local Range = 30
local Speed = 0.03

-- BUSCAR REMOTE DE ATAQUE
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
Frame.Size = UDim2.new(0,220,0,140)
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

local Toggle = Instance.new("TextButton")
Toggle.Parent = Frame
Toggle.Size = UDim2.new(0.8,0,0,40)
Toggle.Position = UDim2.new(0.1,0,0.4,0)
Toggle.Text = "Kill Aura OFF"
Toggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
Toggle.TextColor3 = Color3.new(1,1,1)

local Min = Instance.new("TextButton")
Min.Parent = Frame
Min.Size = UDim2.new(0,30,0,30)
Min.Position = UDim2.new(1,-35,0,0)
Min.Text = "-"

local MinFrame = Instance.new("Frame")
MinFrame.Parent = ScreenGui
MinFrame.Size = UDim2.new(0,120,0,40)
MinFrame.Position = UDim2.new(0.4,0,0.4,0)
MinFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
MinFrame.Visible = false
MinFrame.Active = true
MinFrame.Draggable = true

local Open = Instance.new("TextButton")
Open.Parent = MinFrame
Open.Size = UDim2.new(1,0,1,0)
Open.Text = "Zaza Hub"

Min.MouseButton1Click:Connect(function()
Frame.Visible = false
MinFrame.Visible = true
end)

Open.MouseButton1Click:Connect(function()
Frame.Visible = true
MinFrame.Visible = false
end)

Toggle.MouseButton1Click:Connect(function()

KillAura = not KillAura

if KillAura then
Toggle.Text = "Kill Aura ON"
else
Toggle.Text = "Kill Aura OFF"
end

end)

-- KILL AURA
RunService.Heartbeat:Connect(function()

if not KillAura then return end
if not LocalPlayer.Character then return end

local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
if not myHRP then return end

local closest
local dist = Range

for _,player in pairs(Players:GetPlayers()) do

if player ~= LocalPlayer and player.Character then

local hrp = player.Character:FindFirstChild("HumanoidRootPart")
local hum = player.Character:FindFirstChild("Humanoid")

if hrp and hum and hum.Health > 0 then

local mag = (hrp.Position - myHRP.Position).Magnitude

if mag < dist then
dist = mag
closest = player
end

end
end
end

if closest and closest.Character then

local hum = closest.Character:FindFirstChild("Humanoid")

if hum and HitRemote then
pcall(function()
HitRemote:InvokeServer(hum, myHRP.Position)
end)
end

end

task.wait(Speed)

end)
