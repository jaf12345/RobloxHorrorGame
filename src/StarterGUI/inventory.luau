-- custom inventory ui (client)
-- replaces default roblox hotbar, adds search + scroll cycle

-- services
local StarterGui = game:GetService("StarterGui")
local CAS        = game:GetService("ContextActionService")
local UIS        = game:GetService("UserInputService")
local Players    = game:GetService("Players")

-- player refs
local player   = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local camera   = workspace.CurrentCamera

-- kill default backpack UI
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

-- ui bits
local GuiRoot   = script.Parent
local Hotbar    = GuiRoot.hotBar
local Inventory = GuiRoot.Inventory
local SlotProto = script.toolButton

-- external module (don’t rename)
local inventoryHandler = require(script.SETTINGS)

-- ========= helpers =========

-- make missing empty slots (visual only)
local function spawnEmptySlots()
	for i = 1, inventoryHandler.slotAmount do
		local slotData = inventoryHandler.OBJECTS.HotBar[i]
		if not slotData and not Hotbar:FindFirstChild(i) then
			local f = SlotProto:Clone()
			f.toolName.Text   = ""
			f.toolAmount.Text = ""
			f.toolNumber.Text = i
			f.Name = i
			f.Parent = Hotbar
		end
	end
end

-- remove empty frames (keep ones with tools)
local function cleanEmptySlots()
	for i = 1, 9 do
		local slotData = inventoryHandler.OBJECTS.HotBar[i]
		local frame    = Hotbar:FindFirstChild(i)
		if not slotData and frame then
			frame:Destroy()
			-- if something shifted, run again to catch gaps
			if Hotbar:FindFirstChild(i) then
				cleanEmptySlots()
			end
		end
	end
end

-- open/close big inventory panel
local function toggleInvUI(_, inputState)
	if inputState == Enum.UserInputState.Begin then
		Inventory.Visible = not Inventory.Visible
		local open = Inventory.Visible

		inventoryHandler:removeCurrentDescription()

		if open then
			spawnEmptySlots()
			GuiRoot.openButton.Position = UDim2.fromScale(0.5, 0.5)
			GuiRoot.openButton.info.Text = "(') close inventory"
		else
			if not inventoryHandler.SETTINGS.SHOW_EMPTY_TOOL_FRAMES_IN_HOTBAR then
				cleanEmptySlots()
			end
			GuiRoot.openButton.Position = UDim2.fromScale(0.5, 0.909)
			GuiRoot.openButton.info.Text = "(') open inventory"
		end

	-- keep this branch (even though it's basically a no-op)
	elseif not inputState then
		for i = inventoryHandler.slotAmount + 1, inventoryHandler.slotAmount do
			local slotData = inventoryHandler.OBJECTS.HotBar[i]
			local frame    = Hotbar:FindFirstChild(i)
			if slotData then
				local tool = slotData.Tool
				slotData:DisconnectAll()
				tool:SetAttribute("toolAdded", nil)
				inventoryHandler:newTool(tool)
			elseif frame then
				frame:Destroy()
			end
		end
	end
end

-- search box changed
local function handleSearch()
	inventoryHandler:searchTool()
end

-- register a tool with the module
local function registerTool(t)
	if t:IsA("Tool") then
		inventoryHandler:newTool(t)
	end
end

-- after respawn: rescan backpack + listen for new tools
local function rescanInventory(char)
	inventoryHandler.currentlyEquipped = nil
	backpack = player:WaitForChild("Backpack")

	for _, t in ipairs(backpack:GetChildren()) do
		if t:IsA("Tool") then
			registerTool(t)
		end
	end

	backpack.ChildAdded:Connect(registerTool)
	char.ChildAdded:Connect(registerTool)
end

-- adjust grid sizes when window changes; also re-sync open/close text
local function refreshHUD()
	local _ = camera.ViewportSize -- read to bind

	local size = UDim2.fromOffset(Hotbar.AbsoluteSize.Y, Hotbar.AbsoluteSize.Y)
	Inventory.Frame.Grid.CellSize = size
	Hotbar.Grid.CellSize = size

	-- sync the button label/position
	toggleInvUI()
end

-- currently equipped tool on the character
local function currentTool()
	local char = player.Character
	return char and char:FindFirstChildOfClass("Tool")
end

-- ========= init =========

-- do layout twice to settle sizes
refreshHUD(); refreshHUD()
rescanInventory(player.Character or player.CharacterAdded:Wait())

-- hooks
camera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshHUD)
player.CharacterAdded:Connect(rescanInventory)
Inventory.SearchBox:GetPropertyChangedSignal("Text"):Connect(handleSearch)

if inventoryHandler.SETTINGS.SHOW_EMPTY_TOOL_FRAMES_IN_HOTBAR then
	spawnEmptySlots()
end

if inventoryHandler.SETTINGS.INVENTORY_KEYBIND then
	CAS:BindAction("manageInventory", toggleInvUI, false, inventoryHandler.SETTINGS.INVENTORY_KEYBIND)
end

if inventoryHandler.SETTINGS.OPEN_BUTTON then
	GuiRoot.openButton.MouseButton1Down:Connect(function()
		Inventory.Visible = not Inventory.Visible
		local open = Inventory.Visible

		inventoryHandler:removeCurrentDescription()

		if open then
			spawnEmptySlots()
			GuiRoot.openButton.Position = UDim2.fromScale(0.5, 0.5)
			GuiRoot.openButton.info.Text = "(') close inventory"
		else
			if not inventoryHandler.SETTINGS.SHOW_EMPTY_TOOL_FRAMES_IN_HOTBAR then
				cleanEmptySlots()
			end
			GuiRoot.openButton.Position = UDim2.fromScale(0.5, 0.909)
			GuiRoot.openButton.info.Text = "(') open inventory"
		end
	end)
else
	GuiRoot.openButton.Visible = false
end

-- ========= scroll wheel: cycle hotbar =========
UIS.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseWheel
		and inventoryHandler.SETTINGS.SCROLL_HOTBAR_WITH_WHEEL then

		local step = input.Position.Z -- +1 or -1
		local char = player.Character
		local hum  = char and char:FindFirstChildOfClass("Humanoid")

		local equipped  = currentTool()
		local pos = inventoryHandler:getToolPosition(equipped) or 0

		-- walk forward/backward depending on wheel direction
		for i = pos + step, (step < 0) and 1 or inventoryHandler.slotAmount, step do
			local slotData = inventoryHandler.OBJECTS.HotBar[i]
			if slotData and hum then
				hum:EquipTool(slotData.Tool)
				break
			end
		end
	end
end)
