local eio = require "libs/eio"
local sequence = require "libs/sequence"
local Set = require "libs/Set"
local emath = require "libs/emath"

local input = eio.lines()
local printf = eio.printf
local sgn = emath.sgn
local match = string.match
local makeSet = Set.fromSeq
local insert = Set.add
local makeSequence = sequence.sequence

local dirFromChar = {
    ['U'] = {0, 1},
    ['D'] = {0, -1},
    ['L'] = {-1, 0},
    ['R'] = {1, 0}
}

local function areTouching (head, tail)
    local a = head[1] - tail[1]
    local b = head[2] - tail[2]
    return a * a + b * b < 4
end

local function vec2str (v)
    return v[1] .. ',' .. v[2]
end

local function updateTail (rope, lastKnotPositions)
    for i = 2, #rope do
        local head = rope[i - 1]
        local tail = rope[i]
        if not areTouching(head, tail) then
            tail[1] = tail[1] + sgn(head[1] - tail[1])
            tail[2] = tail[2] + sgn(head[2] - tail[2])
            if i == #rope then
                insert(lastKnotPositions, vec2str(tail))
            end
            rope[i] = tail
        end
    end
end

local function makeRope (ropeLength)
    return makeSequence(function (_) return {0, 0} end, ropeLength)
end

local function moveRope (lines, rope)
    local lastKnotPositions = makeSet{vec2str(rope[#rope])}
    for i = 1, #lines do
        local dir, steps = match(lines[i], "(%a) (%d+)")
        dir = dirFromChar[dir]
        steps = tonumber(steps)
        for _ = 1, steps do
            local head = rope[1]
            head[1] = head[1] + dir[1]
            head[2] = head[2] + dir[2]
            updateTail(rope, lastKnotPositions)
        end
    end
    return #lastKnotPositions
end

printf("Part 1: %i\n", moveRope(input, makeRope(2)))
printf("Part 2: %i\n", moveRope(input, makeRope(10)))
