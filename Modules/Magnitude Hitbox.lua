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
	local targets = {}
	for _, obj in pairs(workspace:GetChildren()) do
		if obj:IsA("Model") and obj ~= hrp.Parent then
			local humanoid = obj:FindFirstChildWhichIsA("Humanoid")
			local root = obj:FindFirstChild("HumanoidRootPart")
			if humanoid and root then
				if Hitbox.Basic(hrp, obj, range) then
					if obj ~= nil then
						table.insert(targets, obj)
					end
				end
			end
		end
	end
	return targets
end

function Hitbox.AOE(hrp: BasePart, range: number)
	local targets = {}
	for _, model in pairs (workspace:GetChildren()) do
		if model:IsA("Model") and model ~= hrp.Parent then
			local root = model:FindFirstChild("HumanoidRootPart")
			local humanoid = model:FindFirstChild("Humanoid")
			if root and humanoid and humanoid.Health > 0 then
				local distance = (root.Position - hrp.Position).Magnitude
				if distance <= range then
					table.insert(targets, model)
				end
			end
		end
	end
	return targets
end

return Hitbox
