-- Flashlight toggle with mouse click + equip/unequip sounds

-- Toggle flashlight with Tool.Activated
script.Parent.Activated:Connect(function()
	local handle = script.Parent.Handle
	local light = handle.SpotLight
	local clickSound = handle.Sound

	if light.Enabled then
		light.Enabled = false
	else
		light.Enabled = true
	end
	clickSound:Play()
end)

-- When equipped, disable light and play equip sound
script.Parent.Equipped:Connect(function()
	local handle = script.Parent.Handle
	handle.SpotLight.Enabled = false
	handle.equip:Play()
end)

-- When unequipped, play equip sound (closing sound effect)
script.Parent.Unequipped:Connect(function()
	script.Parent.Handle.equip:Play()
end)



