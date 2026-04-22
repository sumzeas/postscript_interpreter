local Keywords  = require "keywords"
local Token     = require "token"

local Lex = {}
Lex.__index = Lex

-- Creates a new lexer
function Lex.new(input)
    return setmetatable({
        input = input or "",
        tokens = {}
    }, Lex)
end

-- Resets the lexer's input and tokens
function Lex:reset()
    self.input = ""
    self.tokens = {}
end

-- Reads a string and handles escaped characters
function Lex:read_string(input, start)
    local i = start + 1
    local depth = 1
    local result = ""

    while i <= #input do
        local c = input:sub(i, i)
        if c == "\\" then
            local next_char = input:sub(i + 1, i + 1)
            -- handling special characters
            if next_char == "n" then
                result = result .. "\n"
            elseif next_char == "t" then
                result = result .. "\t"
            elseif next_char == "r" then
                result = result .. "\r"
            elseif next_char == "b" then
                result = result .. "\b"
            elseif next_char == "f" then
                result = result .. "\f"
            elseif next_char == "\n" then
            -- line continuation
            else
                result = result .. next_char
            end
            i = i + 2

        elseif c == "(" then
            depth = depth + 1
            result = result .. c
            i = i + 1

        elseif c == ")" then
            depth = depth - 1
            if depth == 0 then
                return result, i
            end
            result = result .. c
            i = i + 1

        else
            result = result .. c
            i = i + 1

        end
    end

    error("Unterminated string")
end

-- Begins reading the input
function Lex:read()
    local i = 1
    local input = self.input
    while i <= #input do
        local sub = input:sub(i)

        -- Skipping whitespace
        local s, e = sub:find("^%s+")
        if s then
            i = i + e
            goto continue
        end

        local match = sub:match("^{")
        if match then
            i = i + #match
            self:insert_token(
                Token.new(Token.types["leftbrace"])
            )
            goto continue
        end

        match = sub:match("^}")
        if match then
            i = i + #match
            self:insert_token(
                Token.new(Token.types["rightbrace"])
            )
            goto continue
        end

        match = sub:match("^%[")
        if match then
            i = i + #match
            self:insert_token(
                Token.new(Token.types["leftbracket"])
            )
            goto continue
        end

        match = sub:match("^%]")
        if match then
            i = i + #match
            self:insert_token(
                Token.new(Token.types["rightbracket"])
            )
            goto continue
        end

        match = sub:match("^%(")
        if match then
            local str, e_pos = self:read_string(sub, 1)
            i = i + e_pos
            self:insert_token(
                Token.new(Token.types["string"], str)
            )
            goto continue
        end

        match = sub:match("^/")
        if match then
            i = i + #match
            self:insert_token(
                Token.new(Token.types["slash"])
            )
            goto continue
        end

        match = sub:match("^%b()")
        if match then
            i = i + #match
            self:insert_token(
                Token.new(Token.types["string"], match:sub(2, -2))
            )
            goto continue
        end

        match = sub:match("^[%a_][%w_]*")
        if match then
            i = i + #match
            if Keywords[match] then
                self:insert_token(
                    Token.new(Token.types["keyword"], match)
                )
            else
                self:insert_token(
                    Token.new(Token.types["identifier"], match)
                )
            end
            goto continue
        end

        match = sub:match("^%d*%.?%d+")
        if match then
            i = i + #match
            self:insert_token(
                Token.new(Token.types["number"], tonumber(match))
            )
            goto continue
        end

        error(string.format("Unknown pattern: %s", sub))

        ::continue::
    end
end

-- Inserts a token at the end
function Lex:insert_token(token)
    table.insert(self.tokens, token)
end

-- Displays the tokens
function Lex:display_tokens()
    for _, token in ipairs(self.tokens) do
        print(token)
    end
end

return Lex
