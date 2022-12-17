local bit = require "libs.bit"

local bor = bit.bor
local band = bit.band
local lshift = bit.lshift
local rshift = bit.rshift
local bnot = bit.bnot
local cowrap = coroutine.wrap
local yield = coroutine.yield

local function setBit (bitset, i)
    return bor(bitset, lshift(1, i - 1))
end

local function resetBit (bitset, i)
    return band(bitset, bnot(lshift(1, i - 1)))
end

local function testBit (bitset, i)
    return band(bitset, lshift(1, i - 1)) > 0
end

local function count (bitset)
    local c = 0
    while bitset > 0 do
        c = c + band(bitset, 1)
        bitset = rshift(bitset, 1)
    end
    return c
end

local function bits (bitset)
    return cowrap(function ()
        local i = 1
        while bitset > 0 do
            if band(bitset, 1) == 1 then
                yield(i)
            end
            bitset = rshift(bitset, 1)
            i = i + 1
        end
    end)
end

local function bitset2str (bitset)
    local t = {}
    for pos in bits(bitset) do
        t[#t + 1] = pos
    end
    return table.concat(t, ", ")
end

local function union (a, b)
    return bor(a, b)
end

local function intersection (a, b)
    return band(a, b)
end

local function difference (a, b)
    return band(a, bnot(b))
end

local function make (n)
    return 2^n - 1
end

return {
    setBit = setBit,
    resetBit = resetBit,
    testBit = testBit,
    count = count,
    bits = bits,
    bitset2str = bitset2str,
    union = union,
    intersection = intersection,
    difference = difference,
    make = make
}
