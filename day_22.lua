local eio = require "libs.eio"
local profile = require "libs.profile"
local Vec2 = require "libs.Vec2"
local Vec3 = require "libs.Vec3"
local Deque = require "libs.Deque"
local sequence = require "libs.sequence"

local lines = eio.lines
local printf = eio.printf
local tonumber = tonumber
local match = string.match
local len = string.len
local sub = string.sub
local min = math.min
local max = math.max
local huge = math.huge
local P2D = Vec2.makeVec
local P3D = Vec3.makeVec
local cross = Vec3.cross
local floor = math.floor
local makeDual = sequence.dual

profile.start()

local function parseInput ()
    local map = {}
    local minys = {}
    local maxys = {}
    local minxs = {}
    local maxxs = {}
    local instructionsLine = 0
    for y, line in ipairs(lines()) do
        if line == "" then
            instructionsLine = lines()[y + 1]
            break
        end
        map[y] = {}
        for x = 1, len(line) do
            local c = sub(line, x, x)
            map[y][x] = c
            if c ~= " " then
                minys[x] = min(minys[x] or huge, y)
                maxys[x] = max(maxys[x] or -1, y)
                minxs[y] = min(minxs[y] or huge, x)
                maxxs[y] = max(maxxs[y] or -1, x)
            end
        end
    end

    local instructions = {}
    local i = 1
    while i <= len(instructionsLine) do
        local n = match(instructionsLine, "^(%d+)", i)
        local r = match(instructionsLine, "^(%a)", i)
        if n then
            instructions[#instructions + 1] = tonumber(n)
            i = i + len(n)
        else
            instructions[#instructions + 1] = r
            i = i + 1
        end
    end

    return map, minys, maxys, minxs, maxxs, instructions
end

local WEST = P2D(0, 1)
local NORTH = P2D(1, 0)
local EAST = P2D(0, -1)
local SOUTH = P2D(-1, 0)

local DIRS = {NORTH, EAST, SOUTH, WEST}

local ROT_LEFT = P2D(0, 1)
local ROT_RIGHT = P2D(0, -1)
local ROT_BACK = P2D(-1, 0)

local rotVecFromInstr = {
    ["L"] = ROT_LEFT,
    ["R"] = ROT_RIGHT
}

local facingFromDir = {
    [WEST] = 0,
    [NORTH] = 1,
    [EAST] = 2,
    [SOUTH] = 3
}

local function password (pos, dir)
    return 1000 * pos[1] + 4 * pos[2] + facingFromDir[dir]
end

local function rot (v, u)
    return P2D(v[1] * u[1] - v[2] * u[2], v[1] * u[2] + v[2] * u[1])
end

local function walkTorus (map, minys, maxys, minxs, maxxs, instructions)
    local pos = P2D(1, minxs[1])
    local dir = WEST
    for _, instr in ipairs(instructions) do
        if type(instr) == "number" then
            while instr > 0 do
                local nextPos = pos + dir
                local minx = minxs[pos[1]]
                local maxx = maxxs[pos[1]]
                local miny = minys[pos[2]]
                local maxy = maxys[pos[2]]
                if nextPos[2] < minx then
                    nextPos = P2D(nextPos[1], maxx)
                elseif nextPos[2] > maxx then
                    nextPos = P2D(nextPos[1], minx)
                elseif nextPos[1] < miny then
                    nextPos = P2D(maxy, nextPos[2])
                elseif nextPos[1] > maxy then
                    nextPos = P2D(miny, nextPos[2])
                end
                if map[nextPos[1]][nextPos[2]] == "#" then
                    break
                end
                pos = nextPos
                instr = instr - 1
            end
        else
            dir = rot(dir, rotVecFromInstr[instr])
        end
    end
    return pos, dir
end

local UP = P3D(0, 0, 1)
local DOWN = P3D(0, 0, -1)
local LEFT = P3D(-1, 0, 0)
local RIGHT = P3D(1, 0, 0)
local FRONT = P3D(0, 1, 0)
local BACK = P3D(0, -1, 0)

local function findSize (minys, maxys, minxs, maxxs)
    local mindiff = huge
    for x = 1, #minys do
        mindiff = min(maxys[x] - minys[x] + 1, mindiff)
    end
    for y = 1, #minxs do
        mindiff = min(maxxs[y] - minxs[y] + 1, mindiff)
    end
    return mindiff
end

local map, minys, maxys, minxs, maxxs, instructions = parseInput()

local answer1 = password(walkTorus(map, minys, maxys, minxs, maxxs, instructions))
printf("Part 1: %i\n", answer1)

local SIZE = findSize(minys, maxys, minxs, maxxs)
local HALF_SIZE = (SIZE - 1) / 2

local function cutMap (map)
    local faces = {}
    local faceFromTile = {}
    for miny = 1, #map, SIZE do
        for minx = 1, #map[miny], SIZE do
            if map[miny][minx] ~= " " then
                local face = {}
                face.minx = minx
                face.maxx = minx + SIZE - 1
                face.miny = miny
                face.maxy = miny + SIZE - 1
                face.tiley = floor(miny / SIZE) + 1
                face.tilex = floor(minx / SIZE) + 1
                faces[#faces + 1] = face
                faceFromTile[P2D(face.tiley, face.tilex)] = face
            end
        end
    end
    return faces, faceFromTile
end

local function makeEdges (face, edge2d, neighbourFaceNormal)
    face.edges = {[edge2d] = neighbourFaceNormal}
    face.edges[rot(edge2d, ROT_RIGHT)] = -cross(face.normal, neighbourFaceNormal)
    face.edges[rot(edge2d, ROT_BACK)] = -neighbourFaceNormal
    face.edges[rot(edge2d, ROT_LEFT)] = cross(face.normal, neighbourFaceNormal)
    face.edgesDual = makeDual(face.edges)
end

local function findCubeFaces (faces, faceFromTile)
    local faceFromNormal = {}

    local Q = Deque.new()
    local visited = {}

    faces[1].normal = UP
    faceFromNormal[UP] = faces[1]
    makeEdges(faces[1], NORTH, FRONT)
    Q:pushLast(faces[1])

    while not Q:isEmpty() do
        local face = Q:popFirst()
        if not visited[face] then
            visited[face] = true
            local tile = P2D(face.tiley, face.tilex)
            for _, dir in ipairs(DIRS) do
                local neighbourFace = faceFromTile[tile + dir]
                if neighbourFace and neighbourFace ~= face then
                    neighbourFace.normal = face.edges[dir]
                    faceFromNormal[neighbourFace.normal] = neighbourFace
                    makeEdges(neighbourFace, -dir, face.normal)
                    Q:pushLast(neighbourFace)
                end
            end
        end
    end

    return faceFromNormal
end

local function facePosFromMapPos (face, mapPos)
    return P2D(mapPos[1] - face.miny, mapPos[2] - face.minx)
end

local function mapPosFromFacePos (face, facePos)
    return P2D(facePos[1] + face.miny, facePos[2] + face.minx)
end

local function complexQuotient (z, w)
    local l = w[1] * w[1] + w[2] * w[2]
    return P2D((z[1] * w[1] + z[2] * w[2]) / l, (z[2] * w[1] - z[1] * w[2]) / l)
end

local function walkCube (map, faces, faceFromNormal, instructions)
    local pos = P2D(1, minxs[1])
    local dir = WEST
    local face = faces[1]
    for _, instr in ipairs(instructions) do
        if type(instr) == "number" then
            while instr > 0 do
                local nextFace = face
                local nextDir = dir
                local nextPos = pos + dir
                local minx = face.minx
                local maxx = face.maxx
                local miny = face.miny
                local maxy = face.maxy
                if nextPos[2] < minx or nextPos[2] > maxx or nextPos[1] < miny or nextPos[1] > maxy then
                    -- we are out of bounds of the current face, we have to find our position on a new face
                    nextFace = faceFromNormal[face.edges[dir]]
                    nextDir = -nextFace.edgesDual[face.normal]

                    -- convert current position to position relative to top-left of the current face: (0, SIZE - 1)
                    local facePos = facePosFromMapPos(face, pos)

                    -- translate it so that the coordinates are relative to the center of the face
                    local facePosRelativeToFaceCenter = P2D(facePos[1] - HALF_SIZE, facePos[2] - HALF_SIZE)

                    -- rotate so that rotated original direction is matching the direction we'll have on the new face
                    local rotVec = complexQuotient(nextDir, dir)
                    local faceNewPos = rot(facePosRelativeToFaceCenter, rotVec)

                    -- now translate back to pos relative to the top-left of the face and move forward,
                    -- wrap around so that we end up on the opposite edge
                    local faceNewPosAfterMoveOnFaceTorus = P2D(
                        (faceNewPos[1] + HALF_SIZE + nextDir[1]) % SIZE,
                        (faceNewPos[2] + HALF_SIZE + nextDir[2]) % SIZE)

                    -- convert back to map pos treating face pos as if we're on the new face
                    nextPos = mapPosFromFacePos(nextFace, faceNewPosAfterMoveOnFaceTorus)
                end
                if map[nextPos[1]][nextPos[2]] == "#" then
                    break
                end
                face = nextFace
                dir = nextDir
                pos = nextPos
                instr = instr - 1
            end
        else
            dir = rot(dir, rotVecFromInstr[instr])
        end
    end
    return pos, dir
end

local faces, faceFromTile = cutMap(map)
local faceFromNormal = findCubeFaces(faces, faceFromTile)
local answer2 = password(walkCube(map, faces, faceFromNormal, instructions))
printf("Part 2: %i\n", answer2)

return answer1, answer2, profile.finish()
