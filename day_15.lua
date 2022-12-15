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

local MIN_COORD = 0
local MAX_COORD = 4000000

local tuningFrequency = nil
for y = MIN_COORD, MAX_COORD do
    rangeUnion = findCoveredRangeAtRow(sensors, beacons, y, MIN_COORD, MAX_COORD)
    if #rangeUnion > 1 then -- edge case not covered: x=0 or x=4000000
        local range1 = rangeUnion[1]
        local x = range1[2] + 1
        tuningFrequency = x * MAX_COORD + y
        break
    end
end

local answer2 = tuningFrequency
printf("Part 2: %i\n", answer2)

return answer1, answer2, profile.finish()
