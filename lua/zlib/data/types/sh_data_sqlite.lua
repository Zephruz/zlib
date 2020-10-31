--[[
    zlib - (SH) DATA - SQLite
    Developed by Zephruz
]]

zlib.data:RegisterType("sqlite", {
	connect = function(self, cb)
		if (cb) then cb() end
	end,
	query = function(self, query, sucCb, errCb)
		query = query:gsub("AUTO_INCREMENT", "AUTOINCREMENT") -- Workaround for sqlite & mysql compatible queries
		local query = sql.Query(query)
		local result, lastID

		if (query == nil || query) then
			query = (query or {})
			result = query

			if (sucCb) then
				lastID = sql.Query("SELECT last_insert_rowid()")
				lastID = (lastID && tonumber(lastID[1]["last_insert_rowid()"]) || 0)

				/*for _,row in pairs(query) do
					for k,v in pairs(row) do
						local vtonum = tonumber(v)
						
						if (vtonum) then
							query[_][k] = vtonum
						end
					end
				end*/

				sucCb(query, lastID)
			end
		elseif (errCb) then
			result = sql.LastError()

			errCb(result, query)
		end

		return result, lastID
	end,
})