local Players = game:GetService("Players")
local dnaFolder = workspace:WaitForChild("Pickups") -- where DNA is stored

-- function to check if part belongs to a character
local function getPlayerFromPart(part)
	local character = part:FindFirstAncestorWhichIsA("Model")
	if character and Players:GetPlayerFromCharacter(character) then
		return Players:GetPlayerFromCharacter(character)
	end
	return nil
end

-- function to hook up touch event for a DNA object
local function setupDNA(dna)
	if dna.PrimaryPart then
		dna.PrimaryPart.Touched:Connect(function(hit)
			local player = getPlayerFromPart(hit)
			if player then
				-- remove DNA when touched by player
				dna:Destroy()
				print(player.Name .. " collected DNA!")
			end
		end)
	end
end

-- setup existing DNA
for _, dna in ipairs(dnaFolder:GetChildren()) do
	if dna:IsA("Model") then
		setupDNA(dna)
	end
end

-- handle new DNA if spawned later
dnaFolder.ChildAdded:Connect(function(child)
	if child:IsA("Model") then
		child:GetPropertyChangedSignal("PrimaryPart"):Connect(function()
			if child.PrimaryPart then
				setupDNA(child)
			end
		end)
	end
end)
