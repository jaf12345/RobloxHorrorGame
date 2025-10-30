local collisionsFolder = workspace:WaitForChild("Collisions")
local lobbyGuiFolder = workspace:WaitForChild("LobbyGuis")

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BoxUpdate = ReplicatedStorage:WaitForChild("BoxUpdate")

-- store boxes table to access by number
local boxes = {
	[1] = collisionsFolder:WaitForChild("BoxOne"),
	[2] = collisionsFolder:WaitForChild("BoxTwo"),
	[3] = collisionsFolder:WaitForChild("BoxThree"),
	[4] = collisionsFolder:WaitForChild("BoxFour")
}

-- collision gui table to access by number
local guis = {
	[1] = lobbyGuiFolder:WaitForChild("GuiOne"),
	[2] = lobbyGuiFolder:WaitForChild("GuiTwo"),
	[3] = lobbyGuiFolder:WaitForChild("GuiThree"),
	[4] = lobbyGuiFolder:WaitForChild("GuiFour")
}

-- settings
local MIN_PLAYERS = 2
local CHECK_INTERVAL = 0.5

-- track current players and timers per box
local boxStates = {}

-- reset gui
local function resetGui(id)
	local gui = guis[id]
	local maxPlayers = gui:GetAttribute("MaxPlayers") or 0

	local frame = gui:WaitForChild("SurfaceGui"):WaitForChild("Frame")
	frame.TimerTextLabel.Text = "open"
	frame.PlayerTextLabel.Text = "0 / " .. maxPlayers
	
end

-- update gui text
local function updateGui(id, playerCount)
	local gui = guis[id]
	local maxPlayers = gui:GetAttribute("MaxPlayers") or 0
	local frame = gui:WaitForChild("SurfaceGui"):WaitForChild("Frame")
	frame.PlayerTextLabel.Text = playerCount .. " / " .. maxPlayers
end

-- get players inside a box
local function getPlayersInBox(box)
	local overlap = OverlapParams.new()
	overlap.FilterDescendantsInstances = { box }
	overlap.FilterType = Enum.RaycastFilterType.Blacklist

	local parts = workspace:GetPartBoundsInBox(box.CFrame, box.Size, overlap)
	local players = {}

	for _, part in ipairs(parts) do
		local character = part:FindFirstAncestorWhichIsA("Model")
		if character and character:FindFirstChild("Humanoid") then
			local player = Players:GetPlayerFromCharacter(character)
			if player and not table.find(players, player) then
				table.insert(players, player)
			end
		end
	end

	return players
end

-- main loop to check boxes
for id, box in pairs(boxes) do
	boxStates[id] = {
		players = {},
		timerRunning = false,
		locked = false
	}
	resetGui(id)
end

task.spawn(function()
	while true do
		for id, box in pairs(boxes) do
			local gui = guis[id]
			local maxPlayers = gui:GetAttribute("MaxPlayers") or 0
			local state = boxStates[id]
			local players = getPlayersInBox(box)

			-- remove players who left or walked out
			for i = #state.players, 1, -1 do
				local p = state.players[i]
				if not table.find(players, p) then
					table.remove(state.players, i)
				end
			end

			-- add new players if space
			for _, p in ipairs(players) do
				if not table.find(state.players, p) then
					if #state.players < maxPlayers then
						table.insert(state.players, p)
					end
				end
			end

			local playerIds = {}
			for _, p in ipairs(state.players) do
				table.insert(playerIds, p.UserId) -- send userIds to clients
			end
			
			BoxUpdate:FireAllClients(id, playerIds)
			
			-- update gui player count
			updateGui(id, #state.players)

			-- reset gui if no players remain
			if #state.players == 0 and not state.timerRunning then
				state.locked = false
				resetGui(id)
			elseif #state.players < MIN_PLAYERS then
				local frame = gui:WaitForChild("SurfaceGui"):WaitForChild("Frame")
				frame.TimerTextLabel.Text = "waiting..."
			end
			
			-- start countdown if enough players and not already running
			if #state.players >= MIN_PLAYERS and not state.timerRunning then
				state.timerRunning = true
				state.locked = true
				local countdown = gui:GetAttribute("Countdown") or 10

				task.spawn(function()
					local frame = gui:WaitForChild("SurfaceGui"):WaitForChild("Frame")
					for i = countdown, 1, -1 do
						frame.TimerTextLabel.Text = tostring(i)
						task.wait(1)

						-- stop countdown if players leave
						if #state.players < MIN_PLAYERS then
							frame.TimerTextLabel.Text = "waiting..."
							state.timerRunning = false
							state.locked = false
							break
						end
					end

					-- if countdown finished successfully
					if state.timerRunning then
						frame.TimerTextLabel.Text = "starting!"
						print("box", id, "ready with", #state.players, "players")

						-- teleport players in the box
						
						local PLACE_ID = 140078118155277
						
						-- create a private server and get the access code
						local privateServerCode, privateServerId = TeleportService:ReserveServer(PLACE_ID)

						-- get player list
						local teleportPlayers = {}
						for _, p in ipairs(state.players) do
							if p and p.Parent == Players then
								table.insert(teleportPlayers, p)
							end
						end

						-- teleport players to the private server
						TeleportService:TeleportToPrivateServer(PLACE_ID, privateServerCode, teleportPlayers)

						-- reset state
						state.players = {}
						state.timerRunning = false
						state.locked = false
						resetGui(id)
					end
				end)
			end
		end
		task.wait(CHECK_INTERVAL)
	end
end)

-- handle players leaving the game
Players.PlayerRemoving:Connect(function(player)
	for id, state in pairs(boxStates) do
		for i = #state.players, 1, -1 do
			if state.players[i] == player then
				table.remove(state.players, i)
			end
		end
	end
end)