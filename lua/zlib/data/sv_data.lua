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

zlib.data.migrations = (zlib.data.migrations or {})

--[[
	zlib.data:CreateMigration(name [string], desc [string], onCall [function])

	- Registers/creates a database migration
]]
function zlib.data:CreateMigration(name, desc, onCall)
    if (!name or !onCall) then return end

    if (self.migrations[name]) then
        zlib:ConsoleMessage(Color(255,0,0), "Database migration overwritten: " .. name)
    end

    self.migrations[name] = {
        desc = (desc || "No description."),
        onCall = onCall
    }
end

--[[
    zlib.data:GetMigrations()

    - Returns all migrations
]]
function zlib.data:GetMigrations()
    return self.migrations
end

--[[
    zlib.data:GetMigration(name [string])

    - Returns a migration (or false if not valid)
]]
function zlib.data:GetMigration(name)
    return (self.migrations[name] || false)
end

--[[
    zlib.data:RemoveMigration(name [string])

    - Removes a migration
]]
function zlib.data:RemoveMigration(name)
    self.migrations[name] = nil
end

--[[
    Register migration command
]]
zlib.cmds:RegisterConsole("zlib_data_migration", 
function(ply, cmd, args)
    if (IsValid(ply)) then return end
    
    local migrationName = args[1]
    local migration = zlib.data:GetMigration(migrationName)

    if !(migration) then
        zlib:ConsoleMessage("Invalid migration name.")
        zlib:ConsoleMessage("Available migrations:")

        local migrations = zlib.data:GetMigrations()

        if (table.Count(migrations) > 0) then
            for k,v in pairs(migrations) do
                zlib:ConsoleMessage(string.format("\t %s - %s", k, v.desc))
            end
        else
            zlib:ConsoleMessage("\t None")
        end

        return
    end

    migration.onCall()
end)