local Animation = {}
local cachedAnims = {}
local activeTracks = {} 

local function cleanupCharacter(char)
	if activeTracks[char] then
		for _, track in pairs(activeTracks[char]) do
			track:Stop()
			track:Destroy()
		end
		activeTracks[char] = nil
	end
end

game:GetService("Players").PlayerRemoving:Connect(function(player)
	if player.Character then
		cleanupCharacter(player.Character)
	end
end)



function Animation.PlayAnimation(char, animationId)
	if not char then return end

	local human = char:FindFirstChild("Humanoid")
	if not human then
		warn("Humanoid not found in character!")
		return
	end

	if not activeTracks[char] then
		activeTracks[char] = {}
		char.AncestryChanged:Connect(function(_, parent)
			if not parent then
				cleanupCharacter(char)
			end
		end)
	end

	if not cachedAnims[animationId] then
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. tostring(animationId)
		cachedAnims[animationId] = anim
	end

	local animator = human:FindFirstChildOfClass("Animator") or human:WaitForChild("Animator")

	local track = animator:LoadAnimation(cachedAnims[animationId])
	table.insert(activeTracks[char], track)

	track.Stopped:Connect(function()
		for i, t in ipairs(activeTracks[char]) do
			if t == track then
				table.remove(activeTracks[char], i)
				track:Destroy()
				break
			end
		end
	end)

	track:Play()
	return track
end

function Animation.PlayAnimationThatHasAnAnimationEvent(char, animationId)
	return Animation.PlayAnimation(char, animationId)
end

function Animation.CreateAnimation(char, animationId)
	return Animation.PlayAnimation(char, animationId)
end

function Animation.PlayAndHoldAnimation(char, animationId)
	if not char then return end
	local human = char:FindFirstChild("Humanoid")
	if not human then
		warn("Humanoid not found in character!")
		return
	end

	if not activeTracks[char] then
		activeTracks[char] = {}
		char.AncestryChanged:Connect(function(_, parent)
			if not parent then
				cleanupCharacter(char)
			end
		end)
	end

	if not cachedAnims[animationId] then
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. tostring(animationId)
		cachedAnims[animationId] = anim
	end

	local animator = human:FindFirstChildOfClass("Animator") or human:WaitForChild("Animator")
	local track = animator:LoadAnimation(cachedAnims[animationId])
	table.insert(activeTracks[char], track)

	local manualStop = false
	local conn
	
	local originalSpeed = track.Speed 
	conn = track.Stopped:Connect(function()
		conn:Disconnect()
		conn = nil

		if not manualStop then
			track.TimePosition = track.Length - 0.01
			track:AdjustSpeed(0)
		end
	end)

	track:Play()
	return track, function()
		manualStop = true

		if conn then
			conn:Disconnect()
			conn = nil
		end
		
		track:AdjustSpeed(originalSpeed)

		if activeTracks[char] then
			for i, t in ipairs(activeTracks[char]) do
				if t == track then
					table.remove(activeTracks[char], i)
					break
				end
			end
		end
		track:Stop()
		track:Destroy()
	end
end




function Animation.StopAndCleanup(char, track)
	if not char or not track then return end

	if activeTracks[char] then
		for i, t in ipairs(activeTracks[char]) do
			if t == track then
				table.remove(activeTracks[char], i)
				break
			end
		end
	end

	track:Stop()
	track:Destroy()
end

function Animation.StopAllAnimations(char)
	if char and activeTracks[char] then
		cleanupCharacter(char)
	end
end

return Animation
