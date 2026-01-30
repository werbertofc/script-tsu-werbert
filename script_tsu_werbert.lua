-- ==========================================================
-- BRAINROT SUPREME HUB | BY WERBERT_OFC (v5.1)
-- FUNÇÕES: Auto-Farm (Novo Remote), VIP Unlock e Celestial TP
-- ==========================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- === CONFIGURAÇÕES GERAIS ===
local totalSlots = 30
local delayUpgrade = 4
local delayColeta = 5 -- Pode ajustar se precisar coletar mais rápido
local ligado = false
local plotIdFixo = "{b201fbdf-a8b6-4aea-a1a7-e88485724a29}" -- ID fornecido

-- === REMOTES DO JOGO ===
-- Novo Remote de Coleta (Caminho atualizado)
local plotActionRemote = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RF/Plot.PlotAction")

-- Remote Antigo de Upgrade (Mantido, verifique se ainda funciona ou se precisa atualizar também)
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

-- === FUNÇÃO DE LIMPEZA DO MAPA (ATUALIZADA) ===
local function limparMapa()
    -- ATENÇÃO: A limpeza de Tsunamis foi REMOVIDA conforme pedido.
    
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
local function teleportarParaCelestial(brainrot)
    if not ligado then return end
    
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hrp and brainrot then
        local alvoPos = brainrot:GetPivot().Position
        player:RequestStreamAroundAsync(alvoPos) 
        
        task.wait(0.2)
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
                        teleportarParaCelestial(itens[1])
                    end
                end
            end
        end
        task.wait(1.5)
    end
end)

-- === SISTEMA DE ARRASTAR O BOTÃO ===
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

-- === LOOPS DE FARM AUTOMÁTICO (ATUALIZADO) ===
-- Loop de Coleta (Dinheiro) com NOVO REMOTE
task.spawn(function()
    while true do
        if ligado then
            for i = 1, totalSlots do
                -- Estrutura dos argumentos fornecida pelo usuário
                local args = {
                    "Collect Money",
                    plotIdFixo,   -- ID do plot fornecido
                    tostring(i)   -- Converte o número do slot (1 a 30) para string
                }
                
                -- Usamos pcall para evitar que o script pare se um slot falhar
                pcall(function()
                    plotActionRemote:InvokeServer(unpack(args))
                end)
                
                task.wait(0.05) -- Pequeno delay para não sobrecarregar
            end
            
            limparMapa() -- Remove apenas paredes VIP agora
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
                task.wait(0.05)
            end
        end
        task.wait(delayUpgrade)
    end
end)

print("🚀 Script v5.1 Atualizado Carregado!")
print("👤 Criado por: werbert_ofc | Atualizado com novo Remote")
