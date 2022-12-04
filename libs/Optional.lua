local Optional = {}

Optional.__index = Optional

function Optional.new (payload)
    local opt = {payload = payload}
    setmetatable(opt, Optional)
    return opt
end

function Optional.empty ()
    return Optional.new()
end

function Optional:value ()
    if not self:hasValue() then
        error("attempt to access empty Optional", 2)
    end
    return self.payload
end

function Optional:hasValue ()
    return self.payload ~= nil
end

function Optional:isEmpty ()
    return not self:hasValue()
end

function Optional.__eq (a, b)
    return (a:isEmpty() and b:isEmpty()) or (a:hasValue() and b:hasValue() and a.payload == b.payload)
end

return Optional
