local sequence = require "libs.sequence"

local makeDual = sequence.dual
local dualSwap = sequence.dualSwap
local floor = math.floor

local Heap = {}

local mt = {__index = Heap}

function mt:__len ()
    return #self.heap
end

local function defaultComp (a, b)
    return a < b
end

-- comp(a, b) == true means that a will be higher in the heap than b
function Heap.new (seq, dualSeq, comp)
    local heap = setmetatable({
        heap = seq,
        dualHeap = dualSeq or makeDual(seq),
        comp = comp or defaultComp
    }, mt)
    heap:build()
    return heap
end

function Heap:isEmpty ()
    return #self.heap == 0
end

function Heap:heapify (i)
    local heap = self.heap

    if i > floor(#heap / 2) then
        -- leaf
        return
    end

    local dualHeap = self.dualHeap
    local comp = self.comp

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
        dualSwap(heap, dualHeap, best, root)
        return self:heapify(best)
    end
end

function Heap:build ()
    for i = floor(#self / 2), 1, -1 do
        self:heapify(i)
    end
end

function Heap:findBest ()
    return self.heap[1]
end

function Heap:extractBest ()
    local heap = self.heap
    if #heap == 0 then
        error("attempt to extract from empty heap", 1)
    end

    local dualHeap = self.dualHeap

    local ret = heap[1]

    heap[1] = heap[#heap]
    heap[#heap] = nil

    -- fix dual after the removal
    dualHeap[ret] = nil
    if heap[1] ~= nil then
        dualHeap[heap[1]] = 1
    end

    -- fix the heap
    self:heapify(1)

    return ret
end

function Heap:moveUp (i)
    if i == 1 then
        return
    end
    local heap = self.heap
    local root = floor(i / 2)
    if self.comp(heap[i], heap[root]) then
        dualSwap(heap, self.dualHeap, root, i)
        return self:moveUp(root)
    end
end

function Heap:getItemId (value)
    return self.dualHeap[value]
end

function Heap:insert (value)
    local heap = self.heap
    heap[#heap + 1] = value
    self.dualHeap[value] = #heap
    self:moveUp(#heap)
end

return Heap
