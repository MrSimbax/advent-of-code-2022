local eio = require "libs/eio"
local estring = require "libs/estring"
local F = require "libs/functional"
local Set = require "libs/Set"
local input = require "libs/input"

local function familyFromLine (line)
    local chars = estring.tableFromString(line)
    local firstCompartment = F.take(#line // 2, chars)
    local secondCompartment = F.take(#line // 2, F.reversed(chars))
    return F.map(Set.new, {firstCompartment, secondCompartment})
end

local function commonItemInFamily (family)
    local allItems = F.reduce(Set.union, Set.new{}, family)
    return F.head(Set.toSeq(F.reduce(Set.intersection, allItems, family)))
end

local function itemPriority (c)
    if estring.isLower(c) then
        return c:byte() - string.byte('a') + 1
    elseif estring.isUpper(c) then
        return c:byte() - string.byte('A') + 27
    end
end

local function sumPrioritiesOfCommonItemsInFamily (family)
    return F.sum(F.map(F.compose(itemPriority, commonItemInFamily), family))
end

eio.printf("Part 1: %i\n", sumPrioritiesOfCommonItemsInFamily(F.map(familyFromLine, input.lines())))

local function familyFromLines (lines)
    return F.map(F.compose(Set.new, estring.tableFromString), lines)
end

eio.printf("Part 2: %i\n", sumPrioritiesOfCommonItemsInFamily(F.map(familyFromLines, F.groupsOf(3, input.lines()))))
