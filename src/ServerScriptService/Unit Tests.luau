local TestService = game:GetService("TestService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MyModule = require(ReplicatedStorage.TestModules:WaitForChild("MyModule"))
local GlitchEffect = require(ReplicatedStorage.TestModules:WaitForChild("GlitchEffect"))


-- helper to make a fake player with leaderstats.Cash
local function createFakePlayer(startingCash)
	local player = Instance.new("Folder")
	player.Name = "FakePlayer"
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = startingCash or 0
	cash.Parent = leaderstats
	return player, cash
end


-- glitch cooldown test
local function testGlitchCooldown()
	-- get static images
	local staticEffect1 = ReplicatedStorage:WaitForChild("Static1")
	local staticEffect2 = ReplicatedStorage:WaitForChild("Static2")
	local staticEffect3 = ReplicatedStorage:WaitForChild("Static3")
	local staticEffect4 = ReplicatedStorage:WaitForChild("Static4")
	local staticEffect5 = ReplicatedStorage:WaitForChild("Static5")

	local effectTable = { staticEffect1, staticEffect2, staticEffect3, staticEffect4, staticEffect5 }

	-- dummy image for testing
	local image = Instance.new("ImageLabel")
	image.ImageTransparency = 1

	-- create glitch controller
	local glitch = GlitchEffect.create(effectTable, image)

	TestService:Message("testing glitch trigger... (should pass)")

	local firstRun = glitch:trigger()
	TestService:Check(firstRun == true, "FAILED: Currently in cooldown")
	TestService:Message("testing glitch trigger... (without cooldown: should fail)")
	
	local secondRun = glitch:trigger()
	TestService:Check(secondRun == true, "FAILED: Currently in cooldown")
	TestService:Message("testing glitch trigger... (with cooldown: should pass)")
	
	task.wait(0.4)
	local thirdRun = glitch:trigger()
	TestService:Check(thirdRun == true, "FAILED: Currently in cooldown")
end


-- Coin tests

local function test_singleIncrement()
	TestService:Message("Running test_singleIncrement... (should pass)")
	local _, cash = createFakePlayer(5)
	cash.Value += 1
	TestService:Check(cash.Value == 6, "FAILED: Cash should now be 6 after one coin (+1 from 5)")
end

local function test_multipleIncrements()
	TestService:Message("Running test_multipleIncrements... (should pass adds 5 in multiple increments from 0)")
	local _, cash = createFakePlayer(0)
	for _ = 1, 5 do
		cash.Value += 1
	end
	TestService:Check(cash.Value == 5, "FAILED: Cash should be 5 after five coins worth 1 each")
end

--  This one will FAIL visibly
local function test_customValue()
	TestService:Message("Running test_customValue... (should fail 10+10 does not equal 21")
	local _, cash = createFakePlayer(10)
	local COIN_VALUE = 10
	cash.Value += COIN_VALUE

	TestService:Check(cash.Value == 21, "FAILED: Cash didn't equal 21")
end

local function test_zeroAdd()
	TestService:Message("Running test_zeroAdd... (should pass adds 0 to coin value 3)")
	local _, cash = createFakePlayer(3)
	cash.Value += 0
	TestService:Check(cash.Value == 3, "FAILED: Cash should stay 3 when adding 0")
end


-- safely run tests
local ok, err = pcall(function()
	task.wait(1.5)
	TestService:Message("starting tests in 5 seconds...")
	task.wait(5)
	TestService:Message("unit tests begun (WILL OUTPUT 'FAILED' IF TEST FAILED AND NOTHING IF PASSED)")

	testGlitchCooldown()
	test_singleIncrement()
	test_multipleIncrements()
	test_customValue()
	test_zeroAdd()
end)


