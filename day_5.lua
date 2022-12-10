local eio = require "libs/eio"
local sequence = require "libs/sequence"

local input = eio.lines()
local printf = eio.printf
local sub = string.sub
local find = sequence.find
local equals = sequence.equals
local match = string.match
local concat = table.concat
local move = table.move

local nils = {}
local blank = find(equals(""), input)

local function parseStacks ()
    local stacks = {}
    for j = 2, #input[blank - 1], 4 do
        local stack = {}
        for i = blank - 2, 1, -1 do
            local c = sub(input[i], j, j)
            if c == " " then
                break
            end
            stack[#stack + 1] = c
        end
        stacks[#stacks + 1] = stack
    end
    return stacks
end

local function parseMove (line)
    return match(line, "move (%d+) from (%d) to (%d)")
end

local function tops (stacks)
    local ts = {}
    for i = 1, #stacks do
        local stack = stacks[i]
        ts[#ts + 1] = stack[#stack]
    end
    return concat(ts)
end

local function crateMover9000 (howMany, from, to)
    for _ = 1, howMany do
        to[#to + 1] = from[#from]
        from[#from] = nil
    end
end

local function crateMover9001 (howMany, from, to)
    local fromIdx = #from - howMany + 1
    move(from, fromIdx, #from, #to + 1, to)
    move(nils, 1, howMany, fromIdx, from)
end

local function moveCrates (mover)
    local stacks = parseStacks()
    for i = blank + 1, #input do
        local howMany, from, to = parseMove(input[i])
        mover(howMany, stacks[tonumber(from)], stacks[tonumber(to)])
    end
    return tops(stacks)
end

printf("Part 1: %s\n", moveCrates(crateMover9000))
printf("Part 2: %s\n", moveCrates(crateMover9001))
