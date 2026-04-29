echo "Testing parser..."
lua tests/test_parsing.lua
echo "Testing arithmetic operations..."
lua tests/test_arithmetic.lua 
echo "Testing comparison operations..."
lua tests/test_cmp.lua
echo "Testing stack operations..."
lua tests/test_stack.lua
echo "Testing dynamic/static scoping..."
lua tests/test_scoping.lua
