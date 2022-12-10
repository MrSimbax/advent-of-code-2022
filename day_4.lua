local eio = require "libs/eio"

local input = eio.lines()
local printf = eio.printf
local match = string.match

local function isOneRangeSubsetOfOther (a, b, c, d)
    return (a <= c and d <= b) or (c <= a and b <= d)
end

local function areOverlapping (a, b, c, d)
    return not (b < c or d < a)
end

local count1 = 0
local count2 = 0
for i = 1, #input do
    local a, b, c, d = match(input[i], "(%d+)-(%d+),(%d+)-(%d+)")
    a, b, c, d = tonumber(a), tonumber(b), tonumber(c), tonumber(d)
    count1 = count1 + (isOneRangeSubsetOfOther(a, b, c, d) and 1 or 0)
    count2 = count2 + (areOverlapping(a, b, c, d) and 1 or 0)
end

printf("Part 1: %i\n", count1)
printf("Part 2: %i\n", count2)
