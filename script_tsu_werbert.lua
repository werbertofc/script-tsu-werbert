-- ==========================================================
-- BRAINROT SUPREME HUB | v8.0 (BOTÃO MÓVEL + AUTO-FARM)
-- ==========================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- === VARIÁVEIS DE CONTROLE ===
local farmAtivo = false
local totalSlots = 30
local plotActionRemote = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RF/Plot.PlotAction")

-- === CRIAÇÃO DA INTERFACE (GUI) ===
local ScreenGui = Instance.new("ScreenGui")
local MenuButton = Instance.new("TextButton")

ScreenGui.Name = "BrainrotHubGui"
ScreenGui.Parent = lp:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

MenuButton.Name = "ToggleFarm"
MenuButton.Parent = ScreenGui
MenuButton.Size = UDim2.new(0, 20, 0, 20) -- Tamanho 20x20
MenuButton.Position = UDim2.new(0.5, 0, 0.5, 0)
MenuButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Começa Vermelho
MenuButton.Text = ""
MenuButton.BorderSizePixel = 2
MenuButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
MenuButton.ZIndex = 10

-- === SISTEMA DE ARRASTAR (DRAGGABLE) ===
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MenuButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MenuButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MenuButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MenuButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- === LÓGICA DO AUTO-FARM ===

local function getPlotID()
    for _, plot in pairs(Workspace:WaitForChild("Plots"):GetChildren()) do
        if plot:FindFirstChild("Owner") and plot.Owner.Value == lp.Name then
            return plot.Name
        end
    end
    return nil
end

local function removerParedesVIP()
    pcall(function()
        if Workspace:FindFirstChild("VIPWalls") then Workspace.VIPWalls:Destroy() end
        if Workspace:FindFirstChild("Floors") and Workspace.Floors:FindFirstChild("VIPWalls") then
            Workspace.Floors.VIPWalls:Destroy()
        end
    end)
end

-- Loop de Coleta e Evolução (Só roda se farmAtivo for true)
task.spawn(function()
    while true do
        if farmAtivo then
            local plotID = getPlotID()
            if plotID then
                removerParedesVIP()
                for i = 1, totalSlots do
                    if not farmAtivo then break end
                    pcall(function()
                        -- Coleta
                        plotActionRemote:InvokeServer("Collect Money", plotID, tostring(i))
                        -- Evolução (Simultânea para eficiência)
                        plotActionRemote:InvokeServer("Upgrade Slot", plotID, tostring(i))
                    end)
                    task.wait(0.1) -- Proteção anti-kick
                end
            end
        end
        task.wait(1)
    end
end)

-- === EVENTO DE CLIQUE DO BOTÃO ===
MenuButton.MouseButton1Click:Connect(function()
    farmAtivo = not farmAtivo
    
    if farmAtivo then
        MenuButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Verde
        print("✅ Farm Ativado")
    else
        MenuButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Vermelho
        print("❌ Farm Desativado")
    end
end)

print("🚀 Script Carregado! Botão 20x20 na tela. Clique para ativar.")
