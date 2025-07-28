--[[


   _____            __    _ __  ___           __           
  / ___/__  _______/ /_  (_)  |/  /___ ______/ /____  _____
  \__ \/ / / / ___/ __ \/ / /|_/ / __ `/ ___/ __/ _ \/ ___/
 ___/ / /_/ (__  ) / / / / /  / / /_/ (__  ) /_/  __/ /    
/____/\__,_/____/_/ /_/_/_/  /_/\__,_/____/\__/\___/_/     
                                                           




____________________________________________________________________________________________________________________________________________________________________________
				
	[ UPDATE LOG v1.1 :]
1. New property!!
	Hitbox.Key = "insert anything you want here"C
		--- This property will be used for the new function | module:FindHitbox(key)

2. New function!!
	Module:FindHitbox(Key)
		--- Returns a hitbox using specified Key, nil otherwise

3. New detection mode! | "ConstantDetection"
	Hitbox.DetectionMode = "ConstantDetection"
		--- The same as the default detection mode but no hit pool / debounce
		--- You're free to customize the debounce anyway you want
		
4, Made the scripts cleaner

____________________________________________________________________________________________________________________________________________________________________________

	Example code:
		local module = require(game.ServerStorage.MuchachoHitbox)

		local hitbox = module.CreateHitbox()
		hitbox.Visualizer = true
		hitbox.Size = Vector3.new(10,10,10)
		hitbox.CFrame = workspace.Part
		hitbox.Shape = Enum.PartType.Block
		hitbox.DetectionMode = "HitParts"

		hitbox.Touched:Connect(function(hit, hum)
			print(hit)
			hum:TakeDamage(10)
		end)
		hitbox:Start()
	
	
	Alright thats all for the example code, its a pretty simple module, you could make a module similar to this yourself.
	And maybe even make it better.
	
	If you encounter any bugs, please tell me in the comment section, or you could DM me on discord
	sushimaster#7840
	
	❤ SushiMaster
____________________________________________________________________________________________________________________________________________________________________________
	
	
	[MuchachoHitbox API]

		* local Module = require(MuchachoHitbox)
				--- Require the module


			[ FUNCTIONS ]

		* Module.CreateHitbox()
				Description
					--- Creates a hitbox
					
		* Module:FindHitbox(Key)
				Description
					--- Returns a hitbox with specified Key

		* HitboxObject:Start()
				Description
					--- Starts the hitbox. 
					
		* HitboxObject:Stop()
				Description
					--- Stops the hitbox and resets the debounce.
					
			[ EVENTS ]

		* HitboxObject.Touched:Connect(hit, humanoid)
				Description
					--- If hitbox touches a humanoid, it'll return information on them
				Arguments
					--- Instance part: Returns the part that the hitbox hit first
					--- Instance humanoid: Returns the Humanoid object 
					
			[ PROPERTIES ]

		* HitboxObject.OverlapParams: OverlapParams
				Description
					--- Takes in a OverlapParams object

		* HitboxObject.Visualizer: boolean
				Description
					--- Turns on or off the visualizer part

		* HitboxObject.CFrame: CFrame / Instance
				Description
					--- Sets the hitbox CFrame to the CFrame
					--- If its an instance, then the hitbox would follow the instance
					
		* HitboxObject.Shape: Enum.PartType.Block / Enum.PartType.Ball
				Description
					--- Defaults to block
					--- Sets the hitbox shape to the property
					
		* HitboxObject.Size: Vector3 / number 
				Description
					--- Sets the size of the hitbox
					--- It uses Vector3 if the shape is block
					--- It uses number if the shape is ball
					
		* HitboxObject.Offset: CFrame
				Description
					--- Hitbox offset

		* HitboxObject.DetectionMode: string | "Default" , "HitOnce" , "HitParts" , "ConstantDetection"
				Description
					--- Defaults to "Default"
					--- Changes on how the detection works
					
		* HitboxObject.Key: String
				Description
					--- The key property for the find hitbox function
					--- Once you set a key, the module will save the hitbox, and can be found using | Module:FindHitbox(Key)
			
			[ DETECTION MODES ]

		* Default
				Description
					--- Checks if a humanoid exists when this hitbox touches a part. The hitbox will not return humanoids it has already hit for the duration
					--- the hitbox has been active.

		* HitParts
				Description
					--- OnHit will return every hit part, regardless if it's ascendant has a humanoid or not.
					--- OnHit will no longer return a humanoid so you will have to check it. The hitbox will not return parts it has already hit for the
					--- duration the hitbox has been active.

		* HitOnce
				Description
					--- Hitbox will stop as soon as it detects a humanoid
					
		* ConstantDetection
				Description
					--- The default detection mode but no hitlist / debounce
					
____________________________________________________________________________________________________________________________________________________________________________

]]


local GoodSignal : funct = require(script.Parent.GoodSignal)
local rs = game:GetService("RunService")

local module = {}
module.__index = module

local hitboxes = {}


function module:FindHitbox(k)
	if hitboxes[k] then
		return hitboxes[k]
	end
end

function module:Visualize()
	
	if not self.Visualizer then return end
	local c = self.CFrame

	if typeof(c) == "Instance" then
		c = c.CFrame
	end

	local s = self.Size

	if typeof(s) == "Instance" then
		s = s.Size
	end
	
	if self.Shape == Enum.PartType.Ball then
		self.Box = Instance.new("SphereHandleAdornment")
		self.Box.Radius = s
	elseif self.Shape == Enum.PartType.Block then		
		self.Box = Instance.new("BoxHandleAdornment")
		self.Box.Size = s
	end
	
	self.Box.Name = "Visualizer"
	self.Box.CFrame = c * self.Offset
	self.Box.Adornee = workspace.Terrain
	self.Box.Color3 = Color3.fromRGB(255,0,0)
	self.Box.AlwaysOnTop = true
	self.Box.Transparency = .8
	self.Box.Parent = workspace.Terrain
end

function module:UpdateVisualizer()
	if not self.Visualizer then return end
	
	local c = self.CFrame
	
	if typeof(c) == "Instance" then
		c = c.CFrame
	end
	
	local s = self.Size

	if typeof(s) == "Instance" then
		s = s.Size
	end
	
	self.Box.CFrame = c * self.Offset
	self.Box.Size = s
end

function module:Cast()
	local parts
	local mode = self.DetectionMode
	local c = self.CFrame

	if typeof(c) == "Instance" then
		c = c.CFrame
	end

	local s = self.Size

	if typeof(s) == "Instance" then
		s = s.Size
	end

	if self.Shape == Enum.PartType.Block then
		parts = workspace:GetPartBoundsInBox(c * self.Offset, s, self.OverlapParams)
	elseif self.Shape == Enum.PartType.Ball then
		parts = workspace:GetPartBoundsInRadius(c.p + self.Offset.p, s, self.OverlapParams)
	end

	
	for i, hit in pairs(parts) do
		if mode ~= "HitParts" then
			local character = hit:FindFirstAncestorOfClass("Model") or hit.Parent
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			
			if hit.Parent:FindFirstChild("Humanoid") then
				if mode == "Default" then
					if character and humanoid and not self.HitList[table.find(self.HitList, humanoid)] then
						table.insert(self.HitList, humanoid)
						self.Touched:Fire(hit, humanoid)
					end
				elseif mode == "ConstantDetection" then
					if character and humanoid then
						self.Touched:Fire(hit, humanoid)
					end
				elseif mode == "HitOnce" then
					if character and humanoid then
						self.Touched:Fire(hit, humanoid)
						self:Stop()
						break
					end
				end
			end
		end	
		
		if mode == "HitParts" then
			self.Touched:Fire(hit)
		end
	end
end

function module.CreateHitbox()
	return setmetatable({
		Box = nil,
		Key = nil,
		CFrame = CFrame.new(0,0,0),
		Offset = CFrame.new(0,0,0),
		Size = Vector3.new(0,0,0),
		Visualizer = false,
		Touched = GoodSignal.new(),
		OverlapParams = OverlapParams.new(),
		Connection = nil,
		HitList = {},
		DetectionMode = "Default",
		Shape = Enum.PartType.Block
	}, module)
end

function module:Start()
	if hitboxes[self.Key] then
		warn("A hitbox with this Key has already been started. Change the key if you want to start this hitbox.")
		return		
	end
	
	if self.Key then
		hitboxes[self.Key] = self
	end
	
	
	self:Visualize()

	if self.OverlapParams and self.OverlapParams.FilterType == Enum.RaycastFilterType.Exclude then
		self.OverlapParams.FilterDescendantsInstances = {table.unpack(self.OverlapParams.FilterDescendantsInstances), self.Box}
	elseif not self.OverlapParams then
		self.OverlapParams.FilterType = Enum.RaycastFilterType.Exclude
		self.OverlapParams.FilterDescendantsInstances = {self.Box}
	end

	-- looping the hitbox
	task.spawn(function()
		self.Connection = rs.Heartbeat:Connect(function()
			self:Cast()
			self:UpdateVisualizer()
		end)
	end)
end

function module:Stop()
	self.HitList = {}
	self.Touched:DisconnectAll()
	
	if self.Key then
		hitboxes[self.Key] = nil
	end
	
	if self.Connection then
		self.Connection:Disconnect()
	end
	
	if self.Box then
		self.Box:Destroy()
	end
end

return module
