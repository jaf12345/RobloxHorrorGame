-- client gun script (non-lethal “stun shotgun” ui + firing)
-- comments are basic, like personal notes

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = Workspace.CurrentCamera
local Character = Workspace:WaitForChild(Player.Name)
local Humanoid = Character:WaitForChild("Humanoid")

local VisualizeBullet = script.Parent:WaitForChild("VisualizeBullet")
local Module = require(Tool:WaitForChild("Setting"))

-- server bits
local GunScript_Server = Tool:WaitForChild("GunScript_Server")
local ChangeAmmoAndClip = GunScript_Server:WaitForChild("ChangeAmmoAndClip")
local InflictTarget = GunScript_Server:WaitForChild("InflictTarget")
local AmmoValue = GunScript_Server:WaitForChild("Ammo")
local ClipsValue = GunScript_Server:WaitForChild("Clips")

-- ui
local GUI = script:WaitForChild("GunGUI")

-- anim refs (loaded later)
local IdleAnim
local FireAnim
local ReloadAnim
local ShotgunClipinAnim

-- dual handle
local leftGrip
local Handle2
local handleToFire = Handle

if Module.DualEnabled then
	Handle2 = Tool:WaitForChild("Handle2", 2)
	if Handle2 == nil then error("\"Dual\" setting is enabled but \"Handle2\" is missing!") end
end

-- state flags
local equipped = false
local canFire = true
local mouseDown = false
local reloading = false
local ads = false -- aim down sights

-- ammo state (mirrors server values)
local ammo = AmmoValue.Value
local clips = ClipsValue.Value
local maxClip = Module.MaxClip

-- who we already pierced this shot
local pierced = {}

-- used so the “OUT OF AMMO” text only spawns one flasher
local flashingEmpty = false

-- load animations once
if Module.IdleAnimationID ~= nil or Module.DualEnabled then
	IdleAnim = Humanoid:LoadAnimation(Tool:WaitForChild("IdleAnim"))
end
if Module.FireAnimationID ~= nil then
	FireAnim = Humanoid:LoadAnimation(Tool:WaitForChild("FireAnim"))
end
if Module.ReloadAnimationID ~= nil then
	ReloadAnim = Humanoid:LoadAnimation(Tool:WaitForChild("ReloadAnim"))
end
if Module.ShotgunClipinAnimationID ~= nil then
	ShotgunClipinAnim = Humanoid:LoadAnimation(Tool:WaitForChild("ShotgunClipinAnim"))
end

-- custom wait using Heartbeat (this file overrides global wait)
local function waitHB(t)
	if t ~= nil then
		local total = 0
		total += game:GetService("RunService").Heartbeat:Wait()
		while total < t do
			total += game:GetService("RunService").Heartbeat:Wait()
		end
	else
		game:GetService("RunService").Heartbeat:Wait()
	end
end

-- simple raycast with some ignore rules
local function raycast(startPos, dir, range, ignore)
	local hit, endPos = workspace:FindPartOnRay(Ray.new(startPos, dir * range), ignore)
	if hit then
		if (hit.Transparency > 0.75
			or hit.Name == "Handle"
			or hit.Name == "Effect"
			or hit.Name == "Bullet"
			or hit.Name == "Laser"
			or string.lower(hit.Name) == "water"
			or hit.Name == "Rail"
			or hit.Name == "Arrow"
			or (hit.Parent:FindFirstChild("Humanoid") and hit.Parent.Humanoid.Health == 0)
			or (hit.Parent:FindFirstChild("Humanoid") and pierced[hit.Parent.Humanoid])) then
			hit, endPos = raycast(endPos + (dir * 0.01), dir, range - ((startPos - endPos).magnitude), ignore)
		end
	end
	return hit, endPos
end

-- tiny camera shake
local function shakeCamera()
	if Module.CameraShakingEnabled then
		local intensity = Module.Intensity / (ads and Module.MouseSensitive or 1)
		for _ = 1, 10 do
			local camRot = Camera.CoordinateFrame - Camera.CoordinateFrame.p
			local camDist = (Camera.CoordinateFrame.p - Camera.Focus.p).magnitude
			local ncf = CFrame.new(Camera.Focus.p)
				* camRot
				* CFrame.fromEulerAnglesXYZ(
					(-intensity + (math.random() * (intensity * 2))) / 100,
					(-intensity + (math.random() * (intensity * 2))) / 100,
					0
				)
			Camera.CoordinateFrame = ncf * CFrame.new(0, 0, camDist)
			waitHB()
		end
	end
end

-- fire one “trigger pull”
local function fireOnce(shootHandle)
	local pierceCount = Module.Piercing
	pierced = {}

	if FireAnim then FireAnim:Play(nil, nil, Module.FireAnimationSpeed) end
	if not shootHandle.FireSound.Playing or not shootHandle.FireSound.Looped then
		shootHandle.FireSound:Play()
		if script.Parent:FindFirstChild("Model") and script.Parent.Model:FindFirstChild("casing") then
			script.Parent.Model.casing:FireServer()
		end
	end

	local startPos = (Humanoid.Torso.CFrame * CFrame.new(0, 1.5, 0)).p
	local spread = Module.Spread * (ads and (1 - Module.SpreadRedution) or 1)
	local dir = (CFrame.new(startPos, Mouse.Hit.p)
		* CFrame.Angles(math.rad(-spread + (math.random() * (spread * 2))),
			math.rad(-spread + (math.random() * (spread * 2))), 0)).lookVector

	while pierceCount >= 0 do
		local hit, endPos = raycast(startPos, dir, 5000, Character)

		if not Module.ExplosiveEnabled then
			if hit and hit.Parent then
				local targetHum = hit.Parent:FindFirstChild("Humanoid")
				local targetRoot = hit.Parent:FindFirstChild("HumanoidRootPart")
				if targetHum and targetHum.Health > 0 and targetRoot then
					-- server handles the stun (15s) instead of damage
					InflictTarget:FireServer(
						targetHum,
						targetRoot,
						(hit.Name == "Head" and Module.HeadshotEnabled) and (Module.BaseDamage * Module.HeadshotDamageMultiplier) or Module.BaseDamage,
						dir,
						Module.Knockback,
						Module.Lifesteal,
						Module.FlamingBullet
					)
					pierced[targetHum] = true
				else
					pierceCount = 0
				end
			end
		else
			-- explosion path (not really used for stun shotgun but kept)
			local exp = Instance.new("Explosion")
			exp.BlastRadius = Module.Radius
			exp.BlastPressure = 0
			exp.Position = endPos
			exp.Parent = Workspace.CurrentCamera
			exp.Hit:Connect(function(part)
				if part and part.Parent and part.Name == "Torso" then
					local targetHum = part.Parent:FindFirstChild("Humanoid")
					local targetTorso = part.Parent:FindFirstChild("Torso")
					if targetHum and targetHum.Health > 0 and targetTorso then
						InflictTarget:FireServer(
							targetHum,
							targetTorso,
							(part.Name == "Head" and Module.HeadshotEnabled) and (Module.BaseDamage * Module.HeadshotDamageMultiplier) or Module.BaseDamage,
							dir,
							Module.Knockback,
							Module.Lifesteal,
							Module.FlamingBullet
						)
					end
				end
			end)
			pierceCount = 0
		end

		pierceCount = hit and (pierceCount - 1) or -1

		-- local tracer viz (client)
		if script.Parent:FindFirstChild("BulletVisualizerScript") then
			script.Parent.BulletVisualizerScript.Visualize:Fire(
				nil, shootHandle,
				Module.MuzzleOffset, endPos, script.MuzzleEffect, script.HitEffect,
				Module.HitSoundIDs[math.random(1, #Module.HitSoundIDs)],
				{ Module.ExplosiveEnabled, Module.BlastRadius, Module.BlastPressure },
				{ Module.BulletSpeed, Module.BulletSize, Module.BulletColor, Module.BulletTransparency, Module.BulletMaterial, Module.FadeTime },
				false, (pierceCount == -1) and Module.VisualizerEnabled or false
			)
		end

	
-- no auto reload for this weapon
local function reload() end

-- ui update (also handles “OUT OF AMMO” flashing)
local function updateGui()
	-- hide clips panel
	if GUI and GUI.Frame and GUI.Frame:FindFirstChild("Clips") then
		GUI.Frame.Clips.Visible = false
	end

	-- ammo bar
	GUI.Frame.Ammo.Fill:TweenSizeAndPosition(
		UDim2.new(math.clamp(ammo / Module.AmmoPerClip, 0, 1), 0, 1, 0),
		UDim2.new(0, 0, 0, 0),
		Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.25, true
	)

	local ammoGroup = GUI.Frame:FindFirstChild("Ammo")
	if not ammoGroup then return end

	if ammo > 0 then
		GUI.Frame.Visible = true
		ammoGroup.Current.Visible = true
		ammoGroup.Max.Visible = true
		ammoGroup.Current.Text = tostring(ammo)
		ammoGroup.Max.Text = tostring(Module.AmmoPerClip)
		ammoGroup.Current.TextColor3 = Color3.fromRGB(255, 255, 255)
		ammoGroup.Max.TextColor3 = Color3.fromRGB(255, 255, 255)
		if ammoGroup:FindFirstChild("Frame") then ammoGroup.Frame.Visible = true end
		if ammoGroup:FindFirstChild("Reloading") then ammoGroup.Reloading.Visible = false end
		flashingEmpty = false
	else
		GUI.Frame.Visible = true
		if ammoGroup:FindFirstChild("Frame") then ammoGroup.Frame.Visible = false end
		if ammoGroup:FindFirstChild("Reloading") then ammoGroup.Reloading.Visible = false end
		for _, obj in ipairs(ammoGroup:GetChildren()) do
			if obj ~= ammoGroup.Current and (obj:IsA("TextLabel") or obj:IsA("ImageLabel") or obj:IsA("Frame")) then
				obj.Visible = false
			end
		end
		ammoGroup.Current.Visible = true
		ammoGroup.Current.Text = "OUT OF AMMO"

		if not flashingEmpty then
			flashingEmpty = true
			task.spawn(function()
				while flashingEmpty and ammo <= 0 and equipped do
					ammoGroup.Current.TextColor3 = Color3.fromRGB(255, 0, 0)
					task.wait(0.4)
					ammoGroup.Current.TextColor3 = Color3.fromRGB(120, 0, 0)
					task.wait(0.4)
				end
			end)
		end
	end

	-- compact ui corner
	GUI.Frame.Size = UDim2.new(0, 250, 0, 55)
	GUI.Frame.Position = UDim2.new(1, -260, 1, -65
