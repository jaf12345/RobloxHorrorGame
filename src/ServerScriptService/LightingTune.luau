-- only creates haze effect when game is running
local LightingService = game:GetService("Lighting") -- retrieves lighting service

local function makeHazeEffect()
	-- creates a new atmosphere effect to tune the lighting effects to suit the game
	local atmostphereSetting = Instance.new("Atmosphere")
	atmostphereSetting.Parent = LightingService
	atmostphereSetting.Density = 0.8
	atmostphereSetting.Color = Color3.new(0, 0, 0)
	atmostphereSetting.Decay = Color3.new(106, 112, 125)
	atmostphereSetting.Haze = 10
	
	-- creates a new sky effect to tune the lighting effects to suit the game
	local skySetting = Instance.new("Sky")
	skySetting.Parent = LightingService
	skySetting.SunAngularSize = 0
end

makeHazeEffect()
