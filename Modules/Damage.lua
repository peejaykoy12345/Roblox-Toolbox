local Damage = {}

local DamageDebounce = {}

function Damage.ApplyDamage(char: Model, hit: Model, damage: number)
	local isPlayer = not char:GetAttribute("BotID")
	local attackerID = isPlayer and game.Players:GetPlayerFromCharacter(char).UserId or char:GetAttribute("BotID")
	local targetID = hit:GetAttribute("BotID") or (game.Players:GetPlayerFromCharacter(hit) and game.Players:GetPlayerFromCharacter(hit).UserId)

	if not targetID then return end

	local debounceKey = attackerID.."_"..targetID  

	DamageDebounce[debounceKey] = DamageDebounce[debounceKey] or false
	if not DamageDebounce[debounceKey] then
		local humanoid = hit:FindFirstChild("Humanoid")
		if not humanoid then return end

		DamageDebounce[debounceKey] = true
		humanoid:TakeDamage(damage)

		task.delay(0.05, function()
			DamageDebounce[debounceKey] = false
		end)
	end
end

return Damage
