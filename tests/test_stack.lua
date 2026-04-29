local LU        = require "luaunit"
local Exec      = require "modules.exec"
local Token     = require "modules.token"
local Keywords  = require "modules.keywords"

TestStack = {}

function TestStack:compareOpStack(op_stack, expected)
    local result

    if #op_stack.data ~= #expected then
        result = false
    end

    for i = 1, #expected do
        if op_stack.data[i] ~= expected[i] then
            result = false
        end
    end

    if result == nil then
        result = true
    end

    LU.assertIsTrue(result)
end

function TestStack:execStackOp(op, contents, expected)
    table.insert(contents, Token.new(Token.types["keyword"], op))
    local e = Exec.new(contents)
    e:run()
    self:compareOpStack(e.operand_stack, expected)
end

function TestStack:testPop()
    self:execStackOp(
        Keywords["pop"],
        {
            Token.new(Token.types["number"], 1),
        },
        {}
    )
end

function TestStack:testExch()
    self:execStackOp(
        Keywords["exch"],
        {
            Token.new(Token.types["number"], 2),
            Token.new(Token.types["number"], 1),
        },
        {
            Token.new(Token.types["number"], 1),
            Token.new(Token.types["number"], 2),
        }
    )
end

function TestStack:testDup()
    self:execStackOp(
        Keywords["dup"],
        {
            Token.new(Token.types["number"], 1),
        },
        {
            Token.new(Token.types["number"], 1),
            Token.new(Token.types["number"], 1),
        }
    )
end

function TestStack:testClear()
    self:execStackOp(
        Keywords["clear"],
        {
            Token.new(Token.types["number"], 1),
            Token.new(Token.types["number"], 2),
            Token.new(Token.types["number"], 3),
        },
        {}
    )
end

function TestStack:testCount()
    self:execStackOp(
        Keywords["count"],
        {
            Token.new(Token.types["number"], 1),
            Token.new(Token.types["number"], 2),
            Token.new(Token.types["number"], 3),
        },
        {
            Token.new(Token.types["number"], 1),
            Token.new(Token.types["number"], 2),
            Token.new(Token.types["number"], 3),
            Token.new(Token.types["number"], 3)
        }
    )
end

function TestStack:testCopy()
    self:execStackOp(
        Keywords["copy"],
        {
            Token.new(Token.types["string"], "Hello "),
            Token.new(Token.types["string"], "world!"),
            Token.new(Token.types["number"], 2),
        },
        {
            Token.new(Token.types["string"], "Hello "),
            Token.new(Token.types["string"], "world!"),
            Token.new(Token.types["string"], "Hello "),
            Token.new(Token.types["string"], "world!"),
        }
    )
end

os.exit(LU.LuaUnit.run())
