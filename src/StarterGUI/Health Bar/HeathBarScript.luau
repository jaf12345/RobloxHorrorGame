-- Get the local player (the player running this script)
local player = game.Players.LocalPlayer

-- Get the player's character. If it doesn't exist yet, wait until it spawns
local character = player.Character or player.CharacterAdded:Wait()

-- Wait until the "Humanoid" object is available inside the character
local humanoid = character:WaitForChild("Humanoid")

-- Connect a function to the "HealthChanged" event of the humanoid
-- This event triggers whenever the player's health changes
humanoid.HealthChanged:Connect(function(Damage)
	-- Update the size of the GUI element (script's parent) based on current health
	-- The X scale is set to the ratio of current health / max health
	-- This effectively makes a health bar that shrinks as the player takes damage
	script.Parent.Size = UDim2.new(Damage / humanoid.MaxHealth, 0, 1, 0)
end)
