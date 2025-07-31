local ray = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, self.raycastParams)
		if ray and ray.Position then
			local pos = ray.Position
			pos = Vector3.new(
				math.floor(pos.X + 0.5),
				pos.Y,
				math.floor(pos.Z + 0.5)
			)
			self.towerModel:PivotTo(CFrame.new(pos))
		end