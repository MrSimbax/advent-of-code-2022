local F = require "libs/functional"

local Set = {}

local mt = {}

local sizes = {}
setmetatable(sizes, {__mode = "k"})

function Set.add (a, k)
    if not a[k] then
        a[k] = true
        sizes[a] = sizes[a] + 1
    end
end

function Set.del (a, k)
    if a[k] then
        a[k] = nil
        sizes[a] = sizes[a] - 1
    end
end

function Set.new (list)
    local set = {}
    setmetatable(set, mt)
    sizes[set] = 0
    for _, v in ipairs(list) do
        Set.add(set, v)
    end
    return set
end

function Set.union (a, b)
    if getmetatable(a) ~= mt or getmetatable(b) ~= mt then
        error("attempt to 'add' a set with a non-set value", 2)
    end
    local res = Set.new{}
    for k in pairs(a) do
        Set.add(res, k)
    end
    for k in pairs(b) do
        Set.add(res, k)
    end
    return res
end

mt.__add = Set.union

function Set.intersection (a, b)
    if getmetatable(a) ~= mt or getmetatable(b) ~= mt then
        error("attempt to 'multiply' a set with a non-set value", 2)
    end
    local res = Set.new{}
    for k in pairs(a) do
        if b[k] then
            Set.add(res, k)
        end
    end
    return res
end

mt.__mul = Set.intersection

function Set.difference (a, b)
    if getmetatable(a) ~= mt or getmetatable(b) ~= mt then
        error("attempt to 'subtract' a set with a non-set value, or the other way around", 2)
    end
    local res = Set.new{}
    for k in pairs(a) do
        if not b[k] then
            Set.add(res, k)
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
        table.insert(seq, el)
    end
    return seq
end

function Set.toString (set)
    return "{" .. table.concat(F.map(tostring, Set.toSeq(set)), ", ") .. "}"
end

mt.__tostring = Set.toString

return Set
