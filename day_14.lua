local eio = require "libs.eio"
local profile = require "libs.profile"
local estring = require "libs.estring"
local emath = require "libs.emath"
local Vec2 = require "libs.Vec2"

local printf = eio.printf
local split = estring.split
local match = string.match
local tonumber = tonumber
local sgn = emath.sgn
local P = Vec2.makeVec
local map = Vec2.map

profile.start()

local START = P(500, 0)

local bottom = 0

local function posFromStr (str)
    local x, y = match(str, "(%d+),(%d+)")
    return P(tonumber(x), tonumber(y))
end

local function addRock (set, pos)
    set[pos] = true
    if pos[2] > bottom then
        bottom = pos[2]
    end
end

local function parseRocks ()
    local rocks = {}
    for line in io.lines() do
        local words = split(line)
        local from = posFromStr(words[1])
        addRock(rocks, from)
        for j = 3, #words, 2 do
            local to = posFromStr(words[j])
            addRock(rocks, to)
            local dir = map(sgn, to - from)
            local pos = from + dir
            while pos ~= to do
                addRock(rocks, pos)
                pos = pos + dir
            end
            from = to
        end
    end
    return rocks
end

local function dropSand (rocks, isOccupied, shouldStop)
    local sands = {}
    local count = 0
    local function dropFrom (pos)
        if shouldStop(sands, rocks, pos) then
            return false
        end
        if isOccupied(sands, rocks, pos) then
            return true
        end

        local x, y = pos[1], pos[2]
        local isBlocked = dropFrom(P(x, y + 1)) and dropFrom(P(x - 1, y + 1)) and dropFrom(P(x + 1, y + 1))
        if isBlocked then
            sands[pos] = true
            count = count + 1
        end
        return isBlocked
    end
    dropFrom(START)
    return sands, count
end

local function stopWhenHitBottomlessPit (_, _, pos)
    return pos[2] > bottom
end

local function isOccupied (rocks, sands, pos)
    return sands[pos] or rocks[pos]
end

local rocks = parseRocks()

local _, answer1 = dropSand(rocks, isOccupied, stopWhenHitBottomlessPit)
printf("Part 1: %i\n", answer1)

local function stopWhenStartBlocked (_, _, _)
    return false
end

local function isOccupiedOrInfiniteFloor (rocks, sands, pos)
    return isOccupied(rocks, sands, pos) or pos[2] == bottom + 2
end

local _, answer2 = dropSand(rocks, isOccupiedOrInfiniteFloor, stopWhenStartBlocked)
printf("Part 2: %i\n", answer2)

return answer1, answer2, profile.finish()
