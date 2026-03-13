-- SERVICIOS
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ðŸ” WHITELIST
local Whitelist = {
    "cxchxrrx_27",
    "Amigo456"
}

local allowed = false

for _,name in pairs(Whitelist) do
    if LocalPlayer.Name == name then
        allowed = true
    end
end

-- â¬› SI NO ESTA PERMITIDO
if not allowed then

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local Frame = Instance.new("Frame")
    Frame.Parent = ScreenGui
    Frame.Size = UDim2.new(1,0,1,0)
    Frame.BackgroundColor3 = Color3.fromRGB(0,0,0)

    local Text = Instance.new("TextLabel")
    Text.Parent = Frame
    Text.Size = UDim2.new(1,0,0,50)
    Text.Position = UDim2.new(0,0,0.5,-25)
    Text.BackgroundTransparency = 1
    Text.Text = "No tienes permiso para usar Zaza Hub"
    Text.TextColor3 = Color3.new(1,0,0)
    Text.TextScaled = true

    return
end

-- CONFIG
local KillAuraEnabled = false
local Mode = "Target"
local TargetPlayerName = ""
local Range = 30
local AttackDelay = 0.01

local HitRemote = workspace:WaitForChild("Remotes"):WaitForChild("Hit")

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,240,0,200)
Frame.Position = UDim2.new(0.05,0,0.3,0)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.Active = true
Frame.Draggable = true

-- TITULO
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundColor3 = Color3.fromRGB(20,20,20)
Title.TextColor3 = Color3.new(1,1,1)
Title.Text = "Kill Aura Hub - by zaza"

-- MINIMIZAR
local Minimize = Instance.new("TextButton", Frame)
Minimize.Size = UDim2.new(0,30,0,30)
Minimize.Position = UDim2.new(1,-30,0,0)
Minimize.Text = "-"

-- BOTON AURA
local Toggle = Instance.new("TextButton", Frame)
Toggle.Size = UDim2.new(1,-20,0,40)
Toggle.Position = UDim2.new(0,10,0,50)
Toggle.Text = "Kill Aura: OFF"

-- MODO
local ModeButton = Instance.new("TextButton", Frame)
ModeButton.Size = UDim2.new(1,-20,0,30)
ModeButton.Position = UDim2.new(0,10,0,95)
ModeButton.Text = "Modo: Objetivo"

-- OBJETIVO
local TargetBox = Instance.new("TextBox", Frame)
TargetBox.Size = UDim2.new(1,-20,0,30)
TargetBox.Position = UDim2.new(0,10,0,135)
TargetBox.PlaceholderText = "Nombre del jugador"

-- ACTIVAR
Toggle.MouseButton1Click:Connect(function()

    KillAuraEnabled = not KillAuraEnabled

    if KillAuraEnabled then
        Toggle.Text = "Kill Aura: ON"
    else
        Toggle.Text = "Kill Aura: OFF"
    end

end)

-- CAMBIAR MODO
ModeButton.MouseButton1Click:Connect(function()

    if Mode == "Target" then
        Mode = "Nearest"
        ModeButton.Text = "Modo: Cercano"
    else
        Mode = "Target"
        ModeButton.Text = "Modo: Objetivo"
    end

end)

-- GUARDAR OBJETIVO
TargetBox.FocusLost:Connect(function()
    TargetPlayerName = Target-- SERVICIOS
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ðŸ” WHITELIST
local Whitelist = {
    "Joel123",
    "Amigo456"
}

local allowed = false

for _,name in pairs(Whitelist) do
    if LocalPlayer.Name == name then
        allowed = true
    end
end

-- â¬› SI NO ESTA PERMITIDO
if not allowed then

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local Frame = Instance.new("Frame")
    Frame.Parent = ScreenGui
    Frame.Size = UDim2.new(1,0,1,0)
    Frame.BackgroundColor3 = Color3.fromRGB(0,0,0)

    local Text = Instance.new("TextLabel")
    Text.Parent = Frame
    Text.Size = UDim2.new(1,0,0,50)
    Text.Position = UDim2.new(0,0,0.5,-25)
    Text.BackgroundTransparency = 1
    Text.Text = "No tienes permiso para usar Zaza Hub"
    Text.TextColor3 = Color3.new(1,0,0)
    Text.TextScaled = true

    return
end

-- CONFIG
local KillAuraEnabled = false
local Mode = "Target"
local TargetPlayerName = ""
local Range = 30
local AttackDelay = 0.01

local HitRemote = workspace:WaitForChild("Remotes"):WaitForChild("Hit")

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,240,0,200)
Frame.Position = UDim2.new(0.05,0,0.3,0)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.Active = true
Frame.Draggable = true

-- TITULO
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundColor3 = Color3.fromRGB(20,20,20)
Title.TextColor3 = Color3.new(1,1,1)
Title.Text = "Kill Aura Hub - by zaza"

-- MINIMIZAR
local Minimize = Instance.new("TextButton", Frame)
Minimize.Size = UDim2.new(0,30,0,30)
Minimize.Position = UDim2.new(1,-30,0,0)
Minimize.Text = "-"

-- BOTON AURA
local Toggle = Instance.new("TextButton", Frame)
Toggle.Size = UDim2.new(1,-20,0,40)
Toggle.Position = UDim2.new(0,10,0,50)
Toggle.Text = "Kill Aura: OFF"

-- MODO
local ModeButton = Instance.new("TextButton", Frame)
ModeButton.Size = UDim2.new(1,-20,0,30)
ModeButton.Position = UDim2.new(0,10,0,95)
ModeButton.Text = "Modo: Objetivo"

-- OBJETIVO
local TargetBox = Instance.new("TextBox", Frame)
TargetBox.Size = UDim2.new(1,-20,0,30)
TargetBox.Position = UDim2.new(0,10,0,135)
TargetBox.PlaceholderText = "Nombre del jugador"

-- ACTIVAR
Toggle.MouseButton1Click:Connect(function()

    KillAuraEnabled = not KillAuraEnabled

    if KillAuraEnabled then
        Toggle.Text = "Kill Aura: ON"
    else
        Toggle.Text = "Kill Aura: OFF"
    end

end)

-- CAMBIAR MODO
ModeButton.MouseButton1Click:Connect(function()

    if Mode == "Target" then
        Mode = "Nearest"
        ModeButton.Text = "Modo: Cercano"
    else
        Mode = "Target"
        ModeButton.Text = "Modo: Objetivo"
    end

end)

-- GUARDAR OBJETIVO
TargetBox.FocusLost:Connect(function()
    TargetPlayerName = Target
