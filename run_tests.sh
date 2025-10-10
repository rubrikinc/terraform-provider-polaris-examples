#!/bin/sh

set -e

if ! command -v terraform >/dev/null 2>&1; then
    echo "error: terraform command must be installed"
    exit 1
fi

function run_tests() {
    for dir in */; do
      dir="${dir%/}"
      if [ -d "$dir" ] && [ -d "$dir/tests" ]; then
        echo "Running tests in $dir:"
        terraform -chdir="$dir" init -input=false -upgrade >/dev/null
        terraform -chdir="$dir" test
        echo
      fi
    done
}

dir=$(dirname "$0")
(
    cd "$dir"
    run_tests
)
