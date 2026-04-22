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

-- Creates a new token
function Token.new(type, value)
    return setmetatable({
        type = type,
        value = value,
    }, mt)
end

return Token
