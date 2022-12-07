local eio = require "libs/eio"
local F = require "libs/functional"
local input = require "libs/input"
local estring = require "libs/estring"

local function isCommand (line)
    return line:sub(1, 1) == "$"
end

local function commandFromLine (line)
    local _, commandName, arg = table.unpack(estring.split(line))
    if commandName == "cd" then
        return "cd", arg
    elseif commandName == "ls" then
        return "ls"
    else
        error(string.format("bad command: %s", line))
    end
end

local function makeDir (parent)
    return {parent = parent, dirs = {}, files = {}}
end

local function fileFromLine (line)
    local x, name = table.unpack(estring.split(line))
    if x == "dir" then
        return "dir", -1, name
    else
        return "file", tonumber(x), name
    end
end

local function parseLsOutput (lines, lineIdx, line, currentDir)
    lineIdx = lineIdx + 1
    line = lines[lineIdx]
    while line and not isCommand(line) do
        local type, size, name = fileFromLine(line)
        if name == nil then
            error(string.format("bad file: %s", line))
        end
        if type == "dir" then
            currentDir.dirs[name] = makeDir(currentDir)
        elseif type == "file" then
            currentDir.files[name] = size
        end

        lineIdx = lineIdx + 1
        line = lines[lineIdx]
    end
    return lineIdx, line
end

local function dirTreeFromLines (lines)
    local root = makeDir(nil)
    local currentDir = root
    local lineIdx = 1
    local line = lines[1]
    while line do
        if not isCommand(line) then
            error(string.format("expected command: %s", line))
        end

        local cmd, arg = commandFromLine(line)
        if cmd == "ls" then
            lineIdx, line = parseLsOutput(lines, lineIdx, line, currentDir)
        elseif cmd == "cd" then
            if arg == "/" then
                currentDir = root
            elseif arg == ".." then
                currentDir = currentDir.parent
            else
                currentDir = currentDir.dirs[arg]
            end
            lineIdx = lineIdx + 1
            line = lines[lineIdx]
        end
    end
    return root
end

local function findDirSizes (root)
    for _, dir in pairs(root.dirs) do
        findDirSizes(dir)
    end

    local size = 0
    for _, dir in pairs(root.dirs) do
        size = size + dir.size
    end
    for _, fileSize in pairs(root.files) do
        size = size + fileSize
    end
    root.size = size
end

local function concat (as, bs)
    table.move(bs, 1, #bs, #as + 1, as)
end

local function allDirs (name, root)
    local dirs = {{name, root.size}}
    for dirName, dir in pairs(root.dirs) do
        concat(dirs, allDirs(dirName, dir))
    end
    return dirs
end

local root = dirTreeFromLines(input.lines())
findDirSizes(root)

eio.printf("Part 1: %i\n",
    F.sum(
    F.filter(function (size) return size <= 100000 end,
    F.map(function (dir) return dir[2] end,
    allDirs("/", root)))))

local function findDirToDelete (root)
    local usedSpace = root.size
    local totalDiskSpace = 70000000
    local neededFreeSpace = 30000000
    local freeSpace = totalDiskSpace - usedSpace
    local spaceToFree = neededFreeSpace - freeSpace
    local dirs = allDirs("/", root)

    local candidatesToRemove = {}
    for _, dir in ipairs(dirs) do
        if dir[2] >= spaceToFree then
            table.insert(candidatesToRemove, dir)
        end
    end

    local dirToDelete = {"/", root.size}
    for _, dir in ipairs(candidatesToRemove) do
        if dir[2] < dirToDelete[2] then
            dirToDelete = dir
        end
    end

    return dirToDelete
end

eio.printf("Part 2: %i\n", findDirToDelete(root)[2])
