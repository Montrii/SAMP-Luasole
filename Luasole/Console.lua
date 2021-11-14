script_name("Console")
script_author("Montri")
script_version("1.0.0")
script_description("This script allows you to receive close insight on your moonloader process. It does not require SAMPFUNCS.")


-- Console Dependencies
local console = require "montri/console/dependencies"
local requiredScripts = console:loopMoonloaderFolder()


-- Loading console Modules
function initializeRequires()
    mainFunctions = {}
    functions = {}
    names = {}
    for k,v in pairs(requiredScripts) do
        string = "./consoleLoad/" .. v
        fileName = v
        if string ~= "./consoleLoad/Console" and string ~= "./consoleLoad/others" then
            local status, err = pcall(require, string)
            if status then
                print("Module {00D30A}successfully{FFFFFF} loaded: {06B5CA}" .. string .. "{FFFFFF}")
                local lines = console:lines_from(getWorkingDirectory() .. "\\consoleLoad\\" .. v .. ".lua")
                for k,v in pairs(lines) do
                    start, finish, text = v:find("function (%a+)%(%)")
    
                    if text ~= nil then -- Every function from each module
                        table.insert(names, string)
                        if text == "main"..fileName then -- Main Function detected
                            table.insert(mainFunctions, text)
                        else
                            console:addConsoleFunction(text)
                        end 
                    end 
                end
            else 
                print("{DC2014}Error{FFFFFF}:\n" .. err .. "\n \t \t\t\t\t\t\t\t While trying to load:: {DC2014}" .. string .. ".lua " ..  "{FFFFFF}")
            end 
        end 
    end 
    for k, v in pairs(mainFunctions) do
        local status, err = pcall(_G[v])
        if status == true then
            print("Main function {00D30A}successfully{FFFFFF} executed from Module: {06B5CA}" .. names[k] .. ".lua " ..  "{FFFFFF}")
        else
            print("{DC2014}Error{FFFFFF}:\n" .. err .. "\n \t \t\t\t\t\t\t\t While trying to execute from: {DC2014}" .. names[k] .. ".lua " ..  "{FFFFFF}")
        end 
    end 
end 
initializeRequires()





-- Imports 
local imgui = require "imgui"
local fa         = require 'fAwesome5'
local ec = require "encoding"
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
local memory = require 'memory'
local ffi = require 'ffi'
local lfs = require "lfs"

-- Variables
local fsFont = nil
local main_window_state = imgui.ImBool(false)
ec.default = 'CP1251'
u8 = ec.UTF8
local selected_item = imgui.ImInt(2)
local inputCommand = imgui.ImBuffer(300)
local length = 0
local moonloaderLog = {}
commands = {}

-- Functions
function imgui.BeforeDrawFrame()
	if fa_font == nil then
		local font_config = imgui.ImFontConfig()
		font_config.MergeMode = true
		fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 13.0, font_config, fa_glyph_ranges)
	end
    if fsFont == nil then
        fsFont = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 25.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
end


function imgui.OnDrawFrame()
    if main_window_state.v then
        if not sampIsCursorActive() and openChat == true then sampToggleCursor(true) end
        local sw, sh = getScreenResolution() -- Get Screenresolution to make perfect results.
        moonloaderLog = console:openFile("moonloader/moonloader.log")
        length = tablelength(moonloaderLog)
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(920, 460))
		imgui.Begin("LUA Console", main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
        imgui.CaptureMouseFromApp(openChat)
        imgui.BeginChild('##content', imgui.ImVec2(0, 400), false)
            local clipper = imgui.ImGuiListClipper(length)
            while clipper:Step() do
                for i = clipper.DisplayStart + 1, clipper.DisplayEnd do
                    -- Managing new Timestamps
                    result, string, timestampNormal = console:checkIfTimestamp(moonloaderLog[i])
                    if result then
                        string = string.gsub(moonloaderLog[i], "%[.-%]", string .. " ->{FFFFFF}") 
                        result, specialTag = console:checkIfSpecialTag(string)
                        if result then
                            imgui.TextColoredRGB(specialTag,i)
                        else 
                            imgui.TextColoredRGB(string,i)
                        end 
                    else 
                        imgui.TextColoredRGB(moonloaderLog[i],i)
                    end 
                end
            end
        imgui.EndChild()
        imgui.PushItemWidth(820)
		imgui.InputText("##inputtext", inputCommand)
        imgui.PopItemWidth()
        imgui.SameLine(0)
        if imgui.Button("Send", imgui.ImVec2(0, 20)) then
            -- looping through each command
            console:loadFunction(inputCommand.v)
        end 
        imgui.End()
    end 
end 


function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
  end

function main()
    while true do
        wait(0)
        if testCheat("console") then
            main_window_state.v = not main_window_state.v
            if main_window_state.v == true then 
                openChat = true
            else 
                openChat = false
                main_window_state.v = false
            end 
        end 
        imgui.Process = main_window_state.v
    end 
end 




function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

function testFunction()
    print("testfunction executed")
end 





function imgui.CenterTextColoredRGB(text)
    local width = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local textsize = w:gsub('{.-}', '')
            local text_width = imgui.CalcTextSize(u8(textsize))
            imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else
                imgui.Text(u8(w))
            end
        end
    end
    render_text(text)
end

function imgui.TextColoredRGB(text, id)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local col = imgui.Col
	
	local designText = function(text__)
		local pos = imgui.GetCursorPos()
		if sampGetChatDisplayMode() == 2 then
			for i = 1, 1 --[[������� ����]] do
				imgui.SetCursorPos(imgui.ImVec2(pos.x + i, pos.y))
				imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
				imgui.SetCursorPos(imgui.ImVec2(pos.x - i, pos.y))
				imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
				imgui.SetCursorPos(imgui.ImVec2(pos.x, pos.y + i))
				imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
				imgui.SetCursorPos(imgui.ImVec2(pos.x, pos.y - i))
				imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
			end
		end
		imgui.SetCursorPos(pos)
	end
	
	if openChat and id > 0 then
		imgui.Selectable('##'..id)
		imgui.SameLine(0)
		if imgui.BeginPopupContextItem() then
			if imgui.Button(u8'Copy to clipboard') then
                setClipboardText(moonloaderLog[id])
                imgui.CloseCurrentPopup()
            end 
			imgui.EndPopup()
		end
	end
	
	local text = text:gsub('{(%x%x%x%x%x%x)}', '{%1FF}')

	local color = colors[col.Text]
	local start = 1
	local a, b = text:find('{........}', start)	
	
	while a do
		local t = text:sub(start, a - 1)
		if #t > 0 then
			designText(t)
			imgui.TextColored(color, t)
			imgui.SameLine(nil, 0)
		end

		local clr = text:sub(a + 1, b - 1)
		if clr:upper() == 'STANDART' then color = colors[col.Text]
		else
			clr = tonumber(clr, 16)
			if clr then
				local r = bit.band(bit.rshift(clr, 24), 0xFF)
				local g = bit.band(bit.rshift(clr, 16), 0xFF)
				local b = bit.band(bit.rshift(clr, 8), 0xFF)
				local a = bit.band(clr, 0xFF)
				color = imgui.ImVec4(r / 255, g / 255, b / 255, a / 255)
			end
		end

		start = b + 1
		a, b = text:find('{........}', start)
	end
	imgui.NewLine()
	if #text >= start then
		imgui.SameLine(nil, 0)
		designText(text:sub(start))
		imgui.TextColored(color, text:sub(start))
	end
end

function imgui.Hint(text, delay)
    if imgui.IsItemHovered() then
        if go_hint == nil then go_hint = os.clock() + (delay and delay or 0.0) end
        local alpha = (os.clock() - go_hint) * 5 --spawn rate
        if os.clock() >= go_hint then 
            imgui.PushStyleVar(imgui.StyleVar.Alpha, (alpha <= 1.0 and alpha or 1.0))
                imgui.PushStyleColor(imgui.Col.PopupBg, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
                    imgui.BeginTooltip()
                    imgui.PushTextWrapPos(450)
                    imgui.TextUnformatted(text)
                    if not imgui.IsItemVisible() and imgui.GetStyle().Alpha == 1.0 then go_hint = nil end
                    imgui.PopTextWrapPos()
                    imgui.EndTooltip()
                imgui.PopStyleColor()
            imgui.PopStyleVar()
        end
    end
end



function style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2

   	style.WindowPadding 		= imgui.ImVec2(8, 8)
    style.WindowRounding 		= 6
    style.ChildWindowRounding 	= 5
    style.FramePadding 			= imgui.ImVec2(5, 3)
    style.FrameRounding 		= 3.0
    style.ItemSpacing 			= imgui.ImVec2(5, 4)
    style.ItemInnerSpacing 		= imgui.ImVec2(4, 4)
    style.IndentSpacing 		= 21
    style.ScrollbarSize 		= 10.0
    style.ScrollbarRounding 	= 13
    style.GrabMinSize 			= 8
    style.GrabRounding			= 1
    style.WindowTitleAlign 		= imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign 		= imgui.ImVec2(0.5, 0.5)

    colors[clr.Text]                                = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]                        = ImVec4(0.30, 0.30, 0.30, 1.00)
    colors[clr.WindowBg]                            = ImVec4(0.09, 0.09, 0.09, 1.00)
    colors[clr.ChildWindowBg]                       = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                             = ImVec4(0.05, 0.05, 0.05, 1.00)
    colors[clr.ComboBg]                             = ImVec4(0.00, 0.53, 0.76, 1.00)
    colors[clr.Border]                              = ImVec4(0.43, 0.43, 0.50, 0.10)
    colors[clr.BorderShadow]                        = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]                             = ImVec4(0.30, 0.30, 0.30, 0.10)
    colors[clr.FrameBgHovered]                      = ImVec4(0.00, 0.53, 0.76, 0.30)
    colors[clr.FrameBgActive]                       = ImVec4(0.00, 0.53, 0.76, 0.80)
    colors[clr.TitleBg]                             = ImVec4(0.13, 0.13, 0.13, 0.99)
    colors[clr.TitleBgActive]                       = ImVec4(0.13, 0.13, 0.13, 0.99)
    colors[clr.TitleBgCollapsed]                    = ImVec4(0.05, 0.05, 0.05, 0.79)
    colors[clr.MenuBarBg]                           = ImVec4(0.13, 0.13, 0.13, 0.99)
    colors[clr.ScrollbarBg]                         = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]                       = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]                = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]                 = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CheckMark]                           = ImVec4(0.00, 0.53, 0.76, 1.00)
    colors[clr.SliderGrab]                          = ImVec4(0.28, 0.28, 0.28, 1.00)
    colors[clr.SliderGrabActive]                    = ImVec4(0.00, 0.53, 0.76, 1.00)
    colors[clr.Button]                              = ImVec4(0.26, 0.26, 0.26, 0.30)
    colors[clr.ButtonHovered]                       = ImVec4(0.00, 0.53, 0.76, 1.00)
    colors[clr.ButtonActive]                        = ImVec4(0.00, 0.43, 0.76, 1.00)
    colors[clr.Header]                              = ImVec4(0.12, 0.12, 0.12, 0.94)
    colors[clr.HeaderHovered]                       = ImVec4(0.34, 0.34, 0.35, 0.89)
    colors[clr.HeaderActive]                        = ImVec4(0.12, 0.12, 0.12, 0.94)
    colors[clr.Separator]                           = ImVec4(0.30, 0.30, 0.30, 1.00)
    colors[clr.SeparatorHovered]                    = ImVec4(0.26, 0.59, 0.98, 0.78)
    colors[clr.SeparatorActive]                     = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip]                          = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered]                   = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive]                    = ImVec4(0.26, 0.59, 0.98, 0.95)
    colors[clr.CloseButton]                         = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]                  = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]                   = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]                           = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]                    = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]                       = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]                = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg]                      = ImVec4(0.00, 0.43, 0.76, 1.00)
    colors[clr.ModalWindowDarkening]                = ImVec4(0.20, 0.20, 0.20,  0.0)
end
style()
