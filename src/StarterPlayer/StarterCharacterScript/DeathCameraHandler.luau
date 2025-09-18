local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpectateEvent = ReplicatedStorage:WaitForChild("SpectateEvent")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

SpectateEvent.OnClientEvent:Connect(function(targetPlayer)
	local char = targetPlayer.Character or targetPlayer
	local camera = workspace.CurrentCamera
	camera.CameraSubject = targetPlayer.Character:WaitForChild("Humanoid")
	camera.CameraType = Enum.CameraType.Custom
end)