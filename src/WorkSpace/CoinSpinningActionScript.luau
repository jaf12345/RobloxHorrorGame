-- Rotates the part slowly on the X-axis forever
local part = script.Parent

while true do
	task.wait() -- small pause to keep it smooth
	part.CFrame *= CFrame.fromEulerAnglesXYZ(0.1, 0, 0)
end
