local Pathfind = {}

local PathFindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local function followPath(Human, Torso, goalPosition)
	local path = PathFindingService:CreatePath()

	local success, errorMsg = pcall(function()
		path:ComputeAsync(Torso.Position, goalPosition)
	end)
	if not success or path.Status ~= Enum.PathStatus.Success then
		warn("Path failed:", errorMsg)
		return
	end

	local waypoints = path:GetWaypoints()
	local currentWaypointIndex = 1

	local function retry()
		followPath(Human, Torso, goalPosition)
	end

	path.Blocked:Connect(function(blockedIndex)
		if blockedIndex >= currentWaypointIndex then
			warn("Path blocked! Retrying...")
			retry()
		end
	end)

	for i, waypoint in ipairs(waypoints) do
		currentWaypointIndex = i
		if waypoint.Action == Enum.PathWaypointAction.Jump then
			Human:ChangeState(Enum.HumanoidStateType.Jumping)
		end
		Human:MoveTo(waypoint.Position)
		Human.MoveToFinished:Wait()
	end
end

function Pathfind.Basic()
	function Pathfind.Complex(Rig, closestPlayer)
		local Human = Rig:WaitForChild("Humanoid")
		local Torso = Rig:FindFirstChild("UpperTorso") or Rig:WaitForChild("HumanoidRootPart")

		if not Torso then
			warn("No torso or HumanoidRootPart found!")
			return
		end

		RunService.Heartbeat:Connect(function()
			if closestPlayer and closestPlayer.Character then
				local targetTorso = closestPlayer.Character:FindFirstChild("UpperTorso")
				if not targetTorso then return end

				followPath(Human, Torso, targetTorso.Position)
			end
		end)
	end
end

function Pathfind.Complex(Rig)
	local Human = Rig:WaitForChild("Humanoid")
	local Torso = Rig:FindFirstChild("UpperTorso") or Rig:WaitForChild("HumanoidRootPart")

	if not Torso then
		warn("No torso or HumanoidRootPart found!")
		return
	end

	local function getClosestPlayer()
		local closestDistance = math.huge
		local closestPlayer = nil

		for _, player in pairs(Players:GetPlayers()) do
			local char = player.Character
			if char and char:FindFirstChild("UpperTorso") then
				local dist = (Torso.Position - char.UpperTorso.Position).Magnitude
				if dist < closestDistance then
					closestDistance = dist
					closestPlayer = player
				end
			end
		end

		return closestPlayer
	end

	RunService.Heartbeat:Connect(function()
		local closest = getClosestPlayer()
		if closest and closest.Character then
			local targetTorso = closest.Character:FindFirstChild("UpperTorso")
			if not targetTorso then return end

			followPath(Human, Torso, targetTorso.Position)
		end
	end)
end

function Pathfind.Clone(sourcePlr, Rig)
	local Human = Rig:WaitForChild("Humanoid")
	local Torso = Rig:FindFirstChild("UpperTorso") or Rig:WaitForChild("HumanoidRootPart")

	if not Torso then
		warn("No torso or HumanoidRootPart found!")
		return
	end

	local function getClosestPlayer()
		local closestDistance = math.huge
		local closestPlayer = nil

		for _, player in pairs(Players:GetPlayers()) do
			if player ~= sourcePlr then
				local char = player.Character
				if char and char:FindFirstChild("UpperTorso") then
					local dist = (Torso.Position - char.UpperTorso.Position).Magnitude
					if dist < closestDistance then
						closestDistance = dist
						closestPlayer = player
					end
				end
			end
		end

		return closestPlayer
	end

	RunService.Heartbeat:Connect(function()
		local closest = getClosestPlayer()
		if closest and closest.Character then
			local targetTorso = closest.Character:FindFirstChild("UpperTorso")
			if not targetTorso then return end

			followPath(Human, Torso, targetTorso.Position)
		end
	end)
end

function Pathfind.Object(Rig, object)
	local Human = Rig:WaitForChild("Humanoid")
	local Torso = Rig:FindFirstChild("UpperTorso") or Rig:WaitForChild("HumanoidRootPart")

	if not Torso then
		warn("No torso or HumanoidRootPart found!")
		return
	end

	RunService.Heartbeat:Connect(function()
		if object and object:IsA("BasePart") then
			followPath(Human, Torso, object.Position)
		end
	end)
end