local eio = require "libs.eio"
local profile = require "libs.profile"
local estring = require "libs.estring"

local printf = eio.printf
local match = string.match
local str2tab = estring.str2tab
local concat = table.concat
local sort = table.sort

profile.start()

local CmpRes = {
    lt = -1,
    eq = 0,
    gt = 1
}

local function lt(packet1, packet2)
    if type(packet1) ~= "table" or type(packet2) ~= "table" then
        return false
    end

    for i = 1, #packet1 do
        local p1 = packet1[i]
        local p2 = packet2[i]
        if not p2 then
            return CmpRes.gt
        end
        local t1 = type(p1)
        local t2 = type(p2)
        if t1 == "number" and t2 == "number" then
            if p1 < p2 then
                return CmpRes.lt
            elseif p1 > p2 then
                return CmpRes.gt
            end
        elseif t1 == "number" then
            local r = lt({p1}, p2)
            if r ~= CmpRes.eq then
                return r
            end
        elseif t2 == "number" then
            local r = lt(p1, {p2})
            if r ~= CmpRes.eq then
                return r
            end
        else
            local r = lt(p1, p2)
            if r ~= CmpRes.eq then
                return r
            end
        end
    end

    if #packet1 < #packet2 then
        return CmpRes.lt
    elseif #packet1 == #packet2 then
        return CmpRes.eq
    else
        return CmpRes.gt
    end
end

local function packetFromLine (line)
    local stack = {}
    local line = str2tab(line)
    local i = 1
    while i <= #line do
        local c = line[i]
        if c == "[" then
            stack[#stack + 1] = {}
            i = i + 1
        elseif c == "]" then
            local innerList = stack[#stack]
            stack[#stack] = nil

            local outerList = stack[#stack]
            if outerList then
                outerList[#outerList + 1] = innerList
            else
                return innerList
            end

            i = i + 1
        elseif c == "," then
            i = i + 1
        else
            local digits = {line[i]}
            local j = i + 1
            while match(line[j], "%d") do
                digits[#digits + 1] = line[j]
                j = j + 1
            end
            local n = tonumber(concat(digits))

            local innerList = stack[#stack]
            innerList[#innerList + 1] = n

            i = j
        end
    end
end

local input = eio.lines()
local count = 0
local idx = 1
local packets = {}
for i = 1, #input, 3 do
    local packet1 = packetFromLine(input[i])
    local packet2 = packetFromLine(input[i + 1])
    if lt(packet1, packet2) == CmpRes.lt then
        count = count + idx
    end

    packets[#packets + 1] = packet1
    packets[#packets + 1] = packet2
    idx = idx + 1
end

local answer1 = count
printf("Part 1: %i\n", answer1)

packets[#packets + 1] = {{2}}
packets[#packets + 1] = {{6}}
local function cmp (p1, p2)
    return lt(p1, p2) == CmpRes.lt
end
sort(packets, cmp)

local i1 = -1
local i2 = -1
for i = 1, #packets do
    local p = packets[i]
    if #p == 1 then
        local outer = p[1]
        if outer and type(outer) == "table" and #outer == 1 then
            local inner = outer[1]
            if type(inner) == "number" then
                if inner == 2 then
                    i1 = i
                elseif inner == 6 then
                    i2 = i
                end
            end
        end
    end
end

local answer2 = i1 * i2
printf("Part 2: %i\n", answer2)

return answer1, answer2, profile.finish()

