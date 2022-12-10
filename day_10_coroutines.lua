local profile = require "libs.profile"

local match = string.match
local write = io.write
local abs = math.abs
local cocreate = coroutine.create
local coresume = coroutine.resume
local yield = coroutine.yield
local costatus = coroutine.status

profile.start()

local X = 1
local cycle = 0
local cpu = {}
local totalStrength = 0

function cpu.noop ()
end

function cpu.addx (x)
    yield()
    X = X + x
end

local function runCycle ()
    cycle = cycle + 1

    if (cycle - 20) % 40 == 0 then
        totalStrength = totalStrength + cycle * X
    end

    local pos = (cycle - 1) % 40

    if pos == 0 then
        write("\n")
    end

    if abs(X - pos) <= 1 then
        write("#")
    else
        write(".")
    end
end

local function runInstr (instr, arg)
    while costatus(instr) ~= "dead" do
        runCycle()
        coresume(instr, arg)
    end
end

local function run ()
    for line in io.lines() do
        local instr, arg = match(line, "(%l+)%s?(-?%d*)")
        runInstr(cocreate(cpu[instr]), tonumber(arg))
    end
end

write("Part 2:")
run()
write("\nPart 1: ", totalStrength, "\n")

profile.finish()
