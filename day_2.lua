local eio = require "libs.eio"
local profile = require "libs.profile"
local sequence = require "libs.sequence"

local input = eio.lines()
local printf = eio.printf
local match = string.match
local dual = sequence.dual

profile.start()

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

local desiredOutcomeFromChar = {
    ["X"] = Outcome.Loss,
    ["Y"] = Outcome.Draw,
    ["Z"] = Outcome.Win
}

local winningShapeAgainst = dual(losingShapeAgainst)

local function shapeForOutcome (opponentShape, desiredOutcome)
    if desiredOutcome == Outcome.Draw then
        return opponentShape
    elseif desiredOutcome == Outcome.Loss then
        return losingShapeAgainst[opponentShape]
    else
        return winningShapeAgainst[opponentShape]
    end
end

local totalScore = 0
local correctTotalScore = 0
for i = 1, #input do
    local opponentChar, char = match(input[i], "(%u) (%u)")
    local opponentShape = shapeFromOpponentChar[opponentChar]
    local playerShape = shapeFromPlayerChar[char]
    local desiredOutcome = desiredOutcomeFromChar[char]
    local correctPlayerShape = shapeForOutcome(opponentShape, desiredOutcome)
    totalScore = totalScore + score(opponentShape, playerShape)
    correctTotalScore = correctTotalScore + score(opponentShape, correctPlayerShape)
end

printf("Part 1: %i\n", totalScore)
printf("Part 2: %i\n", correctTotalScore)

return totalScore, correctTotalScore, profile.finish()
