-- Enhanced string
local estring = {}

function estring.split (str, delim)
    delim = delim or "%s"
    local t = {}
    for word in str:gmatch(string.format("[^%s]*", delim)) do
        t[#t + 1] = word
    end
    return table.unpack(t)
end

function estring.tableFromString (str)
    local t = {}
    str:gsub(".", function (c) return table.insert(t, c) end)
    return t
end

function estring.isLower (str)
    return str:find("^%l+$") ~= nil
end

function estring.isUpper (str)
    return str:find("^%u+$") ~= nil
end

return estring
