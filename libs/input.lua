local input = {}

local savedLines = {}

function input.lines ()
    if #savedLines == 0 then
        for line in io.lines() do
            table.insert(savedLines, line)
        end
    end
    return savedLines
end

return input
