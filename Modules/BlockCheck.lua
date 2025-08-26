local Block = {}

local StateManager = require(script.Parent.StateManager)

local BLOCK_ANGLE = 75 

local function isInFront(defenderHRP, attackerPosition, blockAngle)
	local defenderLook = defenderHRP.CFrame.LookVector
	local toAttacker = (attackerPosition - defenderHRP.Position).Unit
	local dot = defenderLook:Dot(toAttacker)
	local angle = math.deg(math.acos(dot))
	local block_angle = blockAngle or BLOCK_ANGLE

	return dot >= math.cos(math.rad(block_angle))
end


function Block.BlockCheck(attackerPosition: Vector3, defender: Model | Part, blockAngle: number?, hitPart: BasePart?)
	if defender == nil then print("defender is nil on skibidi") return end
	if not defender:IsA("Model") or not defender.Parent:IsA("Model") then return end

	local hrp = defender:FindFirstChild("HumanoidRootPart")
	if not hrp or not hrp:IsA("BasePart") then return false end

	local isBlocking = StateManager.HasState(defender, "Block")
	task.wait()
	if not isBlocking then return false end

	if isBlocking and isInFront(hrp, attackerPosition, blockAngle) then
		return true
	elseif hitPart then
		local name = hitPart.Name:lower()
		if not (name:find("arm") or name:find("shield") or name == "blockpart") then
			return false
		end
	end

	return false
end

return Block
