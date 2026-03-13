-- KILL AURA SYSTEM

local KillAuraConnection
local originalHitboxSizes = {}

local function StartKillAura()

    if not HitRemote then
        warn("HitRemote not found")
        return
    end

    -- Expandir hitbox
    for _,player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                originalHitboxSizes[hrp] = hrp.Size
                hrp.Size = Vector3.new(30,30,30)
            end
        end
    end

    KillAuraConnection = RunService.Heartbeat:Connect(function()

        if not LocalPlayer.Character then return end

        local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local closestPlayer = nil
        local closestDistance = 35

        for _,player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then

                local hum = player.Character:FindFirstChild("Humanoid")
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")

                if hum and hrp and hum.Health > 0 then

                    local distance = (hrp.Position - myHRP.Position).Magnitude

                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end

                end
            end
        end

        if closestPlayer and closestPlayer.Character then

            local hum = closestPlayer.Character:FindFirstChild("Humanoid")

            if hum then
                pcall(function()
                    HitRemote:InvokeServer(hum, myHRP.Position)
                end)
            end

        end

    end)

end

local function StopKillAura()

    if KillAuraConnection then
        KillAuraConnection:Disconnect()
        KillAuraConnection = nil
    end

    for hrp, size in pairs(originalHitboxSizes) do
        if hrp and hrp.Parent then
            hrp.Size = size
        end
    end

    originalHitboxSizes = {}

end
