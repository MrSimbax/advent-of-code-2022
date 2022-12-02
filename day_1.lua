local eio = require "libs/eio"
local functional = require "libs/functional"

local printf = eio.printf
local maximum = functional.maximum
local map = functional.map
local sum = functional.sum
local take = functional.take
local reversed = functional.reversed
local sorted = functional.sorted

local function loadInput ()
    local elves = {}

    local elf = {}
    for line in io.lines() do
        if line == "" then
            table.insert(elves, elf)
            elf = {}
        else
            table.insert(elf, tonumber(line))
        end
    end

    return elves
end

local calories = map(sum, loadInput())
printf("Part 1: %i\n", maximum(calories))
printf("Part 2: %i\n", sum(take(3, reversed(sorted(calories)))))
