local function bnot (a)
    return ~a
end

local function band (a, b)
    return a & b
end

local function bor (a, b)
    return a | b
end

local function bxor (a, b)
    return a ~ b
end

local function lshift (a, n)
    return a << n
end

local function rshift (a, n)
    return a >> n
end

local function arshift (a, n)
    return a // 2^n
end

return {
    bnot = bnot,
    band = band,
    bor = bor,
    bxor = bxor,
    lshift = lshift,
    rshift = rshift,
    arshift = arshift
}
