local module = {}

local States: {[Model]: {[string]: boolean}} = {}
local AncestryChangedConnections: {[Model]: RBXScriptConnection} = {}

function module.InitializeModel(char: Model)
	States[char] = {}
	
	if not AncestryChangedConnections[char] then
		AncestryChangedConnections[char] = char.AncestryChanged:Connect(function(_, parent)
			if not parent then
				States[char] = nil
				if AncestryChangedConnections[char] then
					AncestryChangedConnections[char]:Disconnect()
					AncestryChangedConnections[char] = nil
				end
			end
		end)
	end
end

function module.RemoveState(char: Model, state: string)
	if not States[char] then return end

	States[char][state] = nil
end

function module.SetState(char: Model, state: string, value: boolean)
	if not States[char] then
		module.InitializeModel(char)
	end
	
	States[char][state] = value
end

function module.HasState(char: Model, state: string)
	if not States[char] then
		module.InitializeModel(char)
		return false
	end
	return States[char][state]
end

return module
