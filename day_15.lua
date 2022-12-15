local eio = require "libs.eio"
local profile = require "libs.profile"
local Vec2 = require "libs.Vec2"
local Set = require "libs.Set"

local printf = eio.printf
local match = string.match
local tonumber = tonumber
local P = Vec2.makeVec
local abs = math.abs
local max = math.max
local makeSet = Set.new
local addToSet = Set.add
local huge = math.huge
local sort = table.sort
local min = math.min
local floor = math.floor

profile.start()

local function cabdist (a, b)
    return abs(a[1] - b[1]) + abs(a[2] - b[2])
end

local function parseInput ()
    local sensors = {}
    local beacons = {}
    for line in io.lines() do
        local sx, sy, bx, by = match(line, "Sensor at x=(-?%d+), y=(-?%d+): closest beacon is at x=(-?%d+), y=(-?%d+)")
        sensors[#sensors + 1] = P(tonumber(sx), tonumber(sy))
        beacons[#beacons + 1] = P(tonumber(bx), tonumber(by))
    end
    return sensors, beacons
end

local function compareRangePoints (a, b)
    if a.x < b.x then
        return true
    elseif a.x == b.x then
        return a.left and b.right
    else
        return false
    end
end

local function findCoveredRangeAtRow (sensors, beacons, row, minx, maxx)
    local beaconsSet = makeSet()

    -- find all ranges covered by the sensors
    local ranges = {}
    for i = 1, #sensors do
        local sensorPos = sensors[i]
        local beaconPos = beacons[i]
        if beaconPos[2] == row and not beaconsSet[beaconPos] then
            addToSet(beaconsSet, beaconPos)
        end
        local range = cabdist(sensorPos, beaconPos)
        if (sensorPos[2] - range) <= row and row <= (sensorPos[2] + range) then
            local ydist = abs(row - sensorPos[2])
            local left = max(minx, (sensorPos[1] - range) + ydist)
            local right = min(maxx, (sensorPos[1] + range) - ydist)
            if left <= right then
                ranges[#ranges + 1] = {left, right}
            end
        end
    end

    -- find union of disjoint ranges
    local points = {}
    for i = 1, #ranges do
        local range = ranges[i]
        points[#points + 1] = {x = range[1], left = true, id = i}
        points[#points + 1] = {x = range[2], right = true, id = i}
    end
    sort(points, compareRangePoints)
    local rangeUnion = {}
    local currentRange = nil
    for i = 1, #points do
        local point = points[i]
        if point.left then
            if not currentRange then
                currentRange = ranges[point.id]
            elseif point.x <= currentRange[2] then
                -- found overlapping/connected ranges, make current range as long as possible
                currentRange = {currentRange[1], max(currentRange[2], ranges[point.id][2])}
            else
                -- ranges are not overlapping, finish the current range and start a new one
                rangeUnion[#rangeUnion + 1] = currentRange
                currentRange = ranges[point.id]
            end
        end
    end
    -- add the last range
    rangeUnion[#rangeUnion + 1] = currentRange

    return rangeUnion, beaconsSet
end

local function countCoveredPositions (rangeUnion, beaconSet)
    local count = -#beaconSet
    for i = 1, #rangeUnion do
        local range = rangeUnion[i]
        count = count + (range[2] - range[1] + 1)
    end
    return count
end

-- calculate the answer
local sensors, beacons = parseInput()

local rangeUnion, beaconSet = findCoveredRangeAtRow(sensors, beacons, 2000000, -huge, huge)
local answer1 = countCoveredPositions(rangeUnion, beaconSet)
printf("Part 1: %i\n", answer1)

local function tuningFrequency (pos)
    return pos[1] * 4000000 + pos[2]
end

-- store each edge of the sensor as x-intercept of the line it lies on
local posLines = {} -- lines y =  x + C
local negLines = {} -- lines y = -x + C
for i = 1, #sensors do
    local sensorPos = sensors[i]
    local beaconPos = beacons[i]
    local range = cabdist(sensorPos, beaconPos)
    posLines[#posLines + 1] = sensorPos[2] - range - sensorPos[1]
    posLines[#posLines + 1] = sensorPos[2] + range - sensorPos[1]
    negLines[#negLines + 1] = sensorPos[2] - range + sensorPos[1]
    negLines[#negLines + 1] = sensorPos[2] + range + sensorPos[1]
end

-- find lines which are distance 1 apart, calculate the line in-between and store it
local posCandidates = {}
local negCandidates = {}
for i = 1, #posLines do
    for j = i + 1, #posLines do
        if abs(posLines[i] - posLines[j]) == 2 then
            posCandidates[#posCandidates + 1] = floor((posLines[i] + posLines[j]) / 2)
        end
        if abs(negLines[i] - negLines[j]) == 2 then
            negCandidates[#negCandidates + 1] = floor((negLines[i] + negLines[j]) / 2)
        end
    end
end

-- find intersections
local candidateSolutions = {}
for i = 1, #posCandidates do
    for j = i, #negCandidates do
        candidateSolutions[#candidateSolutions + 1] = P(
            floor((negCandidates[j] - posCandidates[i]) / 2),
            floor((posCandidates[i] + negCandidates[j]) / 2))
    end
end

-- find the solution
local solution = nil
for i = 1, #candidateSolutions do
    for j = 1, #sensors do
        if cabdist(sensors[j], candidateSolutions[i]) <= cabdist(sensors[j], beacons[j]) then
            break
        end
    end
    solution = candidateSolutions[i]
end

local answer2 = tuningFrequency(solution)
printf("Part 2: %i\n", answer2)

return answer1, answer2, profile.finish()
