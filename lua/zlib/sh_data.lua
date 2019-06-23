--[[
    zlib - (SH) Data
    Developed by Zephruz
]]

zlib.data = (zlib.data or {})
zlib.data.types = (zlib.data.types or {})
zlib.data._connections = (zlib.data._connections or {})

--[[
	zlib.data:RegisterType(name [string], data [table])

	- Registers a data type
]]
function zlib.data:RegisterType(name, data)
	self.types[name] = data

	zlib.object:SetMetatable("zlib.DataMeta", self.types[name])

	return self.types[name]
end

--[[
	zlib.data:LoadType(name [, config])

	- Returns a new data type
]]
function zlib.data:LoadType(name, config)
	local dmeta = self.types[name]

	if !(dmeta) then
		zlib:ConsoleMessage(Color(255,125,0), "Invalid data type '" .. name .. "'!")

		return
	end

	local dmtbl = {}
	
	setmetatable(dmtbl, {__index = table.Copy(dmeta)})

	dmtbl:SetName(name or defType)
	dmtbl:SetConfig(config or {})

	return dmtbl
end

--[[
	zlib.data:GetMetaTable()

	- Returns the data metatable
]]
function zlib.data:GetMetaTable()
	return (table.Copy(zlib.object:Get("zlib.DataMeta") or self._metatable) || nil)
end

--[[
	zlib.data:GetConnection(id [string])
]]
function zlib.data:GetConnection(id)
	return self._connections[id]
end

--[[
	zlib.data:SetupConnection(id [string], dtype [data type meta])
]]
function zlib.data:SetupConnection(id, dtype)
	self._connections[id] = dtype

	return self._connections[id]
end

--[[
	Data Metastructure
]]
local dataMeta, dataMetaID = zlib.object:Create("zlib.DataMeta")

dataMeta:setData("Name", "NO.DATATYPE.NAME")
dataMeta:setData("Config", {})
dataMeta:setData("IsLoaded", false)

function dataMeta:EscapeString(string)
	local escape = (self.escapeStr or self.escape or
		function(str)
			return sql.SQLStr(tostring(str))
		end)

	return escape(string)
end

function dataMeta:Connect(sucCb, errCb)
	if (self.connect) then
		self:connect(
		function(...)
			if (sucCb) then sucCb(...) end
		end, 
		function(...)
			if (errCb) then errCb(...) end

			zlib:ConsoleMessage("Failed to connect database: " .. zlib.util:ConcatTable({...}, ", "))
		end)
	end
end

function dataMeta:Query(query, sucCb, errCb)
	if (self.query) then
		return self:query(query, sucCb, errCb)
	end
end

zlib.data._metatable = dataMeta

--[[
    Includes
]]
if (SERVER) then include("data/sv_data.lua") end

--[[Load Data Types]]
local files, dirs = file.Find("zlib/data/types/*", "LUA")

for k,v in pairs(files) do
    zlib.util:IncludeByPath(v, "data/types/")
end