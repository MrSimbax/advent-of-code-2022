-- For (partial) compatibility with Lua 5.4 and LuaJIT

-- Try importing the library from LuaJIT first, load the Lua 5.4 module otherwise
local ok, bit = pcall(require, "bit")
if ok then
    return bit
else
    return require("libs.bit_5_4")
end
