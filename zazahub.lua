local MyUser = game:GetService("Players").LocalPlayer.Name
local AccesoPrivado = {
    ["CXCHXRRX_27"] = true,
    ["Rarita_RmC4"] = true,
    ["Lhyyyyy_7"] = true,
    ["aupyiaiumb"] = true,
    ["ale_vasquez20"] = true,
    ["Pedrin_zxm"] = true,
    ["bruno123456770"] = true
}

if not AccesoPrivado[MyUser] then 
    warn("ACCESO DENEGADO")
    return 
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "salchipapa",
    LoadingTitle = "Cargando...",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

local Tab = Window:CreateTab("Combat", 4483362458)

-- Variables Kill Aura
local KillAuraEnabled = false
local UseClosestOnly = true
local SelectedTarget = nil
local AttackSpeed = 120               -- inicio más agresivo
local Range = 45
local Prediction = 0.16

local originalSizes = {}

local HitRemote
pcall(function()
    HitRemote = game:GetService("ReplicatedStorage")
        :WaitForChild("Packages")
        :WaitForChild("Knit")
        :WaitForChild("Services")
        :WaitForChild("CombatService")
        :WaitForChild("RF")
        :WaitForChild("Hit")
end)

if not HitRemote then
    Rayfield:Notify({Title = "Error", Content = "No se encontró Hit Remote", Duration = 5})
    return
end

-- Lista jugadores
local PlayerOptions = {"Ninguno"}
local function RefreshPlayerList()
    PlayerOptions = {"Ninguno"}
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer then
            table.insert(PlayerOptions, plr.Name)
        end
    end
end
RefreshPlayerList()

-- Interfaz
Tab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,
    Callback = function(Value)
        KillAuraEnabled = Value
        if Value then
            for _, p in ipairs(game.Players:GetPlayers()) do
                if p ~= game.Players.LocalPlayer and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        originalSizes[hrp] = hrp.Size
                        hrp.Size = Vector3.new(40, 40, 40)
                    end
                end
            end
            Rayfield:Notify({Title = "salchipapa", Content = "Kill Aura ON - 10x hits + hitboxes expandidas", Duration = 3.5})
        else
            for hrp, oldSize in pairs(originalSizes) do
                if hrp and hrp.Parent then hrp.Size = oldSize end
            end
            originalSizes = {}
            Rayfield:Notify({Title = "salchipapa", Content = "Kill Aura OFF", Duration = 2.5})
        end
    end,
})

Tab:CreateToggle({
    Name = "Modo Automático (Más cercano)",
    CurrentValue = true,
    Callback = function(Value)
        UseClosestOnly = Value
        if Value then SelectedTarget = nil end
    end,
})

local TargetDropdown = Tab:CreateDropdown({
    Name = "Fijar Objetivo",
    Options = PlayerOptions,
    CurrentOption = "Ninguno",
    Callback = function(Option)
        local name = (type(Option) == "table" and Option[1]) or Option
        if name == "Ninguno" then
            SelectedTarget = nil
        else
            SelectedTarget = game.Players:FindFirstChild(name)
            UseClosestOnly = false
        end
    end,
})

Tab:CreateButton({
    Name = "Actualizar Lista",
    Callback = function()
        RefreshPlayerList()
        TargetDropdown:Refresh(PlayerOptions, true)
    end,
})

Tab:CreateSlider({
    Name = "Ataques por Segundo",
    Range = {1, 1000},
    Increment = 50,
    Suffix = " APS",
    CurrentValue = 120,
    Callback = function(Value)
        AttackSpeed = Value
    end,
})

Tab:CreateSlider({
    Name = "Rango Máximo",
    Range = {10, 100},
    Increment = 5,
    Suffix = " studs",
    CurrentValue = 45,
    Callback = function(Value)
        Range = Value
    end,
})

-- Loop Kill Aura - 10 invokes + intervalo ultra-rápido
local lastAttack = 0
game:GetService("RunService").Heartbeat:Connect(function()
    if not KillAuraEnabled or not HitRemote then return end
    
    local now = tick()
    local cooldown = 1 / AttackSpeed
    if now - lastAttack < cooldown then return end
    lastAttack = now
    
    local lp = game.Players.LocalPlayer
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local target = nil
    
    if SelectedTarget and SelectedTarget.Character then
        local hum = SelectedTarget.Character:FindFirstChild("Humanoid")
        local hrp = SelectedTarget.Character:FindFirstChild("HumanoidRootPart")
        if hum and hum.Health > 0 and hrp then
            local dist = (hrp.Position - root.Position).Magnitude
            if dist <= Range then
                target = {
                    Hum = hum,
                    Pos = hrp.Position + (hrp.AssemblyLinearVelocity * Prediction)
                }
            end
        end
    end
    
    if not target and UseClosestOnly then
        local closestDist = Range
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr == lp then continue end
            local pchar = plr.Character
            if pchar then
                local hum = pchar:FindFirstChild("Humanoid")
                local hrp = pchar:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and hrp then
                    local dist = (hrp.Position - root.Position).Magnitude
                    if dist <= closestDist then
                        closestDist = dist
                        target = {
                            Hum = hum,
                            Pos = hrp.Position + (hrp.AssemblyLinearVelocity * Prediction)
                        }
                    end
                end
            end
        end
    end
    
    if target then
        -- 10 hits con micro-delay para no crashear tanto el cliente
        for i = 1, 10 do
            task.spawn(function()
                pcall(function()
                    HitRemote:InvokeServer(target.Hum, target.Pos)
                end)
            end)
            task.wait(0.0005)  -- ~0.005s total para los 10 → muy rápido pero menos lag
        end
    end
end)

Rayfield:Notify({
    Title = "salchipapa",
    Content = "Cargado - 10x hits por ciclo + intervalo ultra-rápido.\nSube APS con cuidado (lag/ban posible).",
    Duration = 6
})

print("salchipapa | 10x damage mode + fast interval loaded")
