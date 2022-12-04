local eio = require "libs/eio"
local estring = require "libs/estring"
local F = require "libs/functional"
local Set = require "libs/Set"
local input = require "libs/input"

local function rangeFromString (str)
    return F.map(tonumber, estring.split(str, "-"))
end

local function rangesFromLine (line)
    return F.map(rangeFromString, estring.split(line, ","))
end

local function setFromRange (range)
    return Set.new(F.collect(table.unpack(range)))
end

local function familyFromRanges (ranges)
    return F.map(setFromRange, ranges)
end

local function familiesFromInput ()
    return F.map(F.compose(familyFromRanges, rangesFromLine), input.lines())
end

local function isOneSubsetOfOther (family)
    return family[1] <= family[2] or family[2] <= family[1]
end

eio.printf("Part 1: %i\n", #F.filter(isOneSubsetOfOther, familiesFromInput()))

local function areOverlapping (family)
    return #(family[1] * family[2]) ~= 0
end

eio.printf("Part 2: %i\n", #F.filter(areOverlapping, familiesFromInput()))
