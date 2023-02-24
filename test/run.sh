#!/bin/bash
# https://stackoverflow.com/a/29754866/2515275
#
SHELL=/bin/bash

#!/bin/bash
# More safety, by turning some bugs into errors.
# Without `errexit` you don’t need ! and can replace
# ${PIPESTATUS[0]} with a simple $?, but I prefer safety.
set -o errexit -o pipefail -o noclobber -o nounset

# -allow a command to fail with !’s side effect on errexit
# -use return value from ${PIPESTATUS[0]}, because ! hosed $?
! getopt --test > /dev/null 
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo 'I’m sorry, `getopt --test` failed in this environment.'
    exit 1
fi

# option --output/-o requires 1 argument
LONGOPTS=debug,force,output:,verbose
OPTIONS=dw

# -regarding ! and PIPESTATUS see above
# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out “--options”)
# -pass arguments only via   -- "$@"   to separate them correctly
! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

d=n w=n

# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -d|--debug)
            d=y
            shift
            ;;
        -w|--watch)
            w=y
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming error"
            exit 3
            ;;
    esac
done


# handle non-option arguments
if [[ $# -ne 1 ]]; then
  c="lua require'plenary.test_harness'.test_directory('test/', {minimal_init='test/init.lua',sequential=true})"
  echo "running all tests"
else
  c="lua require'plenary.busted'.run(vim.fn.expand('"$1"'), {minimal_init='test/init.lua',sequential=true})"
  echo "running $1"
fi

if [[ $w == y ]]; then
  find . -type f -name '*.lua' ! -path "./.test/**/*" | entr -d nvim --headless -u test/init.lua -c "$c"
else
  nvim --headless -u test/init.lua -c "$c"
fi
