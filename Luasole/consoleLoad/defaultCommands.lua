-- defaultCommands for Console.lua



local lfs = require "lfs"
local ffi = require "ffi"
ffi.cdef[[
    struct stServerPresets
    {
        uint8_t     byteCJWalk;
        int         m_iDeathDropMoney;
        float        fWorldBoundaries[4];
        bool        m_bAllowWeapons;
        float        fGravity;
        uint8_t     byteDisableInteriorEnterExits;
        uint32_t    ulVehicleFriendlyFire;
        bool        m_byteHoldTime;
        bool        m_bInstagib;
        bool        m_bZoneNames;
        bool        m_byteFriendlyFire;
        int            iClassesAvailable;
        float        fNameTagsDistance;
        bool        m_bManualVehicleEngineAndLight;
        uint8_t     byteWorldTime_Hour;
        uint8_t     byteWorldTime_Minute;
        uint8_t     byteWeather;
        uint8_t     byteNoNametagsBehindWalls;
        int         iPlayerMarkersMode;
        float        fGlobalChatRadiusLimit;
        uint8_t     byteShowNameTags;
        bool        m_bLimitGlobalChatRadius;
    }__attribute__ ((packed));
]]


-- main Function Syntax for Modules:
-- main + fileName
function maindefaultCommands() 
    -- let main function do whatever you like
end 



-- Local functions will not be detected and loaded by Console.lua
local function calculateSize(size)
    local bytes = ""
    if tonumber(#tostring(size)) >= 10 and tonumber(#tostring(size)) < 13 then -- Gigabyte
        bytes = size/1000000000 .. " GB"
    elseif tonumber(#tostring(size)) >= 7 and tonumber(#tostring(size)) < 10 then -- Mega Byte
        bytes = size/1000000 .. " MB"
    elseif tonumber(#tostring(size)) >= 4 and tonumber(#tostring(size)) < 7 then -- Kilobyte
        bytes = size/1000 .. " kB"
    elseif tonumber(#tostring(size)) >= 1 and tonumber(#tostring(size)) < 4 then -- Bytes
        bytes = size/1 .. " Bytes"
    end 
    return tostring(bytes)
end 

local function fileExists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

local function lines_from(file)
    if not fileExists(file) then return {} end
    lines = {}
    for line in io.lines(file) do 
      lines[#lines + 1] = line
    end
    return lines
end

local function translateUnit8_TToBoolean(number)
    if number > 0 then
        return "true" 
    else 
        return "false"
    end 
end 



-- Command: filesize
function filesize()
    print("Console file size: " ..  calculateSize(lfs.attributes('moonloader/moonloader.log', "size")))
end 

function listCommands()
    local commands = ""
    local lines = lines_from('moonloader/consoleLoad/consoleCommands.console')
    for k,v in pairs(lines) do
        commands = commands .. v .. ", "
    end 
    print("Current commands: " .. commands)
end 

function serverStats()
    ip, port = sampGetCurrentServerAddress()
    server = ffi.cast('struct stServerPresets*', sampGetServerSettingsPtr())
    print("\n\t\t\t\t\t Server name:{B3B3B3} " .. sampGetCurrentServerName() .. "{FFFFFF}\n\t\t\t\t\t Server IP:{B3B3B3} " .. ip .. "{FFFFFF}\n\t\t\t\t\t Port:{B3B3B3} " .. port .. "{FFFFFF} " .. 
    "\n\t\t\t\t\t Nametags visible:{B3B3B3} " .. translateUnit8_TToBoolean(server.byteShowNameTags) .. "{FFFFFF}\n\t\t\t\t\t CJ Walk:{B3B3B3} " .. translateUnit8_TToBoolean(server.byteCJWalk) .. 
    "{FFFFFF}\n\t\t\t\t\t Playermarker's visible:{B3B3B3} " .. server.iPlayerMarkersMode .. "{FFFFFF}")
end 




