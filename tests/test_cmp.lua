local LU        = require "luaunit"
local Exec      = require "modules.exec"
local Token     = require "modules.token"
local Keywords  = require "modules.keywords"

TestCmp = {}

function TestCmp:execBinary(lhs, rhs, op, expected)
    local e = Exec.new {
        Token.new(Token.types["number"], lhs),
        Token.new(Token.types["number"], rhs),
        Token.new(Token.types["keyword"], op),
    }
    e:run()
    LU.assertEquals(e.operand_stack:peek().value, expected)
end

function TestCmp:execBoolean(lhs, rhs, op, expected)
    local e = Exec.new {
        Token.new(Token.types["keyword"], lhs and Keywords["true"] or Keywords["false"]),
        Token.new(Token.types["keyword"], rhs and Keywords["true"] or Keywords["false"]),
        Token.new(Token.types["keyword"], op)
    }
    e:run()
    LU.assertEquals(e.operand_stack:peek(), expected)
end

function TestCmp:runComparison(op, ...)
    local cases = {...}
    for _, case in ipairs(cases) do
        self:execBinary(case.lhs, case.rhs, op, case.expected)
    end
end

function TestCmp:runBoolean(op, ...)
    local cases = {...}
    for _, case in ipairs(cases) do
        self:execBoolean(case.lhs, case.rhs, op, case.expected)
    end
end

function TestCmp:testEq()
    self:runComparison(
        Keywords["eq"],
        {lhs = 1, rhs = 1, expected = "true"},
        {lhs = 1, rhs = 2, expected = "false"}
    )
end

function TestCmp:testNe()
    self:runComparison(
        Keywords["ne"],
        {lhs = 1, rhs = 1, expected = "false"},
        {lhs = 1, rhs = 2, expected = "true"}
    )
end

function TestCmp:testGt()
    self:runComparison(
        Keywords["gt"],
        {lhs = 1, rhs = 0, expected = "true"},
        {lhs = 0, rhs = 1, expected = "false"},
        {lhs = 1, rhs = 1, expected = "false"}
    )
end

function TestCmp:testGe()
    self:runComparison(
        Keywords["gt"],
        {lhs = 1, rhs = 0, expected = "true"},
        {lhs = 0, rhs = 1, expected = "false"},
        {lhs = 1, rhs = 1, expected = "true"}
    )
end

function TestCmp:testLt()
    self:runComparison(
        Keywords["lt"],
        {lhs = 1, rhs = 0, expected = "false"},
        {lhs = 0, rhs = 1, expected = "true"},
        {lhs = 1, rhs = 1, expected = "false"}
    )
end

function TestCmp:testLe()
    self:runComparison(
        Keywords["le"],
        {lhs = 1, rhs = 0, expected = "false"},
        {lhs = 0, rhs = 1, expected = "true"},
        {lhs = 1, rhs = 1, expected = "true"}
    )
end

function TestCmp:testAnd()
    self:runBoolean(
        Keywords["and"],
        {lhs = true , rhs = true , expected = "true" },
        {lhs = true , rhs = false, expected = "false"},
        {lhs = false, rhs = true , expected = "false"},
        {lhs = false, rhs = false, expected = "false"}
    )
end

function TestCmp:testOr()
    self:runBoolean(
        Keywords["or"],
        {lhs = true , rhs = true , expected = "true"},
        {lhs = true , rhs = false, expected = "true"},
        {lhs = false, rhs = true , expected = "true"},
        {lhs = false, rhs = false, expected = "false"}
    )
end

function TestCmp:testNot()
    local e1 = Exec.new {
        Token.new(Token.types["keyword"], Keywords["true"]),
        Token.new(Token.types["keyword"], Keywords["not"]),
    }
    e1:run()
    LU.assertEquals(e1.operand_stack:peek().value, "false")

    local e2 = Exec.new {
        Token.new(Token.types["keyword"], Keywords["false"]),
        Token.new(Token.types["keyword"], Keywords["not"]),
    }
    e2:run()
    LU.assertEquals(e2.operand_stack:peek().value, "true")
end

os.exit(LU.LuaUnit.run())
