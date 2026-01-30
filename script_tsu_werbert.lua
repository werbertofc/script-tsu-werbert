--[[
    SCRIPT BRAINROT TYCOON AUTO-FARM (V3 - Final)
    
    Funcionalidades:
    1. Auto Detect Plot ID (Detecta seu plot sozinho)
    2. Remove VIPWalls (Procura e deleta "VIPWalls" no Workspace)
    3. Auto Collect (Todos os 30 slots a cada 5s)
    4. Auto Evolve (Tenta evoluir sequencialmente, 1 por segundo)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- CONFIGURAÇÕES
local NomeDaAcaoColetar = "Collect Money"
local NomeDaAcaoEvoluir = "Evolve" -- Se não funcionar, tente trocar por "Upgrade"
local RemotePlot = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RF/Plot.PlotAction")

print("--- Script Iniciado V3 ---")

-------------------------------------------------------------------------
-- 1. DETECTOR AUTOMÁTICO DE ID DO PLOT
-------------------------------------------------------------------------
local function ObterIDDoPlot()
    -- Procura nos filhos do Workspace
    for _, objeto in pairs(Workspace:GetChildren()) do
        local ownerValue = objeto:FindFirstChild("Owner")
        if ownerValue and ownerValue.Value == LocalPlayer then
            return objeto.Name
        end
        
        -- Procura dentro de pastas comuns (Tycoons, Plots, etc)
        if objeto:IsA("Folder") then
            for _, plotInterno in pairs(objeto:GetChildren()) do
                local ownerInterno = plotInterno:FindFirstChild("Owner")
                if ownerInterno and ownerInterno.Value == LocalPlayer then
                    return plotInterno.Name
                end
            end
        end
    end
    return nil
end

local MEU_PLOT_ID = nil
repeat
    MEU_PLOT_ID = ObterIDDoPlot()
    if not MEU_PLOT_ID then
        task.wait(1)
    end
until MEU_PLOT_ID ~= nil

print("ID DO PLOT DETECTADO: " .. MEU_PLOT_ID)

-------------------------------------------------------------------------
-- 2. REMOVER ESPECIFICAMENTE "VIPWalls"
-------------------------------------------------------------------------
task.spawn(function()
    print("Procurando objetos 'VIPWalls'...")
    task.wait(1) -- Pequeno delay para garantir carregamento
    local contagem = 0
    
    -- Varre o Workspace inteiro procurando pelo nome exato
    for _, objeto in pairs(Workspace:GetDescendants()) do
        if objeto.Name == "VIPWalls" then
            objeto:Destroy()
            contagem = contagem + 1
        end
    end
    print("Total de 'VIPWalls' removidas: " .. contagem)
end)

-------------------------------------------------------------------------
-- 3. FUNÇÃO DE INTERAÇÃO (Base)
-------------------------------------------------------------------------
local function interagirComSlot(acao, slotNumero)
    local args = {
        acao,
        MEU_PLOT_ID,
        tostring(slotNumero)
    }
    pcall(function()
        RemotePlot:InvokeServer(unpack(args))
    end)
end

-------------------------------------------------------------------------
-- 4. AUTO COLLECT (Todos os slots a cada 5s)
-------------------------------------------------------------------------
task.spawn(function()
    while true do
        for i = 1, 30 do
            task.spawn(function()
                interagirComSlot(NomeDaAcaoColetar, i)
            end)
        end
        task.wait(5)
    end
end)

-------------------------------------------------------------------------
-- 5. AUTO EVOLVE (Um por um, a cada 1s)
-------------------------------------------------------------------------
task.spawn(function()
    while true do
        for i = 1, 30 do
            interagirComSlot(NomeDaAcaoEvoluir, i)
            task.wait(1) -- Tenta o próximo slot após 1 segundo
        end
        -- Ao chegar no 30, o loop 'while' reinicia voltando para o 1
    end
end)
