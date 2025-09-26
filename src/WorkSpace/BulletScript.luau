-- server relay for bullet visualization
-- takes event from one player and rebroadcasts to everyone

local remote = script.Parent:WaitForChild("VisualizeBullet")

-- when a client fires the event
remote.OnServerEvent:Connect(function(shooter, handle, muzzleOffset, endPos, muzzleFx, hitFx, hitSound, explosive, bullet, showExplosion, showTracer)
	-- send it to all players
	for _, plr in ipairs(game.Players:GetPlayers()) do
		remote:FireClient(plr, shooter, handle, muzzleOffset, endPos, muzzleFx, hitFx, hitSound, explosive, bullet, showExplosion, showTracer)
	end
end)
