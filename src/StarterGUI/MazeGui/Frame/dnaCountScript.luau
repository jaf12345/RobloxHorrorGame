local dnaFolder = workspace:WaitForChild("Pickups")
local frame = script.Parent
local dnaLabel = frame:WaitForChild("TextLabel")

wait(1.5)

local initialCount = #dnaFolder:GetChildren()
dnaLabel.Text = "DNA Sequences Found: 0/" .. initialCount

-- function to update the label
local function updateDNALabel()
	local remaining = #dnaFolder:GetChildren()
	local found = initialCount - remaining
	dnaLabel.Text = "DNA Sequences Found: " .. found .. "/" .. initialCount
end

-- update label whenever a DNA is removed or added
dnaFolder.ChildRemoved:Connect(updateDNALabel)
dnaFolder.ChildAdded:Connect(updateDNALabel)
