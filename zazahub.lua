print("Zaza Hub cargado")

local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextLabel = Instance.new("TextLabel")

ScreenGui.Parent = game.CoreGui

Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0,200,0,100)
Frame.Position = UDim2.new(0.5,-100,0.5,-50)
Frame.BackgroundColor3 = Color3.fromRGB(0,0,0)

TextLabel.Parent = Frame
TextLabel.Size = UDim2.new(1,0,1,0)
TextLabel.Text = "Zaza Hub"
TextLabel.TextColor3 = Color3.fromRGB(255,255,255)
TextLabel.BackgroundTransparency = 1
