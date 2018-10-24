--[[
	zlib - (SH) Cache

	- Cache handling (creation, deletion, fetching, etc.)
]]

zlib.cache = (zlib.cache or {})
zlib.cache._caches = (zlib.cache._caches or {})

--[[
	zlib.cache:Load()
]]
function zlib.cache:Load()
	return self:GetAll()
end

--[[
	zlib.cache:GetMetaTable()

	- Returns a copy of the cache metatable
]]
function zlib.cache:GetMetaTable()
	return table.Copy(zlib.object:Get("zlib.CacheMeta") or self._metatable or {})
end

--[[
	zlib.cache:GetAll()

	- Returns the entire table of caches
]]
function zlib.cache:GetAll()
	return self._caches
end

--[[
	zlib.cache:Register(name [string], data [table] (OPTIONAL))

	- Registers a cache
]]
function zlib.cache:Register(name, data)
	if !(name) then return end

	local prevCache = self:Get(name)
	local prevEntries = (prevCache && !prevCache:GetClearOnReload() && prevCache:GetEntries())

	-- Register cache
	self._caches[name] = {}

	setmetatable(self._caches[name], self:GetMetaTable())

	if (data) then
		for k,v in pairs(data) do
			self._caches[name]:setData(k,v)
		end
	end

	self._caches[name]:SetName(name)
	self._caches[name]:SetEntries(prevEntries or {})

	return self._caches[name]
end

--[[
	zlib.cache:Get(name [string], ...)

	- Accepts single/multiple cache names
	- Returns the cache(s) in a table UNLESS there is only one cache requested
]]
function zlib.cache:Get(...)
	local args, results = {...}, {}

	if (#args == 1) then
		local cName = args[1]

		results = (cName && self._caches[cName] || false)
	else
		for k,v in pairs(args) do
			if (self._caches[v]) then
				results[v] = self._caches[v]
			end
		end
	end

	return results
end

--[[
	Character Metastructure
]]
local fCacheMeta, fCacheMetaID = zlib.object:Create("zlib.CacheMeta")

zlib.cache._metatable = fCacheMeta

local cacheMeta = zlib.cache._metatable

function cacheMeta:__tostring()
	local cName, cEntries = (self:getData("Name") || nil), (self:getData("Entries") || {})

	return ("cache[" .. (cName || "NIL") .. "] (Total entries/values: " .. (table.Count(cEntries) || 0) .. ")")
end

function cacheMeta:__eq(c1, c2)
	local c1Name = (c1 && c1.getData && c1:getData("Name") || nil)
	local c2Name = (c2 && c2.getData && c2:getData("Name") || nil)

	return (c1Name && c2Name && c1Name == c2Name)
end

function cacheMeta:__concat()
	return "Cache(" .. (self:getData("Name") or "NIL") .. ")"
end

function cacheMeta:addEntry(data, id)
	local entries = self:GetEntries()

	if (id) then
		entries[id] = data
	else
		id = table.insert(entries, data)
	end

	self:SetEntries(entries)

	return id, self:getEntry(id)
end

function cacheMeta:getEntry(id)
	return self:GetEntries()[id]
end

function cacheMeta:removeEntry(id)
	local entries = self:GetEntries()
	local result = self:getEntry(id)

	if !(result) then return false end

	entries[id] = nil

	self:SetEntries(entries)

	return result
end

function cacheMeta:sendToPlayer(ply, modifyData, sendAmt)
	local entries = self:GetEntries()

	if (modifyData) then
		entries = modifyData(entries)
	end

	netPoint:SendPayload("zlib.cache.Receive", ply, entries, (sendAmt || 2), self:GetName())
end

function cacheMeta:onPlayerReceive(data) end -- called when a player receives the cache

function cacheMeta:clear()
	self:SetEntries({})
end

cacheMeta:setData("Name", "NIL", {shouldSave = false})
cacheMeta:setData("Description", "NIL", {shouldSave = false})
cacheMeta:setData("Entries", {}, {shouldSave = false})
cacheMeta:setData("ClearOnReload", false, {shouldSave = false})

cacheMeta.__index = cacheMeta

--[[
	Networking
]]

--[[Netpoints]]
if (CLIENT) then
	netPoint:ReceivePayload("zlib.cache.Receive",
	function(data,cacheName)
		local cache = zlib.cache:Get(cacheName)

		if !(cache) then return end
		if !(cache.onPlayerReceive) then return end
		
		cache:onPlayerReceive(data)
	end)
end