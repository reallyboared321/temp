-- Global Toggle
_G.EnableMarkerHighlight = false

-- Settings
local newSize = Vector3.new(5, 5, 5)
local originalSize = Vector3.new(1, 1, 1)
local range = 10
local hiddenDecalTransparency = 1
local visibleDecalTransparency = 0

-- Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Track the last hit object (tree or ore)
local lastObject = nil

-- Function to reset the last Marker
local function resetLastMarker()
	if lastObject and lastObject:FindFirstChild("Marker") then
		local marker = lastObject.Marker
		marker.Size = originalSize

		local decal = marker:FindFirstChild("Decal")
		if decal and decal:IsA("Decal") then
			decal.Transparency = visibleDecalTransparency
		end
	end
end

-- Mouse move to detect hits
mouse.Move:Connect(function()
	if not _G.EnableMarkerHighlight then
		resetLastMarker()
		lastObject = nil
		return
	end

	local unitRay = workspace.CurrentCamera:ScreenPointToRay(mouse.X, mouse.Y)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {player.Character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * range, raycastParams)

	if raycastResult then
		local hitPart = raycastResult.Instance
		local target = hitPart:FindFirstAncestorWhichIsA("Model")
		if target and target:FindFirstChild("Marker") then
			if target ~= lastObject then
				resetLastMarker()
				lastObject = target

				local marker = target.Marker
				marker.Size = newSize

				local decal = marker:FindFirstChild("Decal")
				if decal and decal:IsA("Decal") then
					decal.Transparency = hiddenDecalTransparency
				end
			end
			return
		end
	end

	-- Reset if not hitting anything valid
	resetLastMarker()
	lastObject = nil
end)
