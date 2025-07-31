local TransformationModule = {}

local playerStates = {}

local function makeCharacterInvisible(character)
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") or part:IsA("Decal") then
			part.Transparency = 1
		end
	end
end

local function makeCharacterVisible(character)
	for _, part in ipairs(character:GetDescendants()) do
		if (part:IsA("BasePart") or part:IsA("Decal")) and part.Name ~= "HumanoidRootPart" then
			part.Transparency = 0
		end
	end
end

local function attachModelToCharacter(character, modelName)
	local rig = modelName
	if not rig then
		return nil, nil
	end

	local model = rig:Clone()
	model.PrimaryPart = model:FindFirstChild("HumanoidRootPart")
	if not model.PrimaryPart then
		warn("Model does not have a HumanoidRootPart.")
		return nil, nil
	end

	model:SetPrimaryPartCFrame(character.HumanoidRootPart.CFrame)
	model.Parent = character

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = character.HumanoidRootPart
	weld.Part1 = model.PrimaryPart
	weld.Parent = character.HumanoidRootPart

	return model, weld
end

local function detachModel(model, weld)
	if weld then
		weld:Destroy()
	end

	if model then
		model:Destroy()
	end
end

function TransformationModule.transformCharacter(player, modelName, speed)
	local character = player.Character
	if not character then return end

	local oldPos = character.PrimaryPart.Position
	local newPos = Vector3.new(oldPos.X, oldPos.Y + 10, oldPos.Z)
	character:SetPrimaryPartCFrame(CFrame.new(newPos))
	
	speed = speed or 16
	task.spawn(function()
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = speed
		end
	end)
	
	makeCharacterInvisible(character)

	local model, weld = attachModelToCharacter(character, modelName)
	if not model or not weld then
		makeCharacterVisible(character)
		return
	end

	playerStates[player] = {
		model = model,
		weld = weld
	}
end

function TransformationModule.revertTransformation(player, speed)
	local character = player.Character
	if not character then return end

	local state = playerStates[player]
	if not state then
		warn("Player is not transformed.")
		return
	end
	
	speed = speed or 16
	task.spawn(function()
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = speed
		end
	end)
	
	makeCharacterVisible(character)

	detachModel(state.model, state.weld)

	playerStates[player] = nil
end

return TransformationModule
