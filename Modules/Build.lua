local Build = {}
local GRID_SIZE = 4
local ROTATION_ANGLE = math.rad(90) 

local rotationStates = {}

local function SnapToGrid(position: Vector3, Y: number): Vector3
	local function snap(val, isY)
		if isY then
			return math.round(val / Y + 0.5) * Y
		else
			return math.floor(val / GRID_SIZE + 0.5) * GRID_SIZE
		end
	end
	return Vector3.new(snap(position.X, false), snap(position.Y, true), snap(position.Z, false))
end

function Build.Place(Block: BasePart | Model, CFrame: CFrame)
	local clone = Block:Clone()
	if clone:IsA("Model") and clone.PrimaryPart then
		clone:PivotTo(CFrame)
	else
		clone.CFrame = CFrame
	end
	clone.Parent = workspace.Blocks
end

function Build.CreatePreview(Block: BasePart | Model): BasePart | Model
	local ghost
	if Block:IsA("Model") then
		ghost = Block:Clone()
		for _, part in pairs(ghost:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = true
				part.CanCollide = false
				part.Transparency = 0.2
				part.Material = Enum.Material.ForceField
			end
		end
		ghost.PrimaryPart = ghost:FindFirstChild("PrimaryPart")
	else
		ghost = Block:Clone()
		ghost.Anchored = true
		ghost.CanCollide = false
		ghost.Transparency = 0.2
		ghost.Material = Enum.Material.ForceField
	end

	ghost.Name = "PreviewBlock"
	ghost.Parent = workspace.Preview
	rotationStates[ghost] = 0 

	return ghost
end

function Build.UpdatePreview(ghostBlock: BasePart | Model)
	if not ghostBlock or not ghostBlock.Parent then return end

	local player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local mouse = player:GetMouse()

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {character, ghostBlock}

	local ray = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, rayParams)
	if ray then
		local hitPos = ray.Position
		local currentRotation = rotationStates[ghostBlock] or 0

		if ghostBlock:IsA("Model") and ghostBlock.PrimaryPart then
			local size = ghostBlock:GetExtentsSize()
			local snapped = SnapToGrid(hitPos, size.Y)
			ghostBlock:PivotTo(CFrame.new(snapped) * CFrame.Angles(0, currentRotation, 0))
		else
			local snapped = SnapToGrid(hitPos, ghostBlock.Size.Y)
			ghostBlock.CFrame = CFrame.new(snapped) * CFrame.Angles(0, currentRotation, 0)
		end
	end
end

function Build.Rotate(Block: BasePart | Model)
	if not Block or not Block.Parent then return end

	rotationStates[Block] = (rotationStates[Block] or 0) + ROTATION_ANGLE
end

function Build.CleanUp(ghostBlock: BasePart | Model)
	if ghostBlock and ghostBlock.Destroy then
		rotationStates[ghostBlock] = nil -- Clean up rotation state
		ghostBlock:Destroy()
	end
end

return Build
