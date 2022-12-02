-- Enhanced IO
local eio = {}

local function basicShow (o)
    return string.format("%q", o)
end

local function isLuaId (k)
    return type(k) == "string" and string.find(k, "[_%a][_%w]*")
end

local function basicShowKey (k)
    if isLuaId(k) then
        return k
    else
        return "[" .. basicShow(k) .. "]"
    end
end

local function isInteger (o)
    return type(o) == "number" and math.floor(o) == o
end

-- Will print an object
-- Supports cycles
-- The result can be saved into a Lua file
function eio.show (name, value, key, saved, indent)
    key = key or name
    saved = saved or {} -- contains references to tables, i.e. {name, fieldNames}
    indent = indent or ""

    local hideSeqIndices = false

    local function show (name, value, key, saved, indent, hideKey)
        local keyStr = ""
        if not hideKey then
            keyStr = basicShowKey(key) .. " = "
        end
        local valueType = type(value)
        if valueType == "number" or valueType == "string"  or valueType == "boolean" or valueType == "nil" then
            io.write(indent, keyStr, basicShow(value))
        elseif valueType == "table" then
            if saved[value] then
                table.insert(saved[value].fieldNames, name)
                io.write(indent, keyStr, "nil")
            else
                saved[value] = {name = name, fieldNames = {}}
                io.write(indent, keyStr, "{")
                if next(value) then
                    io.write("\n")
                end
                local newIndent = indent.."    "
                local sequenceSize = nil
                for i, v in ipairs(value) do
                    local fieldName = string.format("%s[%q]", name, i)
                    show(fieldName, v, i, saved, newIndent, hideSeqIndices)
                    io.write(",\n")
                    sequenceSize = i
                end
                for k, v in pairs(value) do
                    if sequenceSize and isInteger(k) and 1 <= k and k <= sequenceSize then
                        goto continue
                    end
                    local fname
                    if isLuaId(k) then
                        fname = string.format("%s.%s", name, k)
                    else
                        fname = string.format("%s[%s]", name, basicShow(k))
                    end
                    show(fname, v, k, saved, newIndent, false)
                    io.write(",\n")
                    ::continue::
                end
                if not next(value) then
                    io.write("}")
                else
                    io.write(indent, "}")
                end
                if indent == "" then
                    io.write("\n")
                end
            end
        else
            error("cannot save a "..type(value))
        end
    end

    show(name, value, key, saved, indent, false)

    for _, x in pairs(saved) do
        for _, fieldName in ipairs(x.fieldNames) do
            io.write(fieldName, " = ", x.name, "\n")
        end
    end

    io.write("\n")
end

function eio.printf (fmt, ...)
    return io.write(string.format(fmt, ...))
end

return eio
