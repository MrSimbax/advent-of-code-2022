local eio = require "libs.eio"
local profile = require "libs.profile"

local printf = eio.printf
local gsub = string.gsub
local load = load or loadstring
local type = type

profile.start()

local function lt (a, b)
    local ta = type(a)
    local tb = type(b)
    if ta == "number" and tb == "number" then
        return a < b and true or a == b and nil
    elseif ta == "number" and tb == "table" then
        return lt({a}, b)
    elseif ta == "table" and tb == "number" then
        return lt(a, {b})
    elseif ta == "table" and tb == "table" then
        for i = 1, #a do
            local r = lt(a[i], b[i])
            if r ~= nil then
                return r
            end
        end
        return #a < #b and true or nil
    elseif tb == "nil" then
        return false
    end
end

local bracesFromBrackets = {
    ["["] = "{",
    ["]"] = "}"
}

local function packetFromLine (line)
    return load("return " .. gsub(line, "([%[%]])", bracesFromBrackets))()
end

local input = eio.lines()
local count = 0
local idx = 1
local divider1 = {{2}}
local divider2 = {{6}}
local pos1 = 1
local pos2 = 2
for i = 1, #input, 3 do
    local packet1 = packetFromLine(input[i])
    local packet2 = packetFromLine(input[i + 1])
    count = count + (lt(packet1, packet2) and idx or 0)
    pos1 = pos1 + (lt(packet1, divider1) and 1 or 0)
    pos1 = pos1 + (lt(packet2, divider1) and 1 or 0)
    pos2 = pos2 + (lt(packet1, divider2) and 1 or 0)
    pos2 = pos2 + (lt(packet2, divider2) and 1 or 0)
    idx = idx + 1
end

local answer1 = count
printf("Part 1: %i\n", answer1)
local answer2 = pos1 * pos2
printf("Part 2: %i\n", answer2)

return answer1, answer2, profile.finish()

