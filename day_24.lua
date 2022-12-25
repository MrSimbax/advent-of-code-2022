local eio = require "libs.eio"
local profile = require "libs.profile"
local Vec2 = require "libs.Vec2"
local Set = require "libs.Set"

local printf = eio.printf
local len = string.len
local sub = string.sub
local huge = math.huge
local P = Vec2.makeVec
local makeSet = Set.new
local add = Set.add

profile.start()

local N = P(0, -1)
local S = P(0, 1)
local E = P(1, 0)
local W = P(-1, 0)

local DIRS = {N, S, W, E}

local dirFromChar = {
    ["^"] = N,
    ["v"] = S,
    [">"] = E,
    ["<"] = W
}

local function parseInput ()
    local blizzards = {}
    local occupiedPositions = makeSet()
    local walls = makeSet()
    local maxx = -huge
    local maxy = -huge

    local y = 1
    for line in io.lines() do
        maxx = len(line)
        for x = 1, maxx do
            local c = sub(line, x, x)
            if c == "#" then
                add(walls, P(x, y))
            elseif c == "^" or c == ">" or c == "v" or c == "<" then
                blizzards[#blizzards + 1] = {pos = P(x, y), dir = dirFromChar[c]}
                add(occupiedPositions, P(x, y))
            end
        end
        maxy = y
        y = y + 1
    end

    local startPos = P(2, 1)
    local finishPos = P(maxx - 1, maxy)
    add(walls, startPos + N)
    add(walls, finishPos + S)
    walls.maxx = maxx
    walls.maxy = maxy

    return walls, blizzards, occupiedPositions, startPos, finishPos
end

local function getNextBlizzards (walls, blizzards)
    local nextOccupiedPositions = makeSet()
    for _, blizzard in ipairs(blizzards) do
        blizzard.pos = blizzard.pos + blizzard.dir
        if blizzard.pos[1] >= walls.maxx then
            blizzard.pos = P(2, blizzard.pos[2])
        elseif blizzard.pos[1] <= 1 then
            blizzard.pos = P(walls.maxx - 1, blizzard.pos[2])
        elseif blizzard.pos[2] >= walls.maxy then
            blizzard.pos = P(blizzard.pos[1], 2)
        elseif blizzard.pos[2] <= 1 then
            blizzard.pos = P(blizzard.pos[1], walls.maxy - 1)
        end
        add(nextOccupiedPositions, blizzard.pos)
    end
    return blizzards, nextOccupiedPositions
end

local function findShortestPath (minute, walls, blizzards, occupiedPositions, startPos, finishPos)
    local positions = makeSet()
    add(positions, startPos)
    while true do
        local nextPositions = makeSet()
        blizzards, occupiedPositions = getNextBlizzards(walls, blizzards)
        for pos in pairs(positions) do
            if pos == finishPos then
                return minute, blizzards, occupiedPositions
            end

            if not occupiedPositions[pos] then
                add(nextPositions, pos)
            end

            for _, dir in ipairs(DIRS) do
                local nextPos = pos + dir
                if not occupiedPositions[nextPos] and not walls[nextPos] then
                    add(nextPositions, nextPos)
                end
            end
        end
        positions = nextPositions
        minute = minute + 1
    end
end

local walls, blizzards, occupiedPositions, startPos, finishPos = parseInput()

local answer1, blizzards, occupiedPositions = findShortestPath(0, walls, blizzards, occupiedPositions, startPos, finishPos)
printf("Part 1: %i\n", answer1)

local minuteBack, blizzards, occupiedPositions = findShortestPath(answer1 + 1, walls, blizzards, occupiedPositions, finishPos, startPos)
local answer2 = findShortestPath(minuteBack + 1, walls, blizzards, occupiedPositions, startPos, finishPos)
printf("Part 2: %i\n", answer2)

return answer1, answer2, profile.finish()
