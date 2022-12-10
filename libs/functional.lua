-- Helper local functions for sequences
local F = {}

local max = math.max
local min = math.min
local huge = math.huge
local tiny = -math.huge
local maxinteger = math.maxinteger

local function lazy (as)
    return function (i) return as[i] end
end

local function id (...)
    return ...
end

local function reduce (op, init, as)
    local acc = init
    for i = 1, maxinteger do
        local a = as(i)
        if not a then
            break
        end
        acc = op(acc, a)
    end
    return acc
end

local function plus (a, b)
    return a + b
end

local function mult (a, b)
    return a * b
end

local function sum (as)
    return reduce(plus, 0, as)
end

local function product (as)
    return reduce(mult, 1, as)
end

local function maximum (as)
    return reduce(max, tiny, as)
end

local function minimum (as)
    return reduce(min, huge, as)
end

local function map (f, as)
    return function (i) return f(as(i)) end
end

local function plus1 (a)
    return a + 1
end

local function length (as)
    return reduce(plus1, 0, as)
end

local function reverse (as)
    local len = length(as)
    return function (i) return as(len - i + 1) end
end

local function take (n, as)
    return function (i)
        if i <= n then
            return as(i)
        end
    end
end

local function skip (n, as)
    return function (i) return as(n + i) end
end

local function head (as)
    return as(1)
end

local function tail (as)
    return skip(1, as)
end

local function last (as)
    return as(length(as))
end

local function compose (g, ...)
    if g == nil then return id end
    local f = compose(...)
    return function (...) return g(f(...)) end
end

local function collect (as)
    local rs = {}
    for i = 1, maxinteger do
        local a = as(i)
        if not a then
            break
        end
        rs[#rs + 1] = a
    end
    return rs
end

local function eq (a, b)
    return a == b
end

local function same (eq, as, bs)
    for i = 1, maxinteger do
        local a = as(i)
        local b = bs(i)
        if not a and not b then
            return true
        elseif not a or not b then
            return false
        elseif not eq(a, b) then
            return false
        end
    end
    return true
end

local function groupsOf (n, as)
    return function (i)
        return take(n, skip((i - 1) * n, as))
    end
end

return {
    lazy = lazy,
    id = id,
    reduce = reduce,
    sum = sum,
    product = product,
    maximum = maximum,
    minimum = minimum,
    map = map,
    plus = plus,
    mult = mult,
    length = length,
    reverse = reverse,
    take = take,
    skip = skip,
    head = head,
    tail = tail,
    last = last,
    compose = compose,
    collect = collect,
    same = same,
    eq = eq,
    groupsOf = groupsOf
}
