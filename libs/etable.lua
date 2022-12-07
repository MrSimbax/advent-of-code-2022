-- Extended table module
local etable = {}

function etable.concat (as, bs)
    table.move(bs, 1, #bs, #as + 1, as)
end

return etable
