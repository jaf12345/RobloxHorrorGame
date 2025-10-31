local GlitchEffect = {}

-- create a new glitch effect controller
function GlitchEffect.create(effectTable, image)
	local self = {
		glitchCooldown = false,
		effectTable = effectTable,
		image = image,
	}

	function self:trigger()
		-- ignore if on cooldown
		if self.glitchCooldown then return false end
		self.glitchCooldown = true

		-- pick a random image
		local chosenImage = self.effectTable[math.random(1, #self.effectTable)]
		self.image.Image = chosenImage.Image
		self.image.ImageTransparency = math.random(90, 95) / 100

		-- flicker effect
		task.spawn(function()
			for _ = 1, 5 do
				self.image.ImageTransparency = math.random(90, 95) / 100
				task.wait(0.05)
			end
			self.image.ImageTransparency = 1
		end)

		-- reset cooldown
		task.delay(0.3, function()
			self.glitchCooldown = false
		end)

		return true
	end

	return self
end
return GlitchEffect