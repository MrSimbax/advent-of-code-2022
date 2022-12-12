local write = io.write
local clock = os.clock

local profile = {}

local time

function profile.start ()
    time = clock()
    return time
end

function profile.finish ()
    time = clock() - time
    write("\nTime taken: ", time, " s\n")
    return time
end

return profile
