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

-- === FUNÇÃO DE LIMPEZA ===
local function limparMapa()
    local tsunami = workspace:FindFirstChild("ActiveTsunamis")
    if tsunami then tsunami:Destroy() end

    local vipNoWorkspace = workspace:FindFirstChild("VIPWalls")
    if vipNoWorkspace then vipNoWorkspace:Destroy() end

    local floors = workspace:FindFirstChild("Floors")
    if floors then
        local vipWalls = floors:FindFirstChild("VIPWalls")
        if vipWalls then vipWalls:Destroy() end
    end
end

-- === LÓGICA DE TELEPORTE (FUNÇÃO CENTRAL) ===
local function teleportarParaBrainrot(brainrot)
    if not ligado then return end
    
    task.wait(0.1) -- Delay mínimo para carregar física
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hrp and brainrot then
        local destinoPart = nil
        
        -- Tenta achar a melhor parte para teleportar
        if brainrot:IsA("Model") then
            destinoPart = brainrot.PrimaryPart
            if not destinoPart then
                -- Se não tiver PrimaryPart, pega a primeira peça que achar
                destinoPart = brainrot:FindFirstChildWhichIsA("BasePart", true)
            end
        elseif brainrot:IsA("BasePart") then
            destinoPart = brainrot
        end

        if destinoPart then
            hrp.CFrame = destinoPart.CFrame + Vector3.new(0, 4, 0) -- 4 studs acima
            print("⚡ SUCESSO: Teleportado para " .. brainrot.Name)
        else
            warn("⚠️ ERRO: O Brainrot " .. brainrot.Name .. " não tem peças físicas!")
        end
    end
end

-- === MONITORAMENTO E VARREDURA ===
local folderActive = workspace:WaitForChild("ActiveBrainrots", 10)
local folderCelestial = folderActive and folderActive:WaitForChild("Celestial", 10)

if folderCelestial then
    -- 1. Detecta novos que nascem
    folderCelestial.ChildAdded:Connect(function(child)
        teleportarParaBrainrot(child)
    end)
    print("✅ Monitor de Celestiais Ativado na pasta correta!")
else
    warn("❌ ERRO CRÍTICO: Pasta Celestial não encontrada no Workspace!")
end

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

-- === ATIVAR/DESATIVAR ===
MainButton.Activated:Connect(function()
    ligado = not ligado
    if ligado then
        MainButton.Text = "ON"
        MainButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        limparMapa()
        
        -- NOVA VARREDURA: Checa se JÁ tem algo lá quando liga
        if folderCelestial then
            for _, item in pairs(folderCelestial:GetChildren()) do
                teleportarParaBrainrot(item)
            end
        end
    else
        MainButton.Text = "OFF"
        MainButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

-- === LOOPS ===
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

print("✅ Script v4.0 Carregado - Correção de Teleporte Aplicada")
