-- Functional programming
local M = {}

local function copySeq (as)
    local rs = {}
    table.move(as, 1, #as, 1, rs)
    return rs
end

function M.reduce (op, init, as)
    local acc = init
    for _, a in ipairs(as) do
        acc = op(acc, a)
    end
    return acc
end

function M.sum (as)
    return M.reduce(function (a, b) return a + b end, 0, as)
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

return M
