--[[
    zlib - (SH) Object
    Developed by Zephruz
]]

zlib.object = (zlib.object or {})
zlib.object.cache = (zlib.object.cache or {})

--[[
	zlib.object:GetMetaTable()

	- Returns the object metatable
]]
function zlib.object:GetMetaTable()
	return (self._metatable or {})
end

--[[
	zlib.object:SetMetatable(name [string or number], tbl [table])

	- Sets the meta table to an object
]]
function zlib.object:SetMetatable(name, tbl)
	local objMeta = self:Get(name)

	if !(objMeta) then return end

	setmetatable(tbl, { __index = table.Copy(objMeta) })

	return tbl
end

--[[
	zlib.object:Create(name [string or number], data [table] (OPTIONAL))

	- Creates an object and stores it within the cache
	- Returns the cached object/metatable and its cached name/ID
]]
function zlib.object:Create(name, data)
	local id = (name or #self.cache+1)

	self.cache[id] = {}

	setmetatable(self.cache[id], { __index = table.Copy(self:GetMetaTable()) })

	self.cache[id].__metatable = name

	if (data) then
		for k,v in pairs(data) do
			self.cache[id]:setData(k,v)
		end
	end

	return self.cache[id], id
end

--[[
	zlib.object:SetProtected(name [string or number], isProt [bool])

	- Sets an object as a protected metatable
]]
function zlib.object:SetProtected(name, isProt)
	local obj = self:Get(name)

	if !(obj) then return false end

	obj.__metatable = (isProt && name || nil)

	return obj
end

--[[
	zlib.object:Remove(name [string or number])

	- Removes an object/metatable by cached name (key)
	- Returns true if removed or false if not found/unsuccessful
]]
function zlib.object:Remove(name)
	local data = self.cache[name] -- Get the cache

	self.cache[name] = nil  -- Nil it anyways

	return (data && true || false)
end

--[[
	zlib.object:Get(name [string or number])

	- Returns an object/metatable by cached name (key) OR nil if not found
]]
function zlib.object:Get(name)
	return (self.cache[name] or nil)
end

--[[
	zlib.object:IsObject(name, var)

	- Checks if the passed variable is the same as the passed object
]]
function zlib.object:IsObject(name, var)
	if (!name or !var) then return false end

	local obj = self:Get(name)

	if (obj) then
		local mt = (istable(var) && getmetatable(var))

		return (mt && mt == name)
	end

	return false
end

--[[Object base structure]]
local OMETA_DTNAME, OMETA_PTNAME = "_data", "_params"

local objMeta = {}

function objMeta:setData(name, val, params)
	local getter = self["Get" .. name]
	local setter = self["Set" .. name]

	self[OMETA_DTNAME] = (self[OMETA_DTNAME] or {})

	-- Set parameters
	if !(self:getParameter(name)) then
		self:setParameter(name, params)
	end

	-- Check if this data exists, if so, set data and return
	if (self:getData(name) != nil && isfunction(setter)) then
		return setter(self, val)
	end

	-- Get
	getter = function(self, ...)
		local val = (self[OMETA_DTNAME][name] or false)
		local onGet = self:getParameter(name)
		onGet = (onGet && onGet.onGet)

		-- OnGet param
		if (isfunction(onGet)) then
			local retGet = {onGet(self, val, ...)}

			if (retGet[1] != nil) then
				return unpack(retGet)
			end
		end

		-- OnGet obj
		if (isfunction(self.onGetData)) then
			self:onGetData(name, val, ...)
		end

		return val
	end

	-- Set
	setter = function(self, val, ...)
		local params = self:getParameter(name)
		local shouldSave = (!params || params.shouldSave == nil || params.shouldSave)
		local onSet, postSet = (params && params.onSet), (params && params.postSet)
		local oldVal = (self[OMETA_DTNAME][name] or false)
		
		-- OnSet param
		if (isfunction(onSet)) then
			local retSet = onSet(self, val, oldVal, ...)

			if (retSet != nil) then
				val = retSet
			end
		end

		self[OMETA_DTNAME][name] = (val or false)
		
		if (isfunction(postSet)) then postSet(self, val, oldVal, ...) end

		-- OnSet obj
		if (isfunction(self.onSetData)) then
			self:onSetData(name, val, ...)
		end
		
		if (shouldSave) then
			self:saveData()
		end

		return val
	end

	-- [[Load custom parameters]]
	local hooks = (params && params.hooks || {})

	-- Hooks
	for k,v in pairs(hooks) do
		hook.Add(k, "zlib.obj[" .. table.Count(self[OMETA_DTNAME]) .. "].hook." .. k .. "." .. name,
		function(...)
			if (isfunction(v) && self) then
				v(self, ...)
			end
		end)
	end

	self["Get" .. name] = getter
	self["Set" .. name] = setter
	self[OMETA_DTNAME][name] = (val or false)

	return self[OMETA_DTNAME][name]
end

function objMeta:removeData(name, save)
	self[OMETA_DTNAME][name] = nil
	self[OMETA_PTNAME][name] = nil
	self["Set" .. name] = nil
	self["Get" .. name] = nil

	if (save) then
		self:saveData()
	end
end

function objMeta:setRawData(name, val)
	self[OMETA_DTNAME] = (self[OMETA_DTNAME] or {})

	rawset(self[OMETA_DTNAME], name, val)
end

function objMeta:saveData(callback)
	local oData = (self:getValidatedData() or {})

	if (isstring(oData)) then return oData end

	for k,v in pairs(oData) do
		local params = self:getParameter(k)

		oData[k] = (params.shouldSave != false && v || nil)
	end

	oData = (oData && von && von.serialize(oData) || nil)

	-- On Save
	if !(oData) then return false end

	if (self.onSave) then self:onSave(oData, callback) end
end

function objMeta:getValidatedData(data)
	data = table.Copy(data or self:getDataTable())

	for k,v in pairs(data) do
		local params = self:getParameter(k)

		if (params) then
			local validate = params.validateValue

			if (validate) then
				local err = validate(v)

				if (err) then return err end
			end
		else
			data[k] = nil
		end
	end

	return (data or {})
end

function objMeta:getData(name)
	return (self[OMETA_DTNAME] && self[OMETA_DTNAME][name] == nil && nil || self[OMETA_DTNAME][name])
end

function objMeta:getRawData(name)
	return rawget(self[OMETA_DTNAME], name)
end

function objMeta:getDataTable()
	return (self[OMETA_DTNAME] or {})
end

function objMeta:setParameter(name, params)
	self[OMETA_PTNAME] = (self[OMETA_PTNAME] or {})
	self[OMETA_PTNAME][name] = (params or {})
end

function objMeta:getParameter(name)
	return (self[OMETA_PTNAME] && self[OMETA_PTNAME][name] || nil)
end

function objMeta:getParameterTable()
	return (self[OMETA_PTNAME] or {})
end

function objMeta:extendDataParameters(name, extParams)
	local params = self:getParameterTable()
	
	if !(params[name]) then return end

	for k,v in pairs(extParams) do
		params[name][k] = v
	end

	self:setParameter(name, params[name])
end

function objMeta:onSetData(...) end
function objMeta:onGetData(...) end

objMeta.__index = objMeta
zlib.object._metatable = objMeta