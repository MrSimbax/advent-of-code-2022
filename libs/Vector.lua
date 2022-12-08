local Vector = {}

local mt = {}

function Vector.new (a)
    local v = {}
    for i in ipairs(a) do
        v[i] = a[i]
    end
    setmetatable(v, mt)
    return v
end

setmetatable(Vector, {__call = function (_, ...) return Vector.new(...) end})

function mt.__add (u, v)
    local r = Vector.new{}
    if getmetatable(u) == mt and getmetatable(v) == mt then
        for i in ipairs(u) do
            r[i] = u[i] + v[i]
        end
    elseif getmetatable(u) == mt then
        for i in ipairs(u) do
            r[i] = u[i] + v
        end
    else
        for i in ipairs(v) do
            r[i] = u + v[i]
        end
    end
    return r
end

function mt.__mul (u, v)
    local r = Vector.new{}
    if getmetatable(u) == mt and getmetatable(v) == mt then
        for i in ipairs(u) do
            r[i] = u[i] * v[i]
        end
    elseif getmetatable(u) == mt then
        for i in ipairs(u) do
            r[i] = u[i] * v
        end
    else
        for i in ipairs(v) do
            r[i] = u * v[i]
        end
    end
    return r
end

function mt.__sub (u, v)
    local r = Vector.new{}
    if getmetatable(u) == mt and getmetatable(v) == mt then
        for i in ipairs(u) do
            r[i] = u[i] - v[i]
        end
    elseif getmetatable(u) == mt then
        for i in ipairs(u) do
            r[i] = u[i] - v
        end
    else
        error("attempt to subtract vector from scalar", 2)
    end
    return r
end

function mt.__div (u, v)
    local r = Vector.new{}
    if getmetatable(u) == mt and getmetatable(v) == mt then
        for i in ipairs(u) do
            r[i] = u[i] / v[i]
        end
    elseif getmetatable(u) == mt then
        for i in ipairs(u) do
            r[i] = u[i] / v
        end
    else
        error("attempt to divide scalar by vector", 2)
    end
    return r
end

function mt.__idiv (u, v)
    local r = Vector.new{}
    if getmetatable(u) == mt and getmetatable(v) == mt then
        for i in ipairs(u) do
            r[i] = u[i] // v[i]
        end
    elseif getmetatable(u) == mt then
        for i in ipairs(u) do
            r[i] = u[i] // v
        end
    else
        error("attempt to divide scalar by vector", 2)
    end
    return r
end

function mt.__mod (u, v)
    local r = Vector.new{}
    if getmetatable(u) == mt and getmetatable(v) == mt then
        for i in ipairs(u) do
            r[i] = u[i] % v[i]
        end
    elseif getmetatable(u) == mt then
        for i in ipairs(u) do
            r[i] = u[i] % v
        end
    else
        error("attempt to take scalar modulo vector", 2)
    end
    return r
end

function mt.__unm (u)
    local r = Vector.new{}
    for i in ipairs(u) do
        r[i] = -u[i]
    end
    return r
end

function mt.__eq (u, v)
    if getmetatable(u) ~= mt or getmetatable(v) ~= mt then
        error("attempt to compare a vector with something else", 2)
    end
    for i in ipairs(u) do
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
    for i in ipairs(u) do
        if u[i] < v[i] then
            return true
        end
    end
    return false
end

function mt.__le (u, v)
    if getmetatable(u) ~= mt or getmetatable(v) ~= mt then
        error("attempt to compare a vector with something else", 2)
    end
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
    if type(key) == "string" then
        if key:len() == 1 then
            return rawget(vec, indexFromChar[key])
        else
            local rs = Vector.new{}
            for c in key:gmatch(".") do
                table.insert(rs, rawget(vec, indexFromChar[c]))
            end
            return rs
        end
    else
        return rawget(vec, key)
    end
end

function mt.__newindex (vec, key, value)
    if type(key) == "string" then
        if key:len() == 1 then
            return rawset(vec, indexFromChar[key], value)
        else
            for i = 1, key:len() do
                rawset(vec, indexFromChar[key:sub(i, i)], value[i])
            end
            return vec
        end
    else
        return rawset(vec, key, value)
    end
end

function Vector.dot (u, v)
    local r = 0
    for i in ipairs(u) do
        r = r + u[i] * v[i]
    end
    return r
end

return Vector
