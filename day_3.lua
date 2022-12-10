local eio = require "libs/eio"
local estring = require "libs/estring"
local Set = require "libs/Set"

local input = eio.lines()
local printf = eio.printf
local isLower = estring.isLower
local byte = string.byte
local sub = string.sub
local len = string.len
local makeSet = Set.fromString
local any = Set.getAnyElement

local function priority (c)
    if isLower(c) then
        return byte(c) - byte('a') + 1
    else
        return byte(c) - byte('A') + 27
    end
end

local function sumPrioritiesOfCommonItemsInCompartments ()
    local sum = 0
    for i = 1, #input do
        local line = input[i]
        local halfLength = len(line) // 2
        sum = sum + priority(any(makeSet(sub(line, 1, halfLength)) * makeSet(sub(line, halfLength + 1, len(line)))))
    end
    return sum
end

local function sumPrioritiesOfCommonItemsInThreeBags ()
    local sum = 0
    for i = 1, #input, 3 do
        sum = sum + priority(any(makeSet(input[i]) * makeSet(input[i + 1]) * makeSet(input[i + 2])))
    end
    return sum
end

printf("Part 1: %i\n", sumPrioritiesOfCommonItemsInCompartments())
printf("Part 2: %i\n", sumPrioritiesOfCommonItemsInThreeBags())
