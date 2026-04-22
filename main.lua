local Lex = require "lex"
local Stack = require "stack"

local myLex = Lex.new([=[
dict begin
    /x 10 def
    /y 20 def
end
]=])

myLex:read()
print(myLex:display_tokens())
