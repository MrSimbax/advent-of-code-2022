local eio = require "libs/eio"
local F = require "libs/functional"
local input = require "libs/input"
local estring = require "libs/estring"

local function forest ()
    return F.map(F.compose(function (hs) return F.map(tonumber, hs) end, estring.tableFromString), input.lines())
end

local function isValidCoord (forest, i, j)
    return 1 <= i and i <= #forest and 1 <= j and j <= #forest[1]
end

local function countVisibleFromEdge (forest, origin, dir, isVisible)
    local count = 0
    local maxHeight = -1
    while isValidCoord(forest, origin[1], origin[2]) do
        if forest[origin[1]][origin[2]] > maxHeight and not isVisible[origin[1]][origin[2]] then
            count = count + 1
            isVisible[origin[1]][origin[2]] = true
        end
        maxHeight = math.max(maxHeight, forest[origin[1]][origin[2]])
        origin = {origin[1] + dir[1], origin[2] + dir[2]}
    end
    return count
end

local function countAllVisibleFromEdges (forest)
    local isVisible = F.sequence(function (_) return F.sequence(F.const(false), #forest[1]) end, #forest)
    local count = 0
    for i = 1, #forest do
        count = count + countVisibleFromEdge(forest, {i, 1}, {0, 1}, isVisible)
                      + countVisibleFromEdge(forest, {i, #forest[i]}, {0, -1}, isVisible)
    end
    for j = 1, #forest[1] do
        count = count + countVisibleFromEdge(forest, {1, j}, {1, 0}, isVisible)
                      + countVisibleFromEdge(forest, {#forest, j}, {-1, 0}, isVisible)
    end
    return count
end

eio.printf("Part 1: %i\n", countAllVisibleFromEdges(forest()))

local function countVisibleFrom (forest, origin, dir)
    local count = 0
    local height = forest[origin[1]][origin[2]]
    local tree = {origin[1] + dir[1], origin[2] + dir[2]}
    while isValidCoord(forest, tree[1], tree[2]) do
        count = count + 1
        if forest[tree[1]][tree[2]] >= height then
            break
        end
        tree = {tree[1] + dir[1], tree[2] + dir[2]}
    end
    return count
end

local function scenicScore (forest, origin)
    return countVisibleFrom(forest, origin, {0, 1})
         * countVisibleFrom(forest, origin, {0, -1})
         * countVisibleFrom(forest, origin, {1, 0})
         * countVisibleFrom(forest, origin, {-1, 0})
end

local function findMaxScenicScore (forest)
    local maxScore = -1
    for i = 1, #forest do
        for j = 1, #forest[i] do
            maxScore = math.max(maxScore, scenicScore(forest, {i, j}))
        end
    end
    return maxScore
end

eio.printf("Part 2: %i\n", findMaxScenicScore(forest()))
