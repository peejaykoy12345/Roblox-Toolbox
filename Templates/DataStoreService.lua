local DataStoreService = game:GetService("DataStoreService")
local playerDataStore = DataStoreService:GetDataStore("PlayerData")

game.Players.PlayerAdded:Connect(function(player)
	local leaderstats = player:WaitForChild("leaderstats")
	local kills = leaderstats:WaitForChild("Kills")

	local success, data = pcall(function()
		return playerDataStore:GetAsync(player.UserId)
	end)

	if success and data then
		kills.Value = data.Kills or 0
	else 
		warn("Data load failed:", data)
	end
end)

game.Players.PlayerRemoving:Connect(function(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end

	local kills = leaderstats:FindFirstChild("Kills")
	if not kills then return end
	
	local data = {
		Kills = kills.Value
	}

	local success, err = pcall(function()
		playerDataStore:SetAsync(player.UserId, data)
	end)

	if not success then
		warn("Save failed:", err)
	end
end)