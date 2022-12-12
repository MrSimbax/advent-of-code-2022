local fontEffects = {}
local mt = {}
setmetatable(fontEffects, mt)

local ansiEscapeCodes = {
    normal = 0,
    bold = 1,
    underline = 4,

    black = 30,
    red = 31,
    green = 32,
    yellow = 33,
    blue = 34,
    magenta = 35,
    cyan = 36,
    white = 37,

    blackBg = 40,
    redBg = 41,
    greenBg = 42,
    yellowBg = 44,
    blueBg = 44,
    magentaBg = 45,
    cyanBg = 46,
    whiteBg = 47
}

mt.__index = function (_, key)
    local code = ansiEscapeCodes[key]
    if not code then return nil end
    return string.format("\x1B[%dm", tonumber(code))
end

function fontEffects.sub (str)
    return (str:gsub("${([_%a][%w_]*)}", function (key) return fontEffects[key] end))
end

return fontEffects
