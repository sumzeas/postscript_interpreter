local Exec = require "modules.exec"

Exec.run_source([=[
5 dict begin
    /x 10 def
    /y 20 def
    x y add =
    x y mul =
    x y gt
        { (x is greater) = }
        { (y is greater or equal) = }
        ifelse
end
]=])
