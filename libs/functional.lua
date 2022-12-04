-- Functional programming
local F = {}

function F.id (x)
    return x
end

local function copySeq (as)
    local rs = {}
    table.move(as, 1, #as, 1, rs)
    return rs
end

function F.reduceSeq (op, init, as)
    local acc = init
    for _, a in ipairs(as) do
        acc = op(acc, a)
    end
    return acc
end

-- op must be commutative as pairs(t) is unordered
function F.reduce (op, init, t)
    local acc = init
    for _, v in pairs(t) do
        acc = op(acc, v)
    end
    return acc
end

function F.sum (as)
    return F.reduceSeq(function (a, b) return a + b end, 0, as)
end

function F.maximum (as)
    return math.max(table.unpack(as))
end

function F.map (f, as)
    local rs = {}
    for i, a in ipairs(as) do
        rs[i] = f(a)
    end
    return rs
end

function F.sorted (as, cmp)
    local rs = copySeq(as)
    table.sort(rs, cmp)
    return rs
end

function F.reversed (as)
    local rs = copySeq(as)
    for i = 1, #rs // 2 do
        local j = #rs - i + 1
        rs[i], rs[j] = rs[j], rs[i]
    end
    return rs
end

function F.take (n, as)
    local rs = {}
    table.move(as, 1, math.min(n, #as), 1, rs)
    return rs
end

function F.skip (n, as)
    local rs = {}
    table.move(as, n + 1, #as, 1, rs)
    return rs
end

function F.head (as)
    return as[1]
end

function F.inversed (t)
    local r = {}
    for k, v in pairs(t) do
        r[v] = k
    end
    return r
end

function F.compose (g, ...)
    if g == nil then return F.id end
    local f = F.compose(...)
    return function (...) return g(f(...)) end
end

function F.groupsOf (n, as)
    local rs = {}
    local m = #as // n
    if #as % n ~= 0 then
        m = m + 1
    end
    for _ = 1, m do
        table.insert(rs, F.take(n, as))
        as = F.skip(n, as)
    end
    return rs
end

function F.collect (from, to, step)
    if not step then
        if from <= to then
            step = 1
        else
            step = -1
        end
    end
    local rs = {}
    for i = from, to, step do
        table.insert(rs, i)
    end
    return rs
end

function F.filter (pred, as)
    local rs = {}
    for _, a in ipairs(as) do
        if pred(a) then
            table.insert(rs, a)
        end
    end
    return rs
end

function F.takeWhile (pred, as)
    local rs = {}
    for _, a in ipairs(as) do
        if pred(a) then
            table.insert(rs, a)
        else
            break
        end
    end
    return rs
end

function F.split (delim, as)
    local function pred (a)
        return a ~= delim
    end

    local rs = {}
    while #as > 0 do
        local ays = F.takeWhile(pred, as)
        table.insert(rs, ays)
        as = F.skip(#ays + 1, as)
    end
    return rs
end

return F
