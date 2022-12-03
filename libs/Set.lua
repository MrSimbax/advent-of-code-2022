local F = require "libs/functional"

local Set = {}

local mt = {}

function Set.new (list)
    local set = {}
    setmetatable(set, mt)
    for _, v in ipairs(list) do
        set[v] = true
    end
    return set
end

function Set.union (a, b)
    if getmetatable(a) ~= mt or getmetatable(b) ~= mt then
        error("attempt to 'add' a set with a non-set value", 2)
    end
    local res = Set.new{}
    for k in pairs(a) do
        res[k] = true
    end
    for k in pairs(b) do
        res[k] = true
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
        res[k] = b[k]
    end
    return res
end

mt.__mul = Set.intersection

mt.__sub = function (a, b)
    if getmetatable(a) ~= mt or getmetatable(b) ~= mt then
        error("attempt to 'subtract' a set with a non-set value, or the other way around", 2)
    end
    local res = Set.new{}
    for k in pairs(a) do
        if not b[k] then
            res[k] = true
        end
    end
    return res
end

mt.__len = function (a)
    local len = 0
    for _ in pairs(a) do
        len = len + 1
    end
    return len
end

mt.__le = function (a, b)
    for k in pairs(a) do
        if not b[k] then
            return false
        end
    end
    return true
end

mt.__lt = function (a, b)
    return a <= b and not (b <= a)
end

mt.__eq = function (a, b)
    return a <= b and b <= a
end

local function iter (set, key)
    local nextKey = next(set, key)
    return nextKey, nextKey
end

mt.__pairs = function (set)
    return iter, set, nil
end

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
