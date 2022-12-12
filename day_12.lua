local eio = require "libs.eio"
local profile = require "libs.profile"
local Vec2 = require "libs.Vec2"

local input = eio.lines
local printf = eio.printf
local sub = string.sub
local tonumber = tonumber
local Vec = Vec2.makeVec
local Grid = Vec2.allowVec2Indices
local byte = string.byte

profile.start()

-- path finding start
local function reverse_seq (seq)
    local i = 1
    local j = #seq
    while i < j do
        seq[i], seq[j] = seq[j], seq[i]
        i = i + 1
        j = j - 1
    end
end

local function default_comp (a, b)
    return a < b
end

local function swap_rev (seq, revSeq, i, j)
    seq[i], seq[j] = seq[j], seq[i]
    revSeq[seq[i]] = i
    revSeq[seq[j]] = j
end

local function heapify (heap, revHeap, i, comp)
    comp = comp or default_comp
    if i > math.floor(#heap / 2) then
        --leaf, nothing to do
        return
    end
    local root = i
    local left = 2 * i
    local right = 2 * i + 1
    local best = i
    if left <= #heap and comp(heap[left], heap[best]) then
        best = left
    end
    if right <= #heap and comp(heap[right], heap[best]) then
        best = right
    end
    if best ~= root then
        swap_rev(heap, revHeap, best, root)
        return heapify(heap, revHeap, best, comp)
    end
end

local function build_heap (heap, revHeap, comp)
    comp = comp or default_comp
    for i = math.floor(#heap / 2),1,-1 do
        heapify(heap, revHeap, i, comp)
    end
end

local function heap_find_best (heap)
    return heap[1]
end

local function heap_extract_best (heap, revHeap, comp)
    comp = comp or default_comp
    local ret = heap[1]
    heap[1] = heap[#heap]
    heap[#heap] = nil
    if ret ~= nil then revHeap[ret] = nil end
    if heap[1] ~= nil then revHeap[heap[1]] = 1 end
    heapify(heap, revHeap, 1, comp)
    return ret
end

local function heap_move_up (heap, revHeap, i, comp)
    comp = comp or default_comp
    if i == 1 then
        return
    end
    local root = math.floor(i / 2)
    if comp(heap[i], heap[root]) then
        swap_rev(heap, revHeap, root, i)
        return heap_move_up(heap, revHeap, root, comp)
    end
end

local function heap_insert (heap, revHeap, value, comp)
    comp = comp or default_comp
    table.insert(heap, value)
    revHeap[value] = #heap
    heap_move_up(heap, revHeap, #heap, comp)
end

local function findshortestpath (graph, from, to)
    local prev = {}
    local dist = {}
    local queue = {}
    local revQueue = {}
    for _, n in pairs(graph) do
        table.insert(queue, n)
        revQueue[n] = #queue
        dist[n] = math.huge
    end
    dist[from] = 0
    local function comp (a, b) return dist[a] < dist[b] end
    build_heap(queue, revQueue, comp)
    while next(queue) do
        local node = heap_extract_best(queue, revQueue, comp)
        if node == to then
            local path = {to}
            local n = prev[to]
            while n do
                table.insert(path, n)
                n = prev[n]
            end
            if path[#path] ~= from then
                return {}
            end
            reverse_seq(path)
            return path
        end
        for _, arc in pairs(node.adj) do
            local n = arc.to
            local d = dist[n]
            local newd = dist[node] + tonumber(arc.label)
            if newd < d then
                dist[n] = newd
                prev[n] = node
                heap_move_up(queue, revQueue, revQueue[n], comp)
            end
        end
    end
    return {}
end
-- path finding end

local directions = {
    Vec(0, 1), -- right
    Vec(-1, 0), -- down
    Vec(0, -1), -- left
    Vec(1, 0), -- up
}

local function isValidCoord (m, p)
    return 1 <= p[1] and p[1] <= #m and 1 <= p[2] and p[2] <= #m[1]
end

local function pos2node (graph, grid, pos)
    local node = graph[pos]
    if not node then
        node = {pos = pos, adj = {}, height = grid[pos]}
        graph[pos] = node
        local adj = node.adj
        for _, dir in ipairs(directions) do
            local n = pos + dir
            if isValidCoord(grid, n) and grid[n] - grid[pos] <= 1 then
                local to = pos2node(graph, grid, n)
                local arc = {label = 1, to = to}
                adj[#adj + 1] = arc
            end
        end
    end
    return node
end

local function heightFromLetter (c)
    return byte(c) - byte("a")
end

local function getGrid ()
    local r = {}
    local s = nil
    local e = nil
    local ss = {}
    for y = 1, #input() do
        local line = input()[y]
        local row = {}
        for x = 1, #line do
            local c = sub(line, x, x)
            if c == "S" then
                row[x] = heightFromLetter("a")
                s = Vec(y, x)
                ss[#ss + 1] = s
            elseif c == "E" then
                row[x] = heightFromLetter("z")
                e = Vec(y, x)
            else
                row[x] = heightFromLetter(c)
                if c == "a" then
                    ss[#ss + 1] = Vec(y, x)
                end
            end
        end
        r[y] = row
    end
    return Grid(r), s, e, ss
end

local function graphFromGrid (grid)
    local r = {}
    for y = 1, #grid do
        for x = 1, #grid[1] do
            r[Vec(y, x)] = pos2node(r, grid, Vec(y, x))
        end
    end
    return r
end

local grid, s, e, ss = getGrid()
-- eio.show("grid", grid)
local graph = graphFromGrid(grid)
-- eio.show("graph", graph[Vec(1,1)])
local path = findshortestpath(graph, graph[s], graph[e])

local answer1 = #path - 1
printf("Part 1: %i\n", answer1)

local minSteps = math.huge
for _, a in ipairs(ss) do
    local p = #findshortestpath(graph, graph[a], graph[e]) - 1
    if p > 0 and p < minSteps then
        minSteps = p
    end
end

local answer2 = minSteps
printf("Part 2: %i\n", answer2)

return answer1, answer2, profile.finish()

