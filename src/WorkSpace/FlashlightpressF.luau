-- Flashlight toggle with F key
local player = game.Players.LocalPlayer
local userInput = game:GetService("UserInputService")

userInput.InputBegan:Connect(function(input)
	-- Only works if the tool is equipped (not sitting in Backpack)
	if script.Parent.Parent.Name ~= "Backpack" then
		if input.KeyCode == Enum.KeyCode.F then
			local handle = script.Parent.Handle
			local light = handle.SpotLight
			local clickSound = handle.Sound

			if light.Enabled then
				light.Enabled = false
			else
				light.Enabled = true
			end
			clickSound:Play()
		end
	end
end)
