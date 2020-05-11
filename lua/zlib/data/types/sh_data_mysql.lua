--[[
    zlib - (SH) DATA - Mysqloo
    Developed by Zephruz
]]

zlib.data:RegisterType("mysqloo", {
	connect = function(self, sucCb, errCb)
		local db
		local res, resErr = pcall(require, "mysqloo")
		local cfg = self:GetConfig()
		local dbInfo = (cfg && cfg.mysqlInfo || false)

		if !(dbInfo) then zlib:ConsoleMessage("Invalid MySQL info, cancelling connection attempt.") return end

		if (self._dbconn && self._dbconn:status() == mysqloo.DATABASE_CONNECTED) then
			if (sucCb) then
				sucCb()
			end

			return
		end

		if (res) then
			db = mysqloo.connect(dbInfo.dbHost, dbInfo.dbUser, dbInfo.dbPass, dbInfo.dbName, (dbInfo.dbPort or 3306))

			db.onConnected = function(s)
				if (sucCb) then
					sucCb()
				end
			end

			db.onConnectionFailed = function(s, err)
				if (errCb) then
					errCb(err)
				end
			end

			db:setAutoReconnect(true)
			db:connect()

			self._dbconn = db
		else
			ErrorNoHalt(resErr)
		end
	end,
	disconnect = function(self, sucCb, errCb)
		if (self._dbconn) then
			self._dbconn:disconnect(true)
		end

		if (sucCb) then sucCb(true) end
	end,
	query = function(self, query, sucCb, errCb)
		if !(self._dbconn) then return false end

		query = query:gsub("AUTOINCREMENT", "AUTO_INCREMENT")

		local q = self._dbconn:query(query)
		
		q.onSuccess = function(s, data)
			if (sucCb) then sucCb(data, s:lastInsert()) end
		end
		q.onError = function(s, err, sql)
			if (errCb) then errCb(err, sql) end
		end
		q.onAbort = function(s, sql)
			if (errCb) then errCb("Query was aborted! [" .. sql .. "]", sql) end
		end
		
		q:start()
	end,
	getDatabaseConnection = function(self)
		return self._dbconn
	end,
})