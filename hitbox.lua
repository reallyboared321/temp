-- LocalScript (for client-side)

local player = game.Players.LocalPlayer
local workspace = game.Workspace

-- Global variables for customization
_G.ENABLED = false
_G.HEAD_COLOR = Color3.new(1, 0, 0) -- Red by default
_G.HEAD_SIZE = 5 -- Default size now a single number

local function updateHeadHitboxes()
    if not _G.ENABLED then return end

    -- Loop through all player models in Workspace.Players
    for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player then  -- Skip the local player
            local playerModel = workspace.Players:FindFirstChild(otherPlayer.Name)
            
            if playerModel then
                local head = playerModel:FindFirstChild("Head")
                if head and head:IsA("MeshPart") then
                    local size = Vector3.new(_G.HEAD_SIZE, _G.HEAD_SIZE, _G.HEAD_SIZE)
                    head.Size = size
                    head.CanCollide = false  -- Ensure head does not collide
                    head.Color = _G.HEAD_COLOR
                end
            end
        end
    end
end

-- Run the function to update hitboxes for all players (excluding local player)
updateHeadHitboxes()

-- Update when new characters are added (e.g., respawn) for other players
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if player ~= game.Players.LocalPlayer then
            local playerModel = workspace.Players:FindFirstChild(player.Name)
            if playerModel then
                local head = playerModel:WaitForChild("Head")
                updateHeadHitboxes() -- Use function to update other players
            end
        end
    end)
end)

-- Update other players' heads when they respawn
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    updateHeadHitboxes() -- Only updates other players' heads
end)

-- Optional: Continuous check in case of other changes (like size or color changes mid-game)
game:GetService("RunService").Heartbeat:Connect(function()
    updateHeadHitboxes()
end)

-- Example functions to modify globals
local function setEnabled(enabled)
    _G.ENABLED = enabled
    updateHeadHitboxes()
end

local function setHeadColor(color)
    _G.HEAD_COLOR = color
    updateHeadHitboxes()
end

local function setHeadSize(size)
    _G.HEAD_SIZE = size
    updateHeadHitboxes()
end

-- Example usage:
-- setEnabled(false) -- Disable the script
-- setHeadColor(Color3.new(0, 1, 0)) -- Change to green
-- setHeadSize(3) -- Change size to 3x3x3
