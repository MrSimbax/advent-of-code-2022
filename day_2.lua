local eio = require "libs/eio"
local estring = require "libs/estring"
local F = require "libs/functional"
local input = require "libs/input"

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
    local opponentChar, playerChar = table.unpack(estring.split(line))
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

local function sumScores (rounds)
    return F.sum(F.map(scoreFromRound, rounds))
end

eio.printf("Part 1: %i\n", sumScores(F.map(roundFromLine, input.lines())))

local desiredOutcomeFromChar = {
    ["X"] = Outcome.Loss,
    ["Y"] = Outcome.Draw,
    ["Z"] = Outcome.Win
}

local function roundStrategyFromLine (line)
    local opponentChar, desiredOutcomeChar = table.unpack(estring.split(line))
    return {shapeFromOpponentChar[opponentChar], desiredOutcomeFromChar[desiredOutcomeChar]}
end

local winningShapeAgainst = F.inversed(losingShapeAgainst)

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

eio.printf("Part 2: %i\n", sumScores(F.map(F.compose(roundFromRoundStrategy, roundStrategyFromLine), input.lines())))
