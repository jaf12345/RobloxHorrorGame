-- Shotgun Stun Gun Settings
-- 5 shots total, no reload, stun handled on server

local Module = {
	-- ===== core firing =====
	Auto = false,                 -- no full auto
	FireRate = 1,                 -- 1s between shots
	BaseDamage = 0,               -- no damage (server does stun)
	AmmoPerClip = 5,              -- only 5 shots total
	ReloadTime = 0,               -- no reload

	-- ===== spread / aim =====
	Spread = 1.25,                -- basic spread
	SniperEnabled = true,         -- hold E to zoom (client toggles FOV)
	FieldOfView = 12.5,           -- zoom FOV
	MouseSensitive = 0.05,        -- slower mouse when zoomed
	SpreadRedution = 1,           -- reduce spread while ADS (1 = full)

	-- ===== visuals / sounds =====
	MuzzleOffset = Vector3.new(0, 0.625, 1.25),
	MouseIconID = "316279304",
	HitSoundIDs = {186809061, 186809249, 186809250, 186809252},

	-- ===== animations =====
	IdleAnimationID = 94242777,
	IdleAnimationSpeed = 1,
	FireAnimationID = 94332152,
	FireAnimationSpeed = 6,
	ReloadAnimationID = nil,      -- not used
	ReloadAnimationSpeed = 1,

	-- ===== shotgun behavior =====
	ShotgunEnabled = true,
	BulletPerShot = 5,            -- 5 pellets each click
	ShotgunReload = false,        -- shell reload off
	ShotgunClipinAnimationID = nil,
	ShotgunClipinAnimationSpeed = 1,
	ShellClipinSpeed = 0.5,

	-- ===== burst/minigun/charged (off) =====
	BurstFireEnabled = false,
	BulletPerBurst = 1,
	BurstRate = 0.1,
	ChargedShotEnabled = false,
	ChargingTime = 1,
	MinigunEnabled = false,
	DelayBeforeFiring = 0,
	DelayAfterFiring = 0,

	-- ===== camera shake =====
	CameraShakingEnabled = false,
	Intensity = 0.5,

	-- ===== hit rules =====
	HeadshotEnabled = false,      -- no headshot bonus
	HeadshotDamageMultiplier = 1, -- irrelevant since damage = 0
	Knockback = 0,                -- server can still add small push if needed
	Lifesteal = 0,
	FlamingBullet = false,
	Piercing = 0,                 -- pellets don’t pierce here

	-- ===== clips (off) =====
	LimitedClipEnabled = false,
	Clips = 0,
	MaxClip = 1,

	-- ===== bullet visualizer =====
	VisualizerEnabled = true,
	BulletSpeed = 25,
	BulletSize = Vector3.new(0.25, 0.25, 100),
	BulletColor = BrickColor.new("Lime green"),
	BulletTransparency = 0.25,
	BulletMaterial = Enum.Material.Neon,
	FadeTime = 0.25,

	-- ===== explosive (off) =====
	ExplosiveEnabled = false,
	Radius = 0,

}

return Module
