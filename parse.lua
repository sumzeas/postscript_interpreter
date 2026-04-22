local Lex = require "lex"
local Token = require "token"
local Stack = require "stack"
local Parse = {}
Parse.__index = Parse

function Parse.new(tokens)
    return setmetatable({
        tokens = tokens,
    }, Parse)
end

function Parse:read()
    for i, token in ipairs(self.tokens) do
        if token.type == Token.types["leftbrace"] then
            self:parse_procedure(i)
        elseif token.type == Token.types["leftbracket"] then
            self:parse_array(i)
        end
    end
end

function Parse:parse_procedure(pos, depth)
    depth = depth or 0
    local procedure_token = Token.new(Token.types["procedure"])
    return procedure_token
end

function Parse:parse_array(pos, depth)
    depth = depth or 0
    local array_token = Token.new(Token.types["array"], {})
    local i = pos + 1 -- skip beginning left bracket
    while i < #self.tokens do
        local token = self.tokens[i]
        if token.type == Token.types["leftbracket"] then
            table.insert(
                array_token.value,
                self:parse_array(i, depth + 1)
            )
        elseif token.type == Token.types["rightbracket"] then
            break
        end
    end
    return array_token
end
