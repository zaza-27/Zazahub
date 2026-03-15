--// KRISP Enhanced Kill Aura Hub 2026 - Combined Version
-- Mantiene Rayfield UI + búsqueda + multi-method attack + optimizaciones

local Services = {
    RS = game:GetService("RunService"),
    PL = game:GetService("Players"),
    WS = game:GetService("Workspace"),
    UIS = game:GetService("UserInputService"),
}

local lp = Services.PL.LocalPlayer
local Camera = Services.WS.CurrentCamera

-- ====================== --
-- WHITELIST (mantengo del segundo)
-- ====================== --
local whitelistedUsers = { "CXCHXRRX_27", "Rarita_RmC4", "diegoA7598" }

local function hasPermission()
    for _, name in ipairs(whitelistedUsers) do
        if lp.Name == name then return true end
    end
    return false
end

if not hasPermission() then
    lp:Kick("No autorizado")
    return
end

-- ====================== //
-- CONFIGURACIÓN
-- ====================== //
local cfg = {
    Enabled = false,
    Range = 25,
    RangeSq = 25 * 25,          -- precalculado
    AttackSpeed = 40,           -- intentos por frame
    TargetMode = "Todos (Cercano)",
    SelectedPlayer = nil,       -- será un objeto Player
    SearchText = "",
}

-- Cache de rendimiento
local Vector3_new = Vector3.new
local task_spawn = task.spawn

-- ====================== //
-- MOTOR DE ATAQUE (híbrido de ambos scripts)
-- ====================== //
local HitRemotes = {}

local function CacheRemotes()
    HitRemotes = {}
    local patterns = {"Hit", "Attack", "Combat", "Damage", "Swing", "Punch", "Slash", "Apply", "RF", "Remote"}
    
    for _, obj in ipairs(game:GetDescendants()) do
        if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
            local name = obj.Name:lower()
            for _, pat in ipairs(patterns) do
                if name:find(pat:lower()) then
                    table.insert(HitRemotes, obj)
                    break
                end
            end
        end
    end
    
    -- Intento específico del primer script (ruta común en algunos juegos)
    pcall(function()
        local path = game.ReplicatedStorage.Packages.Knit.Services.CombatService.RF.Hit
        if path then table.insert(HitRemotes, path) end
    end)
end

CacheRemotes()  -- primera búsqueda al cargar

local function Attack(target)
    if not target or not target.Character then return end
    
    local char = target.Character
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if not hum or hum.Health <= 0 or not root then return end
    
    local myChar = lp.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    
    local tool = myChar:FindFirstChildOfClass("Tool")
    
    -- Activar herramienta si existe (click simulation)
    if tool then tool:Activate() end
    
    task_spawn(function()
        for i = 1, cfg.AttackSpeed do
            -- Método 1: todos los remotes cacheados
            for _, remote in ipairs(HitRemotes) do
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(hum, root.Position)
                        remote:FireServer(char, root.Position)
                        remote:FireServer(hum)
                        remote:FireServer(root.Position)
                    else
                        remote:InvokeServer(hum, root.Position)
                        remote:InvokeServer(hum)
                    end
                end)
            end
            
            -- Método 2: remotos dentro de la herramienta (muy común)
            if tool then
                for _, v in ipairs(tool:GetDescendants()) do
                    if v:IsA("RemoteEvent") then
                        pcall(v.FireServer, v, hum, root.Position)
                    end
                end
            end
            
            task.wait() -- evita freeze en loops muy rápidos
        end
    end)
end

-- ====================== //
-- HELPERS DE SELECCIÓN
-- ====================== //
local function GetClosestPlayer()
    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local myPos = myRoot.Position
    local closest = nil
    local bestDistSq = cfg.RangeSq
    
    for _, p in ipairs(Services.PL:GetPlayers()) do
        if p == lp then continue end
        if not p.Character then continue end
        
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        
        if hrp and hum and hum.Health > 0 then
            local distSq = (hrp.Position - myPos).Magnitude ^ 2
            if distSq < bestDistSq then
                bestDistSq = distSq
                closest = p
            end
        end
    end
    return closest
end

local function GetSelectedPlayer()
    if not cfg.SelectedPlayer then return nil end
    return Services.PL:FindFirstChild(cfg.SelectedPlayer)
end

-- ====================== //
-- UI - RAYFIELD (mantenida y mejorada)
-- ====================== //
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "KRISP Kill Aura Hub - 2026",
    LoadingTitle = "Cargando Multi-Method + Search...",
    ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Principal")

Tab:CreateToggle({
    Name = "Kill Aura Activado",
    CurrentValue = false,
    Callback = function(v)
        cfg.Enabled = v
    end,
})

Tab:CreateSlider({
    Name = "Rango de Ataque",
    Range = {8, 60},
    Increment = 1,
    CurrentValue = 25,
    Callback = function(v)
        cfg.Range = v
        cfg.RangeSq = v * v
    end,
})

Tab:CreateSlider({
    Name = "Velocidad de Ataque (intentos)",
    Range = {10, 120},
    Increment = 5,
    CurrentValue = 40,
    Callback = function(v)
        cfg.AttackSpeed = v
    end,
})

local ModeDropdown = Tab:CreateDropdown({
    Name = "Modo de Objetivo",
    Options = {"Todos (Cercano)", "Solo Seleccionado"},
    CurrentOption = {"Todos (Cercano)"},
    Callback = function(opt)
        cfg.TargetMode = opt[1]
    end,
})

local PlayerDropdown = Tab:CreateDropdown({
    Name = "Jugador Específico",
    Options = {"Ninguno"},
    CurrentOption = {"Ninguno"},
    Callback = function(opt)
        if opt[1] == "Ninguno" then
            cfg.SelectedPlayer = nil
        else
            cfg.SelectedPlayer = opt[1]
        end
    end,
})

Tab:CreateButton({
    Name = "Refrescar Lista de Jugadores",
    Callback = function()
        local names = {"Ninguno"}
        for _, p in ipairs(Services.PL:GetPlayers()) do
            if p ~= lp then
                table.insert(names, p.Name)
            end
        end
        PlayerDropdown:Set(names)
    end,
})

Tab:CreateInput({
    Name = "Buscar Jugador (filtro)",
    PlaceholderText = "Escribe nombre o parte...",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        cfg.SearchText = text:lower()
    end,
})

Tab:CreateButton({
    Name = "Recargar Remotos (Fix)",
    Callback = function()
        CacheRemotes()
        Rayfield:Notify({
            Title = "Remotos",
            Content = "Se buscaron nuevamente " .. #HitRemotes .. " remotos posibles.",
            Duration = 4,
        })
    end,
})

-- Notificación inicial
Rayfield:Notify({
    Title = "Hub Cargado",
    Content = "Kill Aura multi-método + búsqueda + selección manual",
    Duration = 6,
})

-- ====================== //
-- BUCLE PRINCIPAL
-- ====================== //
Services.RS.Heartbeat:Connect(function()
    if not cfg.Enabled then return end
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end

    local target = nil

    if cfg.TargetMode == "Solo Seleccionado" then
        target = GetSelectedPlayer()
    else
        -- Modo cercano + filtro de búsqueda opcional
        target = GetClosestPlayer()
        
        if cfg.SearchText ~= "" and target then
            local nameLower = target.Name:lower()
            local displayLower = target.DisplayName:lower()
            if not (nameLower:find(cfg.SearchText) or displayLower:find(cfg.SearchText)) then
                target = nil
            end
        end
    end

    if target then
        local root = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local distSq = (lp.Character.HumanoidRootPart.Position - root.Position).Magnitude ^ 2
            if distSq <= cfg.RangeSq then
                Attack(target)
            end
        end
    end
end)

-- Auto-refresh lista al entrar/salir jugadores
Services.PL.PlayerAdded:Connect(function()
    wait(1.5) -- pequeño retraso para que cargue
    local names = {"Ninguno"}
    for _, p in ipairs(Services.PL:GetPlayers()) do
        if p ~= lp then table.insert(names, p.Name) end
    end
    PlayerDropdown:Set(names)
end)

Services.PL.PlayerRemoving:Connect(function()
    wait(0.8)
    local names = {"Ninguno"}
    for _, p in ipairs(Services.PL:GetPlayers()) do
        if p ~= lp then table.insert(names, p.Name) end
    end
    PlayerDropdown:Set(names)
end)

-- Primer refresh
wait(1)
local names = {"Ninguno"}
for _, p in ipairs(Services.PL:GetPlayers()) do
    if p ~= lp then table.insert(names, p.Name) end
end
PlayerDropdown:Set(names)
