--referenced and stole/modified a lot of iceSV code >.<
SAMELINE_SPACING = 5
DEFAULT_WIDGET_HEIGHT = 26
DEFAULT_WIDGET_WIDTH = 200
BUTTON_WIDGET_RATIOS = { 0.3, 0.7 }

function draw()
   applyStyle()
   svMenu()
end

function applyStyle()
    --Plugin Styles
    
     local rounding = 0
     
     imgui.PushStyleVar( imgui_style_var.WindowPadding,      { 20, 10 } )
     imgui.PushStyleVar( imgui_style_var.FramePadding,       { 8, 6 }   )
     imgui.PushStyleVar( imgui_style_var.ItemSpacing,        {DEFAULT_WIDGET_HEIGHT/2 - 1,  4 } )
     imgui.PushStyleVar( imgui_style_var.ItemInnerSpacing,   {SAMELINE_SPACING, 6 } )
     imgui.PushStyleVar( imgui_style_var.ScrollbarSize,      18         )
     imgui.PushStyleVar( imgui_style_var.WindowBorderSize,   0          )
     imgui.PushStyleVar( imgui_style_var.WindowRounding,     rounding   )
     imgui.PushStyleVar( imgui_style_var.ChildRounding,      rounding   )
     imgui.PushStyleVar( imgui_style_var.FrameRounding,      rounding   )
     imgui.PushStyleVar( imgui_style_var.ScrollbarRounding,  rounding   )
     imgui.PushStyleVar( imgui_style_var.TabRounding,        rounding   )
    
     --Plugin Colors
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

function svMenu()
    imgui.SetNextWindowSize({330, 400})
    imgui.Begin("noticeSV", imgui_window_flags.NoResize)
    imgui.BeginTabBar("function_selection")
    info()
    bounce()
    teleport()
    floating()
    imgui.EndTabBar()
    -- the line below is needed, as IceDynamix notes, in order for clicking and scrolling done on the plugin window
    -- to not also do unintential things in the quaver editor
    state.IsWindowHovered = imgui.IsWindowHovered()
    imgui.End()
end

-- Information Tab that provides an overview with general information about the plugin
function info()
    if imgui.BeginTabItem("Info") then
        section("help", true)
        
        function helpItem(item, text)
            imgui.BulletText(item)
            helpMarker(text)
        end
        
        helpItem("Bounce SV", "Makes a note look like it is jumping or bouncing")
        helpItem("Teleport SV", "Teleports a note to a different part of the screen")
        helpItem("Float SV", "Suspend notes in the middle of the screen")
        
        section("links")
        
        function listItem(text, url)
            imgui.TextWrapped(text)
            linkURL(url)
        end
        
        listItem("noticeSV Wiki", "https://github.com/kloi34/noticeSV/wiki")
        listItem("GitHub Repository", "https://github.com/kloi34/noticeSV")
        listItem("Heavily inspired by IceDynamix's iceSV plugin", "https://github.com/IceDynamix/iceSV")
        
        separator()
        spacing()
        imgui.Text("noticeSV v1.0.0")
        imgui.endTabItem()
    end
end

function bounce()
    if imgui.BeginTabItem("Bounce") then
        section("Settings", true)
        
        local menuID = "bounce"
        local vars = {
            averageSV = 1.0,
            lastSVs = {},
            svPerBounce = 32,
            skipEndSV = false,
        }
        retrieveStateVariables(menuID, vars)
        
        imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH)
        _, vars.svPerBounce = imgui.InputInt("  SVs per bounce", vars.svPerBounce, 4)
        vars.svPerBounce = mathEvenNum(vars.svPerBounce)
        vars.svPerBounce = mathClamp(vars.svPerBounce, 16, 256)
        
        imgui.PopItemWidth()
        
        if imgui.Button("Reset", {DEFAULT_WIDGET_WIDTH * BUTTON_WIDGET_RATIOS[1], DEFAULT_WIDGET_HEIGHT}) then
            vars.averageSV = 1
        end
        
        imgui.SameLine(0, SAMELINE_SPACING)
        imgui.PushItemWidth(DEFAULT_WIDGET_WIDTH * BUTTON_WIDGET_RATIOS[2] - SAMELINE_SPACING)
        _, vars.averageSV = imgui.DragFloat("  Average SV", vars.averageSV, 0.01, -100, 100, "%.2fx")
        imgui.PopItemWidth()
        _, vars.skipEndSV =  imgui.Checkbox(" Skip end SV?", vars.skipEndSV)
        
        
        spacing()
        imgui.Separator()
        spacing()
        
        if insertButton() then
            local offsets = {}
            for i, hitObject in pairs(state.SelectedHitObjects) do
                offsets[i] = hitObject.StartTime
            end
            --if (#offsets == 0) then
            --    imgui.Text("#offsets == 1")
            --elseif (#offsets == 1) then
            --    imgui.Text("#offsets == 1")
            --else
                offsets = uniqueByTime(offsets)
                vars.lastSVs = calculateBounceSV(table.sort(offsets), averageSV, svPerBounce, skipEndSV)
                placesvs(vars.lastSVs)
            --end
        end
        
        saveStateVariables(menuID, vars)
        imgui.endTabItem()
    end
end

function teleport()
    if imgui.BeginTabItem("Teleport") then
        imgui.Text("teleport tab")
        imgui.endTabItem()
    end
end

function floating()
    if imgui.BeginTabItem("Floating") then
        imgui.Text("floating tab")
        imgui.endTabItem()
    end
end

--function reverse scroll direction

function retrieveStateVariables(menuID, variables)
    for key, value in pairs(variables) do
        variables[key] = state.GetValue(menuID..key) or value
    end
end

function saveStateVariables(menuID, variables)
    for key, value in pairs(variables) do
        state.SetValue(menuID..key, value)
    end
end

function mathClamp(x, min, max)
    if x < min then x = min end
    if x > max then x = max end
    return x
end

function mathEvenNum(number)
  if (number % 2 == 0) then
      return number
  else
      return (number - 1)
  end
end

function insertButton()
    imgui.Button("Insert SVs", { DEFAULT_WIDGET_WIDTH, DEFAULT_WIDGET_HEIGHT })
end

function calculateBounceSV(offsets, averageSV, svPerBounce, skipEndSV)
    local SVs = {}
    local lastOffsetEnd
    
    for i, offset in ipairs(offsets) do
        if (i == #offsets) then 
            lastOffsetEnd = offset
        break end
        
        linearSVs = calculateLinearSVs(offset, offsets[i+1], averageSV, svPerBounce)
        table.insert(linearSVs, utils.CreateScrollVelocity(offset, averageSV))
    end
    
    if (skipEndSV == false) then
        table.insert(SVs, utils.CreateScrollVelocity(lastOffsetEnd, averageSV))
    end
    
    return SVs
end

function uniqueByTime(offsets)
    local hash = {}
    local uniqueTimes = {}
    
    for _, value in ipairs(offsets) do
        if (not hash[value]) then
            uniqueTimes[#uniqueTimes + 1] = value
            hash[value] = true
        end
    end
    return uniqueTimes
end

function calculateLinearSVs(startOffset, endOffset, averageSV, svPerBounce)
    local offsetInterval = endOffset - startOffset
    local maxSV = averageSV * 2
    local svIncrement = (maxSV * 2) / svPerBounce
    local steps = svPerBounce / 2
    local svValues = {}
    local SVs = {}
    
    for step = 1, steps, 1 do
        svValues[step] = - maxSV * (steps - step + 1) / steps
    end
    
    for step = steps, 1, -1 do
        svValues[(2*steps+1)-step] = -svValues[step]
    end
    
    for step = 0, svPerBounce - 1, 1 do
        local offset = startOffset + step * (offsetInterval/ svPerBounce)
        SVs[step+1] = utils.CreateScrollVelocity(offset, svValues[step+1])
    end
    return SVs
end

function placeSVs(svs)
    actions.PlaceScrollVelocityBatch(svs)
end

-------------------------------------------------------------------------------------
-- GUI
-------------------------------------------------------------------------------------

function helpMarker(text)
    imgui.SameLine()
    imgui.TextDisabled("(?)")
    tooltip(text)
end

function tooltip(text)
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(imgui.GetFontSize() * 25)
        imgui.Text(text)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function separator()
    spacing()
    imgui.Separator()
end

function spacing()
    imgui.Dummy({0,5})
end
  
function section(title, skipSeparator, helpMarkerText)
    if not skipSeparator then
        spacing()
        imgui.Separator()
    end
    spacing()
    imgui.Text(string.upper(title))
    if helpMarkerText then
        helpMarker(helpMarkerText)
    end
    spacing()
end

function linkURL(url)
    imgui.PushItemWidth(imgui.GetContentRegionAvailWidth())
    imgui.InputText("##"..url, url, #url, imgui_input_text_flags.AutoSelectAll)
    imgui.PopItemWidth()
end
