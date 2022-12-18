local eio = require "libs.eio"
local profile = require "libs.profile"
local Vec3 = require "libs.Vec3"
local Deque = require "libs.Deque"
local Vec2 = require "libs.Vec2"

local printf = eio.printf
local Face = Vec2.makeVec
local P = Vec3.makeVec
local match = string.match
local huge = math.huge

profile.start()

local UP = P(0, 1, 0)
local DOWN = P(0, -1, 0)
local LEFT = P(-1, 0, 0)
local RIGHT = P(1, 0, 0)
local FORWARD = P(0, 0, 1)
local BACKWARD = P(0, 0, -1)

local NORMALS = {UP, DOWN, LEFT, RIGHT, FORWARD, BACKWARD}
local NORMALS_DUAL ={
    [UP] = 1,
    [DOWN] = 2,
    [LEFT] = 3,
    [RIGHT] = 4,
    [FORWARD] = 5,
    [BACKWARD] = 6
}

local function parseInput ()
    local cubes = {}
    local cubesSet = {}
    local smallestCube = P(huge, huge, huge)
    for line in io.lines() do
        local x, y, z = match(line, "(%d+),(%d+),(%d+)")
        local pos = P(tonumber(x), tonumber(y), tonumber(z))
        cubes[#cubes + 1] = pos
        cubesSet[pos] = #cubes
        if pos < smallestCube then
            smallestCube = pos
        end
    end
    return cubes, cubesSet, smallestCube
end

local function findTotalArea (cubes, cubesSet)
    -- Iterate over all cubes, count surface if there's no cube on it
    local totalArea = 0
    for i = 1, #cubes do
        local cube = cubes[i]
        for _, normal in ipairs(NORMALS) do
            if not cubesSet[cube + normal] then
                totalArea = totalArea + 1
            end
        end
    end
    return totalArea
end

local function findTotalExteriorArea (cubes, cubesSet, smallestCube)
    -- We'll walk around only the exterior surface of the droplet

    local Q = Deque.new()
    local visited = {}

    -- Start BFS with any exterior surface
    Q:pushLast(Face(NORMALS_DUAL[DOWN], cubesSet[smallestCube]))

    local totalArea = 0
    while not Q:isEmpty() do
        local face = Q:popFirst()
        if not visited[face] then
            visited[face] = true

            -- Only exterior surfaces are in the queue, so add it to the total
            totalArea = totalArea + 1

            local faceNormal, cubePos = NORMALS[face[1]], cubes[face[2]]

            for _, cubeFaceNormal in ipairs(NORMALS) do
                if faceNormal ~= cubeFaceNormal and -faceNormal ~= cubeFaceNormal then
                    -- cubeFaceNormal is a neighbour face on the current cube
                    -- one can think of it as iterating over the edges of the current exterior face
                    -- each edge on the exterior must be connected to exactly two surfaces
                    -- faceNormal is the normal of the first face, cubeFaceNormal is the second
                    -- now we must consider three cases depending on what cubes are around the edge
                    if cubesSet[cubePos + faceNormal + cubeFaceNormal] then
                        -- there's a cube diagonally connected to the edge
                        Q:pushLast(Face(NORMALS_DUAL[-cubeFaceNormal], cubesSet[cubePos + faceNormal + cubeFaceNormal]))
                    elseif cubesSet[cubePos + cubeFaceNormal] then
                        -- there's a cube on the neighbouring face
                        Q:pushLast(Face(NORMALS_DUAL[faceNormal], cubesSet[cubePos + cubeFaceNormal]))
                    else
                        -- there's no cube on the neighbouring face
                        Q:pushLast(Face(NORMALS_DUAL[cubeFaceNormal], cubesSet[cubePos]))
                    end
                end
            end
        end
    end
    return totalArea
end

local cubes, cubesSet, smallestCube = parseInput()

local answer1 = findTotalArea(cubes, cubesSet)
printf("Part 1: %i\n", answer1)

local answer2 = findTotalExteriorArea(cubes, cubesSet, smallestCube)
printf("Part 2: %i\n", answer2)

return answer1, answer2, profile.finish()
