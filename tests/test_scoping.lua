local LU        = require "luaunit"
local Exec      = require "modules.exec"

TestScoping = {}

function TestScoping:setUp()
    self.source = [=[
/x 10 def
/f { x } def
/g {
    1 dict begin
        /x 20 def
        f
    end
} def
g
]=]
end

function TestScoping:testStatic()
    local e = Exec.fromSource(self.source, { static_scope = true })
    e:run()
    LU.assertEquals(e.operand_stack:peek().value, 10)
end

function TestScoping:testDynamic()
    local e = Exec.fromSource(self.source, { static_scope = false })
    e:run()
    LU.assertEquals(e.operand_stack:peek().value, 20)
end

os.exit(LU.LuaUnit.run())
