local eio = require "libs.eio"
local profile = require "libs.profile"
local estring = require "libs.estring"
local Deque = require "libs.Deque"
local sequence = require "libs.sequence"

local input = eio.lines
local printf = eio.printf
local split = estring.split
local makeDeque = Deque.new
local sub = string.sub
local floor = math.floor
local tonumber = tonumber
local map = sequence.map
local sort = table.sort
local product = sequence.product
local maxinteger = 2^53

profile.start()

local USE_MODULO = true
local DONT_USE_MODULO = false

local function makeMonkey (items, operation, test, onTrue, onFalse, n)
    return {
        items = items,
        operation = operation,
        test = test,
        onTrue = onTrue,
        onFalse = onFalse,
        n = n,
        activity = 0
    }
end

local ops = {
    ["+"] = function (b)
        return function (a, m)
            return (a + b) % m
        end
    end,
    ["*"] = function (b)
        return function (a, m)
            local b = b or a
            return (a * b) % m
        end
    end
}

local function divisibleBy (n)
    return function (x)
        return x % n == 0
    end
end

local function throwItem (monkeys, to)
    return function (item)
        monkeys[to].items:pushLast(item)
    end
end

local function parseInput (useModulo)
    local monkeys = {}
    local ns = {}
    local monkeyId, items, operation, test, onTrue, onFalse, n
    for lineIdx = 1, #input() do
        local line = input()[lineIdx]
        local words = split(line)
        if words[1] == "Monkey" then
            monkeyId = tonumber(sub(words[2], 1, -2))
        elseif words[1] == "Starting" then
            items = makeDeque()
            for i = 3, #words do
                local item = words[i]
                if sub(item, -1, -1) == "," then
                    item = sub(item, 1, -2)
                end
                items:pushLast(tonumber(item))
            end
        elseif words[1] == "Operation:" then
            operation = ops[words[5]](tonumber(words[6]))
        elseif words[1] == "Test:" then
            n = tonumber(words[4])
            test = divisibleBy(n)
            ns[#ns + 1] = n
        elseif words[1] == "If" then
            if words[2] == "true:" then
                onTrue = throwItem(monkeys, tonumber(words[6]) + 1)
            else
                onFalse = throwItem(monkeys, tonumber(words[6]) + 1)
            end
        else
            monkeys[monkeyId + 1] = makeMonkey(items, operation, test, onTrue, onFalse, n)
        end
    end
    monkeys[monkeyId + 1] = makeMonkey(items, operation, test, onTrue, onFalse, n)
    n = useModulo and product(ns) or maxinteger
    return monkeys, n
end

local function simulateRound (monkeys, n, useModulo)
    for monkeyId = 1, #monkeys do
        local monkey = monkeys[monkeyId]

        local items = monkey.items
        local operation = monkey.operation
        local test = monkey.test
        local onTrue = monkey.onTrue
        local onFalse = monkey.onFalse

        while not items:isEmpty() do
            monkey.activity = monkey.activity + 1
            local item = items:popFirst()
            item = operation(item, n)
            if not useModulo then
                item = floor(item / 3)
            end
            if test(item) then
                onTrue(item)
            else
                onFalse(item)
            end
        end
    end
end

local function activityFromMonkey (monkey)
    return monkey.activity
end

local function monkeyBusiness (monkeys)
    local activities = map(activityFromMonkey, monkeys)
    sort(activities)
    return activities[#activities] * activities[#activities - 1]
end

local monkeys, n = parseInput(DONT_USE_MODULO)
for _ = 1, 20 do
    simulateRound(monkeys, n, DONT_USE_MODULO)
end

local answer1 = monkeyBusiness(monkeys)
printf("Part 1: %i\n", answer1)

monkeys, n = parseInput(USE_MODULO)
for _ = 1, 10000 do
    simulateRound(monkeys, n, USE_MODULO)
end

local answer2 = monkeyBusiness(monkeys)
printf("Part 2: %i\n", answer2)

return answer1, answer2, profile.finish()
