local eio = require "libs.eio"
local profile = require "libs.profile"
local Vec2 = require "libs.Vec2"

local input = eio.lines()
local printf = eio.printf
local sub = string.sub
local Vec = Vec2.makeVec
local Grid = Vec2.allowVec2Indices
local makeGrid = Vec2.makeGrid

profile.start()

local function forest ()
    local r = {}
    for y = 1, #input do
        local line = input[y]
        local row = {}
        for x = 1, #line do
            row[x] = tonumber(sub(line, x, x))
        end
        r[y] = row
    end
    return Grid(r)
end

local function isValidCoord (m, p)
    return 1 <= p[1] and p[1] <= #m and 1 <= p[2] and p[2] <= #m[1]
end

local function countVisibleFromEdge (forest, origin, dir, isVisible)
    local count = 0
    local maxHeight = -1
    while isValidCoord(forest, origin) do
        local height = forest[origin]

        if height > maxHeight then
            if not isVisible[origin] then
                count = count + 1
                isVisible[origin] = true
            end
            maxHeight = height
        end

        origin = origin + dir
    end
    return count
end

local function countAllVisibleFromEdges (forest)
    local isVisible = makeGrid(#forest[1], #forest, false)
    local count = 0
    for y = 1, #forest do
        count = count
              + countVisibleFromEdge(forest, Vec(y, 1), Vec(0, 1), isVisible)
              + countVisibleFromEdge(forest, Vec(y, #forest[y]), Vec(0, -1), isVisible)
    end
    for x = 1, #forest[1] do
        count = count
              + countVisibleFromEdge(forest, Vec(1, x), Vec(1, 0), isVisible)
              + countVisibleFromEdge(forest, Vec(#forest, x), Vec(-1, 0), isVisible)
    end
    return count
end

local answer1 = countAllVisibleFromEdges(forest())
printf("Part 1: %i\n", answer1)

local function makeTree (height, treesBehind)
    return {height, treesBehind}
end

local function findScoresInLine (forest, origin, dir, scenicScores)
    local blockingTrees = {makeTree(10, 0)}
    local treesBehind = 0
    while isValidCoord(forest, origin) do
        local height = forest[origin]

        while blockingTrees[#blockingTrees][1] < height do
            blockingTrees[#blockingTrees] = nil
        end

        scenicScores[origin] = scenicScores[origin] * (treesBehind - blockingTrees[#blockingTrees][2])
        blockingTrees[#blockingTrees + 1] = makeTree(height, treesBehind)
        treesBehind = treesBehind + 1

        origin = origin + dir
    end
end

local function findScenicScores (forest)
    local scenicScores = makeGrid(#forest[1], #forest, 1)
    for y = 1, #forest do
        findScoresInLine(forest, Vec(y, 1), Vec(0, 1), scenicScores)
        findScoresInLine(forest, Vec(y, #forest[y]), Vec(0, -1), scenicScores)
    end
    for x = 1, #forest[1] do
        findScoresInLine(forest, Vec(1, x), Vec(1, 0), scenicScores)
        findScoresInLine(forest, Vec(#forest, x), Vec(-1, 0), scenicScores)
    end
    return scenicScores
end

local function findMax (scores)
    local m = -1
    for y = 1, #scores do
        local row = scores[y]
        for x = 1, #row do
            local v = row[x]
            if v > m then
                m = v
            end
        end
    end
    return m
end

local answer2 = findMax(findScenicScores(forest()))
printf("Part 2: %i\n", answer2)

return answer1, answer2, profile.finish()
