local eio = require "libs.eio"
local profile = require "libs.profile"
local Vec2 = require "libs.Vec2"
local estring = require "libs.estring"

local input = eio.lines()
local printf = eio.printf
local Vec = Vec2.makeVec
local Grid = Vec2.allowVec2Indices
local split = estring.split
local norm = Vec2.norm
local vmap = Vec2.map
local vidiv = Vec2.idiv

profile.start()

local function posFromStr (str)
    return vmap(tonumber, split(str, ","))
end

local function gridSet (grid, pos, value)
    grid[pos] = value
    if pos[2] > grid.bottom then
        grid.bottom = pos[2]
    end
end

local function getGrid ()
    local grid = Grid{}
    grid.bottom = -1
    for i = 1, #input do
        local line = input[i]
        local positions = split(line)
        local startPos = posFromStr(positions[1])
        gridSet(grid, startPos, "#")
        for j = 3, #positions, 2 do
            local endPos = posFromStr(positions[j])
            gridSet(grid, endPos, "#")
            local dir = endPos - startPos
            dir = vidiv(dir, norm(dir))
            local pos = startPos + dir
            while pos ~= endPos do
                gridSet(grid, pos, "#")
                pos = pos + dir
            end
            startPos = endPos
        end
    end
    return grid
end

local directions = {
    Vec(0, 1),
    Vec(-1, 1),
    Vec(1, 1)
}

local function runSimulation (grid, isSpaceFree, shouldStop)
    local sand = Vec(500, 0)
    local restCount = 0
    while true do
        local nextSand
        local rest = true
        for i = 1, #directions do
            nextSand = sand + directions[i]
            if isSpaceFree(grid, nextSand) then
                rest = false
                break
            end
        end
        if rest then
            grid[sand] = "o"
            restCount = restCount + 1
            sand = Vec(500, 0)
        else
            sand = nextSand
        end
        if shouldStop(grid, sand) then
            break
        end
    end
    return restCount
end

local function isBelowBottom (grid, pos)
    return pos[2] > grid.bottom
end

local function isNotOccupied (grid, pos)
    return not grid[pos]
end

local answer1 = runSimulation(getGrid(), isNotOccupied, isBelowBottom)
printf("Part 1: %i\n", answer1)

local function cantPour (grid, _)
    return grid[Vec(500, 0)] == "o"
end

local function isNotOccupiedAndNotFloor (grid, pos)
    return not grid[pos] and pos[2] < (grid.bottom + 2)
end

local answer2 = runSimulation(getGrid(), isNotOccupiedAndNotFloor, cantPour)
printf("Part 2: %i\n", answer2)

return answer1, answer2, profile.finish()

