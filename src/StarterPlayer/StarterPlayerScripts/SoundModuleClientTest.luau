task.wait(8) -- wait for other unit tests to fire

-- references to services
-- Test Framework framework
local TestService = game:GetService("TestService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local playerRoot = character:WaitForChild("HumanoidRootPart")

local target = workspace:WaitForChild("EntityNPC")
local targetRoot = target:WaitForChild("HumanoidRootPart")

-- reference to sound module which checks whether the 
local SoundModule = require(game.ReplicatedStorage.TestModules.SoundModule)

local function assertEqual(actual, expected, name)
	-- TESTS
	if expected then
		TestService:Message(("Expected to pass"))
	else
		TestService:Message("Expected to fail")
	end
	
	-- if actual equals expected then print (" Passed: " .. name)
	if actual == expected then
		TestService:Message("✅ Passed: " .. name)
	else
		TestService:Message(("❌ Failed: %s | expected %s, got %s"):format(name, tostring(expected), tostring(actual)))
	end
end

-- message to show the test is starting
TestService:Message("Geiger sound unit test starting...")

-- Static logic tests 
assertEqual(SoundModule.shouldPlaySound(10), true,  "10 studs → play")
assertEqual(SoundModule.shouldPlaySound(50), true,  "50 studs → play")
assertEqual(SoundModule.shouldPlaySound(71), false, "71 studs → stop")
assertEqual(SoundModule.shouldPlaySound(72), true, "72 studs → stop")
assertEqual(SoundModule.shouldPlaySound(-5), false, "-5 studs → stop")

-- distance from player to entity
local distance = (playerRoot.Position - targetRoot.Position).Magnitude
-- returns if 
local expected = SoundModule.shouldPlaySound(distance)

--  one test from player localtion 
TestService:Message(("Player %.1f studs from Entity"):format(distance))
assertEqual(expected, distance <= SoundModule.MAX_DISTANCE, "Live distance boundary")

TestService:Message(("Player %.1f studs from Entity"):format(distance))
assertEqual(expected, distance >= SoundModule.MAX_DISTANCE, "Live distance boundary")

TestService:Message("!!! Test finished.")
