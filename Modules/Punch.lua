local Punch = {}
local Hitbox = require(script.Parent["Magnitude Hitbox"])
local Block = require(script.Parent.Block)
local damageDebounce = {}

function Punch.Punch(player)
	damageDebounce[player.UserId] = false
	local char = player.Character
	if not char then return end

	local hrp = char:WaitForChild("HumanoidRootPart")
	local hit = Hitbox.Complex(hrp, 7)
	if not hit or not hit:IsA("Model") then return end

	local humanoid = hit:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then return end

	local blocked = Block.BlockCheck(hrp.Position, hit)
	if not blocked and not damageDebounce[player.UserId] then
		damageDebounce[player.UserId] = true
		humanoid:TakeDamage(10)
		task.delay(0.1, function()
			damageDebounce[player.UserId] = false
		end)
	end
end


return Punch
