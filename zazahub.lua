-- =============================================
-- KRISP KILL AURA HUB 2026 - VERSIÓN COMPLETA OPTIMIZADA
-- Whitelist SEPARADA y fácil de editar
-- =============================================

-- ==================== WHITELIST ====================
-- Edita SOLO aquí para agregar o quitar usuarios autorizados
local WHITELIST = {
    ["CXCHXRRX_27"]    = true,
    ["Rarita_RmC4"]     = true,
    ["diegoA7598"]     = true,
    -- Agrega más usuarios abajo, uno por línea, así:
    -- ["TuNombreAqui"] = true,
    -- ["OtroAmigo"]    = true,
}

-- =================================================================
--               SEGURIDAD - CHEQUEO DE WHITELIST
-- =================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

if not WHITELIST[LocalPlayer.Name] then
    task.delay(0.5, function()
        LocalPlayer:Kick("Acceso denegado → No estás autorizado.")
    end)
    return
end

print("[KRISP] Acceso autorizado para " .. LocalPlayer.Name .. " → Cargando hub...")

-- =================================================================
--                        CONFIGURACIÓN GLOBAL
-- =================================================================

local Config = {
    Enabled       = false,
    Range         = 30,
    RangeSq       = 30 * 30,
    HitsPerCycle  = 80,
    TargetMode    = "Todos (Cercano)",
    SelectedPlayer = nil,
    SearchText    = "",
}

-- =================================================================
--                        REMOTE DE GOLPE
-- =================================================================

local HitRemote = nil

local function RefreshRemotes()
    HitRemote = nil
    pcall(function()
        local path = game:GetService("ReplicatedStorage")
                     :WaitForChild("Packages", 8)
                     :WaitForChild("Knit", 5)
                     :WaitForChild("Services", 5)
                     :WaitForChild("CombatService", 5)
                     :WaitForChild("RF", 5)
                     :WaitForChild("Hit", 5)
        if path and path:IsA("RemoteFunction") then
            HitRemote = path
        end
    end)
end

RefreshRemotes()

-- =================================================================
--                        INTERFAZ RAYFIELD
-- =================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "KRISP Kill Aura 2026",
    LoadingTitle = "Cargando sistema ultra-rápido...",
    LoadingSubtitle = "Modo high-frequency",
    ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Principal", 4483362458)

MainTab:CreateToggle({
    Name = "Kill Aura Activado",
    CurrentValue = false,
    Flag = "ToggleAura",
    Callback = function(v) Config.Enabled = v end,
})

MainTab:CreateSlider({
    Name = "Rango de ataque",
    Range = {10, 80},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 30,
    Callback = function(v)
        Config.Range = v
        Config.RangeSq = v * v
    end,
})

MainTab:CreateSlider({
    Name = "Intensidad (hits por ciclo)",
    Range = {30, 200},
    Increment = 5,
    Suffix = " hits",
    CurrentValue = 80,
    Callback = function(v) Config.HitsPerCycle = v end,
})

MainTab:CreateDropdown({
    Name = "Modo de objetivo",
    Options = {"Todos (Cercano)", "Solo Seleccionado"},
    CurrentOption = {"Todos (Cercano)"},
    Callback = function(opt) Config.TargetMode = opt[1] end,
})

local PlayerDropdown = MainTab:CreateDropdown({
    Name = "Jugador objetivo",
    Options = {"Ninguno"},
    CurrentOption = {"Ninguno"},
    Callback = function(opt)
        if opt[1] == "Ninguno" then
            Config.SelectedPlayer = nil
        else
            Config.SelectedPlayer = opt[1]
        end
    end,
})

MainTab:CreateButton({
    Name = "Refrescar lista de jugadores",
    Callback = function()
        local names = {"Ninguno"}
        for _, p in Players:GetPlayers() do
            if p ~= LocalPlayer then
                table.insert(names, p.Name)
            end
        end
        PlayerDropdown:Set(names)
    end,
})

MainTab:CreateInput({
    Name = "Buscar jugador",
    PlaceholderText = "Escribe parte del nombre...",
    RemoveTextAfterFocusLost = false,
    Callback = function(txt)
        Config.SearchText = txt:lower()
    end,
})

MainTab:CreateButton({
    Name = "Recargar detección de remote",
    Callback = function()
        RefreshRemotes()
        local count = HitRemote and 1 or 0
        Rayfield:Notify({
            Title = "Remotes actualizados",
            Content = "Se encontró " .. count .. " remote de golpe.",
            Duration = 4.5
        })
    end,
})

Rayfield:Notify({
    Title = "KRISP Hub 2026 cargado",
    Content = "Objetivo estable + golpes ultra-rápidos. ¡Prueba ya!",
    Duration = 6
})

print("[KRISP UI] Interfaz cargada")

-- =================================================================
--               FUNCIÓN DE OBJETIVO MEJORADA
-- =================================================================

local function GetClosestTarget()
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local myPos = myRoot.Position
    local bestPlayer = nil
    local bestDistanceSq = Config.RangeSq + 1

    -- 1. Seleccionado manualmente (máxima prioridad)
    if Config.TargetMode == "Solo Seleccionado" and Config.SelectedPlayer then
        local p = Players:FindFirstChild(Config.SelectedPlayer)
        if p and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                return p
            end
        end
    end

    -- 2. Búsqueda por texto
    if Config.SearchText ~= "" then
        for _, p in Players:GetPlayers() do
            if p == LocalPlayer then continue end
            local nameLower = p.Name:lower()
            local displayLower = (p.DisplayName or p.Name):lower()
            if nameLower:find(Config.SearchText) or displayLower:find(Config.SearchText) then
                local char = p.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChild("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        return p
                    end
                end
            end
        end
    end

    -- 3. Más cercano (último recurso)
    for _, p in Players:GetPlayers() do
        if p == LocalPlayer then continue end
        local char = p.Character
        if not char then continue end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        
        if hrp and hum and hum.Health > 0.1 then
            local distSq = (hrp.Position - myPos).Magnitude ^ 2
            if distSq < bestDistanceSq then
                bestDistanceSq = distSq
                bestPlayer = p
            end
        end
    end
    
    return bestPlayer
end

-- =================================================================
--               MOTOR HIGH-SPEED + SPAM RÁPIDO
-- =================================================================

RunService.RenderStepped:Connect(function()
    if not Config.Enabled then return end
    if not HitRemote then return end

    local target = GetClosestTarget()
    if not target then return end

    local char = target.Character
    if not char then return end

    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if not hum or hum.Health <= 0 or not hrp then return end

    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local distanceSq = (hrp.Position - myRoot.Position).Magnitude ^ 2
    
    if distanceSq <= Config.RangeSq then
        task.spawn(function()
            for i = 1, Config.HitsPerCycle do
                local offset = Vector3.new(
                    math.random(-80, 80)/100,
                    math.random(40, 120)/100,
                    math.random(-80, 80)/100
                )
                
                task.spawn(function()
                    pcall(function()
                        HitRemote:InvokeServer(hum, hrp.Position + offset)
                    end)
                end)
                
                if i % 25 == 0 then
                    task.wait(0.001)
                end
            end
        end)
    end
end)

-- =================================================================
print("[KRISP] Todo cargado - edita la whitelist cuando quieras")
-- =================================================================        
