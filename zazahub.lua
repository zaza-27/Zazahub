-- Zaza Hub - By Zaza

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Range = 30
local KillAura = false
local TargetName = nil

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0,220,0,160)
Frame.Position = UDim2.new(0.5,-110,0.5,-80)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "Zaza Hub - by Zaza"
Title.BackgroundColor3 = Color3.fromRGB(0,0,0)
Title.TextColor3 = Color3.fromRGB(255,255,255)

local Toggle = Instance.new("TextButton")
Toggle.Parent = Frame
Toggle.Size = UDim2.new(1,-20,0,30)
Toggle.Position = UDim2.new(0,10,0,40)
Toggle.Text = "Kill Aura: OFF"

local TargetBox = Instance.new("TextBox")
TargetBox.Parent = Frame
TargetBox.Size = UDim2.new(1,-20,0,30)
TargetBox.Position = UDim2.new(0,10,0,80)
TargetBox.PlaceholderText = "Target Player Name"

local Minimize = Instance.new("TextButton")
Minimize.Parent = Frame
Minimize.Size = UDim2.new(0,30,0,30)
Minimize.Position = UDim2.new(1,-30,0,0)
Minimize.Text = "-"

local Minimized = false

Minimize.MouseButton1Click:Connect(function()
	if Minimized then
		Frame.Size = UDim2.new(0,220,0,160)
		Minimized = false
	else
		Frame.Size = UDim2.new(0,220,0,30)
		Minimized = true
	end
end)

Toggle.MouseButton1Click:Connect(function()
	KillAura = not KillAura
	if KillAura then
		Toggle.Text = "Kill Aura: ON"
	else
		Toggle.Text = "Kill Aura: OFF"
	end
end)

TargetBox.FocusLost:Connect(function()
	TargetName = TargetBox.Text
end)

-- buscar jugador mas cercano
local function GetClosestPlayer()
	local closest = nil
	local shortest = Range

	for _,player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then

			local distance = (LocalPlayer.Character.HumanoidRootPart.Position -
			player.Character.HumanoidRootPart.Position).Magnitude

			if distance < shortest then
				shortest = distance
				closest = player
			end
		end
	end

	return closest
end

RunService.RenderStepped:Connect(function()
	if KillAura and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then

		local targetPlayer

		if TargetName and TargetName ~= "" then
			targetPlayer = Players:FindFirstChild(TargetName)
		else
			targetPlayer = GetClosestPlayer()
		end

		if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
			targetPlayer.Character.Humanoid:TakeDamage(5)
		end
	end
end)
