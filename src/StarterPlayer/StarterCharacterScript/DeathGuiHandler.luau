local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShowSpectateGui = ReplicatedStorage:WaitForChild("ShowSpectateGui")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

ShowSpectateGui.OnClientEvent:Connect(function()
	local gui = player:WaitForChild("PlayerGui"):WaitForChild("SpectateGui")
	gui.Enabled = true
end)