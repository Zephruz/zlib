--[[
    zlib - Autorun
    Developed by Zephruz
]]

zlib = (zlib or {})
zlib._version = "V1.1"

function zlib:ConsoleMessage(...)
    MsgC(Color(125,255,0), "[zlib] ", Color(255,255,255), ...)
    Msg("\n")
end

function zlib:Load()
    hook.Run("zlib.Loaded", self)
end

AddCSLuaFile("zlib/sh_init.lua")
include("zlib/sh_init.lua")