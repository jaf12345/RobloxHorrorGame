-- references
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local puzzle = game.Workspace:WaitForChild("SimonPuzzle")
local unseenmesh = puzzle:WaitForChild("UnseenMesh")
local seenmesh = puzzle:WaitForChild("SeenMesh")
local window = puzzle:WaitForChild("Window")

local MINUNSEEN = 0       -- opaque 
local MINSEEN = 0.3       -- translucent

unseenmesh.Touched:Connect(function(obj)
	if obj.Parent == character then
		window.LocalTransparencyModifier = MINUNSEEN
	end
end)

seenmesh.Touched:Connect(function(obj)
	if obj.Parent == character then
		window.LocalTransparencyModifier = MINSEEN
	end
end)