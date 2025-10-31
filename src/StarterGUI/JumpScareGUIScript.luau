local player = game.Players.LocalPlayer
local jumpscareGUI = player:WaitForChild("PlayerGui"):WaitForChild("JumpScareGUI") 
local lable = jumpscareGUI:WaitForChild('JumpScareLable')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local jumpScareEvent = ReplicatedStorage:WaitForChild('JumpScareEvent')

print("LocalScript running for:", game.Players.LocalPlayer.Name)

--trigged event from the server

jumpScareEvent.OnClientEvent:Connect(function()
	print('Jumpscare triggerd on client event') --debug statement 
	
	lable.Visible = true
	
	--simple fade out effect 
	for i = 0, 1, 0.5 do
		lable.BackgroundTransparency = i
		lable.TextTransparency = i
		task.wait(0.05)
	end
	
	lable.Visible = false
end)
