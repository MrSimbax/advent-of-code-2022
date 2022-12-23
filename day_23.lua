local eio = require "libs.eio"
local profile = require "libs.profile"
local Vec2 = require "libs.Vec2"
local Set = require "libs.Set"
local MultiSet = require "libs.MultiSet"

local printf = eio.printf
local len = string.len
local sub = string.sub
local huge = math.huge
local P = Vec2.makeVec
local makeSet = Set.new
local makeMultiSet = MultiSet.new
local add = Set.add
local addm = MultiSet.add

profile.start()

local N = P(0, -1)
local S = P(0, 1)
local E = P(1, 0)
local W = P(-1, 0)
local NE = N + E
local NW = N + W
local SE = S + E
local SW = S + W

local DIRS = {N, S, W, E}
local ALL_DIRS = {N, NE, E, SE, S, SW, W, NW}
local CHECK_DIRS = {
    [N] = {NE, N, NW},
    [S] = {SE, S, SW},
    [E] = {NE, E, SE},
    [W] = {NW, W, SW}
}

local function parseInput ()
    local positions = makeSet()
    local y = 1
    for line in io.lines() do
        for x = 1, len(line) do
            if sub(line, x, x) == "#" then
                add(positions, P(x, y))
            end
        end
        y = y + 1
    end
    return positions
end

local function hasElf (positions, pos, dir)
    for _, checkDir in ipairs(CHECK_DIRS[dir]) do
        if positions[pos + checkDir] then
            return true
        end
    end
    return false
end

local function hasAnyElfAround (positions, pos)
    for _, dir in ipairs(ALL_DIRS) do
        if positions[pos + dir] then
            return true
        end
    end
    return false
end

local function round (positions, i)
    -- first half
    local propositions = makeMultiSet{}
    local nextPositions = {}
    for pos in pairs(positions) do
        if hasAnyElfAround(positions, pos) then
            for j = 0, 3 do
                local dir = DIRS[(i + j - 1) % #DIRS + 1]
                if not hasElf(positions, pos, dir) then
                    local nextPos = pos + dir
                    nextPositions[pos] = nextPos
                    addm(propositions, nextPos, 1)
                    break
                end
            end
        end
    end

    -- second half
    local retPositions = makeSet()
    local moved = false
    for pos in pairs(positions) do
        local nextPos = nextPositions[pos]
        if nextPos and propositions[nextPos] == 1 then
            moved = true
            add(retPositions, nextPos)
        else
            add(retPositions, pos)
        end
    end

    return retPositions, moved
end

local function findBounds (positions)
    local minx = huge
    local maxx = -huge
    local miny = huge
    local maxy = -huge
    for pos in pairs(positions) do
        if pos[1] > maxx then maxx = pos[1] end
        if pos[1] < minx then minx = pos[1] end
        if pos[2] > maxy then maxy = pos[2] end
        if pos[2] < miny then miny = pos[2] end
    end
    return minx, maxx, miny, maxy
end

local function emptyGrounds (positions)
    local minx, maxx, miny, maxy = findBounds(positions)
    local w, h = maxx - minx + 1, maxy - miny + 1
    return w * h - #positions
end

local function run (positions, n)
    local moved
    for i = 1, n do
        positions, moved = round(positions, i)
        if not moved then
            return positions, i
        end
    end
    return positions
end

local positions = parseInput()

local answer1 = emptyGrounds(run(positions, 10))
printf("Part 1: %i\n", answer1)

local _, answer2 = run(positions, huge)
printf("Part 2: %i\n", answer2)

return answer1, answer2, profile.finish()
