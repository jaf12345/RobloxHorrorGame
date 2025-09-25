--// SERVICES
local StarterGui = game:GetService("StarterGui")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

--// REFERENCES
local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local camera = workspace.CurrentCamera

-- Disable the default Roblox hotbar UI
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

local CustomInventoryGUI = script.Parent
local hotBar = CustomInventoryGUI.hotBar
local Inventory = CustomInventoryGUI.Inventory
local toolButton = script.toolButton

-- External settings/logic module (do not rename)
local inventoryHandler = require(script.SETTINGS)

-- UI HELPERS

-- Create empty hotbar slot frames up to slotAmount (only if missing)
local function renderEmptySlots()
	for slotIdx = 1, inventoryHandler.slotAmount do
		local slotObj = inventoryHandler.OBJECTS.HotBar[slotIdx]
		if not slotObj and not hotBar:FindFirstChild(slotIdx) and slotIdx <= inventoryHandler.slotAmount then
			local slotFrame = toolButton:Clone()
			slotFrame.toolName.Text = ""
			slotFrame.toolAmount.Text = ""
			slotFrame.toolNumber.Text = slotIdx
			slotFrame.Name = slotIdx
			slotFrame.Parent = hotBar
		end
	end
end

-- Remove hotbar slot frames that no longer have tools
local function pruneEmptySlots()
	for slotIdx = 1, 9 do
		local slotObj = inventoryHandler.OBJECTS.HotBar[slotIdx]
		local slotFrame = hotBar:FindFirstChild(slotIdx)
		if not slotObj and slotFrame then
			slotFrame:Destroy()
			-- If anything shifted, re-run to catch cascading gaps
			if hotBar:FindFirstChild(slotIdx) then
				pruneEmptySlots()
			end
		end
	end
end

-- Toggle inventory visibility and update helper UI bits
local function toggleInventory(_, inputState)
	if inputState == Enum.UserInputState.Begin then
		Inventory.Visible = not Inventory.Visible
		local isOpen = Inventory.Visible

		inventoryHandler:removeCurrentDescription()

		if isOpen then
			renderEmptySlots()
			CustomInventoryGUI.openButton.Position = UDim2.fromScale(0.5, 0.5)
			CustomInventoryGUI.openButton.info.Text = "(') close inventory"
		else
			if not inventoryHandler.SETTINGS.SHOW_EMPTY_TOOL_FRAMES_IN_HOTBAR then
				pruneEmptySlots()
			end
			CustomInventoryGUI.openButton.Position = UDim2.fromScale(0.5, 0.909)
			CustomInventoryGUI.openButton.info.Text = "(') open inventory"
		end

	-- This branch mirrors your original logic (kept intact, though it’s effectively a no-op)
	elseif not inputState then
		for slotIdx = inventoryHandler.slotAmount + 1, inventoryHandler.slotAmount do
			local slotObj = inventoryHandler.OBJECTS.HotBar[slotIdx]
			local slotFrame = hotBar:FindFirstChild(slotIdx)
			if slotObj then
				local tool = slotObj.Tool
				slotObj:DisconnectAll()
				tool:SetAttribute("toolAdded", nil)
				inventoryHandler:newTool(tool)
			elseif slotFrame then
				slotFrame:Destroy()
			end
		end
	end
end

-- Live-search callback for the inventory search box
local function onSearchChanged()
	inventoryHandler:searchTool()
end

-- Wrapper to register a new Tool with the handler
local function addTool(tool)
	if tool:IsA("Tool") then
		inventoryHandler:newTool(tool)
	end
end

-- Re-scan the character/backpack and hook listeners after respawn
local function rebuildInventoryCache(character)
	inventoryHandler.currentlyEquipped = nil
	backpack = player:WaitForChild("Backpack")

	for _, tool in pairs(backpack:GetChildren()) do
		if tool:IsA("Tool") then
			addTool(tool)
		end
	end

	backpack.ChildAdded:Connect(addTool)
	character.ChildAdded:Connect(addTool)
end

-- Update grid cell sizes based on viewport; also ensures UI state is consistent
local function updateHudLayout()
	-- We don't need the actual size value here, but reading the property
	-- ensures this runs on viewport changes.
	local _ = camera.ViewportSize

	local slotSize = UDim2.fromOffset(hotBar.AbsoluteSize.Y, hotBar.AbsoluteSize.Y)
	Inventory.Frame.Grid.CellSize = slotSize
	hotBar.Grid.CellSize = slotSize

	-- Keep UI hints in sync (uses same logic as toggling without input)
	toggleInventory()
end


-- INITIALIZE + CONNECTIONS

updateHudLayout(); updateHudLayout()
rebuildInventoryCache(player.Character or player.CharacterAdded:Wait())

camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateHudLayout)
player.CharacterAdded:Connect(rebuildInventoryCache)
Inventory.SearchBox:GetPropertyChangedSignal("Text"):Connect(onSearchChanged)

if inventoryHandler.SETTINGS.SHOW_EMPTY_TOOL_FRAMES_IN_HOTBAR then
	renderEmptySlots()
end

if inventoryHandler.SETTINGS.INVENTORY_KEYBIND then
	ContextActionService:BindAction("manageInventory", toggleInventory, false, inventoryHandler.SETTINGS.INVENTORY_KEYBIND)
end

if inventoryHandler.SETTINGS.OPEN_BUTTON then
	CustomInventoryGUI.openButton.MouseButton1Down:Connect(function()
		Inventory.Visible = not Inventory.Visible
		local isOpen = Inventory.Visible

		inventoryHandler:removeCurrentDescription()

		if isOpen then
			renderEmptySlots()
			CustomInventoryGUI.openButton.Position = UDim2.fromScale(0.5, 0.5)
			CustomInventoryGUI.openButton.info.Text = "(') close inventory"
		else
			if not inventoryHandler.SETTINGS.SHOW_EMPTY_TOOL_FRAMES_IN_HOTBAR then
				pruneEmptySlots()
			end
			CustomInventoryGUI.openButton.Position = UDim2.fromScale(0.5, 0.909)
			CustomInventoryGUI.openButton.info.Text = "(') open inventory"
		end
	end)
else
	CustomInventoryGUI.openButton.Visible = false
end

-- INPUT: SCROLL TO CYCLE HOTBAR TOOLS

-- Helper to get currently equipped tool (character-safe)
local function getEquippedTool()
	local character = player.Character
	return character and character:FindFirstChildOfClass("Tool")
end

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseWheel and inventoryHandler.SETTINGS.SCROLL_HOTBAR_WITH_WHEEL then
		local scrollDir = input.Position.Z -- positive or negative step
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		local equipped = getEquippedTool()
		local currentPos = inventoryHandler:getToolPosition(equipped) or 0

		-- Walk forward or backward across slots based on scroll direction
		for slotIdx = currentPos + scrollDir, (scrollDir < 0) and 1 or inventoryHandler.slotAmount, scrollDir do
			local slotObj = inventoryHandler.OBJECTS.HotBar[slotIdx]
			if slotObj and humanoid then
				humanoid:EquipTool(slotObj.Tool)
				break
			end
		end
	end
end)
