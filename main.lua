-- GTA V Mod Menu Style UI Library Extension
-- Using drawingfix.lua with rounded corners

local Drawing = Drawing
local Vector2 = Vector2
local Color3 = Color3
local math = math
local task = task
local table = table

-- Theme configuration
local theme = {
    baseColor = Color3.fromRGB(20, 20, 20),        -- Dark black base
    hoverColor = Color3.fromRGB(255, 0, 0),        -- Neon red for hover
    textColor = Color3.fromRGB(255, 255, 255),     -- White text
    mutedTextColor = Color3.fromRGB(120, 120, 120),-- Muted gray for inactive
    borderColor = Color3.fromRGB(255, 30, 30),     -- Neon red border
    glowColor = Color3.fromRGB(255, 50, 50),       -- Slightly brighter red for glow
    titleColor = Color3.fromRGB(255, 255, 255),    -- White for title
    font = 2,                                      -- Drawing.Fonts.Plex
    fontSize = 16,                                 -- Readable size
    spacing = 5,                                   -- Consistent spacing
    radius = 4,                                    -- Rounded corner radius
}

-- Sound stubs (replace SOUND_IDs with actual asset IDs if desired)
local hoverSound = Instance.new("Sound", workspace)
hoverSound.SoundId = "rbxassetid://SOUND_ID_HOVER"
local selectSound = Instance.new("Sound", workspace)
selectSound.SoundId = "rbxassetid://SOUND_ID_SELECT"
local backSound = Instance.new("Sound", workspace)
backSound.SoundId = "rbxassetid://SOUND_ID_BACK"

local function playHover()
    if hoverSound.IsLoaded then hoverSound:Play() end
end
local function playSelect()
    if selectSound.IsLoaded then selectSound:Play() end
end
local function playBack()
    if backSound.IsLoaded then backSound:Play() end
end

-- Title bar setup
local camera = workspace.CurrentCamera
local screenWidth = camera.ViewportSize.X
local menuwidth = math.max(screenWidth / 18, 120)

local titleBar = Drawing.new("Square")
titleBar.Color = theme.baseColor
titleBar.Transparency = 0.9
titleBar.Filled = true
titleBar.Size = Vector2.new(menuwidth * 2, 30)
titleBar.Position = Vector2.new(0, 0)
titleBar.Visible = true
titleBar.ZIndex = 998
titleBar.Radius = theme.radius

local titleText = Drawing.new("Text")
titleText.Text = "MY MOD MENU"
titleText.Position = Vector2.new(menuwidth, 7)
titleText.Size = 18
titleText.Center = true
titleText.Outline = true
titleText.Color = theme.titleColor
titleText.OutlineColor = theme.borderColor
titleText.Font = theme.font
titleText.Visible = true
titleText.ZIndex = 999

-- Store title drawings for cleanup


-- Helper to create glow effect
local function createGlowEffect(parentDrawing, offset, sizeAdjust)
    local glow = Drawing.new("Square")
    glow.Color = theme.glowColor
    glow.Transparency = 0.3
    glow.Filled = true
    glow.Size = parentDrawing.Size + Vector2.new(sizeAdjust, sizeAdjust)
    glow.Position = parentDrawing.Position - Vector2.new(offset, offset)
    glow.ZIndex = parentDrawing.ZIndex - 1
    glow.Visible = false
    glow.Radius = theme.radius + 2
    return glow
end

-- Apply styling to existing and future tabs
local function styleTab(tab, index)
    local offsetY = 40 + (index * (15 + theme.spacing))
    
    -- Base square
    tab.drawings.base.Color = theme.baseColor
    tab.drawings.base.Transparency = 0.75
    tab.drawings.base.Size = Vector2.new(menuwidth, 15)
    tab.drawings.base.Position = Vector2.new(0, offsetY)
    tab.drawings.base.Radius = theme.radius
    
    -- Text
    tab.drawings.text.Color = theme.textColor
    tab.drawings.text.Font = theme.font
    tab.drawings.text.Size = theme.fontSize - 2
    tab.drawings.text.Position = tab.drawings.base.Position + Vector2.new(5, 1)
    tab.drawings.text.OutlineColor = theme.borderColor
    
    -- Arrow
    tab.drawings.arrow.Color = theme.textColor
    tab.drawings.arrow.Font = theme.font
    tab.drawings.arrow.Size = theme.fontSize - 2
    tab.drawings.arrow.Position = tab.drawings.base.Position + Vector2.new(menuwidth - 12, 1)
    tab.drawings.arrow.OutlineColor = theme.borderColor
    
    -- Glow effect
    tab.drawings.glow = createGlowEffect(tab.drawings.base, 2, 4)
    table.insert(library.alldrawings, tab.drawings.glow)
    
    -- Override hover
    local originalHover = tab.hovered_
    tab.hovered_ = function(state)
        originalHover(state)
        if state then
            playHover()
            tab.drawings.base.Color = theme.hoverColor
            tab.drawings.glow.Visible = true
        else
            tab.drawings.base.Color = theme.baseColor
            tab.drawings.glow.Visible = false
        end
    end
    
    -- Override open/close
    local originalOpen = tab.open
    tab.open = function(...)
        playSelect()
        tab.drawings.arrow.Text = ">"
        tab.drawings.arrow.Color = theme.hoverColor
        return originalOpen(...)
    end
    local originalClose = tab.close
    tab.close = function(...)
        playBack()
        tab.drawings.arrow.Text = "<"
        tab.drawings.arrow.Color = theme.textColor
        return originalClose(...)
    end
end

-- Style existing tabs
for index, tab in ipairs(library.tabinfo.tabs) do
    styleTab(tab, index)
end

-- Override AddTab to apply styling
local originalAddTab = library.AddTab
library.AddTab = function(self, text)
    local tab = originalAddTab(self, text)
    styleTab(tab, library.tabinfo.amount)
    return tab
end

-- Apply styling to options (buttons, toggles, sliders, dropdowns)
local function styleOption(option, tab, index)
    local offsetX = menuwidth + 10
    local offsetY = (index * (15 + theme.spacing))
    
    -- Base
    option.drawings.base.Color = theme.baseColor
    option.drawings.base.Transparency = 0.75
    option.drawings.base.Size = Vector2.new(menuwidth, 15)
    option.drawings.base.Position = tab.drawings.base.Position + Vector2.new(offsetX, offsetY)
    option.drawings.base.Radius = theme.radius
    
    -- Text
    option.drawings.text.Color = option.enabled and theme.textColor or theme.mutedTextColor
    option.drawings.text.Font = theme.font
    option.drawings.text.Size = theme.fontSize - 2
    option.drawings.text.Position = option.drawings.base.Position + Vector2.new(5, 1)
    
    -- Glow
    option.drawings.glow = createGlowEffect(option.drawings.base, 2, 4)
    table.insert(library.alldrawings, option.drawings.glow)
    
    -- Update visuals function
    local function updateVisuals(hovered)
        option.drawings.base.Color = hovered and theme.hoverColor or theme.baseColor
        option.drawings.glow.Visible = hovered
        if option.enabled ~= nil then
            option.drawings.text.Color = option.enabled and theme.textColor or theme.mutedTextColor
        else
            option.drawings.text.Color = hovered and theme.textColor or theme.mutedTextColor
        end
    end
    
    -- Apply initial state
    updateVisuals(option.hovered)
    
    -- Override interactions based on type
    if option.press then -- Button
        local originalPress = option.press
        option.press = function(...)
            if not option.hovered or not tab.opened then return end
            playSelect()
            task.spawn(function()
                option.drawings.text.Color = theme.borderColor
                task.wait(0.05)
                option.drawings.text.Color = theme.textColor
            end)
            return originalPress(...)
        end
    elseif option.toggle then -- Toggle
        local originalToggle = option.toggle
        option.toggle = function(state)
            if not option.hovered or not tab.opened then return end
            playSelect()
            originalToggle(state)
            updateVisuals(option.hovered)
        end
        local originalSet = option.flag.setvalue
        option.flag.setvalue = function(state)
            originalSet(state)
            updateVisuals(option.hovered)
        end
    elseif option.increase then -- Slider
        local originalIncrease = option.increase
        local originalDecrease = option.decrease
        option.increase = function(...)
            if not option.hovered or not tab.opened then return end
            playSelect()
            return originalIncrease(...)
        end
        option.decrease = function(...)
            if not option.hovered or not tab.opened then return end
            playSelect()
            return originalDecrease(...)
        end
        local originalSet = option.flag.setvalue
        option.flag.setvalue = function(value)
            originalSet(value)
            updateVisuals(option.hovered)
        end
    elseif option.cycleRight then -- Dropdown
        local originalCycleRight = option.cycleRight
        local originalCycleLeft = option.cycleLeft
        option.cycleRight = function(...)
            if not option.hovered or not tab.opened then return end
            playSelect()
            return originalCycleRight(...)
        end
        option.cycleLeft = function(...)
            if not option.hovered or not tab.opened then return end
            playSelect()
            return originalCycleLeft(...)
        end
        local originalSet = option.flag.setvalue
        option.flag.setvalue = function(value)
            originalSet(value)
            updateVisuals(option.hovered)
        end
    end
end

-- Style existing options
for _, tab in ipairs(library.tabinfo.tabs) do
    for index, option in ipairs(tab.options.stored) do
        styleOption(option, tab, index)
    end
end

-- Override option creation methods
local function overrideOptionMethod(methodName)
    local originalMethod = library[methodName]
    library[methodName] = function(self, ...)
        local option = originalMethod(self, ...)
        local index = self.options.amount
        local tab = self
        styleOption(option, tab, index)
        return option
    end
end

overrideOptionMethod("AddButton")
overrideOptionMethod("AddToggle")
overrideOptionMethod("AddSlider")
overrideOptionMethod("AddDropdown")
