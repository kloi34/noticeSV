--referenced and stole a lot of iceSV code >.<
SAMELINE_SPACING = 5
DEFAULT_WIDGET_HEIGHT = 26

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
    imgui.SetNextWindowSize({400, 400})
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
        
        helpItem("Bounce SV", "Make notes look like they are jumping or bouncing")
        helpItem("Teleport SV", "Teleport notes to different parts of the screen")
        helpItem("Float SV", "Suspend notes in the middle of the screen")
        
        section("links")
        
        function listItem(text, url)
            imgui.TextWrapped(text)
            linkURL(url)
        end
        
        listItem("noticeSV Wiki", "https://github.com/kloi34/noticeSV/wiki")
        listItem("GitHub Repository", "https://github.com/kloi34/noticeSV")
        listItem("Heavily inspired by IceDynamix's iceSV", "https://github.com/IceDynamix/iceSV")
        
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
            svPerBounce = 16,
            skipEndSV = false
        }
        retrieveStateVariables(menuID, vars)
        
        _, vars.svPerBounce = imgui.InputInt("SVs per bounce", vars.svPerBounce, 4)
        vars.svPerBounce = mathClamp(vars.svPerBounce, 4, 128)
        
        spacing()
        imgui.Separator()
        spacing()
        
        if imgui.Button("Reset") then
          vars.averageSV = 1
        end
        
        imgui.SameLine(0, SAMELINE_SPACING)
        imgui.PushItemWidth(200)
        _, vars.averageSV = imgui.DragFloat("Average SV", vars.averageSV, 0.01, -100, 100, "%.2fx")
        imgui.PopItemWidth()
        _, vars.skipEndSV =  imgui.Checkbox("Skip end SV?", vars.skipEndSV)
        
        
        spacing()
        imgui.Separator()
        spacing()
        if imgui.Button("Insert SVs onto selected notes") then
          
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
