--[[
	zlib - (SV) DATA

	- Data saving methods
]]

--[[CONFIG START]]

zlib.data.mysqlInfo = {
	dbModule = "mysqloo", -- Only allows mysqloo as of now
    dbName = "database",
    dbHost = "localhost",
    dbUser = "root",
    dbPass = "password",
}

--[[CONFIG END]]

--[[
    Includes
]]
include("sv_migrations.lua")