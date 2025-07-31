local TravelDevice = {}
TravelDevice.__index = TravelDevice

local RunService = game:GetService("RunService")

function TravelDevice.new(owner: Player, parent: Model)
	local self = setmetatable({}, TravelDevice)

	self.owner = owner
	self.character = owner.Character or owner.CharacterAdded:Wait()
	self.humanoid = self.character:WaitForChild("Humanoid")

	self.VehicleSeat = parent:WaitForChild("VehicleSeat")
	self.Attachment = self.VehicleSeat:WaitForChild("Attachment")
	self.LinearVelocity = self.VehicleSeat:WaitForChild("LinearVelocity")
	self.AngularVelocity = self.VehicleSeat:WaitForChild("AngularVelocity")
	self.speed = 100
	self.max_speed = 500

	self.LinearVelocity.MaxForce = math.huge
	self.AngularVelocity.MaxTorque = math.huge

	if not self.LinearVelocity.Attachment0 then
		warn("No attachment set for " .. parent.Name)
		self.LinearVelocity.Attachment0 = self.Attachment
		self.LinearVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	end

	if not self.AngularVelocity.Attachment0 then
		warn("No attachment set for " .. parent.Name)
		self.AngularVelocity.Attachment0 = self.Attachment
		self.AngularVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	end
	
	local thrusters = self.VehicleSeat:WaitForChild("thrusters")
	self.thrusters = thrusters:GetChildren()
	
	self.fire_emitters = {}
	
	task.spawn(function()
		for _, thruster in pairs(self.thrusters) do
			local fireAttachment = thruster:FindFirstChild("fireAttachment")
			if not fireAttachment then warn(`Fire attachment not found for {self.VehicleSeat.Parent.Name}`) return end

			local fireEmitter: ParticleEmitter = Instance.new("ParticleEmitter")
			fireEmitter.Name = "FireEmitter"
			fireEmitter.Texture = "rbxassetid://241594419" 
			fireEmitter.Lifetime = NumberRange.new(1.5)
			fireEmitter.Rate = 0 
			fireEmitter.Speed = NumberRange.new(2, 4)
			fireEmitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
			fireEmitter.LightEmission = 0.7
			fireEmitter.Parent = fireAttachment

			fireEmitter.Enabled = false

			table.insert(self.fire_emitters, fireEmitter)
		end
	end)	

	local remoteEvents = self.VehicleSeat:WaitForChild("RemoteEvents")
	self.roll_event = remoteEvents:WaitForChild("roll")
	self.activate_thrusters_event = remoteEvents:WaitForChild("activate_thrusters")
	self.adjust_speed = remoteEvents:WaitForChild("adjust_speed")
	self.on_player_seated = remoteEvents:WaitForChild("on_player_seated")

	self.activate_thrusters = false
	self._is_increasing_held = false
	self._is_decreasing_held = false

	-- Angular components
	self._rotation_x = 0 -- pitch
	self._rotation_y = 0 -- yaw
	self._rotation_z = 0 -- roll

	return self
end

local function exploit_check(player: Player, vehicle_seat: VehicleSeat)
	local occupant = vehicle_seat.Occupant
	if not occupant then return false end

	local character = player.Character
	if not character then return false end

	return occupant == character:FindFirstChild("Humanoid")
end

function TravelDevice:Start()

	self.activate_thrusters_event.OnServerEvent:Connect(function(player: Player)
		if not exploit_check(player, self.VehicleSeat) then return end
		self.activate_thrusters = not self.activate_thrusters
	end)

	self.roll_event.OnServerEvent:Connect(function(player: Player, speed_delta: number, is_held: boolean)
		if not exploit_check(player, self.VehicleSeat) then return end
		if is_held then
			self._rotation_z = speed_delta
		else
			self._rotation_z = 0
		end
	end)

	self.adjust_speed.OnServerEvent:Connect(function(player: Player, speed_delta: number, is_held: boolean)
		if not exploit_check(player, self.VehicleSeat) then return end
		if speed_delta > 0 then
			if is_held and not self._is_increasing_held then
				self._is_increasing_held = true
				task.spawn(function()
					while self._is_increasing_held do
						self.speed = math.min(self.speed + speed_delta, self.max_speed)
						if self.speed < 0 then self.speed = 0 end
						task.wait(0.01)
					end
				end)
			elseif not is_held then
				self._is_increasing_held = false
			end
		elseif speed_delta < 0 then
			if is_held and not self._is_decreasing_held then
				self._is_decreasing_held = true
				task.spawn(function()
					while self._is_decreasing_held do
						self.speed -= 1
						if self.speed < 0 then self.speed = 0 end
						task.wait(0.01)
					end
				end)
			elseif not is_held then
				self._is_decreasing_held = false
			end
		end
	end)
	
	self._past_occupant = nil

	self._occupantChangedConnection = self.VehicleSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
		if self.VehicleSeat.Occupant and self.VehicleSeat.Occupant ~= self.humanoid then
			self.VehicleSeat.Occupant = nil
			return
		end
		
		if self.VehicleSeat.Occupant == nil and self._past_occupant then
			self.on_player_seated:FireClient(self._past_occupant, false)
			self._past_occupant = nil
		end
		
		if self.VehicleSeat.Occupant then
			local char = self.VehicleSeat.Occupant.Parent
			local plr = game.Players:GetPlayerFromCharacter(char)
			self.on_player_seated:FireClient(plr, true)
			self._past_occupant = plr
		end
	end)

	self._heartbeatConnection = RunService.Heartbeat:Connect(function()
		self._rotation_y = -2 * self.VehicleSeat.Steer

		self._rotation_x = -2 * self.VehicleSeat.Throttle
		
		
		self.AngularVelocity.AngularVelocity = Vector3.new(
			self._rotation_x,
			self._rotation_y,
			self._rotation_z
		)

		if self.activate_thrusters then
			self.LinearVelocity.Enabled = true
			self.LinearVelocity.VectorVelocity = Vector3.new(0, 0, -self.speed)
			
			for _, emitter in pairs(self.fire_emitters) do
				emitter.Enabled = true
				emitter:Emit(2)
			end
			
			self.AngularVelocity.Enabled = true
		else
			self.AngularVelocity.Enabled = false
			self.LinearVelocity.Enabled = false
			
			for _, emitter in ipairs(self.fire_emitters) do
				emitter.Enabled = false
			end
		end
	end)
end

function TravelDevice:Stop()
	if self._heartbeatConnection then
		self._heartbeatConnection:Disconnect()
		self._heartbeatConnection = nil
	end

	if self._occupantChangedConnection then
		self._occupantChangedConnection:Disconnect()
		self._occupantChangedConnection = nil
	end
end

return TravelDevice
