local Stun = {}
local stunStates = {}

function Stun.StopStun(humanoid)
	local char = humanoid.Parent
	if not char or not stunStates[char] then return end

	humanoid.WalkSpeed = stunStates[char].originalSpeed or 16
	stunStates[char] = nil
end

function Stun.StunWithoutAnimation(char: Model, speed: number, time: number, priority: number)
	if not char then return end
	local humanoid = char:FindFirstChild("Humanoid")
	if not humanoid then return end

	priority = priority or 0
	local currentStun = stunStates[char]

	if currentStun and currentStun.priority >= priority then
		return
	end

	if not currentStun then
		stunStates[char] = {
			priority = priority,
			originalSpeed = humanoid.WalkSpeed
		}
	else
		stunStates[char].priority = priority
	end

	humanoid.WalkSpeed = speed

	task.delay(time, function()
		if stunStates[char] and stunStates[char].priority == priority then
			Stun.StopStun(humanoid)
		end
	end)
end

function Stun.StunWithAnimation(char: Model, speed: number, track , priority: number)
	if not char then return end
	local humanoid = char:FindFirstChild("Humanoid")
	if not humanoid then return end

	priority = priority or 0
	local currentStun = stunStates[char]

	if currentStun and currentStun.priority >= priority then
		return
	end

	if not currentStun then
		stunStates[char] = {
			priority = priority,
			originalSpeed = humanoid.WalkSpeed
		}
	else
		stunStates[char].priority = priority
	end

	humanoid.WalkSpeed = speed

	track.Stopped:Once(function()
		if stunStates[char] and stunStates[char].priority == priority then
			Stun.StopStun(humanoid)
		end
	end)
end

return Stun