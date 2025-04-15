-- Global variables for FOV control
_G.OverallFOV = 70 -- Overall FOV that you can change at any time
_G.ZoomedFOV = 30
_G.ZoomKey = Enum.KeyCode.Z
_G.ZoomSpeed = 10
_G.ZoomEnabled = false

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- Internal state
local targetFOV = _G.OverallFOV -- Set the normal FOV to be the overall FOV

-- Function to update the FOV
local function updateFOV(dt)
    if math.abs(camera.FieldOfView - targetFOV) > 0.1 then
        camera.FieldOfView = camera.FieldOfView + (targetFOV - camera.FieldOfView) * math.clamp(dt * _G.ZoomSpeed, 0, 1)
    else
        camera.FieldOfView = targetFOV
    end
end

-- Toggle zoom on key press
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == _G.ZoomKey then
        _G.ZoomEnabled = not _G.ZoomEnabled
        if _G.ZoomEnabled then
            targetFOV = _G.ZoomedFOV
        else
            targetFOV = _G.OverallFOV -- Use the overall FOV when zoom is not active
        end
    end
end)

-- Update FOV on every frame
RunService.RenderStepped:Connect(function(dt)
    updateFOV(dt)
end)

-- Expose a
