local eio = require "libs.eio"
local profile = require "libs.profile"
local pathfinding = require "libs.pathfinding"
local sequence = require "libs.sequence"

local printf = eio.printf
local match = string.match
local tonumber = tonumber
local max = math.max
local sort = table.sort
local floor = math.floor
local gmatch = string.gmatch
local findDistances = pathfinding.findShortestPath
local yield = coroutine.yield
local cowrap = coroutine.wrap
local filter = sequence.filter
local concat = table.concat

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

local function findUsefulDistances (usefulValves, graph)
    local distancesFrom = {}
    for valveName in pairs(usefulValves) do
        local _, _, d = findDistances(graph, graph[valveName])
        local distanceToValve = {}
        for neighbourValveName in pairs(usefulValves) do
            if valveName ~= neighbourValveName then
                distanceToValve[neighbourValveName] = d[graph[neighbourValveName]]
            end
        end
        distancesFrom[valveName] = distanceToValve
    end
    return distancesFrom
end

local function coCombinations (a, k, n, r)
    if not k then
        for k = 0,#a do
            coCombinations(a, k, #a, {})
        end
        return
    end

    n = n or #a
    r = r or {}

    if k > n then
        return
    end

    if k == 0 then
        yield(r)
        return
    end

    r[#r + 1] = a[#a - n + 1]
    coCombinations(a, k - 1, n - 1, r)
    r[#r] = nil
    coCombinations(a, k, n - 1, r)
end

local function combinations (a, k)
    return cowrap(function () coCombinations(a, k) end)
end

local function idx (names)
    return concat(names, ",")
end

local function getNames (valves)
    local rs = {}
    for valveName in pairs(valves) do
        if valveName ~= "AA" then
            rs[#rs + 1] = valveName
        end
    end
    sort(rs)
    return rs
end

local function notEquals (x)
    return function (y) return y ~= x end
end

local valves = parseInput()
local usefulValves = filterOutStuckValves(valves)
local graph = buildGraphFromValves(valves)
local distances = findUsefulDistances(usefulValves, graph)
local names = getNames(usefulValves)

local function solve (names, time)
    -- dynamic programming
    -- total[set][X] is the highest possible pressure if we start at AA, turn valves in the set in some order, and finish at valve X
    local totals = {} -- how much pressure we'll release after 30 minutes
    local prev = {} -- what is the previous valve in the best path
    local left = {} -- what is the time left

    -- f({}, X) is the base case: we go from AA to X, there's only one possibility
    local emptySet = idx({})
    prev[emptySet] = {}
    left[emptySet] = {}
    totals[emptySet] = {}
    for _, name in ipairs(names) do
        prev[emptySet][name] = "AA"
        left[emptySet][name] = max(0, time - distances["AA"][name] - 1)
        totals[emptySet][name] = left[idx({})][name] * valves[name].rate
    end

    -- for the general case we use the fact that to get optimal value at valve X,
    -- we must get to valve X from some valve Y ~= X in the set of k visited nodes,
    -- and we must have previously get to Y in an optimal way by going through some k-1 nodes which are neither X nor Y
    for setSize = 1, #names - 1 do
        for _, name in ipairs(names) do
            local allExceptCurrent = filter(notEquals(name), names)
            for subset in combinations(allExceptCurrent, setSize) do
                local maxTotal = -1
                local maxPrev = -1
                local maxLeft = -1
                for _, prevNode in ipairs(subset) do
                    local prevSubset = filter(notEquals(prevNode), subset)
                    local prevSubsetIdx = idx(prevSubset)
                    local newLeft = max(0, left[prevSubsetIdx][prevNode] - distances[prevNode][name] - 1)
                    local newTotal = totals[prevSubsetIdx][prevNode] + newLeft * valves[name].rate
                    if newTotal > maxTotal then
                        maxTotal = newTotal
                        maxLeft = newLeft
                        maxPrev = prevNode
                    end
                end
                local subsetIdx = idx(subset)
                if not left[subsetIdx] then left[subsetIdx] = {} end
                if not totals[subsetIdx] then totals[subsetIdx] = {} end
                if not prev[subsetIdx] then prev[subsetIdx] = {} end
                left[subsetIdx][name] = maxLeft
                totals[subsetIdx][name] = maxTotal
                prev[subsetIdx][name] = maxPrev
            end
        end
    end

    -- now find the best last location, and total
    local maxTotal = -1
    for _, name in ipairs(names) do
        local allExceptCurrent = filter(notEquals(name), names)
        for subset in combinations(allExceptCurrent, #names - 1) do
            local total = totals[idx(subset)][name]
            if total > maxTotal then
                maxTotal = total
            end
        end
    end

    return maxTotal
end

local answer1 = solve(names, 30)
printf("Part 1: %i\n", answer1)

local function complementSet (space, set)
    local res = {}
    local j = 1
    for i = 1, #space do
        if j > #set or space[i] ~= set[j] then
            res[#res + 1] = space[i]
        else
            j = j + 1
        end
    end
    return res
end

-- brute force: divide valves between us and elephants, let us both open our valves optimally, and sum the total
local maxTotal = -1
for mySize = floor(#names / 2), floor(#names / 2) do -- change this range if the answer is wrong
    for mySubset in combinations(names, mySize) do
        local total = solve(mySubset, 26) + solve(complementSet(names, mySubset), 26)
        if total > maxTotal then
            maxTotal = total
        end
    end
end

local answer2 = maxTotal
printf("Part 2: %i\n", answer2)

return answer1, answer2, profile.finish()
