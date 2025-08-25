local module = {}

local function SetCharacterVisibility(char: Model, visible: boolean)
	local transperancy = if visible then 0 else 1
	
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.Transparency = transperancy
		end
		if part.Name == "face" then
			part.Transparency = transperancy
		end
	end
end

local function RemoveTransformModel(char: Model)
	local transformed_model = char:FindFirstChild("TransformModel")
	if not transformed_model then return end

	transformed_model:Destroy()
end

local function SetScaleValue(hum: Humanoid, scale_value: number)
	hum.BodyHeightScale.Value = scale_value
	hum.BodyWidthScale.Value = scale_value
	hum.BodyDepthScale.Value = scale_value
	hum.HeadScale.Value = scale_value
	
	hum.WalkSpeed = 50
end

function module.Transform(plr: Player, model_template: Model, scale_value: number, tp_pos: Vector3?)
	local char = plr.Character
	local hum = char:FindFirstChildWhichIsA("Humanoid")
	
	scale_value = scale_value or 1
	
	RemoveTransformModel(char)
	
	SetScaleValue(hum, scale_value)
	
	local model = model_template:Clone()
	
	SetCharacterVisibility(char, false)
	
	model.Parent = char
	model.Name = "TransformModel"
	model:PivotTo(char:GetPivot())
	local weld = Instance.new("Weld", model)
	weld.Part0 = char.HumanoidRootPart
	weld.Part1 = model.HumanoidRootPart
	
	if not tp_pos then return end
	
	task.delay(0.1, function()
		char:PivotTo(CFrame.new(tp_pos))
	end)
end

function module.Untransform(plr: Player)
	local char = plr.Character
	local hum = char:FindFirstChildWhichIsA("Humanoid")

	SetScaleValue(hum, 1)
	
	RemoveTransformModel(char)
	SetCharacterVisibility(char, true)
end

return module
