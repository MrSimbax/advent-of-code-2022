local eio = require "libs/eio"
local estring = require "libs/estring"
local functional = require "libs/functional"

local printf = eio.printf
local compose = functional.compose
local map = functional.map
local sum = functional.sum
local inversed = functional.inversed
local split = estring.split

local input = {}

local function loadInput ()
    if #input == 0 then
        for line in io.lines() do
            table.insert(input, line)
        end
    end
    return input
end

local Shape = {
    Rock = 1,
    Paper = 2,
    Scissors = 3
}

local shapeFromOpponentChar = {
    ["A"] = Shape.Rock,
    ["B"] = Shape.Paper,
    ["C"] = Shape.Scissors
}

local shapeFromPlayerChar = {
    ["X"] = Shape.Rock,
    ["Y"] = Shape.Paper,
    ["Z"] = Shape.Scissors
}

local function roundFromLine (line)
    local opponentChar, playerChar = split(line)
    return {shapeFromOpponentChar[opponentChar], shapeFromPlayerChar[playerChar]}
end

local Outcome = {
    Loss = 1,
    Draw = 2,
    Win = 3
}

local scoreFromShape = {
    [Shape.Rock] = 1,
    [Shape.Paper] = 2,
    [Shape.Scissors] = 3,
}

local scoreFromOutcome = {
    [Outcome.Loss] = 0,
    [Outcome.Draw] = 3,
    [Outcome.Win] = 6
}

local losingShapeAgainst = {
    [Shape.Rock] = Shape.Scissors,
    [Shape.Paper] = Shape.Rock,
    [Shape.Scissors] = Shape.Paper,
}

local function roundOutcome (opponentShape, playerShape)
    if opponentShape == playerShape then
        return Outcome.Draw
    elseif losingShapeAgainst[opponentShape] == playerShape then
        return Outcome.Loss
    else
        return Outcome.Win
    end
end

local function score (opponentShape, playerShape)
    return scoreFromShape[playerShape] + scoreFromOutcome[roundOutcome(opponentShape, playerShape)]
end

local function scoreFromRound (round)
    return score(table.unpack(round))
end

printf("Part 1: %i\n", sum(map(compose(scoreFromRound, roundFromLine), loadInput())))

local desiredOutcomeFromChar = {
    ["X"] = Outcome.Loss,
    ["Y"] = Outcome.Draw,
    ["Z"] = Outcome.Win
}

local function roundStrategyFromLine (line)
    local opponentChar, desiredOutcomeChar = split(line)
    return {shapeFromOpponentChar[opponentChar], desiredOutcomeFromChar[desiredOutcomeChar]}
end

local winningShapeAgainst = inversed(losingShapeAgainst)

local function shapeForOutcome (opponentShape, desiredOutcome)
    if desiredOutcome == Outcome.Draw then
        return opponentShape
    elseif desiredOutcome == Outcome.Loss then
        return losingShapeAgainst[opponentShape]
    else
        return winningShapeAgainst[opponentShape]
    end
end

local function roundFromRoundStrategy (roundStrategy)
    local opponentShape, desiredOutcome = table.unpack(roundStrategy)
    return {opponentShape, shapeForOutcome(opponentShape, desiredOutcome)}
end

printf("Part 2: %i\n", sum(map(compose(scoreFromRound, roundFromRoundStrategy, roundStrategyFromLine), loadInput())))
