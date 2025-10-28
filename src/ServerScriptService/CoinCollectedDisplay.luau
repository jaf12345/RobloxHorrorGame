game.Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder",player)
	leaderstats.Name = "leaderstats"
	
	local Cash = Instance.new("IntValue",leaderstats)
	Cash.Name = "Cash"
	Cash.Value = 0
end)

script.Parent.CanCollide = false
local cloning
db = false
script.Parent.Touched:Connect(function(hit)
	cloning = script.Parent:Clone()
	script.Parent.Transparency = 0.3
	local humanoid = game.Players:GetPlayerFromCharacter(hit.Parent)
	if humanoid then
		if not db then
			db =true
			humanoid.leaderstats.Coins.Value = humanoid.leaderstats.Coins.Value + 1
			wait()
			cloning.Parent = game.Lighting
			cloning.Transparency = 0
			for i = 0.3,1,0.01 do
				script.Parent.Transparency = i
				wait()
				print(i)
			end
			script.Parent:Destroy()
			wait(10)
			cloning.Parent = game.Workspace
			--cloning.Position = Vector3(-2.92, 1.915, -3.423)
			db = false
		end
	end
end)
