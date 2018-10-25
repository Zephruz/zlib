--[[
    zlib - (SH) HTTP
    Developed by Zephruz
]]

zlib.http = {}

--[[
    zlib.http:JSONRequest(url, onSuccess, onFail)
]]
function zlib.http:JSONRequest(url, onSuccess, onFail)
    http.Fetch(url,
    function(body, len, headers, code)
        local json = util.JSONToTable(body)

        if (istable(json)) then
            if (onSuccess) then onSuccess(json) end
        else
            if (onFail) then onFail({["error"] = "No JSON received."}) end
        end
    end,
    function(error)
        if (onFail) then onFail({["error"] = error}) end
    end)
end