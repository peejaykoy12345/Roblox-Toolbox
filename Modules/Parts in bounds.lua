local PartsInBounds = {}
local Workspace = game:GetService("Workspace")
local PlayerService = game:GetService("Players")
local Stun = require(script.Parent.Stun)
local Damage = require(script.Parent.Damage)
local Knockback = require(script.Parent.Knockback)

function PartsInBounds.GetPlayersInBox(centerCFrame: CFrame, size: Vector3)
	local foundPlayers = {}
	local parts = Workspace:GetPartBoundsInBox(centerCFrame, size)

	for _, part in ipairs(parts) do
		local model = part:FindFirstAncestorOfClass("Model")
		if model and model:FindFirstChild("Humanoid") then
			local player = PlayerService:GetPlayerFromCharacter(model)
			if player then
				foundPlayers[player] = true
			end
		end
	end

	local players = {}
	for plr in pairs(foundPlayers) do
		table.insert(players, plr)
	end

	return players
end

function PartsInBounds.GetCharactersInBox(centerCFrame: CFrame, size: Vector3)
	local foundCharacters = {}
	print(tostring(centerCFrame) .. " is CFrame" .. tostring(size) .. " is size")
	local parts = Workspace:GetPartBoundsInBox(centerCFrame, size, nil)

	for _, part in ipairs(parts) do
		local model = part:FindFirstAncestorOfClass("Model")
		if model and model:FindFirstChild("Humanoid") then
			foundCharacters[model] = true
		end
	end

	local characters = {}
	for char in pairs(foundCharacters) do
		table.insert(characters, char)
	end

	return characters
end

function PartsInBounds.Damage(char: Model, CFrame: CFrame, size: Vector3, damage: number, stun: SharedTable, knockback: number)
	local targets = PartsInBounds.GetCharactersInBox(CFrame, size)
	local part = Instance.new("Part", workspace)
	part.CFrame = CFrame
	part.Size = size
	part.Anchored = true
	part.Transparency = 0.5
	part.CanCollide = false
	task.delay(0.5, function()
		part:Destroy()
	end)
	if targets then
		for _, target in pairs(targets) do
			if target ~= char then
				print(target)
				Damage.ApplyDamageFromMeshTouchEvent(char, target, damage)
				if stun then
					Stun.StunWithoutAnimation(target, stun.Speed, stun.Time, stun.Priority)
				end
				if Knockback then
					Knockback.ApplyKnockback(target, char, knockback)
					print("Applied knockback to " .. tostring(target))
				end
			end
		end
	end
end

return PartsInBounds