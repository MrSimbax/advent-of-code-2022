local sqrt = math.sqrt
local setmetatable = setmetatable
local getmetatable = getmetatable
local floor = math.floor
local concat = table.concat

local mt = {}

local function makeCacheZ (x, y)
    return {
        __index = function (cacheZ, z)
            local vec = setmetatable({x, y, z}, mt)
            cacheZ[z] = vec
            return vec
        end
    }
end

local function makeCacheY (x)
    return {
        __index = function (cacheY, y)
            local cacheZ = setmetatable({}, makeCacheZ(x, y))
            cacheY[y] = cacheZ
            return cacheZ
        end
    }
end

local cache = setmetatable({}, {
    __index = function (cache, x)
        local cacheY = setmetatable({}, makeCacheY(x))
        cache[x] = cacheY
        return cacheY
    end
})

local function makeVec (x, y, z)
    return cache[x][y][z]
end

local function isVec (v)
    return getmetatable(v) == mt
end

function mt.__add (u, v)
    if isVec(u) and isVec(v) then
        return makeVec(u[1] + v[1], u[2] + v[2], u[3] + v[3])
    elseif isVec(u) then
        return makeVec(u[1] + v, u[2] + v, u[3] + v)
    else
        return makeVec(u + v[1], u + v[2], u + v[3])
    end
end

function mt.__mul (u, v)
    if isVec(u) and isVec(v) then
        return makeVec(u[1] * v[1], u[2] * v[2], u[3] * v[3])
    elseif isVec(u) then
        return makeVec(u[1] * v, u[2] * v, u[3] * v)
    else
        return makeVec(u * v[1], u * v[2], u * v[3])
    end
end

function mt.__sub (u, v)
    if isVec(u) and isVec(v) then
        return makeVec(u[1] - v[1], u[2] - v[2], u[3] - v[3])
    elseif isVec(u) then
        return makeVec(u[1] - v, u[2] - v, u[3] - v)
    else
        return error("attempt to subtract vector from scalar", 2)
    end
end

function mt.__div (u, v)
    if isVec(u) and isVec(v) then
        return makeVec(u[1] / v[1], u[2] / v[2], u[3] / v[3])
    elseif isVec(u) then
        return makeVec(u[1] / v, u[2] / v, u[3] / v)
    else
        return error("attempt to divide vector by scalar", 2)
    end
end

local function idiv (u, v)
    if isVec(u) and isVec(v) then
        return makeVec(floor(u[1] / v[1]), floor(u[2] / v[2]), floor(u[3] / v[3]))
    elseif isVec(u) then
        return makeVec(floor(u[1] / v), floor(u[2] / v), floor(u[3] / v))
    else
        return error("attempt to divide vector by scalar", 2)
    end
end

mt.__idiv = idiv

function mt.__mod (u, v)
    if isVec(u) and isVec(v) then
        return makeVec(u[1] % v[1], u[2] % v[2], u[3] % v[3])
    elseif isVec(u) then
        return makeVec(u[1] % v, u[2] % v, u[3] % v)
    else
        return error("attempt to divide vector by scalar", 2)
    end
end

function mt.__unm (u)
    return makeVec(-u[1], -u[2], -u[3])
end

function mt.__lt (u, v)
    if not isVec(u) or not isVec(v) then
        error("attempt to compare a vector with something else", 2)
    end
    return u[1] < v[1] or (u[1] == v[1] and (u[2] < v[2] or (u[2] == v[2] and u[3] < v[3])))
end

function mt.__le (u, v)
    return u == v or u < v
end

function mt.__tostring (v)
    return '(' .. concat(v, ", ") .. ')'
end

local function dot (u, v)
    return u[1] * v[1] + u[2] * v[2] + u[3] * v[3]
end

local function norm (u)
    return sqrt(dot(u, u))
end

local function dist (u, v)
    return norm(u - v)
end

local function map (f, v)
    return makeVec(f(v[1]), f(v[2]), f(v[3]))
end

return {
    makeVec = makeVec,
    dot = dot,
    norm = norm,
    dist = dist,
    map = map,
    isVec = isVec,
    idiv = idiv
}
