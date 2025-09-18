local replicatedStorage = game:GetService('ReplicatedStorage') -- get the replicated storage service
local players = game:GetService('Players') --acessing player service 


local joinEvent = replicatedStorage.MainMenuRemoteEvents:WaitForChild('JoinLobby') --remote event for joining lobbies client and server communnication
local updateEvent = replicatedStorage.MainMenuRemoteEvents:WaitForChild('UpdateLobbyUI') --remote event for updating client side UI

--lobby que
local lobbyPlayer = {} --store que

local MIN_PLAYERS = 2
local MAX_PLAYERS = 4

-- function to update all players UI

local function updateAllUIs()
	local plyCount = #lobbyPlayer --gets index total of players in que
	
	for _, plr in ipairs(players:GetPlayers()) do
		updateEvent:FireClient(plr, plyCount, MIN_PLAYERS, MAX_PLAYERS)
	end
end

--handaling join/leave requests 

joinEvent.OnServerEvent:Connect(function(player, action)
	if action == 'Join' then
		if not table.find(lobbyPlayer,player) and #lobbyPlayer < MAX_PLAYERS then
			table.insert(lobbyPlayer, player)
		end
	elseif action == 'Leave' then
		for i, plr in ipairs(lobbyPlayer) do
			if plr == player then
				table.remove(lobbyPlayer, i)
				
				break
			end
		end
	end
	updateAllUIs()
end)
