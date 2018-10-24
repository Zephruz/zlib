--[[
    zlib - (SH) Init
    Developed by Zephruz
]]

--[[Load zlib Base]]
AddCSLuaFile("sh_util.lua")
AddCSLuaFile("sh_includes.lua")
AddCSLuaFile("sh_object.lua")
AddCSLuaFile("sh_data.lua")
AddCSLuaFile("sh_cmds.lua")
AddCSLuaFile("networking/sh_networking.lua")

include("sh_util.lua")
include("sh_includes.lua")
include("sh_object.lua")
include("sh_data.lua")
include("sh_cmds.lua")
include("networking/sh_networking.lua")

zlib:Load()