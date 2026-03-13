print("Zaza Hub cargado")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local KillAura = false
local Range = 50
local Speed = 0.01

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
Frame.Size = UDim2.new(0,230,0,150)
Frame.Position = UDim2.new(0.4,0,0.4,0)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)

-- TITULO
local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "Zaza Hub - by Zaza"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1

-- BOTON
local Toggle = Instance.new("TextButton")
Toggle.Parent = Frame
Toggle.Size = UDim2.new(0.8,0,0,40)
Toggle.Position = UDim2.new(0.1,0,0.4,0)
Toggle.Text = "Kill Aura OFF"
Toggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
Toggle.TextColor3 = Color3.new(1,1,1)

-- BOTON MINIMIZAR
local Min = Instance.new("TextButton")
Min.Parent = Frame
Min.Size = UDim2.new(0,30,0,30)
Min.Position = UDim2.new(1,-35,0,0)
Min.Text = "-"

-- MINI HUB
local Mini = Instance.new("Frame")
Mini.Parent = ScreenGui
Mini.Size = UDim2.new(0,120,0,40)
Mini.Position = UDim2.new(0.4,0,0.4,0)
Mini.BackgroundColor3 = Color3.fromRGB(20,20,20)
Mini.Visible = false

local Open = Instance.new("TextButton")
Open.Parent = Mini
Open.Size = UDim2.new(1,0,1,0)
Open.Text = "Zaza Hub"

-- MINIMIZAR
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

if KillAura then
Toggle.Text = "Kill Aura ON"
else
Toggle.Text = "Kill Aura OFF"
end

end)

-- MOVER HUB MOVIL
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
	local delta = input.Position - dragStart
	Frame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

Frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = Frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

Frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
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
