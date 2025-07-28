local Dash = {}

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")

function Dash.Animations(character, anims, speeds, duration)
	local humanoid = character:FindFirstChild("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp then return end

	local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:WaitForChild("Animator")

	local moveDir = humanoid.MoveDirection
	if moveDir.Magnitude == 0 then
		moveDir = hrp.CFrame.LookVector
	end

	local localMoveDir = hrp.CFrame:VectorToObjectSpace(moveDir)
	local absX, absZ = math.abs(localMoveDir.X), math.abs(localMoveDir.Z)

	local directionKey
	if absZ > absX then
		directionKey = localMoveDir.Z < 0 and "W" or "S"
	else
		directionKey = localMoveDir.X < 0 and "A" or "D"
	end

	local animId = anims[directionKey]
	if animId then
		local anim = Instance.new("Animation")
		anim.AnimationId = animId
		local track = animator:LoadAnimation(anim)
		track:Play()
	end

	local bodyVel = Instance.new("BodyVelocity")
	bodyVel.MaxForce = Vector3.new(1e5, 0, 1e5)
	bodyVel.Velocity = moveDir.Unit * (speeds[directionKey] or 20)
	bodyVel.P = 1250
	bodyVel.Parent = hrp

	task.delay(duration or 0.5, function()
		bodyVel:Destroy()
	end)
end

function Dash.NoAnimations(character, speeds, duration)
	local humanoid = character:FindFirstChild("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp then return end

	local moveDir = humanoid.MoveDirection
	if moveDir.Magnitude == 0 then
		moveDir = hrp.CFrame.LookVector
	end

	local localMoveDir = hrp.CFrame:VectorToObjectSpace(moveDir)
	local absX, absZ = math.abs(localMoveDir.X), math.abs(localMoveDir.Z)

	local directionKey
	if absZ > absX then
		directionKey = localMoveDir.Z < 0 and "W" or "S"
	else
		directionKey = localMoveDir.X < 0 and "A" or "D"
	end

	local dashSpeed = speeds and speeds[directionKey] or 20

	local bodyVel = Instance.new("BodyVelocity")
	bodyVel.MaxForce = Vector3.new(1e5, 0, 1e5)
	bodyVel.Velocity = moveDir.Unit * dashSpeed
	bodyVel.P = 1250
	bodyVel.Parent = hrp

	task.delay(duration or 0.5, function()
		bodyVel:Destroy()
	end)
end

return Dash
