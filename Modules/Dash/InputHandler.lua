local ReplicatedStorage = game:GetService("ReplicatedStorage")
local uis = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local dash = require(ReplicatedStorage.Modules.CombatModules.Dash)

-- Sample animations
local animations = { 
	W = "118948577407636", 
	A = "103005903496275",
	S = "99955655386675",
	D = "94518762580530"
}

uis.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed then
		if input.KeyCode == Enum.KeyCode.Q then
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not humanoid or not hrp then return end

			local moveDir = humanoid.MoveDirection
			if moveDir.Magnitude == 0 then
				moveDir = hrp.CFrame.LookVector
			end

			local localMoveDir = hrp.CFrame:VectorToObjectSpace(moveDir)

			local dashDirection
			if math.abs(localMoveDir.Z) > math.abs(localMoveDir.X) then
				dashDirection = localMoveDir.Z < 0 and "Front" or "Back"
			else
				dashDirection = localMoveDir.X < 0 and "Left" or "Right"
			end

			dash.Dash(char, dashDirection, animations)
		end

	end
end)
