local sequence = require "libs.sequence"
local Set = require "libs.Set"

local map = sequence.map
local concat = table.concat

local MultiSet = {}

local mt = {}

local sizes = {}
setmetatable(sizes, {__mode = "k"})

function MultiSet.add (a, k, m)
    m = m or 1
    local c = a[k]
    if c then
        a[k] = c + m
    else
        a[k] = m
    end
    sizes[a] = sizes[a] + m
end

function MultiSet.del (a, k, m)
    m = m or 1
    local c = a[k]
    if c then
        local n = c - m
        if n <= 0 then
            sizes[a] = sizes[a] - c
            a[k] = nil
        else
            sizes[a] = sizes[a] - m
            a[k] = n
        end
    end
end

function MultiSet.toSet (a)
    return Set.fromSeq(MultiSet.toSetSeq(a))
end

function MultiSet.isSet (a)
    for _, m in pairs(a) do
        if m ~= 1 then
            return false
        end
    end
    return true
end

function MultiSet.new (seq)
    local set = {}
    setmetatable(set, mt)
    sizes[set] = 0
    for i = 1, #seq do
        MultiSet.add(set, seq[i], 1)
    end
    return set
end

function MultiSet.union (a, b)
    if getmetatable(a) ~= mt or getmetatable(b) ~= mt then
        error("attempt to 'add' a set with a non-set value", 2)
    end
    local res = MultiSet.new{}
    for k, m in pairs(a) do
        MultiSet.add(res, k, m)
    end
    for k, m in pairs(b) do
        MultiSet.add(res, k, m)
    end
    return res
end

mt.__add = MultiSet.union

function MultiSet.intersection (a, b)
    if getmetatable(a) ~= mt or getmetatable(b) ~= mt then
        error("attempt to 'multiply' a set with a non-set value", 2)
    end
    local res = MultiSet.new{}
    local size = 0
    for k in pairs(a) do
        local ak = a[k] and a[k] or 0
        local bk = b[k] and b[k] or 0
        local m = math.min(ak, bk)
        if m > 0 then
            res[k] = m
            size = size + m
        end
    end
    sizes[res] = size
    return res
end

mt.__mul = MultiSet.intersection

function MultiSet.difference (a, b)
    if getmetatable(a) ~= mt or getmetatable(b) ~= mt then
        error("attempt to 'subtract' a set with a non-set value, or the other way around", 2)
    end
    local res = MultiSet.new{}
    for k, m in pairs(a) do
        MultiSet.add(res, k, m)
        if b[k] then
            MultiSet.del(res, k, b[k])
        end
    end
    return res
end

mt.__sub = MultiSet.difference

function MultiSet.size (a)
    return sizes[a]
end

mt.__len = MultiSet.size

function MultiSet.isSubset (a, b)
    for k, m in pairs(a) do
        if not b[k] or m > b[k] then
            return false
        end
    end
    return true
end

mt.__le = MultiSet.isSubset

function MultiSet.isStrictSubset (a, b)
    return a <= b and not (b <= a)
end

mt.__lt = MultiSet.isStrictSubset

function MultiSet.areEqual (a, b)
    return a <= b and b <= a
end

mt.__eq = MultiSet.areEqual

function MultiSet.toSeq (set)
    local seq = {}
    for el, m in pairs(set) do
        for _ = 1, m do
            table.insert(seq, el)
        end
    end
    return seq
end

function MultiSet.toSetSeq (set)
    local seq = {}
    for k, _ in pairs(set) do
        seq[#seq + 1] = k
    end
    return seq
end

function MultiSet.toString (set)
    return "{" .. concat(map(tostring, MultiSet.toSeq(set)), ", ") .. "}"
end

mt.__tostring = MultiSet.toString

return MultiSet
