local eio = require "libs.eio"
local profile = require "libs.profile"

local printf = eio.printf
local len = string.len
local sub = string.sub
local reverse = string.reverse
local concat = table.concat
local floor = math.floor

profile.start()

local digitFromSnafuChar = {
    ["0"] = 0,
    ["1"] = 1,
    ["2"] = 2,
    ["="] = -2,
    ["-"] = -1
}

local function decimalFromSnafu (n)
    local b = 1
    local r = 0
    for i = len(n), 1, -1 do
        r = r + b * digitFromSnafuChar[sub(n, i, i)]
        b = b * 5
    end
    return r
end

local snafuDigitValueFromDigit = {
    [0] = 0,
    [1] = 1,
    [2] = 2,
    [3] = -2,
    [4] = -1
}

local snafuDigitFromSnafuDigitValue = {
    [0] = "0",
    [1] = "1",
    [2] = "2",
    [-2] = "=",
    [-1] = "-"
}

local function snafuFromDecimal (n)
    local r = {}
    while n > 0 do
        local v = snafuDigitValueFromDigit[n % 5]
        if v < 0 then
            n = n + 5
        end
        r[#r + 1] = snafuDigitFromSnafuDigitValue[v]
        n = floor(n / 5)
    end
    return #r == 0 and "0" or reverse(concat(r))
end

local function sum ()
    local r = 0
    for line in io.lines() do
        r = r + decimalFromSnafu(line)
    end
    return snafuFromDecimal(r)
end

local answer1 = sum()
printf("Part 1: %s\n", answer1)

local answer2 = "solve all the previous days"
printf("Part 2: %s\n", answer2)

return answer1, answer2, profile.finish()
