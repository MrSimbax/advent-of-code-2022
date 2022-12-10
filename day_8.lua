local eio = require "libs/eio"

local input = eio.lines()
local printf = eio.printf
local sub = string.sub

local function make2dArray (width, height, init)
    local r = {}
    for y = 1, height do
        local row = {}
        for x = 1, width do
            row[x] = init
        end
        r[y] = row
    end
    return r
end

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
    return r
end

local function isValidCoord (m, y, x)
    return 1 <= y and y <= #m and 1 <= x and x <= #m[1]
end

local function countVisibleFromEdge (forest, originY, originX, dirY, dirX, isVisible)
    local count = 0
    local maxHeight = -1
    while isValidCoord(forest, originY, originX) do
        local height = forest[originY][originX]

        if height > maxHeight then
            if not isVisible[originY][originX] then
                count = count + 1
                isVisible[originY][originX] = true
            end
            maxHeight = height
        end

        originY = originY + dirY
        originX = originX + dirX
    end
    return count
end

local function countAllVisibleFromEdges (forest)
    local isVisible = make2dArray(#forest[1], #forest, false)
    local count = 0
    for y = 1, #forest do
        count = count
              + countVisibleFromEdge(forest, y, 1,          0,  1, isVisible)
              + countVisibleFromEdge(forest, y, #forest[y], 0, -1, isVisible)
    end
    for x = 1, #forest[1] do
        count = count
              + countVisibleFromEdge(forest, 1, x,        1, 0, isVisible)
              + countVisibleFromEdge(forest, #forest, x, -1, 0, isVisible)
    end
    return count
end

printf("Part 1: %i\n", countAllVisibleFromEdges(forest()))

local function makeTree (height, treesBehind)
    return {height, treesBehind}
end

local function findScoresInLine (forest, originY, originX, dirY, dirX, scenicScores)
    local blockingTrees = {makeTree(10, 0)}
    local treesBehind = 0
    while isValidCoord(forest, originY, originX) do
        local height = forest[originY][originX]

        while blockingTrees[#blockingTrees][1] < height do
            table.remove(blockingTrees)
        end

        scenicScores[originY][originX] = scenicScores[originY][originX]
                                       * (treesBehind - blockingTrees[#blockingTrees][2])
        blockingTrees[#blockingTrees + 1] = makeTree(height, treesBehind)
        treesBehind = treesBehind + 1

        originY = originY + dirY
        originX = originX + dirX
    end
end

local function findScenicScores (forest)
    local scenicScores = make2dArray(#forest[1], #forest, 1)
    for y = 1, #forest do
        findScoresInLine(forest, y, 1,          0,  1, scenicScores)
        findScoresInLine(forest, y, #forest[y], 0, -1, scenicScores)
    end
    for x = 1, #forest[1] do
        findScoresInLine(forest, 1, x,        1, 0, scenicScores)
        findScoresInLine(forest, #forest, x, -1, 0, scenicScores)
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

printf("Part 2: %i\n", findMax(findScenicScores(forest())))
