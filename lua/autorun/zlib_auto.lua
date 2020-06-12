--[[
    zlib - Autorun
    Developed by Zephruz
]]

if (zlib) then return end

zlib = (zlib or {})
zlib._version = "v1.3"
zlib._debugMode = true

function zlib:ConsoleMessage(...)
    MsgC(Color(125,255,0), "[zlib] ", Color(255,255,255), ...)
    Msg("\n")

    return true
end

function zlib:DebugMessage(...)
    if !(self._debugMode) then 
        return false 
    end

    return self:ConsoleMessage("", Color(255,127,80), "[debug] ", Color(255,255,255), ...)
end

function zlib:Load()
    AddCSLuaFile("zlib/sh_init.lua")
    include("zlib/sh_init.lua")

    self:ConsoleMessage("Loaded successfully!")

    hook.Run("zlib.Loaded", self)
end
concommand.Add("zlib_reload", function() zlib:Load() end)

zlib:Load()