local seq = require "libs.sequence"

local map = seq.map
local concat = table.concat
local len = string.len
local sub = string.sub

local Set = {}

local mt = {}

local sizes = {}
setmetatable(sizes, {__mode = "k"})

local function add (a, k)
    if not a[k] then
        a[k] = true
        sizes[a] = sizes[a] + 1
    end
end

Set.add = add

local function del (a, k)
    if a[k] then
        a[k] = nil
        sizes[a] = sizes[a] - 1
    end
end

Set.del = del

local function makeSet ()
    local set = setmetatable({}, mt)
    sizes[set] = 0
    return set
end

function Set.fromSeq (as)
    local set = makeSet()
    for i = 1, #as do
        add(set, as[i])
    end
    return set
end

function Set.fromString (str)
    local set = makeSet()
    for i = 1, len(str) do
        add(set, sub(str, i, i))
    end
    return set
end

Set.new = makeSet

function Set.union (a, b)
    if getmetatable(a) ~= mt or getmetatable(b) ~= mt then
        error("attempt to 'add' a set with a non-set value", 2)
    end
    local res = makeSet()
    for k in pairs(a) do
        add(res, k)
    end
    for k in pairs(b) do
        add(res, k)
    end
    return res
end

mt.__add = Set.union

function Set.intersection (a, b)
    if getmetatable(a) ~= mt or getmetatable(b) ~= mt then
        error("attempt to 'multiply' a set with a non-set value", 2)
    end
    local res = makeSet()
    for k in pairs(a) do
        if b[k] then
            add(res, k)
        end
    end
    return res
end

mt.__mul = Set.intersection

function Set.difference (a, b)
    if getmetatable(a) ~= mt or getmetatable(b) ~= mt then
        error("attempt to 'subtract' a set with a non-set value, or the other way around", 2)
    end
    local res = makeSet()
    for k in pairs(a) do
        if not b[k] then
            add(res, k)
        end
    end
    return res
end

mt.__sub = Set.difference

function Set.size (a)
    return sizes[a]
end

mt.__len = Set.size

function Set.isSubset (a, b)
    for k in pairs(a) do
        if not b[k] then
            return false
        end
    end
    return true
end

mt.__le = Set.isSubset

function Set.isStrictSubset (a, b)
    return a <= b and not (b <= a)
end

mt.__lt = Set.isStrictSubset

function Set.areEqual (a, b)
    return a <= b and b <= a
end

mt.__eq = Set.areEqual

function Set.toSeq (set)
    local seq = {}
    for el in pairs(set) do
        seq[#seq + 1] = el
    end
    return seq
end

function Set.toString (set)
    return "{" .. concat(map(tostring, Set.toSeq(set)), ", ") .. "}"
end

function Set.getAnyElement (set)
    for el in pairs(set) do
        return el
    end
end

mt.__tostring = Set.toString

return Set
