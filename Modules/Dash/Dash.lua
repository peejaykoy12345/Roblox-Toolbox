local Dash = {}

function Dash.Dash(char: Model, direction: string, animations)
	local hrp: Part = char:WaitForChild("HumanoidRootPart")
	local hum: Humanoid = char:WaitForChild("Humanoid")
	if not hrp or not hum then return end
	local AnimationPlayer = require(script.Parent.Parent.Miscellaneous.Animation)
	local dashDuration = 0.35
	local rate = 0.01

	local bv = Instance.new("BodyVelocity", char)
	bv.MaxForce = Vector3.new(100000, 0, 100000)
	bv.Parent = hrp

	local dashStrength = 100

	local minimumDashStrength = dashStrength * 0.15

	local amountOfIterations = dashDuration / rate

	local removalOfStrengthPerIteration = dashStrength / amountOfIterations

	for i = 0, dashDuration, rate do

		if direction == "Front" then

			bv.Velocity = hrp.CFrame.LookVector * dashStrength
			AnimationPlayer.PlayAnimation(char, animations.W)

		elseif direction == "Back" then

			bv.Velocity = (hrp.CFrame.LookVector * -1) * dashStrength
			AnimationPlayer.PlayAnimation(char, animations.S)
			
		elseif direction == "Right" then

			bv.Velocity = hrp.CFrame.RightVector * dashStrength
			AnimationPlayer.PlayAnimation(char, animations.D)

		elseif direction == "Left" then

			bv.Velocity = (hrp.CFrame.RightVector * -1) * dashStrength
			AnimationPlayer.PlayAnimation(char, animations.A)
			
		end

		if dashStrength > minimumDashStrength then

			dashStrength -= removalOfStrengthPerIteration	
			--
			if dashStrength < minimumDashStrength then

				dashStrength = minimumDashStrength

			end

		end

		task.wait(rate)

	end

	bv:Destroy()
end

return Dash
