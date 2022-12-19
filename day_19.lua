local eio = require "libs.eio"
local profile = require "libs.profile"

local printf = eio.printf
local match = string.match
local tonumber = tonumber
local max = math.max
local ceil = math.ceil

profile.start()

local TIME_LIMIT = 24

local function parseBlueprints ()
    local blueprints = {}
    for line in io.lines() do
        local blueprintId,
            oreBotOreCost,
            clayBotOreCost,
            obsidianBotOreCost, obsidianBotClayCost,
            geodeBotOreCost, geodeBotObsidianCost = match(line, "Blueprint (%d+): Each ore robot costs (%d+) ore. Each clay robot costs (%d+) ore. Each obsidian robot costs (%d+) ore and (%d+) clay. Each geode robot costs (%d+) ore and (%d+) obsidian.")

        blueprintId = tonumber(blueprintId)
        oreBotOreCost = tonumber(oreBotOreCost)
        clayBotOreCost = tonumber(clayBotOreCost)
        obsidianBotOreCost = tonumber(obsidianBotOreCost)
        obsidianBotClayCost = tonumber(obsidianBotClayCost)
        geodeBotOreCost = tonumber(geodeBotOreCost)
        geodeBotObsidianCost = tonumber(geodeBotObsidianCost)

        local maxOreCost = max(oreBotOreCost, clayBotOreCost, obsidianBotOreCost, geodeBotOreCost)

        blueprints[blueprintId] = {
            blueprintId = blueprintId,
            oreBotOreCost = oreBotOreCost,
            clayBotOreCost = clayBotOreCost,
            obsidianBotOreCost = obsidianBotOreCost,
            obsidianBotClayCost = obsidianBotClayCost,
            geodeBotOreCost = geodeBotOreCost,
            geodeBotObsidianCost = geodeBotObsidianCost,
            maxOreCost = maxOreCost
        }
    end
    return blueprints
end

local function findQualityLevelOfBlueprint(
    blueprint,
    time,
    oreBots, clayBots, obsidianBots, geodeBots,
    ore, clay, obsidian, geode,
    bestGeode,
    depth)

    -- printf("%sminute %i: bots (ore=%i, clay=%i, obsidian=%i, geode=%i); resources (ore=%i, clay=%i, obsidian=%i, geode=%i, BEST=%i)\n",
    --     string.rep(" ", depth),
    --     time,
    --     oreBots, clayBots, obsidianBots, geodeBots,
    --     ore, clay, obsidian, geode,
    --     bestGeode)

    local timeLeft = TIME_LIMIT - time

    if timeLeft >= 0 then
        bestGeode = max(bestGeode, geode + timeLeft * geodeBots)
    end

    if timeLeft <= 0 or geode + geodeBots * timeLeft + ((timeLeft - 1) * timeLeft) / 2 <= bestGeode then
        return bestGeode
    end

    do
        local oreNeeded = max(0, blueprint.geodeBotOreCost - ore)
        local obsidianNeeded = max(0, blueprint.geodeBotObsidianCost - obsidian)
        local waitingTime = max(ceil(oreNeeded / oreBots), ceil(obsidianNeeded / obsidianBots)) + 1
        if waitingTime <= timeLeft then
            local solution = findQualityLevelOfBlueprint(
                blueprint,
                time + waitingTime,
                oreBots, clayBots, obsidianBots, geodeBots + 1,
                ore + oreBots * waitingTime - blueprint.geodeBotOreCost,
                clay + clayBots * waitingTime,
                obsidian + obsidianBots * waitingTime - blueprint.geodeBotObsidianCost,
                geode + geodeBots * waitingTime,
                bestGeode, depth + 1)
            if solution > bestGeode then
                bestGeode = solution
            end
        end
    end

    if obsidianBots < blueprint.geodeBotObsidianCost then
        local oreNeeded = max(0, blueprint.obsidianBotOreCost - ore)
        local clayNeeded = max(0, blueprint.obsidianBotClayCost - clay)
        local waitingTime = max(ceil(oreNeeded / oreBots), ceil(clayNeeded / clayBots)) + 1
        if waitingTime <= timeLeft then
            local solution = findQualityLevelOfBlueprint(
                blueprint,
                time + waitingTime,
                oreBots, clayBots, obsidianBots + 1, geodeBots,
                ore + oreBots * waitingTime - blueprint.obsidianBotOreCost,
                clay + clayBots * waitingTime - blueprint.obsidianBotClayCost,
                obsidian + obsidianBots * waitingTime,
                geode + geodeBots * waitingTime,
                bestGeode, depth + 1)
            if solution > bestGeode then
                bestGeode = solution
            end
        end
    end

    if clayBots < blueprint.obsidianBotClayCost then
        local oreNeeded = max(0, blueprint.clayBotOreCost - ore)
        local waitingTime = ceil(oreNeeded / oreBots) + 1
        if waitingTime <= timeLeft then
            local solution = findQualityLevelOfBlueprint(
                blueprint,
                time + waitingTime,
                oreBots, clayBots + 1, obsidianBots, geodeBots,
                ore + oreBots * waitingTime - blueprint.clayBotOreCost,
                clay + clayBots * waitingTime,
                obsidian + obsidianBots * waitingTime,
                geode + geodeBots * waitingTime,
                bestGeode, depth + 1)
            if solution > bestGeode then
                bestGeode = solution
            end
        end
    end

    if oreBots < blueprint.maxOreCost then
        local oreNeeded = max(0, blueprint.oreBotOreCost - ore)
        local waitingTime = ceil(oreNeeded / oreBots) + 1
        if waitingTime <= timeLeft then
            local solution = findQualityLevelOfBlueprint(
                blueprint,
                time + waitingTime,
                oreBots + 1, clayBots, obsidianBots, geodeBots,
                ore + oreBots * waitingTime - blueprint.oreBotOreCost,
                clay + clayBots * waitingTime,
                obsidian + obsidianBots * waitingTime,
                geode + geodeBots * waitingTime,
                bestGeode, depth + 1)
            if solution > bestGeode then
                bestGeode = solution
            end
        end
    end

    return bestGeode
end

local blueprints = parseBlueprints()

local function qualityLevel (blueprint)
    return blueprint.blueprintId * findQualityLevelOfBlueprint(blueprint, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0)
end

local function maxQualityLevel (blueprints)
    local r = 0
    for i = 1, #blueprints do
        r = r + qualityLevel(blueprints[i])
    end
    return r
end

local answer1 = maxQualityLevel(blueprints)
printf("Part 1: %i\n", answer1)

TIME_LIMIT = 32

local function part2 (blueprints)
    local r = 1
    for i = 1, 3 do
        r = r * findQualityLevelOfBlueprint(blueprints[i], 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    end
    return r
end

local answer2 = part2(blueprints)
printf("Part 2: %i\n", answer2)

return answer1, answer2, profile.finish()
