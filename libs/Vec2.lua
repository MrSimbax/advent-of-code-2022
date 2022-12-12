local sqrt = math.sqrt
local setmetatable = setmetatable
local getmetatable = getmetatable

local mt = {}

local function makeCacheY (x)
    return {
        __index = function (cacheY, y)
            local vec = setmetatable({x, y}, mt)
            cacheY[y] = vec
            return vec
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

local function makeVec (x, y)
    return cache[x][y]
end

local function isVec (v)
    return getmetatable(v) ~= nil
end

function mt.__add (u, v)
    if isVec(u) and isVec(v) then
        return makeVec(u[1] + v[1], u[2] + v[2])
    elseif isVec(u) then
        return makeVec(u[1] + v, u[2] + v)
    else
        return makeVec(u + v[1], u + v[2])
    end
end

function mt.__mul (u, v)
    if isVec(u) and isVec(v) then
        return makeVec(u[1] * v[1], u[2] * v[2])
    elseif isVec(u) then
        return makeVec(u[1] * v, u[2] * v)
    else
        return makeVec(u * v[1], u * v[2])
    end
end

function mt.__sub (u, v)
    if isVec(u) and isVec(v) then
        return makeVec(u[1] - v[1], u[2] - v[2])
    elseif isVec(u) then
        return makeVec(u[1] - v, u[2] - v)
    else
        return error("attempt to subtract vector from scalar", 2)
    end
end

function mt.__div (u, v)
    if isVec(u) and isVec(v) then
        return makeVec(u[1] / v[1], u[2] / v[2])
    elseif isVec(u) then
        return makeVec(u[1] / v, u[2] / v)
    else
        return error("attempt to divide vector by scalar", 2)
    end
end

-- function mt.__idiv (u, v)
--     if isVec(u) and isVec(v) then
--         return makeVec(u[1] // v[1], u[2] // v[2])
--     elseif isVec(u) then
--         return makeVec(u[1] // v, u[2] // v)
--     else
--         return error("attempt to divide vector by scalar", 2)
--     end
-- end

function mt.__mod (u, v)
    if isVec(u) and isVec(v) then
        return makeVec(u[1] % v[1], u[2] % v[2])
    elseif isVec(u) then
        return makeVec(u[1] % v, u[2] % v)
    else
        return error("attempt to divide vector by scalar", 2)
    end
end

function mt.__unm (u)
    return makeVec(-u[1], -u[2])
end

function mt.__lt (u, v)
    if not isVec(u) or not isVec(v) then
        error("attempt to compare a vector with something else", 2)
    end
    if u[1] >= v[1] or u[2] >= v[2] then
        return false
    end
    return true
end

function mt.__le (u, v)
    return u == v or u < v
end

function mt.__tostring (v)
    return '('..v[1]..', '..v[2]..')'
end

local function dot (u, v)
    return u[1] * v[1] + u[2] * v[2]
end

local function norm (u)
    return sqrt(dot(u, u))
end

local function dist (u, v)
    return norm(u - v)
end

local function map (f, v)
    return makeVec(f(v[1]), f(v[2]))
end

local mtArray2d = {}

local function allowVec2Indices (t)
    return setmetatable(t, mtArray2d)
end

function mtArray2d.__index (t, v)
    if isVec(v) then
        return t[v[1]][v[2]]
    else
        return rawget(t, v)
    end
end

function mtArray2d.__newindex (t, v, x)
    t[v[1]][v[2]] = x
end

local function makeGrid (width, height, value)
    local grid = {}
    for y = 1, height do
        local row = {}
        for x = 1, width do
            row[x] = value
        end
        grid[y] = row
    end
    return allowVec2Indices(grid)
end

return {
    makeVec = makeVec,
    dot = dot,
    norm = norm,
    dist = dist,
    allowVec2Indices = allowVec2Indices,
    makeGrid = makeGrid,
    map = map,
    isVec = isVec
}
