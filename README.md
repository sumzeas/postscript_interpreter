# Lua Postscript Interpreter
Author: Jesse Perez
ID: 11882973
Date: 04/21/2026

## Dependencies
```
lua -v
Lua 5.4.6  Copyright (C) 1994-2023 Lua.org, PUC-Rio

luarocks --version
/usr/local/bin/luarocks 3.13.0

luarocks show luaunit
LuaUnit 3.5-1 - A unit testing framework for Lua
```

## Running Tests
After ensuring all dependencies are installed, run a test as follows:
```
./tests/run.sh
Testing parser...
...
Ran 3 tests in 0.000 seconds, 3 successes, 0 failures
OK
Testing arithmetic operations...
............
Ran 12 tests in 0.001 seconds, 12 successes, 0 failures
OK
Testing comparison operations...
.........
Ran 9 tests in 0.001 seconds, 9 successes, 0 failures
OK
Testing stack operations...
......
Ran 6 tests in 0.001 seconds, 6 successes, 0 failures
OK
```
