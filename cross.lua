--// CONFIG
_G.SpinningCrosshairEnabled = true
_G.SpinningCrosshairColor = Color3.fromRGB(0, 255, 255)
_G.SpinningCrosshairSize = 20
_G.SpinningCrosshairThickness = 2
_G.SpinningCrosshairSpeed = 2 -- degrees per frame

--// Drawing setup
local function createLine()
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = _G.SpinningCrosshairColor
    line.Thickness = _G.SpinningCrosshairThickness
    line.Transparency = 1
    return line
end

local lines = {
    createLine(),
    createLine(),
    createLine(),
    createLine()
}

local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local angle = 0

--// Main loop
RunService.RenderStepped:Connect(function()
    if not _G.SpinningCrosshairEnabled then
        for _, line in ipairs(lines) do
            line.Visible = false
        end
        return
    end

    local center = camera.ViewportSize / 2
    local size = _G.SpinningCrosshairSize
    local thickness = _G.SpinningCrosshairThickness
    local color = _G.SpinningCrosshairColor
    angle = (angle + _G.SpinningCrosshairSpeed) % 360

    for i = 1, 4 do
        local theta = math.rad(angle + (i - 1) * 90)
        local fromX = center.X + math.cos(theta) * (size / 2)
        local fromY = center.Y + math.sin(theta) * (size / 2)
        local toX = center.X + math.cos(theta) * size
        local toY = center.Y + math.sin(theta) * size

        local line = lines[i]
        line.From = Vector2.new(fromX, fromY)
        line.To = Vector2.new(toX, toY)
        line.Visible = true
        line.Color = color
        line.Thickness = thickness
    end
end)
