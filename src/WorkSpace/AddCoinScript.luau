-- Coin script: gives cash on touch, then respawns after a short delay

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local coin = script.Parent
coin.CanCollide = false

local COIN_VALUE = 1          -- change to 1000 if you want bigger rewards
local RESPAWN_DELAY = 10      -- time (in seconds) before the coin reappears

local cooldown = false
local spawnCFrame = coin.CFrame

-- makes the coin fade out before disappearing
local function fadeOut(part)
	for step = 0.3, 1, 0.05 do
		part.Transparency = step
		task.wait()
	end
end

-- handle player touching the coin
coin.Touched:Connect(function(hit)
	if cooldown then return end

	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player then return end

	local stats = player:FindFirstChild("leaderstats")
	if not stats then return end

	local cash = stats:FindFirstChild("Cash")
	if not cash then return end

	cooldown = true
	cash.Value += COIN_VALUE

	-- fade away the collected coin
	fadeOut(coin)

	-- prepare a clone for later respawn
	local replacement = coin:Clone()
	replacement.Transparency = 0
	replacement.CFrame = spawnCFrame
	replacement.Parent = ServerStorage

	-- remove the old coin
	coin:Destroy()

	-- wait and then bring it back
	task.wait(RESPAWN_DELAY)
	replacement.Parent = workspace
end)
