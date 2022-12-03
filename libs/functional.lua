-- Functional programming
local M = {}

local eio = require "libs/eio"

function M.id (x)
    return x
end

local function copySeq (as)
    local rs = {}
    table.move(as, 1, #as, 1, rs)
    return rs
end

function M.reduceSeq (op, init, as)
    local acc = init
    for _, a in ipairs(as) do
        acc = op(acc, a)
    end
    return acc
end

-- op must be commutative as pairs(t) is unordered
function M.reduce (op, init, t)
    local acc = init
    for _, v in pairs(t) do
        acc = op(acc, v)
    end
    return acc
end

function M.sum (as)
    return M.reduceSeq(function (a, b) return a + b end, 0, as)
end

function M.maximum (as)
    return math.max(table.unpack(as))
end

function M.map (f, as)
    local rs = {}
    for i, a in ipairs(as) do
        rs[i] = f(a)
    end
    return rs
end

function M.sorted (as, cmp)
    local rs = copySeq(as)
    table.sort(rs, cmp)
    return rs
end

function M.reversed (as)
    local rs = copySeq(as)
    for i = 1, #rs // 2 do
        local j = #rs - i + 1
        rs[i], rs[j] = rs[j], rs[i]
    end
    return rs
end

function M.take (n, as)
    local rs = {}
    table.move(as, 1, math.min(n, #as), 1, rs)
    return rs
end

function M.skip (n, as)
    local rs = {}
    table.move(as, n + 1, #as, 1, rs)
    return rs
end

function M.head (as)
    return as[1]
end

function M.inversed (t)
    local r = {}
    for k, v in pairs(t) do
        r[v] = k
    end
    return r
end

function M.compose (g, ...)
    if g == nil then return M.id end
    local f = M.compose(...)
    return function (...) return g(f(...)) end
end

function M.groupsOf (n, as)
    local rs = {}
    local m = #as // n
    if #as % n ~= 0 then
        m = m + 1
    end
    for _ = 1, m do
        table.insert(rs, M.take(n, as))
        as = M.skip(n, as)
    end
    return rs
end

return M
