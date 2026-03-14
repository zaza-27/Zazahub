--// Enhanced Universal Hub 2026 - Optimized Target Mode
local Services = {
    RS = game:GetService("RunService"),
    PL = game:GetService("Players"),
    WS = game:GetService("Workspace"),
}

local lp = Services.PL.LocalPlayer

-- ====================== --
-- WHITELIST FIJA
-- ====================== --
local whitelistedUsers = { "CXCHXRRX_27", "Rarita_RmC4", "Rojas123728" }
local function hasPermission()
    for _, name in ipairs(whitelistedUsers) do if lp.Name == name then return true end end
    return false
end
if not hasPermission() then lp:Kick("Acceso Denegado") return end

-- ====================== --
-- CONFIGURACIÓN
-- ====================== --
local cfg = {
    KillAura = false,
    AuraRange = 25,
    AttackSpeed = 15, -- Ajustado para velocidad sin lag
    TargetMode = "Todos",
    SelectedPlayer = "Ninguno",
    ESP_Names = false
}

local function GetDamageRemote()
    local names = {"Hit", "Attack", "Combat", "Damage", "Swing", "Punch"}
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            for _, n in pairs(names) do
                if v.Name:find(n) or v.Name:lower():find(n:lower()) then return v end
            end
        end
    end
    return nil
end

-- ====================== --
-- FUNCIÓN DE ATAQUE UNIFICADA
-- ====================== --
local function Attack(target)
    if not target or not target.Character then return end
    local hum = target.Character:FindFirstChildOfClass("Humanoid")
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    
    if not hum or hum.Health <= 0 then return end
    local remote = GetDamageRemote()
    if tool then tool:Activate() end 

    for i = 1, cfg.AttackSpeed do
        task.spawn(function()
            if remote then
                local args = {[1] = hum, [2] = hrp.Position}
                if remote:IsA("RemoteEvent") then remote:FireServer(unpack(args))
                else pcall(function() remote:InvokeServer(unpack(args)) end) end
            end
        end)
    end
end

-- ====================== --
-- BUSCADOR DEL MÁS CERCANO
-- ====================== --
local function GetClosestPlayer()
    local closest = nil
    local dist = cfg.AuraRange
    local myHRP = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    for _, v in pairs(Services.PL:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local eHum = v.Character:FindFirstChildOfClass("Humanoid")
            if eHum and eHum.Health > 0 then
                local magnitude = (myHRP.Position - v.Character.HumanoidRootPart.Position).Magnitude
                if magnitude < dist then
                    dist = magnitude
                    closest = v
                end
            end
        end
    end
    return closest
end

-- ====================== --
-- BUCLE MAESTRO OPTIMIZADO
-- ====================== --
Services.RS.Heartbeat:Connect(function()
    if not cfg.KillAura or not lp.Character then return end

    local target = nil

    -- Decidir a quién atacar
    if cfg.TargetMode == "Solo Seleccionado" then
        local p = Services.PL:FindFirstChild(cfg.SelectedPlayer)
        if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (lp.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if dist <= cfg.AuraRange then target = p end
        end
    else
        -- Modo "Todos" ahora busca automáticamente al más cercano para evitar lag
        target = GetClosestPlayer()
    end

    if target then
        Attack(target)
    end

    -- ESP Nombres (Fuera de la lógica de ataque para que siempre funcione)
    if cfg.ESP_Names then
        for _, v in pairs(Services.PL:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("Head") then
                local head = v.Character.Head
                if not head:FindFirstChild("ESP_NAME_GUI") then
                    local bill = Instance.new("BillboardGui", head)
                    bill.Name = "ESP_NAME_GUI"
                    bill.Size, bill.AlwaysOnTop = UDim2.new(0, 100, 0, 25), true
                    bill.StudsOffset = Vector3.new(0, 2.5, 0)
                    local txt = Instance.new("TextLabel", bill)
                    txt.Size, txt.BackgroundTransparency = UDim2.new(1, 0, 1, 0), 1
                    txt.Text, txt.TextColor3 = v.Name, Color3.new(1, 0, 0)
                    txt.TextStrokeTransparency, txt.TextScaled = 0, true
                end
            end
        end
    end
end)

-- ====================== --
-- UI (RAYFIELD)
-- ====================== --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({ Name = "Enhanced Hub V8 - Anti-Lag", LoadingTitle = "Optimizando..." })

local CombatTab = Window:CreateTab("Combat")
local VisualTab = Window:CreateTab("Visuals")

CombatTab:CreateToggle({
    Name = "Kill Aura (Más Cercano)",
    CurrentValue = false,
    Callback = function(Value) cfg.KillAura = Value end,
})

CombatTab:CreateSlider({
    Name = "Rango",
    Range = {5, 50}, Increment = 1, CurrentValue = 25,
    Callback = function(Value) cfg.AuraRange = Value end,
})

local TargetDrop = CombatTab:CreateDropdown({
    Name = "Fijar Objetivo",
    Options = {"Ninguno"},
    Callback = function(Option) cfg.SelectedPlayer = Option[1] end,
})

CombatTab:CreateDropdown({
    Name = "Modo",
    Options = {"Todos (Cercano)", "Solo Seleccionado"},
    CurrentOption = {"Todos (Cercano)"},
    Callback = function(Option) cfg.TargetMode = Option[1] end,
})

CombatTab:CreateButton({
    Name = "Refrescar Lista",
    Callback = function()
        local p = {"Ninguno"}
        for _, v in pairs(Services.PL:GetPlayers()) do if v ~= lp then table.insert(p, v.Name) end end
        TargetDrop:Set(p)
    end,
})

VisualTab:CreateToggle({
    Name = "ESP Nombres",
    CurrentValue = false,
    Callback = function(Value) cfg.ESP_Names = Value end,
})
