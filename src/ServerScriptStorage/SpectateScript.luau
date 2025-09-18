local Players  = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SpectateEvent = ReplicatedStorage:WaitForChild("SpectateEvent")
local RefreshSpectateList = ReplicatedStorage:WaitForChild("RefreshSpectateList")

local ShowSpectateGui = ReplicatedStorage:WaitForChild("ShowSpectateGui")

Players.CharacterAutoLoads = false

Players.PlayerAdded:Connect(function(player)
	print(player.Name .. " connected")
	player:LoadCharacter()

	-- wait for their character to exist
	local char = player.Character or player.CharacterAdded:Wait()

	-- now spawn the character
	if not char then
		player:LoadCharacter()
		char = player.Character or player.CharacterAdded:Wait()
	end

	local humanoid = char:WaitForChild("Humanoid")
	print(player.Name .. " character added")

	humanoid.Died:Connect(function()
		print(player.Name .. " is dead")
		
		-- show SpectateGui for player who died
		ShowSpectateGui:FireClient(player)
		RefreshSpectateList:FireClient(player)
		
		-- find another alive player to spectate
		for _, otherPlayer in pairs(Players:GetPlayers()) do
			if otherPlayer ~= player and otherPlayer.Character then
				local otherHum = otherPlayer.Character:FindFirstChild("Humanoid")
				if otherHum and otherHum.Health > 0 then
					print(player.Name .. " now spectating " .. otherPlayer.Name)
					SpectateEvent:FireClient(player, otherPlayer)
				end
			end
		end
	end)
end)


SpectateEvent.OnServerEvent:Connect(function(requester, targetPlayer)
	if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
		-- Tell the requester to spectate this player
		SpectateEvent:FireClient(requester, targetPlayer)
	end
end)