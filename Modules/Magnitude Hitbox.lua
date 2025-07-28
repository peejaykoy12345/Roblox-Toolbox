local Hitbox = {}

function Hitbox.Basic(hrp: BasePart, target: Model, range: number)
	local targetRoot = target:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return false end

	local directionToTarget = (targetRoot.Position - hrp.Position).Unit
	local lookDirection = hrp.CFrame.LookVector
	local distance = (targetRoot.Position - hrp.Position).Magnitude
	local dot = lookDirection:Dot(directionToTarget)

	return distance <= range and dot > 0.5
end

function Hitbox.Complex(hrp: BasePart, range: number)
	for _, obj in pairs(workspace:GetChildren()) do
		if obj:IsA("Model") and obj ~= hrp.Parent then
			local humanoid = obj:FindFirstChildWhichIsA("Humanoid")
			local root = obj:FindFirstChild("HumanoidRootPart")
			if humanoid and root then
				if Hitbox.Basic(hrp, obj, range) then
					if obj ~= nil then
						return obj
					else
						return
					end
				end
			end
		end
	end
end

return Hitbox
