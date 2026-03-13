-- AUTO FARM TREBOLES CON BOTON

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local enabled = false

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)

local button = Instance.new("TextButton")
button.Size = UDim2.new(0,160,0,50)
button.Position = UDim2.new(0,20,0,200)
button.Text = "Auto Clover: OFF"
button.BackgroundColor3 = Color3.fromRGB(30,30,30)
button.TextColor3 = Color3.new(1,1,1)
button.Parent = gui

button.MouseButton1Click:Connect(function()
	enabled = not enabled
	button.Text = enabled and "Auto Clover: ON" or "Auto Clover: OFF"
end)

-- FARM LOOP
while true do
	if enabled then
		local char = player.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			local root = char.HumanoidRootPart
			
			for _,v in pairs(workspace:GetDescendants()) do
				if v:IsA("BasePart") and string.find(v.Name:lower(),"clover") then
					firetouchinterest(root, v, 0)
					firetouchinterest(root, v, 1)
				end
			end
		end
	end
	
	task.wait(0.3)
end
