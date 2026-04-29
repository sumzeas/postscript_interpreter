echo "Testing parser..."
lua tests/test_parsing.lua
echo "Testing arithmetic commands..."
lua tests/test_arithmetic.lua 
echo "Testing comparison commands..."
lua tests/test_cmp.lua
echo "Testing stack commands..."
lua tests/test_stack.lua
