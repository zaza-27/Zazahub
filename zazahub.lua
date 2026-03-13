--// Enhanced Universal Hub 2026 --// Whitelist por USERNAME
local Services = {
    RS = game:GetService("RunService"),
    PL = game:GetService("Players"),
    UIS = game:GetService("UserInputService"),
    WS = game:GetService("Workspace"),
}

local lp = Services.PL.LocalPlayer
local cam = Services.WS.CurrentCamera

-- ====================== --
-- WHITELIST POR USUARIO --
-- ====================== --
local whitelistedUsers = { "CXCHXRRX_27", "Rarita_RmC4" }

local function hasPermission()
    local myName = lp.Name
    for _, allowedName in ipairs(whitelistedUsers) do
        if myName == allowedName then return true end
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

-- ====================== --
-- VARIABLES KILL AURA --
-- ====================== --
local KillAuraConnection
local originalHitboxSizes = {}
local hitboxVisuals = {}
local HitRemote

-- Intento de encontrar el Remote de combate (Framework Knit)
pcall(function()
    HitRemote = game:GetService("ReplicatedStorage")
        :WaitForChild("Packages", 5)
        :WaitForChild("Knit")
        :WaitForChild("Services")
        :WaitForChild("CombatService")
        :WaitForChild("RF")
        :WaitForChild("Hit")
end)

-- ====================== --
-- UI SETUP --
-- ====================== --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Enhanced Universal Hub 2026",
    LoadingTitle = "Enhanced Hub",
    LoadingSubtitle = "Whitelist Version",
    ConfigurationSaving = { Enabled = false }
})

-- ====================== --
-- CONFIG --
-- ====================== --
local cfg = {
    Aimbot = false,
    KillAura = false,
    AuraRange = 25,
    HitboxSize = 30,
    ShowHitbox = false,
    Speed = false,
    SpeedValue = 30,
    Fly = false
}

-- ====================== --
-- TABS --
-- ====================== --
local CombatTab = Window:CreateTab("Combat")
local MovementTab = Window:CreateTab("Movement")
local VisualTab = Window:CreateTab("Visual")

-- ====================== --
-- FUNCIONES KILL AURA --
-- ====================== --
local function StopKillAura()
    if KillAuraConnection then KillAuraConnection:Disconnect() KillAuraConnection = nil end
    for hrp, oldSize in pairs(originalHitboxSizes) do
        if hrp and hrp.Parent then hrp.Size = oldSize end
    end
    originalHitboxSizes = {}
    for _, v in pairs(hitboxVisuals) do if v then v:Destroy() end end
    hitboxVisuals = {}
end

local function UpdateHitboxVisuals()
    for _, v in pairs(hitboxVisuals) do if v then v:Destroy() end end
    hitboxVisuals = {}
    if not cfg.ShowHitbox then return end
    
    for _, p in pairs(Services.PL:GetPlayers()) do
        if p ~= lp and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local visual = Instance.new("Part")
                visual.Size = Vector3.new(cfg.HitboxSize, cfg.HitboxSize, cfg.HitboxSize)
                visual.CFrame = hrp.CFrame
                visual.Anchored = true
                visual.CanCollide = false
                visual.Material = Enum.Material.ForceField
                visual.Color = Color3.fromRGB(255, 0, 0)
                visual.Transparency = 0.7
                visual.Parent = Services.WS
                hitboxVisuals[hrp] = visual
            end
        end
    end
end

local function StartKillAura()
    StopKillAura()
    
    -- Expansión de Hitboxes inicial
    for _, p in pairs(Services.PL:GetPlayers()) do
        if p ~= lp and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                originalHitboxSizes[hrp] = hrp.Size
                hrp.Size = Vector3.new(cfg.HitboxSize, cfg.HitboxSize, cfg.HitboxSize)
            end
        end
    end

    KillAuraConnection = Services.RS.Heartbeat:Connect(function()
        if not cfg.KillAura or not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
        
        local myHRP = lp.Character.HumanoidRootPart
        local target, targetDist = nil, cfg.AuraRange
        
        for _, p in pairs(Services.PL:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("Humanoid") then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp and p.Character.Humanoid.Health > 0 then
                    local dist = (hrp.Position - myHRP.Position).Magnitude
                    if dist <= targetDist then
                        targetDist = dist
                        target = p
                    end
                end
            end
        end
        
        if target and HitRemote then
            pcall(function()
                HitRemote:InvokeServer(target.Character.Humanoid, myHRP.Position)
            end)
        end
        
        -- Actualizar posición de visuales
        if cfg.ShowHitbox then
            for hrp, visual in pairs(hitboxVisuals) do
                if hrp and hrp.Parent and visual then visual.CFrame = hrp.CFrame end
            end
        end
    end)
end

-- ====================== --
-- ELEMENTOS COMBAT --
-- ====================== --
CombatTab:CreateToggle({
    Name = "Kill Aura (Hitbox Extender)",
    CurrentValue = false,
    Callback = function(Value)
        cfg.KillAura = Value
        if Value then StartKillAura() else StopKillAura() end
    end,
})

CombatTab:CreateSlider({
    Name = "Aura Range (Attack)",
    Range = {5, 60}, Increment = 1, CurrentValue = 25,
    Callback = function(Value) cfg.AuraRange = Value end,
})

CombatTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {2, 100}, Increment = 1, CurrentValue = 30,
    Callback = function(Value) 
        cfg.HitboxSize = Value 
        if cfg.KillAura then StartKillAura() UpdateHitboxVisuals() end
    end,
})

CombatTab:CreateToggle({
    Name = "Show Hitboxes",
    CurrentValue = false,
    Callback = function(Value)
        cfg.ShowHitbox = Value
        UpdateHitboxVisuals()
    end,
})

-- Aimbot Section (Manteniendo tu lógica original)
CombatTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(Value) cfg.Aimbot = Value end,
})

local function getClosestPlayer()
    local closest = nil
    local distance = math.huge
    for _,v in pairs(Services.PL:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("Head") then
            local pos, visible = cam:WorldToViewportPoint(v.Character.Head.Position)
            if visible then
                local dist = (Vector2.new(pos.X,pos.Y) - Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)).Magnitude
                if dist < distance then closest = v distance = dist end
            end
        end
    end
    return closest
end

Services.RS.RenderStepped:Connect(function()
    if cfg.Aimbot then
        local target = getClosestPlayer()
        if target and target.Character then
            cam.CFrame = CFrame.new(cam.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

-- ====================== --
-- MOVEMENT & VISUALS --
-- ====================== --
MovementTab:CreateToggle({
    Name = "Speed",
    CurrentValue = false,
    Callback = function(Value) cfg.Speed = Value end,
})

MovementTab:CreateSlider({
    Name = "Speed Power",
    Range = {16, 120}, Increment = 1, CurrentValue = 30,
    Callback = function(Value) cfg.SpeedValue = Value end,
})

Services.RS.RenderStepped:Connect(function()
    if cfg.Speed and lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.WalkSpeed = cfg.SpeedValue
    end
end)

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
                local v = lp.Character.HumanoidRootPart:FindFirstChild("FlyVelocity")
                if v then v:Destroy() end
            end
        end
    end,
})

Services.RS.RenderStepped:Connect(function()
    if cfg.Fly and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local vel = lp.Character.HumanoidRootPart:FindFirstChild("FlyVelocity")
        if vel then vel.Velocity = cam.CFrame.LookVector * 80 end
    end
end)

VisualTab:CreateToggle({
    Name = "ESP Names",
    CurrentValue = false,
    Callback = function(Value)
        for _,v in pairs(Services.PL:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("Head") then
                if Value then
                    local bill = Instance.new("BillboardGui", v.Character.Head)
                    bill.Name = "ESP_NAME"
                    bill.Size = UDim2.new(0,100,0,40)
                    bill.AlwaysOnTop = true
                    local txt = Instance.new("TextLabel", bill)
                    txt.Size = UDim2.new(1,0,1,0)
                    txt.BackgroundTransparency = 1
                    txt.Text = v.Name
                    txt.TextColor3 = Color3.new(1,0,0)
                    txt.TextScaled = true
                else
                    local e = v.Character.Head:FindFirstChild("ESP_NAME")
                    if e then e:Destroy() end
                end
            end
        end
    end,
})

-- ====================== --
-- HANDLER JUGADORES NUEVOS --
-- ====================== --
Services.PL.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if cfg.KillAura then
            task.wait(0.5)
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            if hrp then
                originalHitboxSizes[hrp] = hrp.Size
                hrp.Size = Vector3.new(cfg.HitboxSize, cfg.HitboxSize, cfg.HitboxSize)
                UpdateHitboxVisuals()
            end
        end
    end)
end)

-- NOTIFICACIÓN FINAL
Rayfield:Notify({
    Title = "Enhanced Hub",
    Content = "Cargado correctamente\nUsuario: "..lp.Name,
    Duration = 6,
})
