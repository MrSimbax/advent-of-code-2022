local eio = require "libs.eio"
local profile = require "libs.profile"
local estring = require "libs.estring"
local Deque = require "libs.Deque"
local sequence = require "libs.sequence"

local input = eio.lines
local printf = eio.printf
local show = eio.show
local split = estring.split
local makeDeque = Deque.new
local sub = string.sub
local floor = math.floor
local tonumber = tonumber
local map = sequence.map
local sort = table.sort
local product = sequence.product
local huge = math.maxinteger or (2^53)

profile.start()

local DEBUG_LOGS = false

local USE_MODULO = true
local DONT_USE_MODULO = false

local function debug (...)
    if DEBUG_LOGS then
        printf(...)
    end
end

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
            local r = (a + b) % m
            debug("    Worry level increases by %i to %i.\n", b, r)
            return r
        end
    end,
    ["*"] = function (b)
        return function (a, m)
            local b = b or a
            local r = (a * b) % m
            debug("    Worry level is multiplied by %i to %i.\n", b, r)
            return r
        end
    end
}

local function divisibleBy (n)
    return function (x)
        local r = (x % n == 0)
        debug("    Current worry level is %sdivisible by %i.\n", r and "" or "not ", n)
        return r
    end
end

local function throwItem (monkeys, to)
    return function (item)
        debug("    Item with worry level %i is thrown to monkey %i.\n", item, to - 1)
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
    n = useModulo and product(ns) or huge
    return monkeys, n
end

local function simulateRound (monkeys, n, useModulo)
    for monkeyId = 1, #monkeys do
        debug("Monkey %i:\n", monkeyId - 1)
        local monkey = monkeys[monkeyId]

        local items = monkey.items
        local operation = monkey.operation
        local test = monkey.test
        local onTrue = monkey.onTrue
        local onFalse = monkey.onFalse

        while not items:isEmpty() do
            monkey.activity = monkey.activity + 1
            local item = items:popFirst()
            debug("  Monkey inspects an item with a worry level of %i.\n", item)
            item = operation(item, n)
            if not useModulo then
                item = floor(item / 3)
                debug("    Monkey gets bored with item. Worry level is divided by 3 to %i.\n", item)
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
if DEBUG_LOGS then
    show("monkeys", monkeys)
    show("n = ", n)
end
for _ = 1, (DEBUG_LOGS and 1 or 20) do
    simulateRound(monkeys, n, DONT_USE_MODULO)
end

printf("Part 1: %i\n", monkeyBusiness(monkeys))

monkeys, n = parseInput(USE_MODULO)
for _ = 1, (DEBUG_LOGS and 1 or 10000) do
    simulateRound(monkeys, n, USE_MODULO)
end

printf("Part 2: %i\n", monkeyBusiness(monkeys))

profile.finish()
