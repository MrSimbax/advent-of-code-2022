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

return estring
