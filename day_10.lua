local profile = require "libs.profile"
local eio = require "libs.eio"

local printf = eio.printf
local match = string.match
local abs = math.abs
local concat = table.concat

profile.start()

local X = 1
local cycle = 0
local cpu = {}
local totalStrength = 0
local crt = {}

local function display (str)
    crt[#crt + 1] = str
end

local function nextCycle ()
    cycle = cycle + 1

    if (cycle - 20) % 40 == 0 then
        totalStrength = totalStrength + cycle * X
    end

    local pos = (cycle - 1) % 40

    if pos == 0 then
        display("\n")
    end

    if abs(X - pos) <= 1 then
        display("#")
    else
        display(".")
    end
end

function cpu.noop ()
    nextCycle()
end

function cpu.addx (x)
    nextCycle()
    nextCycle()
    X = X + x
end

local function run ()
    for line in io.lines() do
        local instr, arg = match(line, "(%l+)%s?(-?%d*)")
        cpu[instr](tonumber(arg))
    end
end

run()

local answer1 = totalStrength
printf("Part 1: %i\n", answer1)

local answer2 = concat(crt)
printf("Part 2: %s\n", answer2)

return answer1, answer2, profile.finish()
