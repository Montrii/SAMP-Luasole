-- This file is part of Console.lua (Dependencie)
-- Copyright (c) 2021, Montri <https://github.com/Montrii>
local lfs        = require 'lfs'
assert(getMoonloaderVersion() >= 026, 'dependencies.lua requires MoonLoader v.026 or greater.')

local console = {}


function console:openFile(file)
    if not console:fileExists(file) then return {} end
    lines = {}
    for line in io.lines(file) do 
      lines[#lines + 1] = line
    end
    return lines
end


function console:fileExists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

function console:getTableCharacters(table)
    local string = ""
    for k,v in pairs(table) do 
        string = string + v + "\n"
    end 
    return string.len(string)
end 

function console:checkIfTimestamp(wholeString)
    local timestampNormal = string.sub(wholeString,1,17)
    if string.find(timestampNormal, "%[.-%]") then
        -- removing first bracket 
        timestamp = string.gsub(timestampNormal, "%[", "")
        -- second bracket
        timestamp = string.gsub(timestamp, "%]", "")
        -- removing milliseconds
        timestamp = string.sub(timestamp, 1,8)
        return true, "{8C8C8C} " .. timestamp
    else 
        return false, ""
    end 
end 

function console:checkIfSpecialTag(wholeString)
    if string.find(wholeString, "(debug)") then
        newString = string.gsub(wholeString, "(debug)", "{DCB714}debug{FFFFFF}")
        return true, newString
    elseif string.find(wholeString, "(system)") then
        newString = string.gsub(wholeString, "(system)", "{00D30A}system{FFFFFF}")
        return true, newString
    elseif string.find(wholeString, "(error)") then
        newString = string.gsub(wholeString, "(error)", "{DC2014}error{FFFFFF}")
        return true, newString
    elseif string.find(wholeString, "(script)") then
        newString = string.gsub(wholeString, "(script)", "{14CDDC}script{FFFFFF}")
        return true, newString
    else 
        return false, ""
    end 
end 

function console:lines_from(file)
    if not console:fileExists(file) then return {} end
    lines = {}
    for line in io.lines(file) do 
      lines[#lines + 1] = line
    end
    return lines
  end
  
function console:findFunction(x)
    assert(type(x) == "string")
    local f=_G
    for v in x:gmatch("[^%.]+") do
      if type(f) ~= "table" then
         return nil, "looking for '"..v.."' expected table, not "..type(f)
      end
      f=f[v]
    end
    if type(f) == "function" then
      return f
    else
      return nil, "expected function, not "..type(f)
    end
end
function console:loadFunction(functionName)
    local doesCommandExist = false
    local file = console:fileExists('moonloader/consoleLoad/consoleCommands.console')
    if file then
        local lines = console:lines_from('moonloader/consoleLoad/consoleCommands.console')
        for k,v in pairs(lines) do
            if functionName == v then
                doesCommandExist = true
                local status, err = pcall(console:findFunction(v))
                if status then
                    print("Function {00D30A}successfully{FFFFFF} executed: {06B5CA}" .. v ..  "{FFFFFF}")
                else 
                    print("{DC2014}Error{FFFFFF}:\n" .. err .. "\n \t \t\t\t\t\t\t\t While trying to execute Command: {DC2014}" .. v ..  "{FFFFFF}")
                end 
                break
            end 
        end 
    end 
    if doesCommandExist == false then
        print("Function: {06B5CA}" .. functionName ..  "{FFFFFF} does {DC2014}not{FFFFFF} exist.")
    end 
end 
function console:loopMoonloaderFolder()
    local requiredNames = {}
    dir = getWorkingDirectory() .. "\\consoleLoad"
    for file in lfs.dir(dir) do
        if file ~= "." and file ~= ".." then
            local file_extension = string.match(file, "([^\\%.]+)$")
            --print ("\t "..file_extension)
            if file_extension:match("lua") and not file_extension:match("luac") then
                fileFinished = string.gsub(file, ".lua", "")
                table.insert(requiredNames, fileFinished)
            end 
        end 
    end 
    return requiredNames
end 

function scanGameFolder(path, tables)
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path..'\\'..file
            --print ("\t "..f)
			--local file3 = string.gsub(file_extension, "(.+)%..+", "Test")
			local file_extension = string.match(file, "([^\\%.]+)$") -- Avoids double "extension" file names from being included and seen as "audiofile"
            if file_extension:match("mp3") or file_extension:match("mp4") or file_extension:match("wav") or file_extension:match("m4a") or file_extension:match("flac") or file_extension:match("m4r") or file_extension:match("ogg")
			or file_extension:match("mp2") or file_extension:match("amr") or file_extension:match("wma") or file_extension:match("aac") or file_extension:match("aiff") then
				table.insert(tables, file)
                tables[file] = f
            end 
            if lfs.attributes(f, "mode") == "directory" then
                tables = scanGameFolder(f, tables)
            end 
        end
    end
    return tables
end

function console:addConsoleFunction(functionName)
    if type(functionName) ~= 'string' then
        return false, "Parameter is not a string."
    else 
        local file = console:fileExists('moonloader/consoleLoad/consoleCommands.console')
        if file then
            local lines = console:lines_from('moonloader/consoleLoad/consoleCommands.console')-- loading current file and saving each command
            local file = io.open('moonloader/consoleLoad/consoleCommands.console', 'w') -- Writing new Command to file with the rest of the content
            for k,v in pairs(lines) do
                file:write(v .. '\n')
            end 
            file:write(functionName .. '\n')
            file:close()
        end 
    end 
    print("Command:{0FCA06} " .. functionName .. "{FFFFFF} successfully added to the Commandstorage.")
    return true, "Successfully added to consoleCommands.console"
end 







return console


