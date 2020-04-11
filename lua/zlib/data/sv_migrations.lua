--[[
	zlib - (SV) MIGRATIONS

    - Data migrations
]]

zlib.data._migrationActive = false
zlib.data.migrationFuncs = {
    ["run"] = { f = function(m) return m:run() end, desc = "Run the migration." },
    ["reverse"] = { f = function(m) return m:reverse() end, desc = "Reverse the migration." },
}

--[[
	zlib.data:CreateMigration(name [string], data [table = null])

	- Registers/creates a database migration
]]
function zlib.data:CreateMigration(name, data)
    if !(name) then return end

    return self:SetupMigration(name, data)
end

--[[
    zlib.data:SetupMigration(name [string], data [table = empty table], cb [function = null])

    [INTERNAL FUNCTION]
    - Sets a migration object up with the specified information
]]
function zlib.data:SetupMigration(name, data, cb)
    if !(name) then return end

    data = (data or {})
    local migration = {}

    // Setup object
    zlib.object:SetMetatable("zlib.data.Migration", migration)

    if (data) then
        for k,v in pairs(data) do
            migration:setRawData(k,v)
        end
    end

    migration:SetUniqueID(name)

    // Cache migration
    local cache = zlib.cache:Get("zlib.data.Migrations")

	if (cache) then
		cache:addEntry(migration, name)

		return cache:getEntry(name)
	end
    
    return migration
end

--[[
    zlib.data:GetMigrations()

    - Returns all migrations
]]
function zlib.data:GetMigrations()
    local cache = zlib.cache:Get("zlib.data.Migrations")

    if !(cache) then return {} end

    return cache:GetEntries()
end

--[[
    zlib.data:GetMigration(name [string])

    - Returns a migration (or false if not valid)
]]
function zlib.data:GetMigration(name)
    local cache = zlib.cache:Get("zlib.data.Migrations")

    if !(cache) then return end

    return cache:getEntry(name)
end

--[[
    zlib.data:RemoveMigration(name [string])

    - Removes a migration
]]
function zlib.data:RemoveMigration(name)
    local cache = zlib.cache:Get("zlib.data.Migrations")

    if !(cache) then return end

    return (cache:removeEntry(name) != nil)
end

--[[
    zlib.data:RunMigration(mName [string], fName [string])

    - Runs a migration
]]
function zlib.data:RunMigration(mName, fName)
    local migration = self:GetMigration(mName)
    local func = self.migrationFuncs[fName]
    
    if (!migration or !func) then return end
    
    if (self._migrationActive) then
        zlib:ConsoleMessage(string.format("Migration %s is currently running, please try again in a while.", self._migrationActive))

        return
    end

    -- Run migration
    zlib:ConsoleMessage(string.format("Running migration '%s' using function '%s'...", mName, fName))

    self._migrationActive = mName .. "(" .. fName .. ")"
    func.f(migration)
    self._migrationActive = false

    zlib:ConsoleMessage(string.format("Completed migration '%s', please restart your server.", mName))
end

--[[
	Migration cache
]]
zlib.cache:Register("zlib.data.Migrations")

--[[
	Migration metastructure(s)
]]
local migrationMtbl = zlib.object:Create("zlib.data.Migration")
migrationMtbl:setData("UniqueID", false, {shouldSave = false})
migrationMtbl:setData("Description", false, {shouldSave = false})
migrationMtbl:setData("ActiveConnection", false, {shouldSave = false})

-- Utilities
function migrationMtbl:backupTable(tableName, cb, dropTable)
    local dataType = self:GetActiveConnection()

    if (!dataType or !tableName) then if (cb) then cb(false) end return end

    local fDType = zlib.data:LoadType("file")

    if !(fDType) then if (cb) then cb(false) end return end

    fDType:CreateDir("zlib/migration/backups", true) -- Create backup directory & set it to current directory

    // Get data from table
    dataType:Query(string.format("SELECT * FROM `%s`", tableName),
    function(data)
        local rows = {}

        if (table.Count(data) > 0) then
            for k,v in pairs(data) do
                if (istable(v)) then
                    table.insert(rows, zlib.util:Serialize(v)) // Add data to table
                end
            end
        end

        fDType:Write(string.format("%s_%s_%s_%s.dat", self:GetUniqueID(), tableName, "backup", os.date("%m%d%Y")), table.concat(rows, "\n"))

        if (dropTable) then
            dataType:Query(string.format("DROP TABLE `%s`", tableName))
        end

        if (cb) then cb(data) end
    end)
end

-- Run/reverse stubs
function migrationMtbl:onRun() end
function migrationMtbl:onReverse() end
function migrationMtbl:run() return self:onRun() end
function migrationMtbl:reverse() return self:onReverse() end

--[[
    Register migration command
]]
zlib.cmds:RegisterConsole("zlib_data_migration", 
function(ply, cmd, args)
    if (IsValid(ply)) then return end

    if (table.Count(player.GetAll()) > 0) then
        zlib:ConsoleMessage("Please remove all players from the server before peforming a migration.")

        return
    end
    
    local migrationName, funcName = args[1], args[2]
    local migration = zlib.data:GetMigration(migrationName)

    if !(migration) then
        -- Print migrations
        zlib:ConsoleMessage("Invalid migration name.")
        zlib:ConsoleMessage("Available migrations:")

        local migrations = zlib.data:GetMigrations()

        if (table.Count(migrations) > 0) then
            for k,v in pairs(migrations) do
                zlib:ConsoleMessage(string.format("\t %s - %s", k, v:GetDescription()))
            end
        else
            zlib:ConsoleMessage("\t None")
        end

        return
    end

    local funcs = zlib.data.migrationFuncs
    local func = funcs[funcName]

    if !(func) then 
        zlib:ConsoleMessage("Invalid function.")
        zlib:ConsoleMessage("Available functions:")

        if (table.Count(funcs) > 0) then
            for k,v in pairs(funcs) do
                zlib:ConsoleMessage(string.format("\t %s - %s", k, (v.desc || "")))
            end
        else
            zlib:ConsoleMessage("\t None")
        end

        return
    end

    // Run migration
    zlib.data:RunMigration(migrationName, funcName)
end)

--[[
    Hooks
]]
hook.Add("zlib.Loaded", "zlib.data.MigrationLoad[zlib.Loaded]",
function()
    zlib.data:LoadType("sqlite"):Query([[CREATE TABLE IF NOT EXISTS `zlib_migrations` (
        `uid` VARCHAR(120) PRIMARY KEY,
        `data` LONGTEXT NOT NULL
    )]], nil, function(err, sSql) zlib:ConsoleMessage((err || "Unknown error") .. " - " .. (sSql || "")) end)
end)