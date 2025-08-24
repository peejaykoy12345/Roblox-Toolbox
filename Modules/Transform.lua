local module = {}
local CollectionService = game:GetService("CollectionService")

function module.Transform(plr: Player, model_template: Model)
	local char = plr.Character
	local hum = char:FindFirstChildWhichIsA("Humanoid")
	
	hum.BodyHeightScale.Value = 5
	hum.BodyWidthScale.Value = 5
	hum.BodyDepthScale.Value = 5
	hum.HeadScale.Value = 5
	
	local model = model_template:Clone()
	
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.Transparency = 1
			part.CanCollide = false
		end
		if part.Name == "face" then
			part.Transparency = 1
		end
	end
	model.Parent = char
	model:AddTag("Model")
	model:PivotTo(char:GetPivot())
	local weld = Instance.new("Weld", model)
	weld.Part0 = model.HumanoidRootPart
	weld.Part1 = char.HumanoidRootPart
end

function module.Untransform(plr: Player)
	local char = plr.Character
	local hum = char:FindFirstChildWhichIsA("Humanoid")

	hum.BodyHeightScale.Value = 1
	hum.BodyWidthScale.Value = 1
	hum.BodyDepthScale.Value = 1
	hum.HeadScale.Value = 1
	
	for _, part in pairs(char:GetDescendants()) do
		if CollectionService:HasTag(part, "Model") then
			part:Destroy()
			continue
		end
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.Transparency = 0
			part.CanCollide = false
		end
		if part.Name == "face" then
			part.Transparency = 0
		end
	end
end

return module
