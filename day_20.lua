local eio = require "libs.eio"
local profile = require "libs.profile"
local sequence = require "libs.sequence"

local printf = eio.printf
local tonumber = tonumber
local copyseq = sequence.copy
local map = sequence.map
local swap = sequence.dualSwap

profile.start()

local function parseInput ()
    local numbers = {}
    local indices = {}
    local indicesDual = {}
    local zeroIdx = 0
    for line in io.lines() do
        local idx = #numbers + 1
        local n = tonumber(line)
        numbers[idx] = n
        indices[idx] = idx
        indicesDual[idx] = idx
        if n == 0 then
            zeroIdx = idx
        end
    end
    return numbers, indices, indicesDual, zeroIdx
end

local function mul (x)
    return function (a) return x * a end
end

local function prepareInput (numbers, indices, indicesDual, decryptionKey)
    local numbersCopy = map(mul(decryptionKey), numbers)
    local indicesCopy = copyseq(indices)
    local indicesDualCopy = copyseq(indicesDual)
    return numbersCopy, indicesCopy, indicesDualCopy
end

local function decrypt (numbers, indices, indicesDual)
    for i = 1, #numbers do
        local number = numbers[i]
        local currentIndex = indicesDual[i]
        local finalPosition = (currentIndex - 1 + number) % (#indices - 1) + 1
        local step = currentIndex < finalPosition and 1 or -1
        while currentIndex ~= finalPosition do
            swap(indices, indicesDual, currentIndex, currentIndex + step)
            currentIndex = currentIndex + step
        end
    end
end

local function answer (numbers, indices, indicesDual, zeroIdx)
    local zeroPos = indicesDual[zeroIdx]
    local first = numbers[indices[(zeroPos - 1 + 1000) % #indices + 1]]
    local second = numbers[indices[(zeroPos - 1 + 2000) % #indices + 1]]
    local third = numbers[indices[(zeroPos - 1 + 3000) % #indices + 1]]
    return first + second + third
end

local numbers, indices, indicesDual, zeroIdx = parseInput()

local decryptedNumbers, decryptedIndices, decryptedIndicesDual = prepareInput(numbers, indices, indicesDual, 1)
decrypt(decryptedNumbers, decryptedIndices, decryptedIndicesDual)
local answer1 = answer(decryptedNumbers, decryptedIndices, decryptedIndicesDual, zeroIdx)
printf("Part 1: %i\n", answer1)


decryptedNumbers, decryptedIndices, decryptedIndicesDual = prepareInput(numbers, indices, indicesDual, 811589153)
for _ = 1, 10 do
    decrypt(decryptedNumbers, decryptedIndices, decryptedIndicesDual)
end
local answer2 = answer(decryptedNumbers, decryptedIndices, decryptedIndicesDual, zeroIdx)
printf("Part 2: %i\n", answer2)

return answer1, answer2, profile.finish()
