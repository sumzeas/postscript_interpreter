local Stack = {}
Stack.__index = Stack

function Stack.new()
    return setmetatable({
        data = {},
    }, Stack)
end

function Stack:push(v)
    table.insert(self.data, v)
end

function Stack:pop()
    local v = self:peek()
    table.remove(self.data, -1)
    return v
end

function Stack:peek()
    if #self.data <= 0 then
        error "Stack is empty"
    end
    return self.data[#self.data]
end

function Stack:__tostring()
    local output = ""
    output = output .. "{"
    for i = #self.data, 1, -1 do
        if i ~= 1 then
            output = output .. tostring(self.data[i]) .. ", "
        else
            output = output .. tostring(self.data[i])
        end
    end
    output = output .. "}"
    return output
end

return Stack
