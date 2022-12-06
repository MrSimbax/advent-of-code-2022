local eio = require "libs/eio"
local F = require "libs/functional"
local input = require "libs/input"
local MultiSet = require "libs/MultiSet"
local estring = require "libs/estring"

local function getStream ()
    return estring.tableFromString(F.head(input.lines()))
end

local function firstMarkerPosition (len, stream)
    local i = len
    local marker = MultiSet.new(F.take(len, stream))
    while not MultiSet.isSet(marker) do
        i = i + 1
        MultiSet.del(marker, stream[i - len], 1)
        MultiSet.add(marker, stream[i], 1)
    end
    return i
end

eio.printf("Part 1: %i\n", firstMarkerPosition(4, getStream()))
eio.printf("Part 2: %i\n", firstMarkerPosition(14, getStream()))
