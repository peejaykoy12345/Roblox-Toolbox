local Punch = {}
local players = game:GetService("Players")
local Hitbox = require(script.Parent["Magnitude Hitbox"])
local Block = require(script.Parent.Block)
local animationPlayer = require(script.Parent.Parent.Miscellaneous.Animation)
local Knockback = require(script.Parent.Knockback)
local Damage = require(script.Parent.Damage)
local Stun = require(script.Parent.Stun)
local damageDebounce = {}

function Punch.Punch(character, isPlayer, velocity)
	if not character then return end
	
	local hrp = character:WaitForChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not hrp or not humanoid then return end
	
	local playerUserId
	local botID = not isPlayer and humanoid.Parent:GetAttribute("BotID") or nil 

	if isPlayer then
		local player = players:GetPlayerFromCharacter(character)
		playerUserId = player.UserId
		damageDebounce[playerUserId] = damageDebounce[playerUserId] or false
	elseif botID then
		damageDebounce[botID] = damageDebounce[botID] or false
	else
		return
	end

	local hit = Hitbox.Complex(hrp, 7)
	if not hit or not hit:IsA("Model") then return end

	local targetHumanoid = hit:FindFirstChildWhichIsA("Humanoid")
	if not targetHumanoid then return end

	local blocked = Block.BlockCheck(hrp.Position, hit)
	if not blocked  then
		Damage.ApplyDamageFromMagnitudeHitbox(character, hit, 10, true)
	end
end

function Punch.Complex(char, animations, punchCount, punchLimit, velocity, isPlayer)
	if punchCount < punchLimit then
		local track = animationPlayer.PlayAnimationThatHasAnAnimationEvent(char, animations["Punch" .. punchCount])
		task.spawn(function()
			Stun.StunWithAnimation(char, 6, track)
		end)	
		track:GetMarkerReachedSignal("Punch"):Connect(function()
			Punch.Punch(char, isPlayer, velocity)
		end)
		return punchCount + 1
	elseif punchCount >= punchLimit then
		local track = animationPlayer.PlayAnimationThatHasAnAnimationEvent(char, animations["Punch" .. punchCount])
		task.spawn(function()
			Stun.StunWithAnimation(char, 6, track)
		end)	
		track:GetMarkerReachedSignal("Punch"):Connect(function()
			Punch.Punch(char, isPlayer, velocity)
		end)
		punchCount = 1
		return punchCount 
	end	
end

return Punch
