local seq = require "libs/sequence"

local setmetatable = setmetatable
local getmetatable = getmetatable
local rawget = rawget
local rawset = rawset
local map = seq.map

local Vector = {}

local mt = {}

local function makeVec (a)
    return setmetatable(a, mt)
end

Vector.new = makeVec

setmetatable(Vector, {__call = function (_, ...) return makeVec(...) end})

function mt.__add (u, v)
    local r = {}
    if getmetatable(u) == mt and getmetatable(v) == mt then
        for i = 1, #u do
            r[i] = u[i] + v[i]
        end
    elseif getmetatable(u) == mt then
        for i = 1, #u do
            r[i] = u[i] + v
        end
    else
        for i = 1, #v do
            r[i] = u + v[i]
        end
    end
    return makeVec(r)
end

function mt.__mul (u, v)
    local r = {}
    if getmetatable(u) == mt and getmetatable(v) == mt then
        for i = 1, #u do
            r[i] = u[i] * v[i]
        end
    elseif getmetatable(u) == mt then
        for i = 1, #u do
            r[i] = u[i] * v
        end
    else
        for i = 1, #v do
            r[i] = u * v[i]
        end
    end
    return makeVec(r)
end

function mt.__sub (u, v)
    local r = {}
    if getmetatable(u) == mt and getmetatable(v) == mt then
        for i = 1, #u do
            r[i] = u[i] - v[i]
        end
    elseif getmetatable(u) == mt then
        for i = 1, #u do
            r[i] = u[i] - v
        end
    else
        error("attempt to subtract vector from scalar", 2)
    end
    return makeVec(r)
end

function mt.__div (u, v)
    local r = {}
    if getmetatable(u) == mt and getmetatable(v) == mt then
        for i = 1, #u do
            r[i] = u[i] / v[i]
        end
    elseif getmetatable(u) == mt then
        for i = 1, #u do
            r[i] = u[i] / v
        end
    else
        error("attempt to divide scalar by vector", 2)
    end
    return makeVec(r)
end

function mt.__idiv (u, v)
    local r = {}
    if getmetatable(u) == mt and getmetatable(v) == mt then
        for i = 1, #u do
            r[i] = u[i] // v[i]
        end
    elseif getmetatable(u) == mt then
        for i = 1, #u do
            r[i] = u[i] // v
        end
    else
        error("attempt to divide scalar by vector", 2)
    end
    return makeVec(r)
end

function mt.__mod (u, v)
    local r = {}
    if getmetatable(u) == mt and getmetatable(v) == mt then
        for i = 1, #u do
            r[i] = u[i] % v[i]
        end
    elseif getmetatable(u) == mt then
        for i = 1, #u do
            r[i] = u[i] % v
        end
    else
        error("attempt to take scalar modulo vector", 2)
    end
    return makeVec(r)
end

function mt.__unm (u)
    local r = {}
    for i = 1, #u do
        r[i] = -u[i]
    end
    return makeVec(r)
end

function mt.__eq (u, v)
    if getmetatable(u) ~= mt or getmetatable(v) ~= mt then
        error("attempt to compare a vector with something else", 2)
    end
    for i = 1, #u do
        if u[i] ~= v[i] then
            return false
        end
    end
    return true
end

function mt.__lt (u, v)
    if getmetatable(u) ~= mt or getmetatable(v) ~= mt then
        error("attempt to compare a vector with something else", 2)
    end
    for i = 1, #u do
        if u[i] < v[i] then
            return true
        end
    end
    return false
end

function mt.__le (u, v)
    return u == v or u < v
end

local indexFromChar = {
    ['x'] = 1,
    ['y'] = 2,
    ['z'] = 3,
    ['w'] = 4,

    ['r'] = 1,
    ['g'] = 2,
    ['b'] = 3,
    ['a'] = 4,

    ['i'] = 1,
    ['j'] = 2,
    ['k'] = 3,
    ['l'] = 4
}

function mt.__index (vec, key)
    if key:len() == 1 then
        return rawget(vec, indexFromChar[key])
    else
        local rs = {}
        for c in key:gmatch(".") do
            table.insert(rs, rawget(vec, indexFromChar[c]))
        end
        return makeVec(rs)
    end
end

function mt.__newindex (vec, key, value)
    if key:len() == 1 then
        return rawset(vec, indexFromChar[key], value)
    else
        for i = 1, key:len() do
            rawset(vec, indexFromChar[key:sub(i, i)], value[i])
        end
        return vec
    end
end

function Vector.dot (u, v)
    local r = 0
    for i = 1, #u do
        r = r + u[i] * v[i]
    end
    return r
end

function Vector.norm (u)
    return math.sqrt(Vector.dot(u, u))
end

function Vector.dist (u, v)
    return Vector.norm(u - v)
end

function mt.__tostring (v)
    return "[" .. table.concat(map(tostring, v), ", ") .. "]"
end

local multidimMt = {}

function Vector.allowVectorIndices (t)
    return setmetatable(t, multidimMt)
end

function multidimMt.__index (t, key)
    if getmetatable(key) == mt then
        local r = t
        for i = 1, #key do
            r = r[key[i]]
        end
        return r
    else
        return rawget(t, key)
    end
end

function multidimMt.__newindex (t, key, value)
    if getmetatable(key) == mt then
        local r = t
        for i = 1, #key - 1 do
            r = r[key[i]]
        end
        r[key[#key]] = value
        return r
    else
        return rawget(t, key)
    end
end

return Vector
