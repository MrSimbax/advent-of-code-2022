-- Extended math module
local floor = math.floor

local function sgn (x)
    if x > 0 then
        return 1
    elseif x < 0 then
        return -1
    else
        return 0
    end
end

local function egcd (a, b)
    if a == 0 then
        return b, 0, 1
    end
    local d, x, y = egcd(b % a, a)
    return d, (y - floor(b / a) * x), x
end

local function modinv (a, m)
    local d, x, _ = egcd(a, m)
    if d ~= 1 then
        print("uh oh", a, m)
        return nil
    else
        return (x % m + m) % m
    end
end

return {
    sgn = sgn,
    egcd = egcd,
    modinv = modinv
}
