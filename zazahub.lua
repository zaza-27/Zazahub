-- Zaza Hub PRO (Player List + Kill Aura)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HitRemote = ReplicatedStorage
:WaitForChild("Packages")
:WaitForChild("Knit")
:WaitForChild("Services")
:WaitForChild("CombatService")
:WaitForChild("RF")
:WaitForChild("Hit")

local KillAura = false
local Range = 35
local TargetPlayer = nil
local AttackAll = false

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.Size = UDim2.new(0,260,0,340)
Main.Position = UDim2.new(0.05,0,0.2,0)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.BackgroundTransparency = 0.3
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundTransparency = 1
Title.Text = "Zaza Hub PRO"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

-- SPEED
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Parent = Main
SpeedBtn.Size = UDim2.new(0.9,0,0,30)
SpeedBtn.Position = UDim2.new(0.05,0,0.12,0)
SpeedBtn.Text = "Speed OFF"

local Speed = false

SpeedBtn.MouseButton1Click:Connect(function()

	Speed = not Speed

	if Speed then
		SpeedBtn.Text = "Speed ON"
	else
		SpeedBtn.Text = "Speed OFF"
		LocalPlayer.Character.Humanoid.WalkSpeed = 16
	end

end)

RunService.RenderStepped:Connect(function()

	if Speed and LocalPlayer.Character then
		LocalPlayer.Character.Humanoid.WalkSpeed = 30
	end

end)

-- INFINITE JUMP
local JumpBtn = Instance.new("TextButton")
JumpBtn.Parent = Main
JumpBtn.Size = UDim2.new(0.9,0,0,30)
JumpBtn.Position = UDim2.new(0.05,0,0.24,0)
JumpBtn.Text = "Infinite Jump OFF"

local InfJump = false

JumpBtn.MouseButton1Click:Connect(function()

	InfJump = not InfJump

	if InfJump then
		JumpBtn.Text = "Infinite Jump ON"
	else
		JumpBtn.Text = "Infinite Jump OFF"
	end

end)

UserInputService.JumpRequest:Connect(function()

	if InfJump then
		LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
	end

end)

-- KILL AURA
local KillBtn = Instance.new("TextButton")
KillBtn.Parent = Main
KillBtn.Size = UDim2.new(0.9,0,0,30)
KillBtn.Position = UDim2.new(0.05,0,0.36,0)
KillBtn.Text = "Kill Aura OFF"

KillBtn.MouseButton1Click:Connect(function()

	KillAura = not KillAura

	if KillAura then
		KillBtn.Text = "Kill Aura ON"
	else
		KillBtn.Text = "Kill Aura OFF"
	end

end)

-- ATACAR A TODOS
local AllBtn = Instance.new("TextButton")
AllBtn.Parent = Main
AllBtn.Size = UDim2.new(0.9,0,0,25)
AllBtn.Position = UDim2.new(0.05,0,0.48,0)
AllBtn.Text = "🌍 Atacar a todos"

AllBtn.MouseButton1Click:Connect(function()

	AttackAll = true
	TargetPlayer = nil

end)

-- LISTA DE JUGADORES
local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Parent = Main
PlayerList.Size = UDim2.new(0.9,0,0,100)
PlayerList.Position = UDim2.new(0.05,0,0.58,0)
PlayerList.CanvasSize = UDim2.new(0,0,0,0)
PlayerList.BackgroundColor3 = Color3.fromRGB(30,30,30)

local Layout = Instance.new("UIListLayout",PlayerList)

local function UpdatePlayers()

	PlayerList:ClearAllChildren()
	Layout.Parent = PlayerList

	for _,player in pairs(Players:GetPlayers()) do

		if player ~= LocalPlayer then

			local Btn = Instance.new("TextButton")
			Btn.Parent = PlayerList
			Btn.Size = UDim2.new(1,0,0,25)
			Btn.Text = player.Name

			Btn.MouseButton1Click:Connect(function()

				TargetPlayer = player
				AttackAll = false

			end)

		end

	end

end

UpdatePlayers()

Players.PlayerAdded:Connect(UpdatePlayers)
Players.PlayerRemoving:Connect(UpdatePlayers)

-- REJOIN
local Rejoin = Instance.new("TextButton")
Rejoin.Parent = Main
Rejoin.Size = UDim2.new(0.9,0,0,25)
Rejoin.Position = UDim2.new(0.05,0,0.85,0)
Rejoin.Text = "Rejoin Server"

Rejoin.MouseButton1Click:Connect(function()

	game:GetService("TeleportService"):Teleport(game.PlaceId,LocalPlayer)

end)

-- ATAQUE
task.spawn(function()

	while task.wait(0.3) do

		if not KillAura then continue end

		local char = LocalPlayer.Character
		if not char then continue end

		local myHRP = char:FindFirstChild("HumanoidRootPart")
		if not myHRP then continue end


		if AttackAll then

			for _,p in pairs(Players:GetPlayers()) do

				if p ~= LocalPlayer and p.Character then

					local hum = p.Character:FindFirstChild("Humanoid")
					local hrp = p.Character:FindFirstChild("HumanoidRootPart")

					if hum and hrp and hum.Health > 0 then

						local dist = (hrp.Position - myHRP.Position).Magnitude

						if dist <= Range then
							pcall(function()
								HitRemote:InvokeServer(hum,myHRP.Position)
							end)
						end

					end
				end
			end


		elseif TargetPlayer and TargetPlayer.Character then

			local hum = TargetPlayer.Character:FindFirstChild("Humanoid")
			local hrp = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")

			if hum and hrp then

				local dist = (hrp.Position - myHRP.Position).Magnitude

				if dist <= Range then
					pcall(function()
						HitRemote:InvokeServer(hum,myHRP.Position)
					end)
				end

			end

		end

	end

end)
