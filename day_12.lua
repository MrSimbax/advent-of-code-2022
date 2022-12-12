local eio = require "libs.eio"
local profile = require "libs.profile"
local Vec2 = require "libs.Vec2"
local pathfinding = require "libs.pathfinding"

local input = eio.lines
local printf = eio.printf
local sub = string.sub
local Vec = Vec2.makeVec
local Grid = Vec2.allowVec2Indices
local byte = string.byte
local isValidCoord = Vec2.isValidCoord2d
local huge = math.huge
local findPath = pathfinding.findShortestPath

profile.start()

local directions = {
    Vec(0, 1), -- right
    Vec(-1, 0), -- down
    Vec(0, -1), -- left
    Vec(1, 0), -- up
}

local function pos2node (graph, grid, pos)
    local node = graph[pos]
    if not node then
        node = {pos = pos, adj = {}}
        graph[pos] = node
        local adj = node.adj
        for i = 1, #directions do
            local neighbourPos = pos + directions[i]
            if isValidCoord(grid, neighbourPos) and (grid[pos] - grid[neighbourPos] <= 1) then
                adj[{label = 1, to = pos2node(graph, grid, neighbourPos)}] = true
            end
        end
    end
    return node
end

local function heightFromLetter (c)
    return byte(c) - byte("a")
end

local function getGrid ()
    local grid = {}
    local startPos = nil
    local endPos = nil
    local startPositions = {}
    local input = input()
    for y = 1, #input do
        local line = input[y]
        local row = {}
        for x = 1, #line do
            local c = sub(line, x, x)
            if c == "S" then
                row[x] = heightFromLetter("a")
                startPos = Vec(y, x)
                startPositions[#startPositions + 1] = startPos
            elseif c == "E" then
                row[x] = heightFromLetter("z")
                endPos = Vec(y, x)
            else
                row[x] = heightFromLetter(c)
                if c == "a" then
                    startPositions[#startPositions + 1] = Vec(y, x)
                end
            end
        end
        grid[y] = row
    end
    return Grid(grid), startPos, endPos, startPositions
end

local function graphFromGrid (grid)
    local graph = {}
    for y = 1, #grid do
        for x = 1, #grid[1] do
            graph[Vec(y, x)] = pos2node(graph, grid, Vec(y, x))
        end
    end
    return graph
end

local grid, startPos, endPos, startingPositions = getGrid()
local graph = graphFromGrid(grid)
local _, _, distancesFromEndPos = findPath(graph, graph[endPos])

local answer1 = distancesFromEndPos[graph[startPos]]
printf("Part 1: %i\n", answer1)

local minSteps = huge
for i = 1, #startingPositions do
    local d = distancesFromEndPos[graph[startingPositions[i]]]
    if d < minSteps then
        minSteps = d
    end
end

local answer2 = minSteps
printf("Part 2: %i\n", answer2)

return answer1, answer2, profile.finish()

