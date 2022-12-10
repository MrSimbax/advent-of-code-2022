-- Extended table module
local etable = {}

local copy = table.move

function etable.merge (as, bs)
    return copy(bs, 1, #bs, #as + 1, as)
end

return etable
