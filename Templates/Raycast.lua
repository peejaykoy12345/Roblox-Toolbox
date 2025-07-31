local function raycast(char, distance)
	local hrp = char:WaitForChild("HumanoidRootPart")
	if not hrp then return end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {char}

	local startPos = hrp.Position
	local direction = Vector3.new(0, distance, 0) 

	local raycastResult = workspace:Raycast(startPos, direction, raycastParams)
	return raycastResult
end