-- noticeSV v1.0 (updated 18 Feb 2021)
-- created by kloi34

-- Thank you IceDynamix for writing the Quaver Plugin Guide
-- It was a very good starting point for learning how to code plugins

-- Referenced, stole, and modified much of IceDynamix's iceSV code >.< :
-- https://github.com/IceDynamix/iceSV
---------------------------------------------------------------------------------------------------

-- Creates the plugin window
function draw()
    applyStyle()
    svMenu()
end

---------------------------------------------------------------------------------------------------
-- Global constants
---------------------------------------------------------------------------------------------------

SAMELINE_SPACING = 5               -- value determining spacing between GUI items on the same row
DEFAULT_WIDGET_HEIGHT = 26         -- value determining the height of GUI widgets
DEFAULT_WIDGET_WIDTH = 250         -- value determining the width of GUI widgets
BUTTON_WIDGET_RATIOS = {0.3, 0.7}  -- ratio of lengths for a button and a widget on the same row
MAX_TELEPORT_SV = 24000            -- max value to keep notes on-screen with a 0.016 ms SV
HUGE_SV = 99999                    -- SV value to move past long sections of the note field
BIG_SV = 2000                      -- SV value to move off-screen notes onto the current field

---------------------------------------------------------------------------------------------------
-- Menus and Tabs
---------------------------------------------------------------------------------------------------

-- Creates the plugin menu and all SV tabs
function svMenu()
    imgui.Begin("noticeSV", true, imgui_window_flags.AlwaysAutoResize)
    state.IsWindowHovered = imgui.IsWindowHovered()
    imgui.BeginTabBar("function_selection")
    info()
    reverseScroll()
    bounce()
    imgui.EndTabBar()
    imgui.End()
end

-- Creates the info tab to provide information about the plugin and its supported SV effects
function info()
    if imgui.BeginTabItem("Info") then
        section("help", true)
        
        function helpItem(item, text)
            imgui.BulletText(item)
            helpMarker(text)
        end
        
        helpItem("Reverse Scroll", "Flips the scroll direction, making notes move the opposite way")
        helpItem("Bounce SV", "Makes a note look like it is jumping or bouncing")
        --helpItem("Teleport SV", "Teleports a note to a different parts of the screen")
        --helpItem("Float SV", "Suspend notes in the middle of the screen")
        
        section("links")
        
        function listItem(text, url)
            imgui.TextWrapped(text)
            linkURL(url)
        end
        
        listItem("noticeSV Wiki", "https://github.com/kloi34/noticeSV/wiki")
        listItem("GitHub Repository", "https://github.com/kloi34/noticeSV")
        listItem("Inspired by IceDynamix's iceSV plugin", "https://github.com/IceDynamix/iceSV")
        
        separator()
        spacing()
        
        imgui.Text("noticeSV v1.0                                                                                    \\ ( ^ w ^ ) /")
        imgui.endTabItem()
    end
end

-- Creates the reverse-scroll tab to insert reverse-scroll SVs
function reverseScroll()
    if imgui.BeginTabItem("Reverse") then
        menuID = "reverse"
        variables = {
            reverseSVSpeed = -1,
            teleportSV = MAX_TELEPORT_SV
        }
        retrieveStateVariables(menuID, variables)
        
        giveInstructions()
        
        section("settings")
        
        if imgui.Button("Reset", {DEFAULT_WIDGET_WIDTH * BUTTON_WIDGET_RATIOS[1], DEFAULT_WIDGET_HEIGHT}) then
            variables.teleportSV = MAX_TELEPORT_SV
        end
        imgui.SameLine(0, SAMELINE_SPACING)
        imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * BUTTON_WIDGET_RATIOS[2] - SAMELINE_SPACING)
        _, variables.teleportSV = imgui.DragInt("  Teleport SV", variables.teleportSV, 20, 0, 30000)
        variables.teleportSV = mathClamp(variables.teleportSV, 0, 30000)
        imgui.PopItemWidth()
        helpMarker("This is the SV value that determines how high or low on the screen the reverse-scroll notes will be hit.")
        
        -- buttons with the same string name makes the second button not work for some reason,
        -- so i added a space before and after in the string for this second button to make it work
        if imgui.Button(" Reset ", {DEFAULT_WIDGET_WIDTH * BUTTON_WIDGET_RATIOS[1], DEFAULT_WIDGET_HEIGHT}) then
            variables.reverseSVSpeed = -1
        end
        imgui.SameLine(0, SAMELINE_SPACING)
        imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * BUTTON_WIDGET_RATIOS[2] - SAMELINE_SPACING)
        _, variables.reverseSVSpeed = imgui.DragFloat("  Reverse SV Speed", variables.reverseSVSpeed, 0.01, -10, 0, "%.2fx")
        variables.reverseSVSpeed = mathClamp(variables.reverseSVSpeed, -10, 0)
        imgui.PopItemWidth()
        
        separator()
        spacing()
        
        if imgui.Button("Insert SVs onto selected notes", {DEFAULT_WIDGET_WIDTH, DEFAULT_WIDGET_HEIGHT}) then
            local offsets = uniqueSelectedNoteOffsets()
            if (#offsets > 1) then
                local SVs = calculateReverseSVs(offsets, variables.teleportSV, variables.reverseSVSpeed)
                actions.PlaceScrollVelocityBatch(SVs)
            end
        end
        saveStateVariables(menuID, variables)
        imgui.endTabItem()
    end
end

-- Creates the bounce tab to insert bounce SVs
function bounce()
    if imgui.BeginTabItem("Bounce") then
        menuID = "bounce"
        variables = {
            averageBounceSV = 1,
            numSVsPerBounce = 32,
            skipEndSV = false,
            bounceType = 0,
            bounceTypes = {"Normal"}
            --bounceTypes = {"Normal", "Sharp", "Stacked"}
        }
        retrieveStateVariables(menuID, variables)
        giveInstructions()
        
        section("settings")
        imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
        _, variables.bounceType = imgui.Combo("  Type of Bounce", variables.bounceType, variables.bounceTypes, #variables.bounceTypes)
        imgui.PopItemWidth()
        
        if imgui.Button("Reset", {DEFAULT_WIDGET_WIDTH * BUTTON_WIDGET_RATIOS[1], DEFAULT_WIDGET_HEIGHT}) then
            variables.averageBounceSV = 1
        end
        imgui.SameLine(0, SAMELINE_SPACING)
        imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * BUTTON_WIDGET_RATIOS[2] - SAMELINE_SPACING)
        _, variables.averageBounceSV = imgui.DragFloat("  Average Bounce SV", variables.averageBounceSV, 0.01, 0, 10, "%.2fx")
        variables.averageBounceSV = mathClamp(variables.averageBounceSV, 0, 10)
        imgui.PopItemWidth()
        
        if imgui.Button(" Reset ", {DEFAULT_WIDGET_WIDTH * BUTTON_WIDGET_RATIOS[1], DEFAULT_WIDGET_HEIGHT}) then
            variables.numSVsPerBounce = 32
        end
        imgui.SameLine(0, SAMELINE_SPACING)
        imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * BUTTON_WIDGET_RATIOS[2] - SAMELINE_SPACING)
        _, variables.numSVsPerBounce = imgui.InputInt("  SVs per bounce", variables.numSVsPerBounce, 2)
        variables.numSVsPerBounce = forceEven(variables.numSVsPerBounce)
        variables.numSVsPerBounce = mathClamp(variables.numSVsPerBounce, 16, 128)
        imgui.PopItemWidth()
        
        spacing()
        _, variables.skipEndSV = imgui.Checkbox("Skip final 1.00x SV?", variables.skipEndSV)
        
        separator()
        spacing()
        
        if imgui.Button("Insert SVs onto selected notes", {DEFAULT_WIDGET_WIDTH, DEFAULT_WIDGET_HEIGHT}) then
            local offsets = uniqueSelectedNoteOffsets()
            if (#offsets > 1) then
                local SVs = {}
                if (variables.bounceType == 0) then
                    SVs = calculateNormalBounceSVs(offsets, variables.averageBounceSV, variables.numSVsPerBounce, variables.skipEndSV)
                --elseif (variables.bounceType == 1) then
                --    SVs = calculateSharpBounceSVs(offsets, variables.averageBounceSV, variables.numSVsPerBounce)
                --else -- variables.bounceType == 2
                --    SVs = calculateStackedBounceSVs(offsets, variables.averageBounceSV, variables.numSVsPerBounce)
                end
                actions.PlaceScrollVelocityBatch(SVs)
            end
        end
        
        imgui.endTabItem()
        saveStateVariables(menuID, variables)
    end
end

---------------------------------------------------------------------------------------------------
-- Calculation/helper functions
---------------------------------------------------------------------------------------------------

-- Returns the (unique) offsets of the selected notes
function uniqueSelectedNoteOffsets()
    local offsets = {}
    for i, hitObject in pairs(state.SelectedHitObjects) do
        offsets[i] = hitObject.StartTime
    end
    offsets = uniqueByTime(offsets)
    return offsets
end

-- Takes in a list of offsets and returns the list only with offsets that are at a unique time
-- Parameters
--    offsets : list of offsets (Table)
function uniqueByTime(offsets)
    local hash = {}
    -- new list of offsets
    local uniqueTimes = {}
    
    for _, value in ipairs(offsets) do
        -- if the offset is not already on the new list of offsets
        if (not hash[value]) then
          -- add offset to the new list
            uniqueTimes[#uniqueTimes + 1] = value
            hash[value] = true
        end
    end
    return uniqueTimes
end

-- Retrieves variables from the state
-- Parameters
--    menuID    : name of the tab menu that the variables are from (String)
--    variables : table that contains variables and values (Table)
function retrieveStateVariables(menuID, variables)
    for key, value in pairs(variables) do
        variables[key] = state.GetValue(menuID..key) or value
    end
end

-- Saves variables to the state
-- Parameters
--    menuID    : name of the tab menu that the variables are from (String)
--    variables : table that contains variables and values (Table)
function saveStateVariables(menuID, variables)
    for key, value in pairs(variables) do
        state.SetValue(menuID..key, value)
    end
end

-- Calculates reverse-scroll SVs
-- Parameters
--    offsets        : list of offsets (Table)
--    teleportSV     : value for the teleport SV (Int)
--    reverseSVSpeed : value for the reverse-scroll SV speed (Float)
function calculateReverseSVs(offsets, teleportSV, reverseSVSpeed)
    local SVs = {}
    for i, offset in ipairs(offsets) do
        if (i == 1) then
            table.insert(SVs, utils.CreateScrollVelocity(offset , HUGE_SV))
            table.insert(SVs, utils.CreateScrollVelocity(offset + 1, reverseSVSpeed))
        elseif (i == #offsets) then
            table.insert(SVs, utils.CreateScrollVelocity(offset - 0.016, teleportSV))
            table.insert(SVs, utils.CreateScrollVelocity(offset , HUGE_SV))
            table.insert(SVs, utils.CreateScrollVelocity(offset + 1, 1))
        else
            table.insert(SVs, utils.CreateScrollVelocity(offset - 0.016, teleportSV))
            table.insert(SVs, utils.CreateScrollVelocity(offset, -teleportSV))
            table.insert(SVs, utils.CreateScrollVelocity(offset + 0.016, reverseSVSpeed))
        end
    end
    return SVs
end

-- Returns the first even integer greater than or equal to the given integer
-- Parameters
--    int : the given integer to "force" to be even
function forceEven(int)
    if (int % 2 == 1) then
        return (int + 1)
    else
        return int
    end
end

-- Restricts a number to be within a closed interval
-- Parameters
--    number     : the number to keep within the interval
--    lowerBound : the lower bound of the interval
--    upperBound : the upper bound of the interval
function mathClamp(number, lowerBound, upperBound)
    if (number < lowerBound) then
        return lowerBound
    elseif (number > upperBound) then
        return upperBound
    else
        return number
    end
end

-- Calculates "normal" bounce SVs
-- Parameters
--    offsets         : list of offsets (Table)
--    averageBounceSV : the average bounce SV speed (Float)
--    numSVsPerBounce : number of SVs to place for each bounce (Int)
--    skipEndSV       : whether or not to skip the last 1x end SV (Boolean)
function calculateNormalBounceSVs(offsets, averageBounceSV, numSVsPerBounce, skipEndSV)
    local SVs = {}
    local maxSV = 2 * averageBounceSV
    local deltaSV = maxSV / (numSVsPerBounce / 2)
    local tableOfSVValues = {}
    
    for i = 1, (numSVsPerBounce / 2), 1 do
        table.insert(tableOfSVValues, - maxSV + ((i - 1) * deltaSV))
    end
    for i = #tableOfSVValues, 1, -1 do
        table.insert(tableOfSVValues, -tableOfSVValues[i])
    end
    
    for i, currentOffset in ipairs(offsets) do
        if (i == #offsets) then
            if (not skipEndSV) then
                table.insert(SVs, utils.CreateScrollVelocity(currentOffset, 1))
            end
        else
            table.insert(SVs, utils.CreateScrollVelocity(currentOffset, BIG_SV))
            currentOffset = currentOffset + 1
            
            local nextOffset = offsets[i + 1]
            local timeInterval = nextOffset - currentOffset
            local offsetDelta = timeInterval/numSVsPerBounce
            
            for j = 1, #tableOfSVValues, 1 do
                intermediateOffset = currentOffset + (offsetDelta * (j - 1)) 
                table.insert(SVs, utils.CreateScrollVelocity(intermediateOffset, tableOfSVValues[j]))
            end
        end
    end
    return SVs
end

-- 
function mathQuadraticBezier(P, t)
    return (1-t)^2*P[1] + 2*(1-t)*t*P[2] + t^2*P[3]
end

-- Rounds a number to the n-th decimal place
-- Parameters
--    x : number to round
--    n : n-th decimal place to round the number to
function mathRound(x, n)
    return tonumber(string.format("%." .. (n or 0) .. "f", x))
end

--WIP
function calculateSharpBounceSVs(offsets, averageBounceSV, numSVsPerBounce)
    local SVs = {}
    for i, offset in ipairs(offsets) do
        if (i == 0) then
        end
    end
    return SVs
end

--WIP
function calculateStackedBounceSVs(offsets, averageBounceSV, numSVsPerBounce)
    local SVs = {}
    for i, offset in ipairs(offsets) do
        if (i == 0) then
          
        end
    end
    return SVs
end

-- Makes a section to give instructions on how to insert SVs with the plugin
function giveInstructions()
    section("note", true)
    imgui.Text("Select at least 2 notes that start at different times")
end
---------------------------------------------------------------------------------------------------
-- GUI elements
---------------------------------------------------------------------------------------------------

-- Configures GUI colors and visual settings
function applyStyle()
    -- Plugin Styles
    local rounding = 0
    
    imgui.PushStyleVar( imgui_style_var.WindowPadding,      { 20, 10 } )
    imgui.PushStyleVar( imgui_style_var.FramePadding,       { 8, 6 }   )
    imgui.PushStyleVar( imgui_style_var.ItemSpacing,        {DEFAULT_WIDGET_HEIGHT/2 - 1, 4 })
    imgui.PushStyleVar( imgui_style_var.ItemInnerSpacing,   {SAMELINE_SPACING, 6 })
    imgui.PushStyleVar( imgui_style_var.ScrollbarSize,      18         )
    imgui.PushStyleVar( imgui_style_var.WindowBorderSize,   0          )
    imgui.PushStyleVar( imgui_style_var.WindowRounding,     rounding   )
    imgui.PushStyleVar( imgui_style_var.ChildRounding,      rounding   )
    imgui.PushStyleVar( imgui_style_var.FrameRounding,      rounding   )
    imgui.PushStyleVar( imgui_style_var.ScrollbarRounding,  rounding   )
    imgui.PushStyleVar( imgui_style_var.TabRounding,        rounding   )
    
    -- Plugin Colors
    imgui.PushStyleColor(   imgui_col.WindowBg,                { 0.21, 0.21, 0.23, 1.00 })
    imgui.PushStyleColor(   imgui_col.FrameBg,                 { 0.13, 0.13, 0.14, 1.00 })
    imgui.PushStyleColor(   imgui_col.FrameBgHovered,          { 0.16, 0.16, 0.18, 1.00 })
    imgui.PushStyleColor(   imgui_col.FrameBgActive,           { 0.13, 0.13, 0.14, 1.00 })
    imgui.PushStyleColor(   imgui_col.TitleBg,                 { 0.21, 0.21, 0.23, 1.00 })
    imgui.PushStyleColor(   imgui_col.TitleBgActive,           { 0.45, 0.46, 0.47, 1.00 })
    imgui.PushStyleColor(   imgui_col.TitleBgCollapsed,        { 0.45, 0.46, 0.47, 1.00 })
    imgui.PushStyleColor(   imgui_col.ScrollbarGrab,           { 0.44, 0.44, 0.44, 1.00 })
    imgui.PushStyleColor(   imgui_col.ScrollbarGrabHovered,    { 0.75, 0.73, 0.73, 1.00 })
    imgui.PushStyleColor(   imgui_col.ScrollbarGrabActive,     { 0.99, 0.99, 0.99, 1.00 })
    imgui.PushStyleColor(   imgui_col.CheckMark,               { 1.00, 1.00, 1.00, 1.00 })
    imgui.PushStyleColor(   imgui_col.Button,                  { 0.45, 0.46, 0.47, 1.00 })
    imgui.PushStyleColor(   imgui_col.ButtonHovered,           { 0.55, 0.56, 0.57, 1.00 })
    imgui.PushStyleColor(   imgui_col.ButtonActive,            { 0.70, 0.71, 0.72, 1.00 })
    imgui.PushStyleColor(   imgui_col.Tab,                     { 0.40, 0.41, 0.42, 1.00 })
    imgui.PushStyleColor(   imgui_col.TabHovered,              { 0.60, 0.61, 0.62, 0.80 })
    imgui.PushStyleColor(   imgui_col.TabActive,               { 0.70, 0.71, 0.72, 0.80 })
    imgui.PushStyleColor(   imgui_col.SliderGrab,              { 0.55, 0.56, 0.57, 1.00 })
    imgui.PushStyleColor(   imgui_col.SliderGrabActive,        { 0.45, 0.46, 0.47, 1.00 })
end

-- Adds vertical blank space on the GUI
function spacing()
    imgui.Dummy({0,5})
end

-- Adds a thin horizontal line separator on the GUI
function separator()
    spacing()
    imgui.Separator()
end

-- Creates an uppercased section heading
-- Parameters 
--    title         : title of the section/heading (String)
--    skipSeparator : whether or not to skip the horizontal separator above the heading (Boolean)
function section(title, skipSeparator)
    if not skipSeparator then
        spacing()
        imgui.Separator()
    end
    spacing()
    imgui.Text(string.upper(title))
    spacing()
end

-- Shows a pop-up box with information when the user's cursor hovers over a specific item
-- Parameters
--    text : information that will appear in the pop-up box (String)
function tooltip(text)
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(imgui.GetFontSize() * 25)
        imgui.Text(text)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

-- Creates a '(?)' symbol that can be hovered over to give more info about something
-- Parameters
--    text : info that will appear when the symbol is hovered over (String)
function helpMarker(text)
    imgui.SameLine()
    imgui.TextDisabled("(?)")
    tooltip(text)
end

-- Creates a box with a predefined, copy-able URL link
-- Parameters
--    url : URL link to appear in the box (String)
function linkURL(url)
    imgui.PushItemWidth(imgui.GetContentRegionAvailWidth())
    imgui.InputText("##"..url, url, #url, imgui_input_text_flags.AutoSelectAll)
    imgui.PopItemWidth()
end