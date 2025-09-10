local entity = script.Parent --the entity model

local NPChumanoid = entity:WaitForChild("Humanoid") -- waiting for the humanoid model to spawn into the world
local rootPart = entity:WaitForChild("HumanoidRootPart") --waiting for the core component of humanoid to be registerd

local chaseRange = 60 

local wayPFolder = workspace:WaitForChild("Waypoints") --loads waypoints folder

local wayPoints = wayPFolder:GetChildren() --gets all the waypoints

local players = game:GetService("Players") --roblox servise to retrive all active playyers in game



--DETECT PLAYER FUNCTION
local function getNearestPlayer(MaxDist) --takes parameter max distance we care about
	local nearestPlayer = nil
	local nearestDist = MaxDist

	for _, player in ipairs(players:GetPlayers()) do --getting all players from 'players' servise stored in players storing it in 'player' looping through 
		local char = player.Character --acessing the player character model

		if char and char:FindFirstChild("HumanoidRootPart") then --check statement to see if player exsit and if it has humanoid root part
			local dist = (char.HumanoidRootPart.Position - rootPart.Position).Magnitude  --minus vector 3 positions to give the differnce in studs

			if dist < nearestDist then --if another player is closer then the current closest player then make the new player the closest player
				nearestDist = dist
				nearestPlayer = player 
			end
		end
	end
	print(nearestPlayer)
	return nearestPlayer 
end



while true do 
	--look for nearby player
	local targetPlayer = getNearestPlayer(chaseRange) --currently an enum set to 60 studs
	
	if targetPlayer then
		print("Chasing player:",targetPlayer.Name) --print the player name
		
		local targetChar = targetPlayer.Character --sets target charater model to the target player
		local targetRoot = targetChar:WaitForChild("HumanoidRootPart") --gets the target player root part
		
		NPChumanoid:MoveTo(targetRoot.Position) --moves the entity to the target player
		NPChumanoid.MoveToFinished:Wait(0.5) --wait until the movement is finished before moving to the next waypoint
		
	else
		--normal patroll
		for _, wp in ipairs(wayPoints) do --loops through the waypoints in order using ipairs 
			NPChumanoid:MoveTo(wp.Position) --acess waypoints position and moves to it, .Position is a vector3 (x,y,z)
			NPChumanoid.MoveToFinished:Wait() --waits until the movement is finished before moving to the next waypoint
			wait(1)
		end
	end
end