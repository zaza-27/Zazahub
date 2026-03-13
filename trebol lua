-- AUTO FARM TREBOLES DESDE EL LOBBY

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function getRoot()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

while true do
    local root = getRoot()

    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and string.find(v.Name:lower(),"clover") then
            v.CFrame = root.CFrame
            task.wait(0.05)
        end
    end

    task.wait(0.5)
end
