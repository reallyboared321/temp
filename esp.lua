-- // GLOBAL SETTINGS // --
_G.box_esp = true
_G.box_type = "full" -- "full" or "cornered"
_G.name_esp = true
_G.distance_esp = true
_G.highlight_esp = true
_G.highlight_esp_color = Color3.fromRGB(255, 100, 100)
_G.box_esp_color = Color3.fromRGB(255, 255, 255)
_G.name_esp_color = Color3.fromRGB(255, 255, 255)
_G.distance_esp_color = Color3.fromRGB(200, 200, 200)
_G.measurement_type = "studs" -- or "meters"

-- // SCRIPT START // --
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")

local drawings = {}

local function createDrawing(type, props)
	local obj = Drawing.new(type)
	for k, v in pairs(props) do
		obj[k] = v
	end
	return obj
end

local function setupESP(player)
	if drawings[player] then return end
	drawings[player] = {}

	local d = drawings[player]

	-- Box and outline
	d.Box = createDrawing("Square", {Thickness = 1, Filled = false, Visible = false, Color = _G.box_esp_color})
	d.Box2 = createDrawing("Square", {Thickness = 3, Filled = false, Visible = false, Color = Color3.new()})

	-- Name and distance
	d.name = createDrawing("Text", {
		Size = 13,
		Center = true,
		Outline = true,
		Visible = false,
		Color = _G.name_esp_color,
	})

	d.distance = createDrawing("Text", {
		Size = 13,
		Center = true,
		Outline = true,
		Visible = false,
		Color = _G.distance_esp_color,
	})

	-- Corner ESP parts
	local cornerNames = {
		"LeftTop", "LeftSide", "RightTop", "RightSide",
		"BottomSide", "BottomDown", "BottomRightSide", "BottomRightDown",
	}

	for _, name in ipairs(cornerNames) do
		d[name] = createDrawing("Square", {
			Filled = true,
			Thickness = 1,
			Color = _G.box_esp_color,
			Visible = false
		})
	end
end

local function removeESP(player)
	if drawings[player] then
		for _, obj in pairs(drawings[player]) do
			if typeof(obj) == "table" then
				for _, part in pairs(obj) do
					part:Remove()
				end
			else
				obj:Remove()
			end
		end
		drawings[player] = nil
	end
end

Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		if player == LP then continue end

		setupESP(player)

		local d = drawings[player]
		local char = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild(player.Name)
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		

		if char and hrp and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChild("Head") then
			local cframe, size = char:GetBoundingBox()
			local screenPos, onScreen = Camera:WorldToViewportPoint(cframe.Position)

			if onScreen then
				local scaleTop = Camera:WorldToViewportPoint(cframe.Position + Vector3.new(0, size.Y / 2, 0))
				local scaleBottom = Camera:WorldToViewportPoint(cframe.Position - Vector3.new(0, size.Y / 2, 0))

				local height = math.abs(scaleTop.Y - scaleBottom.Y)
				local width = height / 2

				local x = screenPos.X - width / 2
				local y = screenPos.Y - height / 2

				-- Box ESP
				if _G.box_esp and _G.box_type == "full" then
					d.Box.Position = Vector2.new(x, y)
					d.Box.Size = Vector2.new(width, height)
					d.Box.Visible = true

					d.Box2.Position = Vector2.new(x - 1, y - 1)
					d.Box2.Size = Vector2.new(width + 2, height + 2)
					d.Box2.Visible = true

					local highlight = _G.highlight_esp and LP.Character and char:IsDescendantOf(LP.Character)
					local targetColor = highlight and _G.highlight_esp_color or _G.box_esp_color

					d.Box.Color = d.Box.Color:Lerp(targetColor, 0.1)
					d.Box2.Color = Color3.new(0, 0, 0)
				else
					d.Box.Visible = false
					d.Box2.Visible = false
				end

				-- Cornered ESP
				if _G.box_esp and _G.box_type == "cornered" then
					local thickness = 2
					local cornerLength = math.floor(width / 3)

					local positions = {
						LeftTop = Vector2.new(x, y),
						LeftSide = Vector2.new(x, y),
						RightTop = Vector2.new(x + width - cornerLength, y),
						RightSide = Vector2.new(x + width - thickness, y),
						BottomSide = Vector2.new(x, y + height - thickness),
						BottomDown = Vector2.new(x, y + height - thickness),
						BottomRightSide = Vector2.new(x + width - thickness, y + height - thickness),
						BottomRightDown = Vector2.new(x + width - cornerLength, y + height - thickness),
					}

					local sizes = {
						LeftTop = Vector2.new(cornerLength, thickness),
						LeftSide = Vector2.new(thickness, height / 4),
						RightTop = Vector2.new(cornerLength, thickness),
						RightSide = Vector2.new(thickness, height / 4),
						BottomSide = Vector2.new(thickness, height / 4),
						BottomDown = Vector2.new(cornerLength, thickness),
						BottomRightSide = Vector2.new(thickness, height / 4),
						BottomRightDown = Vector2.new(cornerLength, thickness),
					}

					for name, pos in pairs(positions) do
						d[name].Position = pos
						d[name].Size = sizes[name]
						d[name].Color = d[name].Color:Lerp((_G.highlight_esp and char:IsDescendantOf(LP.Character)) and _G.highlight_esp_color or _G.box_esp_color, 0.1)
						d[name].Visible = true
					end
				else
					for _, name in ipairs({"LeftTop", "LeftSide", "RightTop", "RightSide", "BottomSide", "BottomDown", "BottomRightSide", "BottomRightDown"}) do
						d[name].Visible = false
					end
				end

				-- Name ESP
				if _G.name_esp then
					d.name.Text = player.DisplayName
					d.name.Position = Vector2.new(screenPos.X, y - 15)
					d.name.Color = d.name.Color:Lerp((_G.highlight_esp and char:IsDescendantOf(LP.Character)) and _G.highlight_esp_color or _G.name_esp_color, 0.1)
					d.name.Visible = true
				else
					d.name.Visible = false
				end

				-- Distance ESP
				if _G.distance_esp then
					local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
					local text = _G.measurement_type == "meters" and string.format("%dm", math.floor(distance / 3.5)) or string.format("%dst", math.floor(distance))

					d.distance.Text = text
					d.distance.Position = Vector2.new(screenPos.X, y + height + 2)
					d.distance.Color = d.distance.Color:Lerp((_G.highlight_esp and char:IsDescendantOf(LP.Character)) and _G.highlight_esp_color or _G.distance_esp_color, 0.1)
					d.distance.Visible = true
				else
					d.distance.Visible = false
				end
			else
				-- Hide if off screen
				for _, obj in pairs(d) do
					obj.Visible = false
				end
			end
		else
			for _, obj in pairs(d) do
				obj.Visible = false
			end
		end
	end
end)
