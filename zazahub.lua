-- ⚡ Zaza Hub PRO

local Players = game:GetService("Players")
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

-- BUSCAR JUGADOR POR NOMBRE PARCIAL
local function findPlayer(name)

for _,player in pairs(Players:GetPlayers()) do

if string.find(string.lower(player.Name), string.lower(name)) then
return player
end

end

end

-- ENEMIGO MAS CERCANO
local function getClosest()

local closest = nil
local dist = Range

local myChar = LocalPlayer.Character
if not myChar then return end

local myHRP = myChar:FindFirstChild("HumanoidRootPart")
if not myHRP then return end

for _,player in pairs(Players:GetPlayers()) do

if player ~= LocalPlayer and player.Character then

local hum = player.Character:FindFirstChild("Humanoid")
local hrp = player.Character:FindFirstChild("HumanoidRootPart")

if hum and hrp and hum.Health > 0 then

local distance = (hrp.Position - myHRP.Position).Magnitude

if distance < dist then
dist = distance
closest = player
end

end

end

end

return closest

end

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,260)
frame.Position = UDim2.new(0.4,0,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BackgroundTransparency = 0.3
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.Text = "⚡ Zaza Hub"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 20

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.8,0,0,35)
toggle.Position = UDim2.new(0.1,0,0.2,0)
toggle.Text = "Kill Aura OFF"
toggle.BackgroundTransparency = 0.3

local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(0.8,0,0,30)
box.Position = UDim2.new(0.1,0,0.38,0)
box.PlaceholderText = "Nombre jugador"

local target = Instance.new("TextButton", frame)
target.Size = UDim2.new(0.8,0,0,30)
target.Position = UDim2.new(0.1,0,0.52,0)
target.Text = "🎯 Usar objetivo"

local all = Instance.new("TextButton", frame)
all.Size = UDim2.new(0.8,0,0,30)
all.Position = UDim2.new(0.1,0,0.66,0)
all.Text = "🌍 Pegar a todos"

local rangeText = Instance.new("TextLabel", frame)
rangeText.Size = UDim2.new(1,0,0,30)
rangeText.Position = UDim2.new(0,0,0.82,0)
rangeText.Text = "Range: "..Range
rangeText.BackgroundTransparency = 1
rangeText.TextColor3 = Color3.new(1,1,1)

-- BOTONES

toggle.MouseButton1Click:Connect(function()

KillAura = not KillAura
toggle.Text = KillAura and "Kill Aura ON" or "Kill Aura OFF"

end)

target.MouseButton1Click:Connect(function()

local name = box.Text
local player = findPlayer(name)

if player then
TargetPlayer = player
AttackAll = false
else
TargetPlayer = getClosest()
end

end)

all.MouseButton1Click:Connect(function()

AttackAll = true
TargetPlayer = nil

end)

-- ATAQUE
task.spawn(function()

while task.wait(Speed) do

if not KillAura then continue end

local myChar = LocalPlayer.Character
if not myChar then continue end

local myHRP = myChar:FindFirstChild("HumanoidRootPart")
if not myHRP then continue end

-- PEGAR A TODOS
if AttackAll then

for _,player in pairs(Players:GetPlayers()) do

if player ~= LocalPlayer and player.Character then

local hum = player.Character:FindFirstChild("Humanoid")
local hrp = player.Character:FindFirstChild("HumanoidRootPart")

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

-- OBJETIVO
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
