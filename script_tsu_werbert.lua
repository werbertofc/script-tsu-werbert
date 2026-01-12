local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- === CONFIGURAÇÕES ===
local totalSlots = 30
local delayUpgrade = 4
local delayColeta = 5
local ligado = false

local collectEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("CollectMoney")
local upgradeFunction = ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeBrainrot")

-- === INTERFACE MOBILE ===
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

if pGui:FindFirstChild("BrainrotFinalGui") then pGui.BrainrotFinalGui:Destroy() end

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

-- === FUNÇÃO DE LIMPEZA COMPLETA ===
local function limparMapa()
    -- 1. Apaga a pasta ActiveTsunamis no Workspace
    local tsunami = workspace:FindFirstChild("ActiveTsunamis")
    if tsunami then tsunami:Destroy() end

    -- 2. Apaga VIPWalls direto no Workspace
    local vipNoWorkspace = workspace:FindFirstChild("VIPWalls")
    if vipNoWorkspace then vipNoWorkspace:Destroy() end

    -- 3. Apaga VIPWalls dentro de Workspace.Floors
    local floors = workspace:FindFirstChild("Floors")
    if floors then
        local vipWalls = floors:FindFirstChild("VIPWalls")
        if vipWalls then vipWalls:Destroy() end
    end
end

-- === NOVO: SISTEMA DE TELEPORTE CELESTIAL ===
task.spawn(function()
    -- Aguarda as pastas existirem para evitar erro
    local activeBrainrots = workspace:WaitForChild("ActiveBrainrots", 10)
    if activeBrainrots then
        local celestialFolder = activeBrainrots:WaitForChild("Celestial", 10)
        
        if celestialFolder then
            -- Monitora quando algo NOVO aparece na pasta Celestial
            celestialFolder.ChildAdded:Connect(function(novoBrainrot)
                if ligado then
                    task.wait(0.1) -- Pequeno delay para o objeto carregar física
                    local char = player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp then
                        -- Verifica se é um Modelo ou uma Parte para pegar a posição
                        local destino = nil
                        if novoBrainrot:IsA("Model") then
                            destino = novoBrainrot.PrimaryPart or novoBrainrot:FindFirstChildWhichIsA("BasePart")
                        elseif novoBrainrot:IsA("BasePart") then
                            destino = novoBrainrot
                        end

                        -- Realiza o teleporte
                        if destino then
                            hrp.CFrame = destino.CFrame + Vector3.new(0, 3, 0) -- Teleporta um pouco acima para não bugar
                            print("⚡ Teleportado para Celestial: " .. novoBrainrot.Name)
                        end
                    end
                end
            end)
            print("✅ Monitoramento de Celestiais Ativado!")
        end
    else
        warn("Pasta ActiveBrainrots não encontrada.")
    end
end)

-- === SISTEMA DE ARRASTAR (TOUCH) ===
local dragging = false
local dragStart, startPos

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

MainButton.InputEnded:Connect(function(input)
    dragging = false
end)

-- === LÓGICA DE ATIVAR ===
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

-- === LOOP DE COLETA E LIMPEZA (5s) ===
task.spawn(function()
    while true do
        if ligado then
            for i = 1, totalSlots do
                collectEvent:FireServer("Slot" .. i)
            end
            limparMapa() 
        end
        task.wait(delayColeta)
    end
end)

-- === LOOP DE UPGRADE (4s) ===
task.spawn(function()
    while true do
        if ligado then
            for i = 1, totalSlots do
                pcall(function()
                    upgradeFunction:InvokeServer("Slot" .. i)
                end)
                task.wait(0.05) 
            end
        end
        task.wait(delayUpgrade)
    end
end)

print("✅ Script Carregado: Auto-Farm + Clean Map + Celestial TP")
