local eio = require "libs/eio"
local F = require "libs/functional"
local input = require "libs/input"
local Optional = require "libs/Optional"

local function optionalNumberFromLine (line)
    return Optional.new(tonumber(line))
end

local function unpackOptionals (optionals)
    return F.map(Optional.value, optionals)
end

local function loadInput ()
    return F.map(unpackOptionals, F.split(Optional.empty(), F.map(optionalNumberFromLine, input.lines())))
end

local calories = F.map(F.sum, loadInput())
eio.printf("Part 1: %i\n", F.maximum(calories))
eio.printf("Part 2: %i\n", F.sum(F.take(3, F.reversed(F.sorted(calories)))))
