local Animation = {}

local cachedAnims = {}

function Animation.PlayAnimation(char, animationId)
	if not char then return end
	
	local human = char:WaitForChild("Humanoid")
	local animator = human:FindFirstChildOfClass("Animator") or human:WaitForChild("Animator")

	if not cachedAnims[animationId] then
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. tostring(animationId)
		cachedAnims[animationId] = anim
	end

	local track = animator:LoadAnimation(cachedAnims[animationId])
	track:Play()
end

function Animation.PlayAnimationThatHasAnAnimationEvent(char, animationId)
	if not char then return end
	
	local human = char:WaitForChild("Humanoid")
	if not human then return end
	
	local animator = human:FindFirstChildOfClass("Animator") or human:WaitForChild("Animator")

	if not cachedAnims[animationId] then
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. tostring(animationId)
		cachedAnims[animationId] = anim
	end

	local track = animator:LoadAnimation(cachedAnims[animationId])
	track:Play()
	return track
end

return Animation
