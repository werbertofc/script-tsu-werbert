-- ==========================================================
-- BRAINROT SUPREME HUB | BY WERBERT_OFC (v5.0)
-- FUNÇÕES: Auto-Farm, Anti-Tsunami, VIP Unlock e Celestial TP
-- ==========================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- === CONFIGURAÇÕES GERAIS ===
local totalSlots = 30
local delayUpgrade = 4
local delayColeta = 5
local ligado = false

-- Remotes do Jogo
local collectEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("CollectMoney")
local upgradeFunction = ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeBrainrot")

-- === INTERFACE MOBILE (BOTÃO ON/OFF) ===
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- Remove GUI antiga se existir
if pGui:FindFirstChild("BrainrotFinalGui") then 
    pGui.BrainrotFinalGui:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrainrotFinalGui"
ScreenGui.Parent = pGui
ScreenGui.ResetOnSpawn = false

local MainButton = Instance.new("TextButton")
MainButton.Name = "ToggleButton"
MainButton.Parent = ScreenGui
MainButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
MainButton.Position = UDim2.new(0.5, -45, 0.2, 0)
MainButton.Size = UDim2.new(0, 90, 0, 90)
MainButton.Font = Enum.Font.GothamBold
MainButton.Text = "OFF"
MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MainButton.TextSize = 18
MainButton.AutoButtonColor = false

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 45)
UICorner.Parent = MainButton

-- === FUNÇÃO DE LIMPEZA DO MAPA ===
local function limparMapa()
    -- Deleta Tsunamis ativos
    local tsunami = workspace:FindFirstChild("ActiveTsunamis")
    if tsunami then tsunami:Destroy() end

    -- Deleta VIPWalls (para usar a proteção VIP)
    local vipNoWorkspace = workspace:FindFirstChild("VIPWalls")
    if vipNoWorkspace then vipNoWorkspace:Destroy() end

    local floors = workspace:FindFirstChild("Floors")
    if floors then
        local vipWalls = floors:FindFirstChild("VIPWalls")
        if vipWalls then vipWalls:Destroy() end
    end
end

-- === LÓGICA DE TELEPORTE (CELESTIAL) ===
-- Resolve o problema de StreamingEnabled (não renderizado)
local function teleportarParaCelestial(brainrot)
    if not ligado then return end
    
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hrp and brainrot then
        -- Força o servidor a carregar a área onde o brainrot está
        local alvoPos = brainrot:GetPivot().Position
        player:RequestStreamAroundAsync(alvoPos) 
        
        task.wait(0.2) -- Tempo para física carregar
        
        -- Teleporta 5 blocos acima do alvo para evitar bugs
        hrp.CFrame = CFrame.new(alvoPos + Vector3.new(0, 5, 0))
        print("⚡ SUCESSO: Personagem movido para " .. brainrot.Name)
    end
end

-- === MONITORAMENTO DA PASTA CELESTIAL ===
task.spawn(function()
    while true do
        if ligado then
            local activeFolder = workspace:FindFirstChild("ActiveBrainrots")
            if activeFolder then
                local celestialFolder = activeFolder:FindFirstChild("Celestial")
                if celestialFolder then
                    local itens = celestialFolder:GetChildren()
                    if #itens > 0 then
                        -- Se houver qualquer Celestial na pasta, teleporta para o primeiro
                        teleportarParaCelestial(itens[1])
                    end
                end
            end
        end
        task.wait(1.5) -- Verifica a cada 1.5 segundos
    end
end)

-- === SISTEMA DE ARRASTAR O BOTÃO (MOBILE) ===
local dragging, dragStart, startPos
MainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainButton.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        MainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

MainButton.InputEnded:Connect(function() dragging = false end)

-- === LÓGICA DO BOTÃO ON/OFF ===
MainButton.Activated:Connect(function()
    ligado = not ligado
    if ligado then
        MainButton.Text = "ON"
        MainButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        limparMapa()
    else
        MainButton.Text = "OFF"
        MainButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

-- === LOOPS DE FARM AUTOMÁTICO ===
-- Loop de Coleta (Dinheiro)
task.spawn(function()
    while true do
        if ligado then
            for i = 1, totalSlots do
                collectEvent:FireServer("Slot" .. i)
            end
            limparMapa() -- Garante que o tsunami suma sempre
        end
        task.wait(delayColeta)
    end
end)

-- Loop de Upgrade (Evolução)
task.spawn(function()
    while true do
        if ligado then
            for i = 1, totalSlots do
                pcall(function()
                    upgradeFunction:InvokeServer("Slot" .. i)
                end)
                task.wait(0.05) -- Delay pequeno entre slots para evitar kick
            end
        end
        task.wait(delayUpgrade)
    end
end)

print("🚀 Script v5.0 Carregado com Sucesso!")
print("👤 Criado por: werbert_ofc")
