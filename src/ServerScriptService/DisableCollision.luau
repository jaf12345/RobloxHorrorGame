-- server script to disable player to player collisions
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

-- create a collision group for players
local groupName = "NoPlayerCollision"
if not pcall(function() PhysicsService:GetCollisionGroupId(groupName) end) then
	PhysicsService:CreateCollisionGroup(groupName)
end

-- make this group ignore itself
PhysicsService:CollisionGroupSetCollidable(groupName, groupName, false)

-- function to assign all character parts to the group
local function setCharacterCollisionGroup(character)
	for _, part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(part, groupName)
		end
	end
end

-- apply to current and future players
for _, player in pairs(Players:GetPlayers()) do
	if player.Character then
		setCharacterCollisionGroup(player.Character)
	end
	player.CharacterAdded:Connect(setCharacterCollisionGroup)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(setCharacterCollisionGroup)
end)
