local eio = require "libs/eio"
local F = require "libs/functional"
local input = require "libs/input"

local function parseStackInColumn (column, stacksContents)
    return
        F.reversed(
        F.skipWhile(function (crate) return crate == " " end,
        F.map(function (row) return row:sub(column, column) end,
        stacksContents)))
end

local function parseStacks (stacksStr)
    local stacks = {}
    local stacksContents, stacksNumbers = F.take(#stacksStr - 1, stacksStr), F.last(stacksStr)
    local column = stacksNumbers:find("%d", 1)
    while column do
        table.insert(stacks, parseStackInColumn(column, stacksContents))
        column = stacksNumbers:find("%d", column + 1)
    end
    return stacks
end

local function parseMoves (movesStr)
    return F.map(function (moveStr)
        return F.map(tonumber, table.pack(string.match(moveStr, "move (%d+) from (%d) to (%d)")))
    end, movesStr)
end

local function parseInput ()
    local stacks, moves = table.unpack(F.split("", input.lines()))
    return parseStacks(stacks), parseMoves(moves)
end

local function moveCratesWithCrateMover9000 (howMany, fromStack, toStack)
    for _ = 1, howMany do
        local crate = table.remove(fromStack)
        table.insert(toStack, crate)
    end
end

local function rearrangeStacks (moveCrates, stacks, moves)
    for _, move in ipairs(moves) do
        local howMany, from, to = table.unpack(move)
        moveCrates(howMany, stacks[from], stacks[to])
    end
    return stacks
end

local function topsOfStacks (stacks)
    return table.concat(F.map(F.last, stacks))
end

eio.printf("Part 1: %s\n", topsOfStacks(rearrangeStacks(moveCratesWithCrateMover9000, parseInput())))

local nils = {}

local function moveCratesWithCrateMover9001 (howMany, fromStack, toStack)
    local fromCrate = #fromStack - howMany + 1
    table.move(fromStack, fromCrate, #fromStack, #toStack + 1, toStack)
    table.move(nils, 1, howMany, fromCrate, fromStack)
end

eio.printf("Part 2: %s\n", topsOfStacks(rearrangeStacks(moveCratesWithCrateMover9001, parseInput())))
