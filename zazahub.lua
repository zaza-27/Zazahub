-- [[ ZM HUB - ANTI-RESET & FIXED HIT ]] --
local p = game:GetService("Players").LocalPlayer
local UI_NAME = "ZM_CORE_UI"
local CoreGui = game:GetService("CoreGui")

-- Evitar duplicados y que se borre al morir
if CoreGui:FindFirstChild(UI_NAME) then CoreGui[UI_NAME]:Destroy() end

local ZM_Settings = { 
    Hit = false, -- Empieza apagado
    Spd = false, 
    Esp = false, 
    Val = 2,
    repeatamount = 26, 
    exceptions = {"SayMessageRequest","MeleeUpdateEvent","NinjaBombEvent","BulletUpdateEvent"}
}

-- [[ MULTIPLIER ORIGINAL - FIX LOGIC ]] --
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = function(uh, ...)
    local method = getnamecallmethod()
    
    -- Solo procesar si Hit es TRUE
    if ZM_Settings.Hit == true then
        if method == "FireServer" or method == "InvokeServer" then
            local isException = false
            for _, o in next, ZM_Settings.exceptions do
                if uh.Name == o then
                    isException = true
                    break
                end
            end
            
            if not isException then
                for i = 1, ZM_Settings.repeatamount do
                    old(uh, ...)
                end
            end
        end
    end
    
    return old(uh, ...)
end
setreadonly(mt, true)

-- [[ INTERFAZ EN COREGUI (NO SE BORRA) ]] --
local UI = Instance.new("ScreenGui", CoreGui)
UI.Name = UI_NAME
UI.ResetOnSpawn = false -- Doble protección anti-reset

local Main = Instance.new("Frame", UI)
Main.Size = UDim2.new(0, 180, 0, 260)
Main.Position = UDim2.new(0.5, -90, 0.5, -130)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30); Title.Text = "ZM HUB"; Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.TextColor3 = Color3.new(1,1,1); Title.Font = Enum.Font.GothamBold

-- Botones Flotantes
local Mini = Instance.new("Frame", UI)
Mini.Size = UDim2.new(0, 160, 0, 30); Mini.Position = UDim2.new(0, 75, 0, 10); Mini.BackgroundTransparency = 1; Mini.Visible = false

local function QuickBtn(txt, x)
    local b = Instance.new("TextButton", Mini)
    b.Size = UDim2.new(0, 48, 0, 25); b.Position = UDim2.new(0, x, 0, 0)
    b.Text = txt; b.BackgroundColor3 = Color3.fromRGB(160, 0, 0); b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 10; Instance.new("UICorner", b)
    return b
end

local QHit, QSpd, QEsp = QuickBtn("HIT", 0), QuickBtn("SPD", 52), QuickBtn("ESP", 104)

local ZMBtn = Instance.new("TextButton", UI)
ZMBtn.Size = UDim2.new(0, 55, 0, 25); ZMBtn.Position = UDim2.new(0, 10, 0, 10)
ZMBtn.Text = "ZM"; ZMBtn.Visible = false; ZMBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); ZMBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", ZMBtn)

local function MainBtn(txt, y)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0, 160, 0, 35); b.Position = UDim2.new(0, 10, 0, y)
    b.Text = txt; b.BackgroundColor3 = Color3.fromRGB(160, 0, 0); b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    return b
end

local BHit, BSpd, BEsp = MainBtn("HIT", 40), MainBtn("SPD", 80), MainBtn("ESP", 120)

local SpeedInput = Instance.new("TextBox", Main)
SpeedInput.Size = UDim2.new(0, 160, 0, 30); SpeedInput.Position = UDim2.new(0, 10, 0, 165)
SpeedInput.PlaceholderText = "SPD (2)"; SpeedInput.Text = "2"; SpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedInput.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", SpeedInput)

local Close = Instance.new("TextButton", Main)
Close.Size = UDim2.new(0, 20, 0, 20); Close.Position = UDim2.new(1, -25, 0, 5); Close.Text = "X"; Close.BackgroundColor3 = Color3.fromRGB(200, 0, 0)

-- LÓGICA DE SINCRONIZACIÓN (Visual)
local function Sync()
    local on, off = Color3.fromRGB(0, 160, 0), Color3.fromRGB(160, 0, 0)
    BHit.BackgroundColor3 = ZM_Settings.Hit and on or off; QHit.BackgroundColor3 = ZM_Settings.Hit and on or off
    BSpd.BackgroundColor3 = ZM_Settings.Spd and on or off; QSpd.BackgroundColor3 = ZM_Settings.Spd and on or off
    BEsp.BackgroundColor3 = ZM_Settings.Esp and on or off; QEsp.BackgroundColor3 = ZM_Settings.Esp and on or off
end

-- EVENTOS DE BOTONES
Close.MouseButton1Click:Connect(function() Main.Visible = false; Mini.Visible = true; ZMBtn.Visible = true end)
ZMBtn.MouseButton1Click:Connect(function() Main.Visible = true; Mini.Visible = false; ZMBtn.Visible = false end)

local function ToggleHit() ZM_Settings.Hit = not ZM_Settings.Hit Sync() end
local function ToggleSpd() ZM_Settings.Spd = not ZM_Settings.Spd Sync() end
local function ToggleEsp() ZM_Settings.Esp = not ZM_Settings.Esp Sync() end

BHit.MouseButton1Click:Connect(ToggleHit); QHit.MouseButton1Click:Connect(ToggleHit)
BSpd.MouseButton1Click:Connect(ToggleSpd); QSpd.MouseButton1Click:Connect(ToggleSpd)
BEsp.MouseButton1Click:Connect(ToggleEsp); QEsp.MouseButton1Click:Connect(ToggleEsp)

SpeedInput.FocusLost:Connect(function() ZM_Settings.Val = tonumber(SpeedInput.Text) or 2 end)

-- TP-WALK
game:GetService("RunService").Stepped:Connect(function()
    if ZM_Settings.Spd and p.Character and p.Character:FindFirstChild("PrimaryPart") then
        local hum = p.Character:FindFirstChild("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 then
            p.Character.PrimaryPart.CFrame = p.Character.PrimaryPart.CFrame + (hum.MoveDirection * ZM_Settings.Val)
        end
    end
end)

-- ESP MEJORADO (PARA TODOS)
local function AddESP(plr)
    local function Create(char)
        if not char then return end
        local head = char:WaitForChild("Head", 15)
        local h = Instance.new("Highlight", char); h.FillColor = Color3.new(1, 0, 0)
        local b = Instance.new("BillboardGui", char); b.Size = UDim2.new(0, 200, 0, 50); b.Adornee = head; b.AlwaysOnTop = true; b.ExtentsOffset = Vector3.new(0, 3, 0)
        local l = Instance.new("TextLabel", b); l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1; l.Text = plr.Name; l.TextColor3 = Color3.new(1, 1, 1); l.Font = Enum.Font.GothamBold; l.TextSize = 14
        game:GetService("RunService").RenderStepped:Connect(function()
            if char and char.Parent then
                h.Enabled = ZM_Settings.Esp
                l.Visible = ZM_Settings.Esp
            end
        end)
    end
    plr.CharacterAdded:Connect(Create)
    if plr.Character then Create(plr.Character) end
end

for _, v in pairs(game.Players:GetPlayers()) do if v ~= p then AddESP(v) end end
game.Players.PlayerAdded:Connect(AddESP)
