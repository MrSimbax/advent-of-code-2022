-- Enhanced IO
local eio = {}

local write = io.write
local format = string.format
local type = type
local find = string.find
local floor = math.floor
local Vec2 = require "libs.Vec2"

local function basicShow (o)
    if type(o) == "function" then
        return format("%p", o)
    elseif type(o) == "table" then
        return format("%s", tostring(o))
    else
        return format("%q", o)
    end
end

local function isLuaId (k)
    return type(k) == "string" and find(k, "[_%a][_%w]*")
end

local function basicShowKey (k)
    if isLuaId(k) then
        return k
    else
        return "[" .. basicShow(k) .. "]"
    end
end

local function isInteger (o)
    return type(o) == "number" and floor(o) == o
end

local hideSeqIndices = false

local function showRecursive (name, value, key, saved, indent, hideKey)
    local keyStr = ""
    if not hideKey then
        keyStr = basicShowKey(key) .. " = "
    end
    local valueType = type(value)
    if valueType == "number" or valueType == "string"  or valueType == "boolean" or valueType == "nil" or valueType == "function" then
        write(indent, keyStr, basicShow(value))
    elseif valueType == "table" then
        if saved[value] then
            table.insert(saved[value].fieldNames, name)
            write(indent, keyStr, "nil")
        else
            saved[value] = {name = name, fieldNames = {}}
            write(indent, keyStr, "{")
            if next(value) then
                write("\n")
            end
            local newIndent = indent.."    "
            local sequenceSize = nil
            for i, v in ipairs(value) do
                local fieldName = format("%s[%q]", name, i)
                showRecursive(fieldName, v, i, saved, newIndent, hideSeqIndices)
                write(",\n")
                sequenceSize = i
            end
            for k, v in pairs(value) do
                if sequenceSize and isInteger(k) and 1 <= k and k <= sequenceSize then
                    goto continue
                end
                local fname
                if isLuaId(k) then
                    fname = format("%s.%s", name, k)
                else
                    fname = format("%s[%s]", name, basicShow(k))
                end
                showRecursive(fname, v, k, saved, newIndent, false)
                write(",\n")
                ::continue::
            end
            if not next(value) then
                write("}")
            else
                write(indent, "}")
            end
            if indent == "" then
                write("\n")
            end
        end
    else
        error("cannot save a "..type(value))
    end
end

-- Will print an object
-- Supports cycles
-- The result can be saved into a Lua file
function eio.show (name, value, key, saved, indent)
    key = key or name
    saved = saved or {} -- contains references to tables, i.e. {name, fieldNames}
    indent = indent or ""

    showRecursive(name, value, key, saved, indent, false)

    for _, x in pairs(saved) do
        local refName = x.name
        local fieldNames = x.fieldNames
        for i = 1, #fieldNames do
            write(fieldNames[i], " = ", refName, "\n")
        end
    end

    write("\n")
end

function eio.printf (fmt, ...)
    return write(format(fmt, ...))
end

local cachedLines = {}

function eio.lines ()
    if #cachedLines == 0 then
        for line in io.lines() do
            cachedLines[#cachedLines + 1] = line
        end
    end
    return cachedLines
end

return eio
