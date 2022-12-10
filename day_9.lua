local eio = require "libs.eio"
local profile = require "libs.profile"
local sequence = require "libs.sequence"
local Set = require "libs.Set"
local emath = require "libs.emath"
local Vec2 = require "libs.Vec2"

local input = eio.lines()
local printf = eio.printf
local sgn = emath.sgn
local match = string.match
local makeSet = Set.fromSeq
local insert = Set.add
local makeSequence = sequence.sequence
local Vec = Vec2.makeVec
local map = Vec2.map
local dist = Vec2.dist

profile.start()

local dirFromChar = {
    ['U'] = Vec(0, 1),
    ['D'] = Vec(0, -1),
    ['L'] = Vec(-1, 0),
    ['R'] = Vec(1, 0)
}

local function areTouching (head, tail)
    return dist(head, tail) < 2
end

local function updateTail (rope, lastKnotPositions)
    for i = 2, #rope do
        local head = rope[i - 1]
        local tail = rope[i]
        if not areTouching(head, tail) then
            tail = tail + map(sgn, head - tail)
            if i == #rope then
                insert(lastKnotPositions, tail)
            end
            rope[i] = tail
        end
    end
end

local function makeRope (ropeLength)
    return makeSequence(function (_) return Vec(0, 0) end, ropeLength)
end

local function moveRope (lines, rope)
    local lastKnotPositions = makeSet{rope[#rope]}
    for i = 1, #lines do
        local dir, steps = match(lines[i], "(%a) (%d+)")
        dir = dirFromChar[dir]
        steps = tonumber(steps)
        for _ = 1, steps do
            rope[1] = rope[1] + dir
            updateTail(rope, lastKnotPositions)
        end
    end
    return #lastKnotPositions
end

printf("Part 1: %i\n", moveRope(input, makeRope(2)))
printf("Part 2: %i\n", moveRope(input, makeRope(10)))

profile.finish()
