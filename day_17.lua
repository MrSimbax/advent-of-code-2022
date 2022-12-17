local eio = require "libs.eio"
local profile = require "libs.profile"
local Vec2 = require "libs.Vec2"
local deque = require "libs.Deque"

local printf = eio.printf
local floor = math.floor
local yield = coroutine.yield
local cowrap = coroutine.wrap
local concat = table.concat
local len = string.len
local sub = string.sub
local P = Vec2.makeVec
local write = io.write

profile.start()

local DIRS = {
    P(0, 1),
    P(-1, 0),
    P(1, 0),
    P(0, -1)
}

local WIDTH = 7
local DOWN = P(0, -1)

-- offsets from top-left corner
local rocks = {
    {P(0, 0), P(1, 0), P(2, 0), P(3, 0), width = 4, height = 1},
    {P(1, 0), P(0, -1), P(1, -1), P(2, -1), P(1, -2), width = 3,height = 3},
    {P(2, 0), P(2, -1), P(0, -2), P(1, -2), P(2, -2), width = 3, height = 3},
    {P(0, 0), P(0, -1), P(0, -2), P(0, -3), width = 1, height = 4},
    {P(0, 0), P(0, -1), P(1, 0), P(1, -1), width = 2, height = 2}
}

local function parseInput ()
    local moves
    for line in io.lines() do
        moves = line
        break
    end
    return moves
end

local function coRocks ()
    local i = 1
    local n = #rocks
    while true do
        yield(i, rocks[i])
        i = i % n + 1
    end
end

local function getRocks ()
    return cowrap(coRocks)
end

local dirFromChar = {
    [">"] = P(1, 0),
    ["<"] = P(-1, 0)
}

local function coMoves (str)
    local i = 1
    local n = len(str)
    while true do
        yield(i, dirFromChar[sub(str, i, i)])
        i = i % n + 1
    end
end

local function getMoves (str)
    local function f ()
        coMoves(str)
    end
    return cowrap(f)
end

local function isInBounds (pos, rock)
    return 1 <= pos[1] and pos[1] + rock.width - 1 <= WIDTH and 1 <= pos[2] - rock.height + 1
end

local function isBlocked (board, pos, rock)
    for _, offset in ipairs(rock) do
        if board[pos + offset] then
            return true
        end
    end
    return false
end

local function checkCollision (board, pos, rock)
    return not isInBounds(pos, rock) or isBlocked(board, pos, rock)
end

local function restRock (board, pos, rock)
    for _, offset in ipairs(rock) do
        board[pos + offset] = true
    end
end

local function drawBoard (board, rock, pos, height)
    local p = P(1, height)
    printf("%13i |", p[2])
    while p[2] > 0 do
        for _, offset in ipairs(rock) do
            if p == pos + offset then
                write("@")
                goto move
            end
        end
        if board[p] then
            write("#")
            goto move
        end
        write(" ")

        ::move::
        p = p + P(1, 0)
        if p[1] > WIDTH then
            p = P(1, p[2] - 1)
            printf("|\n%13i |", p[2])
        end
    end
    write("-------|\n\n")
end

local function hashTopOfTheBoard (board, height)
    -- top is the shape of the board which can potentially be modified in next move
    -- run BFS from the top row, explore the holes, and save the coordinates of the walls to an array
    local topBoard = {}
    local Q = deque.new()
    for x = 1, WIDTH do
        Q:pushLast(P(x, height))
    end
    local visited = {}
    while not Q:isEmpty() do
        local p = Q:popFirst()
        if visited[p] or not (1 <= p[1] and p[1] <= WIDTH and 1 <= p[2] and p[2] <= height) then
            goto continue
        end
        visited[p] = true
        if board[p] then
            topBoard[#topBoard + 1] = tostring(P(p[1], height - p[2]))
        else
            for _, dir in ipairs(DIRS) do
                Q:pushLast(p + dir)
            end
        end
        ::continue::
    end
    return concat(topBoard, ",")
end

local function hashState (rockIdx, moveIdx, board, height)
    return rockIdx .. "," .. moveIdx .. "," .. hashTopOfTheBoard(board, height)
end

local input = parseInput()

local function runSim (numberOfRocks)
    local board = {}
    local pos = nil -- top-left
    local height = 0
    local states = {}
    local heights = {}
    local nextMove = getMoves(input)
    local nextRock = getRocks()
    for i = 1, numberOfRocks do
        local rockIdx, rock = nextRock()
        pos = P(3, height + 3 + rock.height)

        while true do
            -- print("BEGIN")
            -- drawBoard(board, rock, pos, height + 8)
            -- print("hash", hashTopOfTheBoard(board, height))

            local moveIdx, move = nextMove()
            local pos1 = pos + move
            if checkCollision(board, pos1, rock) then
                pos1 = pos
            end

            -- print("AFTER WIND")
            -- drawBoard(board, rock, pos1, height + 8)
            -- print("hash", hashTopOfTheBoard(board, height))

            local pos2 = pos1 + DOWN
            if checkCollision(board, pos2, rock) then
                restRock(board, pos1, rock)
                if pos1[2] > height then
                    height = pos1[2]
                end
                heights[i] = height

                -- print("ROCK", i)
                -- drawBoard(board, rock, pos1, height)
                -- print("hash", hashTopOfTheBoard(board, height))
                -- print("-----------------------------------------\n")

                local h = hashState(rockIdx, moveIdx, board, height)
                if states[h] then
                    -- print("FOUND CYCLE", i, height, h)
                    -- print("FIRST APPEARANCE", states[h].iteration, states[h].height)

                    local lengthOfBeginning = states[h].iteration - 1
                    local lengthOfCycle = i - 1 - lengthOfBeginning

                    return heights, lengthOfBeginning, lengthOfCycle
                else
                    states[h] = {iteration = i, height = height}
                end

                break
            else
                pos = pos2
            end
        end
    end
    return height
end

local function findTowerHeight (numberOfRocks, heights, lengthOfBeginning, lengthOfCycle)
    local initialHeight = heights[lengthOfBeginning]
    local cycleHeight = heights[lengthOfBeginning + lengthOfCycle] - initialHeight
    local numberOfCycles = floor((numberOfRocks - lengthOfBeginning) / lengthOfCycle)
    local restOfCycleLength = (numberOfRocks - lengthOfBeginning) % lengthOfCycle
    local heightAfterRestOfCycle = heights[lengthOfBeginning + restOfCycleLength] - initialHeight
    return initialHeight + numberOfCycles * cycleHeight + heightAfterRestOfCycle
end

local heights, lengthOfBeginning, lengthOfCycle = runSim(1000000000000)

local answer1 = findTowerHeight(2022, heights, lengthOfBeginning, lengthOfCycle)
printf("Part 1: %i\n", answer1)

local answer2 = findTowerHeight(1000000000000, heights, lengthOfBeginning, lengthOfCycle)
printf("Part 2: %i\n", answer2)

return answer1, answer2, profile.finish()
