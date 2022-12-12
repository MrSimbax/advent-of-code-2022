local font = require "libs.fontEffects"
local stdlibs = {}
for k, _ in pairs(package.loaded) do
    stdlibs[k] = true
end
stdlibs["libs.fontEffects"] = true

local function ls (path)
    path = path or ""
    local out = io.popen('ls '..path, 'r')
    if not out then error("could not run ls") end
    local dir = {}
    for file in out:lines() do
        dir[#dir + 1] = file
    end
    return dir
end

-- Find the amount of days to run
local maxDay = 0
for _, filename in ipairs(ls()) do
    local day = tonumber(filename:match("day_(%d+).lua"))
    if day and day > maxDay then
        maxDay = day
    end
end

-- Read the answers from file
local answers = nil
local file, fail = io.open("answers.txt")
if file then
    answers = {}
    local day = 1
    for line in file:lines() do
        answers[day] = {line:match("(.+),(.+)")}
        day = day + 1
    end
else
    print(fail)
    print("Could not open 'answers.txt', answer verification will be skipped.")
end

-- Run files
local failures = {}
local function checkAnswer (day, part, expected, actual)
    expected = string.gsub(expected, "\\n", "\n")
    if tonumber(expected) and tonumber(actual) then
        if tonumber(expected) ~= tonumber(actual) then
            failures[#failures + 1] = string.format(
                "Bad answer for day ${bold}%i${normal} part ${bold}%i${normal}: expected ${green}%i${normal} got ${red}%i${normal}",
                day, part, expected, actual)
        end
    elseif expected ~= actual then
        failures[#failures + 1] = string.format("Bad answer for day ${bold}%i${normal} part ${bold}%i${normal}:\nexpected:\n${green}%s${normal}\ngot:\n${red}%s${normal}\n", day, part, expected, actual)
    end
end

local totalTimeTaken = 0
for day = 1, maxDay do
    print(font.sub(string.format("${bold}################################### Day %02i #####################################${normal}", day)))
    local luaFilename = string.format("day_%i.lua", day)
    local inputFilename = string.format("input_%i.txt", day)

    -- Run in separate environment and clear loaded packages
    local env = setmetatable({}, {__index=_G})
    for k, _ in pairs(package.loaded) do
        if not stdlibs[k] then
            package.loaded[k] = nil
        end
    end

    io.input(inputFilename)
    local answer1, answer2, timeTaken
    if setfenv ~= nil then
        -- LuaJIT/Lua 5.1
        local f = assert(loadfile(luaFilename))
        answer1, answer2, timeTaken = setfenv(f, env)()
    else
        answer1, answer2, timeTaken = loadfile(luaFilename, "t", env)()
    end

    if answers then
        checkAnswer(day, 1, answers[day][1], answer1)
        checkAnswer(day, 2, answers[day][2], answer2)
    end
    totalTimeTaken = totalTimeTaken + tonumber(timeTaken)
    print()
end

print(font.sub("${bold}"..string.rep("#", 80).."${normal}"))
print(string.format(font.sub("Total time taken: ${bold}%f s${normal}"), totalTimeTaken))
if #failures > 0 then
    print(string.format(font.sub("There were ${bold}${red}%i${normal} wrong answers."), #failures))
    for _, msg in ipairs(failures) do
        print(font.sub(msg))
    end
else
    print(font.sub("There were ${bold}${green}0${normal} wrong answers."))
end
