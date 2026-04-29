local Token = require "modules.token"
local Stack = require "modules.stack"
local Lex   = require "modules.lex"
local Parse = require "modules.parse"

local Exec = {}
Exec.__index = Exec

function Exec.new(tokens)
    return setmetatable({
        tokens = tokens,
        operand_stack = Stack.new(),
        dict_stack = {{}},
    }, Exec)
end

function Exec:lookup(name)
    for i = #self.dict_stack, 1, -1 do
        local val = self.dict_stack[i][name]
        if val ~= nil then return val end
    end
    return nil
end

function Exec:define(name, value)
    self.dict_stack[#self.dict_stack][name] = value
end

function Exec:run()
    self:exec_tokens(self.tokens)
end

function Exec.run_source(source)
    local lexer = Lex.new(source)
    lexer:read()

    local parser = Parse.new(lexer.tokens)
    parser:read()

    local executor = Exec.new(parser.tokens)
    executor:run()
end

function Exec:exec_tokens(tokens)
    for _, token in ipairs(tokens) do
        self:exec_token(token)
    end
end

function Exec:exec_token(token)
    local T = Token.types
    local s = self.operand_stack

    if token.type == T["number"]
    or token.type == T["string"]
    or token.type == T["procedure"]
    or token.type == T["array"]
    or token.type == T["slash"] then
        s:push(token)

    elseif token.type == T["identifier"] then
        local val = self:lookup(token.value)
        if val == nil then
            error("Undefined name: " .. token.value)
        end
        if val.type == T["procedure"] then
            self:exec_tokens(val.value)
        else
            s:push(val)
        end

    elseif token.type == T["keyword"] then
        self:exec_keyword(token.value)
    end
end

function Exec:exec_keyword(kw)
    local T = Token.types
    local s = self.operand_stack

    if kw == "true" then
        s:push(Token.new(T["keyword"], "true"))
    elseif kw == "false" then
        s:push(Token.new(T["keyword"], "false"))

    -- stack operations
    elseif kw == "pop" then
        s:pop()

    elseif kw == "exch" then
        local b = s:pop()
        local a = s:pop()
        s:push(b)
        s:push(a)

    elseif kw == "dup" then
        s:push(s:peek())

    elseif kw == "copy" then
        local n = s:pop().value
        local base = #s.data - n + 1

        for i = base, base + n - 1 do
            s:push(s.data[i])
        end

    elseif kw == "clear" then
        s.data = {}

    elseif kw == "count" then
        s:push(Token.new(T["number"], #s.data))

    -- arithmetic operations
    elseif kw == "add" then
        local b = s:pop().value
        local a = s:pop().value
        s:push(Token.new(T["number"], a + b))

    elseif kw == "sub" then
        local b = s:pop().value
        local a = s:pop().value
        s:push(Token.new(T["number"], a - b))

    elseif kw == "mul" then
        local b = s:pop().value
        local a = s:pop().value
        s:push(Token.new(T["number"], a * b))

    elseif kw == "div" then
        local b = s:pop().value
        local a = s:pop().value
        s:push(Token.new(T["number"], a / b))

    elseif kw == "idiv" then
        local b = s:pop().value
        local a = s:pop().value
        s:push(Token.new(T["number"], a // b))

    elseif kw == "mod" then
        local b = s:pop().value
        local a = s:pop().value
        s:push(Token.new(T["number"], a % b))

    elseif kw == "abs" then
        s:push(Token.new(T["number"], math.abs(s:pop().value)))

    elseif kw == "neg" then
        s:push(Token.new(T["number"], -s:pop().value))

    elseif kw == "ceiling" then
        s:push(Token.new(T["number"], math.ceil(s:pop().value)))

    elseif kw == "floor" then
        s:push(Token.new(T["number"], math.floor(s:pop().value)))

    elseif kw == "round" then
        s:push(Token.new(T["number"], math.floor(s:pop().value + 0.5)))

    elseif kw == "sqrt" then
        s:push(Token.new(T["number"], math.sqrt(s:pop().value)))

    -- comparison operations
    elseif kw == "eq" then
        local b = s:pop()
        local a = s:pop()
        s:push(Token.new(T["keyword"], a.value == b.value and "true" or "false"))

    elseif kw == "ne" then
        local b = s:pop()
        local a = s:pop()
        s:push(Token.new(T["keyword"], a.value ~= b.value and "true" or "false"))

    elseif kw == "gt" then
        local b = s:pop()
        local a = s:pop()
        s:push(Token.new(T["keyword"], a.value > b.value and "true" or "false"))

    elseif kw == "ge" then
        local b = s:pop()
        local a = s:pop()
        s:push(Token.new(T["keyword"], a.value >= b.value and "true" or "false"))

    elseif kw == "lt" then
        local b = s:pop()
        local a = s:pop()
        s:push(Token.new(T["keyword"], a.value < b.value and "true" or "false"))

    elseif kw == "le" then
        local b = s:pop()
        local a = s:pop()
        s:push(Token.new(T["keyword"], a.value <= b.value and "true" or "false"))

    elseif kw == "and" then
        local b = s:pop()
        local a = s:pop()

        if a.type == T["number"] then
            s:push(Token.new(T["number"], a.value & b.value))
        else
            local result = a.value == "true" and b.value == "true"
            s:push(Token.new(T["keyword"], result and "true" or "false"))
        end

    elseif kw == "or" then
        local b = s:pop()
        local a = s:pop()

        if a.type == T["number"] then
            s:push(Token.new(T["number"], a.value | b.value))
        else
            local result = a.value == "true" or b.value == "true"
            s:push(Token.new(T["keyword"], result and "true" or "false"))
        end

    elseif kw == "not" then
        local a = s:pop()
        if a.type == T["number"] then
            s:push(Token.new(T["number"], ~a.value))
        else
            s:push(Token.new(T["keyword"], a.value == "true" and "false" or "true"))
        end

    -- dictionary operations
    elseif kw == "dict" then
        s:pop()
        s:push(Token.new(T["dictionary"], {}))

    elseif kw == "begin" then
        local d = s:pop()
        table.insert(self.dict_stack, d.value)

    elseif kw == "end" then
        if #self.dict_stack <= 1 then
            error("dict stack underflow")
        end
        table.remove(self.dict_stack)

    elseif kw == "def" then
        local val = s:pop()
        local name = s:pop()
        self:define(name.value, val)

    elseif kw == "length" then
        local a = s:pop()
        if a.type == T["string"] then
            s:push(Token.new(T["number"], #a.value))
        elseif a.type == T["array"] or a.type == T["procedure"] then
            s:push(Token.new(T["number"], #a.value))
        elseif a.type == T["dictionary"] then
            local count = 0
            for _ in pairs(a.value) do count = count + 1 end
            s:push(Token.new(T["number"], count))
        end

    elseif kw == "maxlength" then
        local a = s:pop()
        local count = 0
        for _ in pairs(a.value) do count = count + 1 end
        s:push(Token.new(T["number"], count))

    elseif kw == "get" then
        local key = s:pop()
        local obj = s:pop()
        if obj.type == T["array"] then
            s:push(obj.value[key.value + 1])
        elseif obj.type == T["dictionary"] then
            local v = obj.value[key.value]
            if v == nil then error("get: key not found: " .. tostring(key.value)) end
            s:push(v)
        elseif obj.type == T["string"] then
            s:push(Token.new(T["number"], string.byte(obj.value, key.value + 1)))
        end

    elseif kw == "put" then
        local val = s:pop()
        local key = s:pop()
        local obj = s:pop()

        if obj.type == T["array"] then
            obj.value[key.value + 1] = val
        elseif obj.type == T["dictionary"] then
            obj.value[key.value] = val
        end

    elseif kw == "if" then
        local proc = s:pop()
        local cond = s:pop()
        if cond.value == "true" then
            self:exec_tokens(proc.value)
        end

    elseif kw == "ifelse" then
        local false_proc = s:pop()
        local true_proc = s:pop()
        local cond = s:pop()

        if cond.value == "true" then
            self:exec_tokens(true_proc.value)
        else
            self:exec_tokens(false_proc.value)
        end

    elseif kw == "for" then
        local proc = s:pop()
        local limit = s:pop().value
        local inc = s:pop().value
        local init = s:pop().value
        local i = init
        while (inc > 0 and i <= limit) or (inc < 0 and i >= limit) do
            s:push(Token.new(T["number"], i))
            self:exec_tokens(proc.value)
            i = i + inc
        end

    elseif kw == "repeat" then
        local proc = s:pop()
        local n = s:pop().value
        for _ = 1, n do
            self:exec_tokens(proc.value)
        end

    elseif kw == "print" then
        print(tostring(s:pop().value))

    elseif kw == "=" then
        print(tostring(s:pop().value))

    elseif kw == "==" then
        print(tostring(s:pop()))

    elseif kw == "quit" then
        os.exit(0)

    else
        error("Unknown keyword: " .. kw)
    end
end

return Exec
