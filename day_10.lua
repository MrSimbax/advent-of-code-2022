local match = string.match
local write = io.write
local abs = math.abs

local X = 1
local cycle = 0
local cpu = {}
local totalStrength = 0

local function nextCycle ()
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


write("Part 2:")
run()
write("\nPart 1: ", totalStrength, "\n")
