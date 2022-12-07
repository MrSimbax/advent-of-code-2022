local eio = require "libs/eio"
local F = require "libs/functional"
local input = require "libs/input"
local estring = require "libs/estring"
local etable = require "libs/etable"

local function makeDir (parent)
    return {parent = parent, dirs = {}, files = {}}
end

local function sizeFromDir (dir)
    return dir.size
end

local function findDirSizes (root)
    for _, dir in pairs(root.dirs) do
        findDirSizes(dir)
    end
    root.size = F.sum(F.values(root.files)) + F.sum(F.map(sizeFromDir, F.values(root.dirs)))
end

local function dirTreeFromLines (lines)
    local root = makeDir(nil)
    local currentDir = root
    for _, line in ipairs(lines) do
        local cmd = estring.split(line)
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

local function allDirSizes (root)
    local dirs = {root.size}
    for _, dir in pairs(root.dirs) do
        etable.concat(dirs, allDirSizes(dir))
    end
    return dirs
end

local root = dirTreeFromLines(input.lines())

eio.printf("Part 1: %i\n", F.sum(F.filter(function (size) return size <= 100000 end, allDirSizes(root))))

local function calcSpaceToFree (root)
    local usedSpace = root.size
    local totalDiskSpace = 70000000
    local neededFreeSpace = 30000000
    local freeSpace = totalDiskSpace - usedSpace
    return neededFreeSpace - freeSpace
end

local function sizeOfDirToDelete (root)
    local spaceToFree = calcSpaceToFree(root)
    return F.minimum(F.filter(function (size) return size >= spaceToFree end, allDirSizes(root)))
end

eio.printf("Part 2: %i\n", sizeOfDirToDelete(root))
