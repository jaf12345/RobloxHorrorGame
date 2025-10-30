local PhysicsService = game:GetService("PhysicsService")

-- create collision groups (if they don't exist yet)
PhysicsService:CreateCollisionGroup("Entity")
PhysicsService:CreateCollisionGroup("ClosetCollision")

-- setup collision rules
PhysicsService:CollisionGroupSetCollidable("ClosetCollision", "Default", false)
PhysicsService:CollisionGroupSetCollidable("ClosetCollision", "Entity", true)
PhysicsService:CollisionGroupSetCollidable("Entity", "Default", true)

-- function to assign npc parts to Entity group
local function setEntityCollisionGroup(model)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(part, "Entity")
		end
	end
end

-- function to assign closet collision part
local function setClosetCollision()
	for _, closet in ipairs(workspace:GetChildren()) do
		if closet:IsA("Model") and closet.Name == "Closet" then
			local collisionPart = closet:FindFirstChild("CollisionPart")
			if collisionPart and collisionPart:IsA("BasePart") then
				PhysicsService:SetPartCollisionGroup(collisionPart, "ClosetCollision")
			end
		end
	end
end

-- assign groups
local entityNPC = workspace:WaitForChild("EntityNPC")
setEntityCollisionGroup(entityNPC)
setClosetCollision()



