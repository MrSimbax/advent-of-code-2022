local eio = require "libs.eio"
local profile = require "libs.profile"

local input = eio.lines()
local printf = eio.printf
local sort = table.sort

profile.start()

local calories = {}
local sum = 0
for i = 1, #input do
    local n = tonumber(input[i])
    if n then
        sum = sum + n
    else
        calories[#calories + 1] = sum
        sum = 0
    end
end
sort(calories)

printf("Part 1: %i\n", calories[#calories])
printf("Part 2: %i\n", calories[#calories] + calories[#calories - 1] + calories[#calories - 2])

profile.finish()
