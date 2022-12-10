-- Enhanced string
local estring = {}

local format = string.format
local insert = table.insert
local find = string.find
local gsub = string.gsub
local gmatch = string.gmatch

function estring.split (str, delim)
    delim = delim or "%s"
    local t = {}
    for word in gmatch(str, format("[^%s]*", delim)) do
        t[#t + 1] = word
    end
    return t
end

function estring.str2tab (str)
    local t = {}
    local _ = gsub(str, ".", function (c) insert(t, c) end)
    return t
end

function estring.isLower (str)
    return find(str, "^%l+$") ~= nil
end

function estring.isUpper (str)
    return find(str, "^%u+$") ~= nil
end

return estring
