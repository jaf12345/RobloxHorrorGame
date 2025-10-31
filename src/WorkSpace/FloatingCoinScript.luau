-- Simple floating animation loop
while true do
	wait(0.1)
	
	-- Save the original position before movement starts
	local startPos = script.Parent.Position
	
	-- Move the object gently upward
	for up = 1, 5 do
		wait(0.1)
		script.Parent.Position = script.Parent.Position + Vector3.new(0, up / 40, 0)
	end
	
	-- Smooth out the top part of the motion
	for smoothUp = 4, 1, -1 do
		wait(0.1)
		script.Parent.Position = script.Parent.Position + Vector3.new(0, smoothUp / 40, 0)
	end
	
	-- Move the object downward
	for down = 1, 5 do
		wait(0.1)
		script.Parent.Position = script.Parent.Position + Vector3.new(0, -down / 40, 0)
	end
	
	-- Smooth out the bottom part of the motion
	for smoothDown = 4, 1, -1 do
		wait(0.1)
		script.Parent.Position = script.Parent.Position + Vector3.new(0, -smoothDown / 40, 0)
	end
	
	-- Return to the original position to reset the loop
	script.Parent.Position = startPos
end
