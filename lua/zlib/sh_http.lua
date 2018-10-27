--[[
    zlib - (SH) HTTP
    Developed by Zephruz
]]

zlib.http = {}

--[[
    zlib.http:JSONFetch(url, onSuccess, onFail, header)

    - Makes an http request for a JSON table
]]
function zlib.http:JSONFetch(url, onSuccess, onFail, header)
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
    end, (header or {}))
end

--[[
    zlib.http:JSONPost(url, params, header, onSuccess, onFail)

    - Makes an http post for a JSON table
]]
function zlib.http:JSONPost(url, params, header, onSuccess, onFail)
    http.Post(url, (params or {}),
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
    end, (header or {}))
end

--[[
    zlib.http:Request(method [string], url [string], body [table], onSuccess, onFail)

    - Makes an http request using the specified method, url, and body
]]
function zlib.http:Request(method, url, body, onSuccess, onFail)
    local structure = {
        method = method, 
        url = url, 
        type = "application/json",
        headers = nil, 
        body = util.TableToJSON(body), 
        success = function(...)
            if (onSuccess) then onSuccess(...) end
        end,
        failed = function(...) 
            if (onFail) then onFail(...) end
        end,
    }

    HTTP(structure)
end