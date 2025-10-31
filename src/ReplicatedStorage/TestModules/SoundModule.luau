local SoundModule = {}

SoundModule.MAX_DISTANCE = 70
SoundModule.MIN_DISTANCE = 0

function SoundModule.shouldPlaySound(distance)
	if typeof(distance) ~= "number" then
		error("Distance must be a number!")
	end
	
	return distance >= SoundModule.MIN_DISTANCE and distance <= SoundModule.MAX_DISTANCE
end

return SoundModule
