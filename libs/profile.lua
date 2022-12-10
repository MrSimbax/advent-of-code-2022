local write = io.write
local clock = os.clock

local profile = {}

local time

function profile.start ()
    time = clock()
end

function profile.finish ()
    time = clock() - time
    write("\nTime taken: ", time, " s\n")
end

return profile
