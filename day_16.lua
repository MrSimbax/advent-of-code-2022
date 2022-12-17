local eio = require "libs.eio"
local profile = require "libs.profile"
local pathfinding = require "libs.pathfinding"
local sequence = require "libs.sequence"
local Deque = require "libs.Deque"
local bitset = require "libs.bitset"

local printf = eio.printf
local match = string.match
local tonumber = tonumber
local sort = table.sort
local gmatch = string.gmatch
local findDistances = pathfinding.findShortestPath
local bits = bitset.bits
local union = bitset.union
local resetBit = bitset.resetBit
local dual = sequence.dual
local makeBitset = bitset.make

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
            node.adj[setmetatable({
                label = 1,
                to = valve2node(graph, valves, valves[tunnel])
            }, {__tostring = function (adj) return adj.to.name end})] = true
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
local allClosedValves = makeBitset(#names)

local function makeNode (timeLeft, total, closedValves, position)
    return {
        timeLeft,
        total,
        closedValves,
        position
    }
end

local function node2str (node)
    return table.concat(node, ",")
end

local function solve (totalTimeLeft, set2total)
    local Q = Deque.new()
    local visited = {}
    Q:pushLast(makeNode(totalTimeLeft, 0, allClosedValves, 0))
    local maxTotal = 0
    while not Q:isEmpty() do
        local node = Q:popLast()
        local nodeIdx = node2str(node)

        if not visited[nodeIdx] then
            visited[nodeIdx] = true

            local timeLeft, total, closedValves, position = node[1], node[2], node[3], node[4]

            if total > maxTotal then
                maxTotal = total
            end

            if set2total and (not set2total[closedValves] or set2total[closedValves] < total) then
                set2total[closedValves] = total
            end

            if timeLeft > 1 then
                for valveToOpen in bits(closedValves) do
                    local newTimeLeft = timeLeft - distances[position][valveToOpen] - 1
                    if newTimeLeft >= 0 then
                        Q:pushLast(makeNode(
                            newTimeLeft,
                            total + newTimeLeft * rates[valveToOpen],
                            resetBit(closedValves, valveToOpen),
                            valveToOpen))
                    end
                end
            end
        end
    end
    return maxTotal
end

local answer1 = solve(30)
printf("Part 1: %i\n", answer1)

-- find the best value among all solutions in 26 minutes
-- a solution is valid only if two sets of opened valves are not intersecting
local maxTotal = -1
local set2total = {}
solve(26, set2total)
for set1, total1 in pairs(set2total) do
    for set2, total2 in pairs(set2total) do
        if union(set1, set2) == allClosedValves then
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
