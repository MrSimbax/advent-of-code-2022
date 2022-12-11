-- Helper local functions for sequences
local move = table.move
local sort = table.sort
local pairs = pairs
local min = math.min
local floor = math.floor

local function id (...)
    return ...
end

local function copy (as)
    local rs = {}
    move(as, 1, #as, 1, rs)
    return rs
end

local function reduce (op, init, as)
    local acc = init
    for i = 1, #as do
        acc = op(acc, as[i])
    end
    return acc
end

local function plus (a, b)
    return a + b
end

local function sum (as)
    return reduce(plus, 0, as)
end

local function mult (a, b)
    return a * b
end

local function product (as)
    return reduce(mult, 1, as)
end

local function maximum (as)
    local m = as[1]
    for i = 2, #as do
        local a = as[i]
        if a > m then
            m = a
        end
    end
    return m
end

local function minimum (as)
    local m = as[1]
    for i = 2, #as do
        local a = as[i]
        if a < m then
            m = a
        end
    end
    return m
end

local function map (f, as)
    local rs = {}
    for i = 1, #as do
        rs[i] = f(as[i])
    end
    return rs
end

local function sorted (as, cmp)
    local rs = copy(as)
    sort(rs, cmp)
    return rs
end

local function reverse (as)
    for i = 1, floor(#as / 2) do
        local j = #as - i + 1
        as[i], as[j] = as[j], as[i]
    end
end

local function reversed (as)
    local rs = {}
    for i = 1, #as do
        local j = #as - i + 1
        rs[j] = as[i]
    end
    return rs
end

local function take (n, as)
    local rs = {}
    move(as, 1, min(n, #as), 1, rs)
    return rs
end

local function skip (n, as)
    local rs = {}
    move(as, n + 1, #as, 1, rs)
    return rs
end

local function first (as)
    return as[1]
end

local function last (as)
    return as[#as]
end

local function inversed (t)
    local r = {}
    for k, v in pairs(t) do
        r[v] = k
    end
    return r
end

local function compose (g, ...)
    if g == nil then return id end
    local f = compose(...)
    return function (...) return g(f(...)) end
end

local function groupsOf (n, as)
    local rs = {}
    local m = floor(#as / n)
    if #as % n ~= 0 then
        m = m + 1
    end
    local k = 1
    for i = 1, m do
        local g = {}
        for j = k, k + n - 1 do
            g[#g + 1] = as[j]
        end
        rs[i] = g
        k = k + n
    end
    return rs
end

local function collect (from, to, step)
    if not step then
        if from <= to then
            step = 1
        else
            step = -1
        end
    end
    local rs = {}
    for i = from, to, step do
        rs[#rs + 1] = i
    end
    return rs
end

local function filter (pred, as)
    local rs = {}
    for i = 1, #as do
        local a = as[i]
        if pred(a) then
            rs[#rs + 1] = a
        end
    end
    return rs
end

local function takeWhile (pred, as)
    local rs = {}
    for i = 1, #as do
        local a = as[i]
        if pred(a) then
            rs[#rs + 1] = a
        else
            break
        end
    end
    return rs
end

local function skipWhile (pred, as)
    local rs = {}
    for i = 1, #as do
        local a = as[i]
        if not pred(a) then
            move(as, i, #as, 1, rs)
            return rs
        end
    end
    return rs
end

local function split (delim, as)
    local rs = {}
    local ays = {}
    for i = 1, #as do
        local a = as[i]
        if a ~= delim then
            ays[#ays + 1] = a
        else
            rs[#rs + 1] = ays
            ays = {}
        end
    end
    if #as > 0 then
        rs[#rs + 1] = ays
    end
    return rs
end

local function sequence (a, n)
    local as = {}
    for i = 1, n do
        as[#as + 1] = a(i)
    end
    return as
end

local function const (a)
    return function (...) return a end
end

local function slice (i, j, as)
    local rs = {}
    move(as, i, j < #as and j or #as, 1, rs)
    return rs
end

local function keys (t)
    local rs = {}
    for k, _ in pairs(t) do
        rs[#rs + 1] = k
    end
    return rs
end

local function values (t)
    local rs = {}
    for _, v in pairs(t) do
        rs[#rs + 1] = v
    end
    return rs
end

local function find (pred, as)
    for i = 1, #as do
        if pred(as[i]) then
            return i
        end
    end
end

local function equals (x)
    return function (y) return x == y end
end

return {
    id = id,
    copy = copy,
    reduce = reduce,
    sum = sum,
    maximum = maximum,
    minimum = minimum,
    map = map,
    sorted = sorted,
    reverse = reverse,
    reversed = reversed,
    take = take,
    skip = skip,
    first = first,
    last = last,
    inversed = inversed,
    compose = compose,
    groupsOf = groupsOf,
    collect = collect,
    filter = filter,
    takeWhile = takeWhile,
    skipWhile = skipWhile,
    split = split,
    sequence = sequence,
    const = const,
    slice = slice,
    keys = keys,
    values = values,
    find = find,
    equals = equals,
    product = product
}
