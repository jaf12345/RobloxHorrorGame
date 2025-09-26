-- bullet visualizer (client)
-- does muzzle fx, impact fx+sound, optional boom, and a tracer

local bindEvent   = script:WaitForChild("Visualize")                  -- BindableEvent
local remoteEvent = script.Parent:WaitForChild("VisualizeBullet")     -- RemoteEvent

-- services / refs
local cam   = workspace.CurrentCamera
local run   = game:GetService("RunService")
local debris= game:GetService("Debris")
local plr   = game.Players.LocalPlayer

-- forward declare helpers so the top handler can call them
local doMuzzle, doHit, doExplosion, doTracer

-- ===== one shared handler (hooked right away) =====
local function onVisualize(shooter, handle, offset, endPos, muzzleFx, hitFx, soundId, explosive, bulletData, showBoom, showTracer)
	-- skip our own bullets, and bad handles
	if shooter == plr or not handle then return end

	-- 1) puff at gun
	local muzzlePos = doMuzzle(handle, offset, muzzleFx)

	-- 2) dust + sound at target
	doHit(endPos, hitFx, soundId)

	-- 3) optional explosion (visual only)
	if explosive[1] and showBoom then
		doExplosion(endPos, explosive[2])
	end

	-- 4) tracer line if enabled
	if showTracer then
		doTracer(muzzlePos, endPos, bulletData)
	end
end

-- hook both events up top so layout looks different
bindEvent.Event:Connect(onVisualize)
remoteEvent.OnClientEvent:Connect(onVisualize)

-- ===== helpers below =====

-- tiny invisible part for fx
local function tiny(anchor)
	local p = Instance.new("Part")
	p.Size = Vector3.new(0.01, 0.01, 0.01)
	p.Anchored = anchor
	p.CanCollide = false
	p.Transparency = 1
	p.TopSurface = Enum.SurfaceType.SmoothNoOutlines
	p.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
	p.Parent = cam
	return p
end

-- show muzzle particles at the gun muzzle
doMuzzle = function(handle, offset, fx)
	local pos = (handle.CFrame * CFrame.new(offset.X, offset.Y, offset.Z)).p

	local part = tiny(false)
	local weld = Instance.new("Weld")
	weld.Part0 = handle
	weld.Part1 = part
	weld.C0 = CFrame.new(offset.X, offset.Y, offset.Z)
	weld.Parent = part

	part.Position = pos
	local clone = fx:Clone()
	clone.Parent = part
	task.spawn(function() clone:Emit(5) end)

	debris:AddItem(part, 10)
	return pos
end

-- show hit particles + play hit sound
doHit = function(pos, fx, soundId)
	local part = tiny(true)
	part.Position = pos

	local clone = fx:Clone()
	clone.Parent = part

	local snd = Instance.new("Sound")
	snd.SoundId = "rbxassetid://" .. soundId
	snd.Volume = 1
	snd.Parent = part

	task.spawn(function()
		clone:Emit(2)
		snd:Play()
	end)

	debris:AddItem(part, 10)
end

-- fake explosion (no damage/pressure)
doExplosion = function(pos, radius)
	local e = Instance.new("Explosion")
	e.Position = pos
	e.BlastRadius = radius
	e.BlastPressure = 0
	e.Parent = cam
end

-- draw the tracer brick
-- bulletData = {stepOrInf, sizeVec3, brickColor, transparency, material, fadeTime}
doTracer = function(startPos, endPos, bulletData)
	local stepOrInf, sizeVec, color, trans, mat, fade = unpack(bulletData)

	local tracer = Instance.new("Part")
	tracer.Name = "Bullet"
	tracer.Size = Vecto
