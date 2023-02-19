#!/bin/sh
nvim --version
nvim --headless \
  -u test/init.lua \
  -c "PlenaryBustedDirectory test/ { minimal_init = 'test/init.lua', sequential = true }"
