local eio = require "libs/eio"
local F = require "libs/functional"
local input = require "libs/input"
local estring = require "libs/estring"
local Vec = require "libs/Vector"

local function make2dArray (width, height, init)
    return Vec.allowVectorIndices(F.sequence(function (_) return F.sequence(F.const(init), width) end, height))
end

local function forest ()
    return Vec.allowVectorIndices(
        F.map(F.compose(function (hs) return F.map(tonumber, hs) end, estring.tableFromString), input.lines()))
end

local function isValidCoord (forest, p)
    return 1 <= p[1] and p[1] <= #forest and 1 <= p[2] and p[2] <= #forest[1]
end

local function countVisibleFromEdge (forest, origin, dir, isVisible)
    local count = 0
    local maxHeight = -1
    while isValidCoord(forest, origin) do
        if forest[origin] > maxHeight and not isVisible[origin] then
            count = count + 1
            isVisible[origin] = true
        end
        maxHeight = math.max(maxHeight, forest[origin])
        origin = origin + dir
    end
    return count
end

local function countAllVisibleFromEdges (forest)
    local isVisible = Vec.allowVectorIndices(make2dArray(#forest[1], #forest, false))
    local count = 0
    for i = 1, #forest do
        count = count + countVisibleFromEdge(forest, Vec{i, 1}, Vec{0, 1}, isVisible)
                      + countVisibleFromEdge(forest, Vec{i, #forest[i]}, Vec{0, -1}, isVisible)
    end
    for j = 1, #forest[1] do
        count = count + countVisibleFromEdge(forest, Vec{1, j}, Vec{1, 0}, isVisible)
                      + countVisibleFromEdge(forest, Vec{#forest, j}, Vec{-1, 0}, isVisible)
    end
    return count
end

eio.printf("Part 1: %i\n", countAllVisibleFromEdges(forest()))

local function makeTree (height, treesBehind)
    return {height, treesBehind}
end

local function findScoresInLine (forest, origin, dir, scenicScores)
    local blockingTrees = {makeTree(10, 0)}
    local treesBehind = 0
    while isValidCoord(forest, origin) do
        while blockingTrees[#blockingTrees][1] < forest[origin] do
            table.remove(blockingTrees)
        end
        scenicScores[origin] = scenicScores[origin] * (treesBehind - blockingTrees[#blockingTrees][2])
        table.insert(blockingTrees, makeTree(forest[origin], treesBehind))
        treesBehind = treesBehind + 1
        origin = origin + dir
    end
end

local function findScenicScores (forest)
    local scenicScores = Vec.allowVectorIndices(make2dArray(#forest[1], #forest, 1))
    for i = 1, #forest do
        findScoresInLine(forest, Vec{i, 1}, Vec{0, 1}, scenicScores)
        findScoresInLine(forest, Vec{i, #forest[i]}, Vec{0, -1}, scenicScores)
    end
    for j = 1, #forest[1] do
        findScoresInLine(forest, Vec{1, j}, Vec{1, 0}, scenicScores)
        findScoresInLine(forest, Vec{#forest, j}, Vec{-1, 0}, scenicScores)
    end
    return scenicScores
end

eio.printf("Part 2: %i\n", F.maximum(F.map(F.maximum, findScenicScores(forest()))))
