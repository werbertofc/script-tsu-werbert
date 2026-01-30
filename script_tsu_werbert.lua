-- ==========================================================
-- BRAINROT SUPREME HUB | v6.0 (FULL AUTO)
-- FUNÇÕES: Auto-Farm (Coleta + Evolução Inteligente) + Anti-VIP
-- ==========================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- === CONFIGURAÇÕES ===
local plotID = "{203b3c84-5814-4070-8d7a-db4252ce38d6}" -- ID fornecido por você
local totalSlots = 30
local delayColetaGlobal = 5 -- Tempo para recomeçar a coleta de todos
local delayEvolucao = 1     -- Tempo entre tentar evoluir um slot e outro

-- === REMOTES ===
-- Remote Novo de Coleta
local plotActionRemote = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RF/Plot.PlotAction")

-- Remote de Upgrade (Mantido o padrão funcional, já que não foi fornecido um novo para upgrade)
local upgradeFunction = ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeBrainrot")

-- === FUNÇÃO ANTI-VIP (REMOVE PAREDES) ===
local function removerParedesVIP()
    pcall(function()
        -- Tenta remover do Workspace direto
        if Workspace:FindFirstChild("VIPWalls") then
            Workspace.VIPWalls:Destroy()
        end
        
        -- Tenta remover de dentro da pasta Floors (comum em tycoons)
        if Workspace:FindFirstChild("Floors") and Workspace.Floors:FindFirstChild("VIPWalls") then
            Workspace.Floors.VIPWalls:Destroy()
        end
    end)
end

-- Executa a remoção VIP imediatamente ao iniciar
removerParedesVIP()

-- === LOOP 1: AUTO EVOLUÇÃO (1 por 1 a cada 1 segundo) ===
task.spawn(function()
    print("🧬 Auto-Evolução Iniciada...")
    while true do
        for i = 1, totalSlots do
            pcall(function()
                -- Tenta evoluir o slot atual
                upgradeFunction:InvokeServer("Slot" .. i)
                -- print("🔧 Tentando evoluir Slot " .. i) -- (Opcional: Descomente para ver no F9)
            end)
            
            -- Espera 1 segundo antes de tentar o próximo slot, conforme pedido
            task.wait(delayEvolucao)
        end
        -- Pequena pausa antes de reiniciar o ciclo do 1 ao 30
        task.wait(0.5)
    end
end)

-- === LOOP 2: AUTO COLETA (Todos os slots a cada 5 segundos) ===
task.spawn(function()
    print("💰 Auto-Coleta Iniciada...")
    while true do
        -- Itera por todos os 30 slots para coletar
        for i = 1, totalSlots do
            pcall(function()
                local args = {
                    "Collect Money",
                    plotID,       -- O ID do seu Plot
                    tostring(i)   -- Converte número para texto ("1", "2", etc.)
                }
                plotActionRemote:InvokeServer(unpack(args))
            end)
            -- Um delay minúsculo entre coletas só para o jogo não travar (não afeta os 5s globais)
            task.wait(0.05) 
        end
        
        -- Garante que as paredes VIP sumam sempre
        removerParedesVIP()
        
        -- Espera 5 segundos para fazer a varredura de coleta novamente
        task.wait(delayColetaGlobal)
    end
end)

-- === NOTIFICAÇÃO ===
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Brainrot Hub v6.0";
    Text = "Farm Ativado! Coletando e Evoluindo.";
    Duration = 5;
})

print("🚀 SCRIPT RODANDO: Coleta a cada 5s | Evolução a cada 1s")
