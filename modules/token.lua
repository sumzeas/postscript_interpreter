local Token = {}

-- A table containing the list of token types
Token.types = {
    ["identifier"]      = "identifier",
    ["slash"]           = "slash",
    ["leftbrace"]       = "leftbrace",
    ["rightbrace"]      = "rightbrace",
    ["leftbracket"]     = "leftbracket",
    ["rightbracket"]    = "rightbracket",
    ["string"]          = "string",
    ["number"]          = "number",
    ["procedure"]       = "procedure",
    ["dictionary"]      = "dictionary",
    ["array"]           = "array",
    ["keyword"]         = "keyword",
}

local mt = {}
mt.__index = mt

function mt:__tostring()
    return string.format("{type = %-15s, value = %-10s}", self.type, self.value)
end

function mt:assert_type(type)
    assert(self.type == type)
end

function mt:print(indent)
    indent = indent or 0
    local pad = string.rep("  ", indent)
    local T = Token.types
    if self.type == T["procedure"] or self.type == T["array"] then
        print(string.format("%s{type = %s}", pad, self.type))
        for _, child in ipairs(self.value) do
            child:print(indent + 1)
        end
        print(string.format("%s}", pad))
    else
        print(string.format("%s{type = %-15s, value = %-10s}", pad, self.type, tostring(self.value)))
    end
end

-- Creates a new token
function Token.new(type, value)
    return setmetatable({
        type = type,
        value = value,
    }, mt)
end

return Token
