-- Toggles the shop window on and off when the button is clicked
script.Parent.MouseButton1Click:Connect(function()
	local shopFrame = script.Parent.Parent.Shop
	shopFrame.Visible = not shopFrame.Visible
end)
