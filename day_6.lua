local eio = require "libs/eio"

local input = eio.lines()
local printf = eio.printf
local sub = string.sub

local stream = input[1]

local function makeMarker ()
    return {
        ["a"] = 0,
        ["b"] = 0,
        ["c"] = 0,
        ["d"] = 0,
        ["e"] = 0,
        ["f"] = 0,
        ["g"] = 0,
        ["h"] = 0,
        ["i"] = 0,
        ["j"] = 0,
        ["k"] = 0,
        ["l"] = 0,
        ["m"] = 0,
        ["n"] = 0,
        ["o"] = 0,
        ["p"] = 0,
        ["q"] = 0,
        ["r"] = 0,
        ["s"] = 0,
        ["t"] = 0,
        ["u"] = 0,
        ["v"] = 0,
        ["w"] = 0,
        ["x"] = 0,
        ["y"] = 0,
        ["z"] = 0,
        uniqueCount = 0
    }
end

local function add (counters, letter)
    local c = counters[letter] + 1
    if c == 1 then
        counters.uniqueCount = counters.uniqueCount + 1
    elseif c == 2 then
        counters.uniqueCount = counters.uniqueCount - 1
    end
    counters[letter] = c
end

local function del (counters, letter)
    local c = counters[letter] - 1
    if c == 0 then
        counters.uniqueCount = counters.uniqueCount - 1
    elseif c == 1 then
        counters.uniqueCount = counters.uniqueCount + 1
    end
    if c >= 0 then
        counters[letter] = c
    end
end

local function firstMarkerPosition (len)
    local marker = makeMarker()
    for i = 1, len do
        add(marker, sub(stream, i, i))
    end
    local i = len
    while marker.uniqueCount ~= len do
        i = i + 1
        local begin = i - len
        del(marker, sub(stream, begin, begin))
        add(marker, sub(stream, i, i))
    end
    return i
end

printf("Part 1: %i\n", firstMarkerPosition(4))
printf("Part 2: %i\n", firstMarkerPosition(14))
