local Exec = require "modules.exec"

Exec.run_source([=[
/x 10 def
/f { x } def
/g {
    1 dict begin
        /x 20 def
        f
    end
} def
g =
]=], { static_scope = true })
