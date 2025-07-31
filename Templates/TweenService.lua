local function tween(part)
	local TweenService = game:GetService("TweenService")

	-- Tween information
	local tweenInfo = TweenInfo.new(
		5, -- Duration (seconds)
		Enum.EasingStyle.Linear, -- Easing style
		Enum.EasingDirection.In, -- Easing direction
		0, -- Repeat count (0 means don't repeat)
		false, -- Does it reverse?
		0 -- Delay time
	)
	
	local tweenGoal = {
		Position = Vector3.new(0, 10, 0)
	}

	-- Create the tween
	local tween = TweenService:Create(
		part, -- Object to tween
		tweenInfo, -- Tween info
		tweenGoal -- Properties to change (moves part up 10 studs)
	)
	
	return tween
end