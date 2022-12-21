local eio = require "libs.eio"
local profile = require "libs.profile"

local lines = eio.lines
local printf = eio.printf
local tonumber = tonumber
local match = string.match
local floor = math.floor

profile.start()

local function sum (a, b)
    return a + b
end

local function difference (a, b)
    return a - b
end

local function product (a, b)
    return a * b
end

local function quotient (a, b)
    return floor(a / b)
end

local opFromChar = {
    ["+"] = sum,
    ["-"] = difference,
    ["*"] = product,
    ["/"] = quotient
}

local oppositeOp = {
    [sum] = difference,
    [difference] = sum,
    [product] = quotient,
    [quotient] = product
}

local function parseInput ()
    local tree = {}
    for _, line in ipairs(lines()) do
        local name, left, op, right = match(line, "(%a+): (%a+) (.) (%a+)")
        if not op then
            local name, value = match(line, "(%a+): (%d+)")
            tree[name] = tonumber(value)
        else
            tree[name] = {left, opFromChar[op], right}
        end
    end
    return tree
end

local function calculate (tree, name)
    local node = tree[name]
    if type(node) == "number" then
        return node
    end
    local left, op, right = node[1], node[2], node[3]
    local ret = op(calculate(tree, left), calculate(tree, right))
    tree[name] = ret
    return ret
end

local answer1 = calculate(parseInput(), "root")
printf("Part 1: %i\n", answer1)

local function calculate2 (tree, name, humnTree)
    -- try to calculate either left side or right side of root
    -- if encountered unknown variable "humn", start building the humnTree from opposite operations
    -- in the original tree set the unknown variables to "?" -- we can't calculate them without "humn" but we need to know which ones
    -- once we return to the root, is assumed that one side must have value,
    -- (otherwise we have an equation with unknown variables on both sides but I assume that's outside the scope of the puzzle)
    -- then humnTree can be finished and part 1 is reused to calculate "humn"
    local node = tree[name]
    if name == "root" then
        local left, right = node[1], node[3]
        local leftValue = calculate2(tree, left, humnTree)
        local rightValue = calculate2(tree, right, humnTree)
        if leftValue == "?" then
            humnTree[left] = rightValue
        else
            humnTree[right] = leftValue
        end
        return calculate(humnTree, "humn")
    end
    if name == "humn" then
        return "?"
    end
    if type(node) == "number" then
        return node
    end
    local left, op, right = node[1], node[2], node[3]
    local a = calculate2(tree, left, humnTree)
    local b = calculate2(tree, right, humnTree)
    if a == "?" then
        humnTree[left] = {name, oppositeOp[op], right}
        humnTree[right] = b
        tree[name] = "?"
        return "?"
    elseif b == "?" then
        humnTree[left] = a
        if op == difference or op == quotient then
            -- non-commutative operations require special treatment in case the unknown is to the right of op
            humnTree[right] = {left, op, name}
        else
            humnTree[right] = {name, oppositeOp[op], left}
        end
        tree[name] = "?"
        return "?"
    end
    local ret = op(a, b)
    tree[name] = ret
    return ret
end

local answer2 = calculate2(parseInput(), "root", {})
printf("Part 2: %i\n", answer2)

return answer1, answer2, profile.finish()
