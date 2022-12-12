local Heap = require "libs.Heap"
local sequence = require "libs.sequence"

local huge = math.huge
local reverse = sequence.reverse

local function buildPath (from, to, prev, dist)
    local path = {to}
    local prevNode = prev[to]
    while prevNode ~= nil do
        path[#path + 1] = prevNode
        prevNode = prev[prevNode]
    end
    if path[#path] ~= from then
        -- We didn't reach from, this can happen if the graph is not connected
        return {}, prev, dist
    end
    reverse(path)
    return path, prev, dist
end

-- Returns the shortest path from `from` to `to` in the `graph`.
-- Also, returns the `prev` and `dist`, which are maps from graph nodes to 
-- previous optimal node and distance from `from` respectively.
-- If there's no path or `to` is nil, the returned path is an empty table.
-- The graph has the following structure:
-- {[key] = {adj = {[{label, to}] = true}}}
-- i.e. graph contains nodes (you can use any key you want)
-- nodes have at least an adjacency set of arcs
-- each arc has a numeric label representing the distance and reference to the neighbour
local function findShortestPath (graph, from, to)
    local prev = {}
    local dist = {}
    local queue = {}
    local dualQueue = {}

    -- Build the priority queue
    for _, node in pairs(graph) do
        queue[#queue + 1] = node
        dualQueue[node] = #queue
        dist[node] = huge
    end
    dist[from] = 0
    local function comp (a, b)
        return dist[a] < dist[b]
    end
    queue = Heap.new(queue, dualQueue, comp)

    while not queue:isEmpty() do
        local node = queue:extractBest()
        if node == to then
            -- We've reached the node, let's build the path by going back to the start
            return buildPath(from, to, prev, dist)
        end
        for arc in pairs(node.adj) do
            local neighbour = arc.to
            local currentDistToNeighbour = dist[neighbour]
            local newDistToNeighbour = dist[node] + tonumber(arc.label)
            if newDistToNeighbour < currentDistToNeighbour then
                dist[neighbour] = newDistToNeighbour
                prev[neighbour] = node
                queue:moveUp(queue:getItemId(neighbour))
            end
        end
    end
    -- we haven't reached to or to is nil, so no path
    return {}, prev, dist
end

return {
    findShortestPath = findShortestPath,
    buildPath = buildPath,
}
