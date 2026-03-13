--// Enhanced Universal Hub 2026
--// Whitelist por USERNAME

local Services = {
    RS = game:GetService("RunService"),
    PL = game:GetService("Players"),
    UIS = game:GetService("UserInputService"),
    WS = game:GetService("Workspace"),
}

local lp = Services.PL.LocalPlayer
local cam = Services.WS.CurrentCamera

-- ======================
-- WHITELIST POR USUARIO
-- ======================

local whitelistedUsers = {
    "CXCHXRRX_27",
    "Rarita_Rmc4"
}

local function hasPermission()

    local myName = lp.Name

    for _, allowedName in ipairs(whitelistedUsers) do
        if myName == allowedName then
            return true
        end
    end

    return false
end

if not hasPermission() then

    if lp:FindFirstChild("PlayerGui") then

        local sg = Instance.new("ScreenGui")
        sg.Parent = lp.PlayerGui

        local txt = Instance.new("TextLabel")
        txt.Parent = sg
        txt.Size = UDim2.new(1,0,1,0)
        txt.BackgroundColor3 = Color3.new(0,0,0)
        txt.TextColor3 = Color3.new(1,0,0)
        txt.TextScaled = true
        txt.Text = "No tienes permiso para usar este script."
        txt.Font = Enum.Font.GothamBlack

    end

    task.wait(3)
    lp:Kick("No estás en la whitelist")
    return
end

-- ======================
-- UI
-- ======================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Enhanced Universal Hub 2026",
   LoadingTitle = "Enhanced Hub",
   LoadingSubtitle = "Whitelist Version",
   ConfigurationSaving = {
      Enabled = false,
   }
})

-- ======================
-- CONFIG
-- ======================

local cfg = {
    Aimbot = false,
    KillAura = false,
    AuraRange = 25,
    Speed = false,
    SpeedValue = 30,
    Fly = false
}

-- ======================
-- TABS
-- ======================

local CombatTab = Window:CreateTab("Combat")
local MovementTab = Window:CreateTab("Movement")
local VisualTab = Window:CreateTab("Visual")

-- ======================
-- AIMBOT
-- ======================

CombatTab:CreateToggle({
   Name = "Aimbot",
   CurrentValue = false,
   Callback = function(Value)
       cfg.Aimbot = Value
   end,
})

local function getClosestPlayer()

    local closest = nil
    local distance = math.huge

    for _,v in pairs(Services.PL:GetPlayers()) do

        if v ~= lp and v.Character and v.Character:FindFirstChild("Head") then

            local pos, visible = cam:WorldToViewportPoint(v.Character.Head.Position)

            if visible then

                local dist = (Vector2.new(pos.X,pos.Y) - Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)).Magnitude

                if dist < distance then
                    closest = v
                    distance = dist
                end

            end
        end
    end

    return closest
end

Services.RS.RenderStepped:Connect(function()

    if cfg.Aimbot then

        local target = getClosestPlayer()

        if target and target.Character then

            cam.CFrame = CFrame.new(
                cam.CFrame.Position,
                target.Character.Head.Position
            )

        end
    end
end)

-- ======================
-- KILLAURA
-- ======================

CombatTab:CreateToggle({
   Name = "Kill Aura",
   CurrentValue = false,
   Callback = function(Value)
       cfg.KillAura = Value
   end,
})

CombatTab:CreateSlider({
   Name = "Aura Range",
   Range = {5, 60},
   Increment = 1,
   CurrentValue = 25,
   Callback = function(Value)
       cfg.AuraRange = Value
   end,
})

Services.RS.Heartbeat:Connect(function()

    if not cfg.KillAura then return end
    if not lp.Character then return end

    local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _,v in pairs(Services.PL:GetPlayers()) do

        if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then

            local dist = (hrp.Position - v.Character.HumanoidRootPart.Position).Magnitude

            if dist <= cfg.AuraRange then

                local hum = v.Character:FindFirstChild("Humanoid")

                if hum then
                    hum:TakeDamage(5)
                end

            end

        end

    end

end)

-- ======================
-- SPEED
-- ======================

MovementTab:CreateToggle({
   Name = "Speed",
   CurrentValue = false,
   Callback = function(Value)
       cfg.Speed = Value
   end,
})

MovementTab:CreateSlider({
   Name = "Speed Power",
   Range = {16, 120},
   Increment = 1,
   CurrentValue = 30,
   Callback = function(Value)
       cfg.SpeedValue = Value
   end,
})

Services.RS.RenderStepped:Connect(function()

    if cfg.Speed and lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.WalkSpeed = cfg.SpeedValue
    end

end)

-- ======================
-- FLY
-- ======================

MovementTab:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Callback = function(Value)

       cfg.Fly = Value

       if Value then

           local body = Instance.new("BodyVelocity")
           body.Name = "FlyVelocity"
           body.MaxForce = Vector3.new(1,1,1)*100000
           body.Parent = lp.Character.HumanoidRootPart

       else

           if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
               if lp.Character.HumanoidRootPart:FindFirstChild("FlyVelocity") then
                   lp.Character.HumanoidRootPart.FlyVelocity:Destroy()
               end
           end

       end

   end,
})

Services.RS.RenderStepped:Connect(function()

    if cfg.Fly and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then

        local vel = lp.Character.HumanoidRootPart:FindFirstChild("FlyVelocity")

        if vel then
            vel.Velocity = cam.CFrame.LookVector * 80
        end

    end

end)

-- ======================
-- ESP NAMES
-- ======================

VisualTab:CreateToggle({
   Name = "ESP Names",
   CurrentValue = false,
   Callback = function(Value)

        for _,v in pairs(Services.PL:GetPlayers()) do

            if v ~= lp and v.Character and v.Character:FindFirstChild("Head") then

                if Value then

                    local bill = Instance.new("BillboardGui")
                    bill.Name = "ESP_NAME"
                    bill.Parent = v.Character.Head
                    bill.Size = UDim2.new(0,100,0,40)
                    bill.AlwaysOnTop = true

                    local txt = Instance.new("TextLabel")
                    txt.Parent = bill
                    txt.Size = UDim2.new(1,0,1,0)
                    txt.BackgroundTransparency = 1
                    txt.Text = v.Name
                    txt.TextColor3 = Color3.new(1,0,0)
                    txt.TextScaled = true

                else

                    if v.Character.Head:FindFirstChild("ESP_NAME") then
                        v.Character.Head.ESP_NAME:Destroy()
                    end

                end

            end

        end

   end,
})

-- ======================
-- NOTIFICACIÓN
-- ======================

Rayfield:Notify({
   Title = "Enhanced Hub",
   Content = "Cargado correctamente\nUsuario: "..lp.Name,
   Duration = 6,
})
