local LU    = require "luaunit"
local Lex   = require "modules.lex"
local Token = require "modules.token"

TestParse = {}

function TestParse:setUp()
    self.lex = Lex.new()
end

function TestParse:resetAndParse(input)
    self.lex:reset()
    self.lex.input = input
    self.lex:read()
end

function TestParse:testSingleLineString()
    self:resetAndParse([[
(Hello world!)
]])

    local token = self.lex.tokens[1]
    LU.assertEquals(token.type, Token.types["string"])
    LU.assertEquals(token.value, "Hello world!")
end

function TestParse:testMultilineString()
    self:resetAndParse([[
(Hello
world!)
]])

    local token = self.lex.tokens[1]
    LU.assertEquals(token.type, Token.types["string"])
    LU.assertEquals(token.value, "Hello\nworld!")
end

function TestParse:testEscapedString()
    self:resetAndParse([[
(Hello \
world!)
]])

    local token = self.lex.tokens[1]
    LU.assertEquals(token.type, Token.types["string"])
    LU.assertEquals(token.value, "Hello world!")
end

os.exit(LU.LuaUnit.run())
