-- MAX_TELEPORT_VALUE = 24000


--referenced and stole a lot of iceSV code >.<

function draw()
   applyStyle()
   svMenu()
end

function applyStyle()
    --Plugin Styles
    
     local rounding = 0
     
    imgui.PushStyleVar( imgui_style_var.WindowPadding,      { 20, 10 } )
    imgui.PushStyleVar(imgui_style_var.FramePadding,        { 8, 6 }   )
    --imgui.PushStyleVar( imgui_style_var.ItemSpacing,        { style.DEFAULT_WIDGET_HEIGHT/2 - 1,  4 } )
    --imgui.PushStyleVar( imgui_style_var.ItemInnerSpacing,   { style.SAMELINE_SPACING, 6 } )
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
    imgui.Begin("noticeSV")
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

function get(identifier, defaultValue)
    return state.GetValue(identifier) or defaultValue
end

function info()
    if imgui.BeginTabItem("Info") then
        spacing()
        imgui.Text("noticeSV version 1.0.0")
        imgui.Text("by kloi34 (pepega clap)")
        section("help")
        function helpItem(item, text)
            imgui.BulletText(item)
            helpMarker(text)
        end
        helpItem("bounce", "note bounces of hit area")
        helpItem("teleport", "teleports notes around the screen")
        helpItem("floating", "notes are 'frozen' or suspended in the playing field")
        section("links")
        
        function listItem(text, url)
            imgui.TextWrapped(text)
            linkURL(url)
        end
        
        listItem("noticeSV wiki", "noticeSV URL")
        listItem("noticeSV", "noticeSV URL")
        listItem("Heavily inspired by IceDynamix's iceSV", "https://github.com/IceDynamix/iceSV")
        
  imgui.endTabItem()
  end
end

function bounce()
    if imgui.BeginTabItem("Bounce") then
        imgui.Text("bounce tab")
    
        local myInt = get("myInt", 0)
        _, myNextInt = imgui.InputInt("My label here", myInt)
        state.SetValue("myInt", myNextInt)
        
        imgui.endTabItem()
    end
end

function teleport()
    if imgui.BeginTabItem("Teleport") then
        imgui.Text("teleport tab")
        
        local myIntSlider = get("myIntSlider", 0)
        _, myNextIntSlider = imgui.SliderInt("Test Slider", myIntSlider, -3, 3)
        state.SetValue("myIntSlider", myNextIntSlider)
        
        local averageSV = get("averageSV", 0)
        _, newAverageSV = imgui.DragFloat("Average SV", averageSV, 0.01, -100, 100, "%.2fx")
        state.SetValue("averageSV", newAverageSV)
        
        local myCheckbox = get("myCheckbox", false)
        _, newCheckbox = imgui.Checkbox("Check my box", myCheckbox)
        state.SetValue("myCheckbox", newCheckbox)
        
        imgui.endTabItem()
    end
end

function floating()
    if imgui.BeginTabItem("Floating") then
        imgui.Text("floating tab")
        imgui.endTabItem()
    end
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