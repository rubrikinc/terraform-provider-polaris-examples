#!/bin/sh

set -e

# Required tools
if ! command -v terraform >/dev/null 2>&1; then
  echo "error: the terraform command must be installed"
  exit 1
fi

# Required environment variables
if [ -z "$TF_VAR_account_id" ]; then
  echo "error: the environment variable TF_VAR_account_id must be set to the ID of the AWS account to use for testing"
  exit 1
fi
if [ -z "$TF_VAR_account_name" ]; then
  echo "error: the environment variable TF_VAR_account_name must be set to the name of the AWS account to use for testing"
  exit 1
fi

function run_tests() {
  find . -mindepth 1 -maxdepth 1 -type d -not -path '*/\.*' |  while read -r dir; do
    if [ -d "$dir/tests" ]; then
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
