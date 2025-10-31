-- Adds all items from ServerStorage to the shop UI

local storedItems = game.ServerStorage:WaitForChild("Item"):GetChildren()

for index = 1, #storedItems do
	-- get a fresh copy of the item template
	local itemTemplate = script:WaitForChild("Item"):Clone()
	
	-- set up the item display info
	local currentItem = storedItems[index]
	itemTemplate.Name = currentItem.Name
	itemTemplate.Image = currentItem.TextureId
	itemTemplate.Buy.Text = "$" .. currentItem.Price.Value
	itemTemplate.ItemName.Text = currentItem.Name
	
	-- drop it into the shop frame
	itemTemplate.Parent = script.Parent
end
