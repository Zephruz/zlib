--[[
	zlib - (SH) Cache

	- Cache handling (creation, deletion, fetching, etc.)
]]

zlib.addons = (zlib.addons or {})

--[[
    Addon Metastructure
]]
local fAddonMtbl = zlib.object:Create("zlib.AddonMeta")
fAddonMtbl:setData("Name", "NIL", {shouldSave = false})
fAddonMtbl:setData("Description", "NIL", {shouldSave = false})
fAddonMtbl:setData("Version", "NIL", {shouldSave = false})
fAddonMtbl:setData("Table", nil, {shouldSave = false})

function fAddonMtbl:__tostring()
	return ("addon[" .. (self:getData("Name") || "NIL") .. "]")
end

function fAddonMtbl:__eq(c1, c2) 
	local c1Name = (c1 && c1.getData && c1:getData("Name") || nil)
	local c2Name = (c2 && c2.getData && c2:getData("Name") || nil)

	return (c1Name && c2Name && c1Name == c2Name)
end

function fAddonMtbl:__concat()
	return tostring(self)
end