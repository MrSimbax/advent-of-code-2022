local eio = require "libs/eio"
local F = require "libs/functional"
local input = require "libs/input"
local estring = require "libs/estring"
local Vec = require "libs/Vector"
local Set = require "libs/Set"
local emath = require "libs/emath"

local dirFromChar = {
    ['U'] = Vec{0, 1},
    ['D'] = Vec{0, -1},
    ['L'] = Vec{-1, 0},
    ['R'] = Vec{1, 0}
}

local function areTouching (head, tail)
    return Vec.dist(head, tail) < 2
end

local function moveFromLine (line)
    local dir, steps = table.unpack(estring.split(line))
    return {dir, tonumber(steps)}
end

local function moves ()
    return F.map(moveFromLine, input.lines())
end

local function dirTowardsHead (head, tail)
    return Vec(F.map(emath.sgn, head - tail))
end

local function updateTail (rope, lastKnotPositions)
    for i = 2, #rope do
        local head = rope[i - 1]
        local tail = rope[i]
        if not areTouching(head, tail) then
            tail = tail + dirTowardsHead(head, tail)
            if i == #rope then
                Set.add(lastKnotPositions, tostring(tail))
            end
            rope[i] = tail
        end
    end
end

local function makeRope (ropeLength)
    return F.sequence(function (_) return Vec{0, 0} end, ropeLength)
end

local function moveRope (moves, rope)
    local lastKnotPositions = Set.new{tostring(rope[#rope])}
    for _, move in ipairs(moves) do
        local dir, steps = table.unpack(move)
        for _ = 1, steps do
            rope[1] = rope[1] + dirFromChar[dir]
            updateTail(rope, lastKnotPositions)
        end
    end
    return #lastKnotPositions
end

eio.printf("Part 1: %i\n", moveRope(moves(), makeRope(2)))
eio.printf("Part 2: %i\n", moveRope(moves(), makeRope(10)))
