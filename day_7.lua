local eio = require "libs.eio"
local profile = require "libs.profile"
local estring = require "libs.estring"

local input = eio.lines()
local printf = eio.printf
local split = estring.split
local huge = math.huge
local pairs = pairs

profile.start()

local function makeDir (parent)
    return {parent = parent, dirs = {}, files = {}}
end

local function findDirSizes (root)
    local size = 0

    for _, fileSize in pairs(root.files) do
        size = size + fileSize
    end

    for _, dir in pairs(root.dirs) do
        findDirSizes(dir)
        size = size + dir.size
    end

    root.size = size
end

local function dirTree ()
    local root = makeDir(nil)
    local currentDir = root
    for i = 1, #input do
        local cmd = split(input[i])
        if cmd[1] == "$" and cmd[2] == "cd" then
            local arg = cmd[3]
            if arg == "/" then
                currentDir = root
            elseif arg == ".." then
                currentDir = currentDir.parent
            else
                currentDir = currentDir.dirs[arg]
            end
        elseif cmd[1] == "dir" then
            local dirName = cmd[2]
            currentDir.dirs[dirName] = makeDir(currentDir)
        elseif tonumber(cmd[1]) then
            local size, filename = tonumber(cmd[1]), cmd[2]
            currentDir.files[filename] = size
        end
    end
    findDirSizes(root)
    return root
end

local function getSizes (root, sizes)
    sizes[#sizes + 1] = root.size
    for _, dir in pairs(root.dirs) do
        getSizes(dir, sizes)
    end
    return sizes
end

local function totalSizeOfSmallDirs (sizes)
    local total = 0
    for i = 1, #sizes do
        local size = sizes[i]
        if size <= 100000 then
            total = total + size
        end
    end
    return total
end

local root = dirTree()
local sizes = getSizes(root, {})

local answer1 = totalSizeOfSmallDirs(sizes)
printf("Part 1: %i\n", answer1)

local function calcSpaceToFree (root)
    local usedSpace = root.size
    local totalDiskSpace = 70000000
    local neededFreeSpace = 30000000
    local freeSpace = totalDiskSpace - usedSpace
    return neededFreeSpace - freeSpace
end

local spaceToFree = calcSpaceToFree(root)

local function sizeOfDirToDelete (sizes)
    local minSize = huge
    for i = 1, #sizes do
        local size = sizes[i]
        if size >= spaceToFree and size < minSize then
            minSize = size
        end
    end
    return minSize
end

local answer2 = sizeOfDirToDelete(sizes)
printf("Part 2: %i\n", answer2)

return answer1, answer2, profile.finish()
