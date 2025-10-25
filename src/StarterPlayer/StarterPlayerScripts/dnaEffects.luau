local RunService = game:GetService("RunService")
local ROTATE_SPEED = 90

local function startRotator(model)
	-- try to wait for PrimaryPart
	if not model.PrimaryPart then
		model:GetPropertyChangedSignal("PrimaryPart"):Wait()
	end

	local primary = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not primary then
		print("could not find a part in the model")
		return
	end

	local conn
	conn = RunService.RenderStepped:Connect(function(dt)
		if not model.Parent then
			conn:Disconnect()
			return
		end
		primary.CFrame = primary.CFrame * CFrame.Angles(0, math.rad(ROTATE_SPEED * dt), 0)
	end)
end


-- handle DNA that already exists in Pickups
local pickups = workspace:WaitForChild("Pickups")
for _, child in ipairs(pickups:GetChildren()) do
	if child.Name == "DNA" then
		startRotator(child)
	end
end

-- handle new DNA added to Pickups later
pickups.ChildAdded:Connect(function(child)
	if child.Name == "DNA" then
		startRotator(child)
	end
end)
