local eio = require "libs/eio"
local estring = require "libs/estring"
local functional = require "libs/functional"
local Set = require "libs/Set"

local printf = eio.printf
local compose = functional.compose
local map = functional.map
local head = functional.head
local reduce = functional.reduce
local sum = functional.sum
local take = functional.take
local reversed = functional.reversed
local tableFromString = estring.tableFromString
local isUpper = estring.isUpper
local isLower = estring.isLower
local groupsOf = functional.groupsOf

local input = {}

local function loadInput ()
    if #input == 0 then
        for line in io.lines() do
            table.insert(input, line)
        end
    end
    return input
end

local function familyFromLine (line)
    local chars = tableFromString(line)
    local firstCompartment = take(#line // 2, chars)
    local secondCompartment = take(#line // 2, reversed(chars))
    return map(Set.new, {firstCompartment, secondCompartment})
end

local function commonItemInFamily (family)
    local allItems = reduce(Set.union, Set.new{}, family)
    return head(Set.toSeq(reduce(Set.intersection, allItems, family)))
end

local function itemPriority (c)
    if isLower(c) then
        return c:byte() - string.byte('a') + 1
    elseif isUpper(c) then
        return c:byte() - string.byte('A') + 27
    end
end

printf("Part 1: %i\n", sum(map(compose(itemPriority, commonItemInFamily, familyFromLine), loadInput())))

local function familyFromLines (lines)
    return map(compose(Set.new, tableFromString), lines)
end

printf("Part 2: %i\n", sum(map(compose(itemPriority, commonItemInFamily, familyFromLines), groupsOf(3, loadInput()))))
