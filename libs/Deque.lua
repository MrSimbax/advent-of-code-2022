local Deque = {}

local mt = {__index = Deque}

function Deque.new ()
    return setmetatable({first = 0, last = -1}, mt)
end

function Deque.isEmpty (q)
    return q.first > q.last
end

function Deque.sizeof (q)
    return q.last - q.first + 1
end

function Deque.pushFirst (q, value)
    local first = q.first - 1
    q.first = first
    q[first] = value
end

function Deque.pushLast (q, value)
    local last = q.last + 1
    q.last = last
    q[last] = value
end

function Deque.popFirst (q)
    local first = q.first
    if first > q.last then
        error('q is empty')
    end
    local value = q[first]
    q.first = first + 1
    q[first] = nil
    if q:isEmpty() then
        q.first = 0
        q.last = -1
    end
    return value
end

function Deque.popLast (q)
    local last = q.last
    if last < q.first then
        error('q is empty')
    end
    local value = q[last]
    q.last = last - 1
    q[last] = nil
    if q:isEmpty() then
        q.first = 0
        q.last = -1
    end
    return value
end

return Deque
