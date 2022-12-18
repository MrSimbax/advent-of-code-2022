local eio = require "libs.eio"
local profile = require "libs.profile"
local pathfinding = require "libs.pathfinding"
local sequence = require "libs.sequence"
local bitset = require "libs.bitset"

local printf = eio.printf
local match = string.match
local tonumber = tonumber
local sort = table.sort
local gmatch = string.gmatch
local findDistances = pathfinding.findShortestPath
local intersect = bitset.intersection
local setBit = bitset.setBit
local dual = sequence.dual
local testBit = bitset.testBit

profile.start()

local function makeValve (valveName, flowRate, tunnels)
    return {
        name = valveName,
        rate = flowRate,
        tunnels = tunnels
    }
end

local function parseInput ()
    local valves = {}
    for line in io.lines() do
        local valveName, flowRate, tunnelsStr = match(line, "^Valve (%a+) has flow rate=(%d+); tunnels? leads? to valves? (.+)$")
        local tunnels = {}
        for tunnelStr in gmatch(tunnelsStr, "[^ ]+") do
            tunnels[#tunnels + 1] = match(tunnelStr, "([^,]+)")
        end
        valves[valveName] = makeValve(valveName, tonumber(flowRate), tunnels)
    end
    return valves
end

local function filterOutStuckValves (valves)
    local res = {}
    for valveName, valve in pairs(valves) do
        if valve.rate ~= 0 or valveName == "AA" then
            res[valveName] = valve
        end
    end
    return res
end

local function valve2node (graph, valves, valve)
    local node = graph[valve.name]
    if not node then
        node = {name = valve.name, adj = {}}
        graph[valve.name] = node
        for _, tunnel in ipairs(valve.tunnels) do
            node.adj[{label = 1, to = valve2node(graph, valves, valves[tunnel])}] = true
        end
    end
    return node
end

local function buildGraphFromValves (valves)
    local graph = {}
    for valveName, valve in pairs(valves) do
        graph[valveName] = valve2node(graph, valves, valve)
    end
    return graph
end

local function findUsefulDistances (usefulValves, graph, dualNames)
    local distancesFrom = {}
    for valveName in pairs(usefulValves) do
        local _, _, d = findDistances(graph, graph[valveName])
        local distanceToValve = {}
        for neighbourValveName in pairs(usefulValves) do
            if valveName ~= neighbourValveName then
                distanceToValve[dualNames[neighbourValveName]] = d[graph[neighbourValveName]]
            end
        end
        distancesFrom[dualNames[valveName]] = distanceToValve
    end
    return distancesFrom
end

local function valves2rates (valves, dualNames)
    local rs = {}
    for valveName, valve in pairs(valves) do
        local idx = dualNames[valveName]
        if idx then
            rs[idx] = valve.rate
        end
    end
    return rs
end

local function getNames (valves)
    local rs = {}
    rs[0] = "AA"
    for valveName in pairs(valves) do
        if valveName ~= "AA" then
            rs[#rs + 1] = valveName
        end
    end
    sort(rs)
    return rs
end

local valves = parseInput()
local usefulValves = filterOutStuckValves(valves)
local graph = buildGraphFromValves(valves)

local names = getNames(usefulValves)
local dualNames = dual(names)

local distances = findUsefulDistances(usefulValves, graph, dualNames)
local rates = valves2rates(valves, dualNames)

local function solve (timeLeft, total, openedValves, position, set2total)
    if set2total and (set2total[openedValves] or 0) < total then
        set2total[openedValves] = total
    end
    local maxTotal = total
    for valveToOpen = 1, #rates do
        if not testBit(openedValves, valveToOpen) then
            local newTimeLeft = timeLeft - distances[position][valveToOpen] - 1
            if newTimeLeft >= 0 then
                local newTotal = total + newTimeLeft * rates[valveToOpen]
                newTotal = solve(newTimeLeft, newTotal, setBit(openedValves, valveToOpen), valveToOpen, set2total)
                if newTotal > maxTotal then
                    maxTotal = newTotal
                end
            end
        end
    end
    return maxTotal
end

local answer1 = solve(30, 0, 0, 0)
printf("Part 1: %i\n", answer1)

local maxTotal = -1
local set2total = {}
solve(26, 0, 0, 0, set2total)
for set1, total1 in pairs(set2total) do
    for set2, total2 in pairs(set2total) do
        if intersect(set1, set2) == 0 then
            local total = total1 + total2
            if total > maxTotal then
                maxTotal = total
            end
        end
    end
end

local answer2 = maxTotal
printf("Part 2: %i\n", answer2)

return answer1, answer2, profile.finish()
