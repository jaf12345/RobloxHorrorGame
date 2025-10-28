local Item = game.ServerStorage.Item:GetChildren()

for i = 1, #Item do
	local NewItem = script:WaitForChild("Item"):Clone()
	NewItem.Name = Item[i].Name
	NewItem.Image = Item[i].TextureId
	NewItem.Buy.Text = "$"..Item[i].Price.Value
	NewItem.ItemName.Text = Item[i].Name
	NewItem.Parent = script.Parent
end
