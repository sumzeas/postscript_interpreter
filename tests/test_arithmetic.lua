local LU        = require "luaunit"
local Exec      = require "modules.exec"
local Token     = require "modules.token"
local Keywords  = require "modules.keywords"

TestArithmetic = {}

function TestArithmetic:execBinary(lhs, rhs, op, expected)
    local e = Exec.new {
        Token.new(Token.types["number"], lhs),
        Token.new(Token.types["number"], rhs),
        Token.new(Token.types["keyword"], op),
    }
    e:run()
    LU.assertEquals(e.operand_stack:peek().value, expected)
end

function TestArithmetic:execUnary(v, op, expected)
    local e = Exec.new {
        Token.new(Token.types["number"], v),
        Token.new(Token.types["keyword"], op)
    }
    e:run()
    LU.assertEquals(e.operand_stack:peek().value, expected)
end

function TestArithmetic:testAdd()
    self:execBinary(1, 2, Keywords["add"], 3)
end

function TestArithmetic:testSub()
    self:execBinary(1, 2, Keywords["sub"], -1)
end

function TestArithmetic:testMul()
    self:execBinary(2, 3, Keywords["mul"], 6)
end

function TestArithmetic:testDiv()
    self:execBinary(1, 4, Keywords["div"], 0.25)
end

function TestArithmetic:testiDiv()
    self:execBinary(1, 4, Keywords["idiv"], 0)
end

function TestArithmetic:testMod()
    self:execBinary(8, 5, Keywords["mod"], 3)
end

function TestArithmetic:testAbs()
    self:execUnary(-1, Keywords["abs"], 1)
end

function TestArithmetic:testNeg()
    self:execUnary(1, Keywords["neg"], -1)
end

function TestArithmetic:testCeiling()
    self:execUnary(0.5, Keywords["ceiling"], 1)
end

function TestArithmetic:testFloor()
    self:execUnary(0.5, Keywords["floor"], 0)
end

function TestArithmetic:testRound()
    self:execUnary(0.5, Keywords["round"], 1)
end

function TestArithmetic:testSqrt()
    self:execUnary(9, Keywords["sqrt"], 3)
end

os.exit(LU.LuaUnit.run())
