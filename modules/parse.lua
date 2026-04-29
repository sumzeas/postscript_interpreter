local Token = require "modules.token"
local Parse = {}
Parse.__index = Parse

function Parse.new(tokens)
    return setmetatable({
        tokens = tokens,
    }, Parse)
end

function Parse:read()
    local result, _ = self:parse_sequence(1, nil)
    self.tokens = result
end

function Parse:parse_sequence(start, stop_type)
    local result = {}
    local i = start
    local T = Token.types

    while i <= #self.tokens do
        local token = self.tokens[i]

        if stop_type and token.type == stop_type then
            return result, i

        elseif token.type == T["leftbrace"] then
            local inner, close_pos = self:parse_sequence(i + 1, T["rightbrace"])
            if close_pos > #self.tokens then
                error("Unmatched '{': missing '}'")
            end
            table.insert(result, Token.new(T["procedure"], inner))
            i = close_pos + 1

        elseif token.type == T["leftbracket"] then
            local inner, close_pos = self:parse_sequence(i + 1, T["rightbracket"])
            if close_pos > #self.tokens then
                error("Unmatched '[': missing ']'")
            end
            table.insert(result, Token.new(T["array"], inner))
            i = close_pos + 1

        elseif token.type == T["slash"] then
            local next_tok = self.tokens[i + 1]
            if not next_tok or
               (next_tok.type ~= T["identifier"] and next_tok.type ~= T["keyword"]) then
                error("Expected a name after '/'")
            end
            table.insert(result, Token.new(T["slash"], next_tok.value))
            i = i + 2

        else
            table.insert(result, token)
            i = i + 1
        end
    end

    return result, i
end

function Parse:display_tokens()
    for _, token in ipairs(self.tokens) do
        token:print()
    end
end

return Parse
