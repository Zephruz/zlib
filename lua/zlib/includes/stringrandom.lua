--[[
	Snippet pulled from: https://gist.github.com/haggen/2fd643ea9a261fea2094
]]

local charset = {}

-- qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
for i = 48,  57 do table.insert(charset, string.char(i)) end
for i = 65,  90 do table.insert(charset, string.char(i)) end
for i = 97, 122 do table.insert(charset, string.char(i)) end

function string.random(length)
	math.randomseed(os.time())

	if length < 0 then return "" end
	
	return string.random(length - 1) .. charset[math.random(1, #charset)]
end
