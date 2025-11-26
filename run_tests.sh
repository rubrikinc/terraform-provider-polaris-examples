#!/bin/sh

set -e

# Parse command line arguments.
DRY_RUN=false
while [ $# -gt 0 ]; do
  case "$1" in
    -n|--dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      echo "error: unknown option: $1"
      echo
      echo "usage: $0 [-n | --dry-run]"
      echo
      echo "Note, access for Terraform to tests accounts for RSC, AWS and GCP must already be setup."
      exit 1
      ;;
  esac
done

# Required tools.
if ! command -v terraform >/dev/null 2>&1; then
  echo "error: the terraform command must be installed"
  exit 1
fi

# Required environment variables.
if [ -z "$TF_VAR_account_id" ]; then
  echo "error: the environment variable TF_VAR_account_id must be set to the ID of the AWS account used for testing"
  exit 1
fi
if [ -z "$TF_VAR_account_name" ]; then
  echo "error: the environment variable TF_VAR_account_name must be set to the name of the AWS account used for testing"
  exit 1
fi
if [ -z "$TF_VAR_project_id" ]; then
  echo "error: the environment variable TF_VAR_project_id must be set to the ID of the GCP project used for testing"
  exit 1
fi

function run_tests {
  local flags=""
  if [ -n "$JENKINS_HOME" ]; then
    flags="-no-color"
  fi

  find modules -mindepth 1 -maxdepth 1 -type d -not -path '*/\.*' |  while read -r dir; do
    if [ -d "$dir/tests" ]; then
      if [ "$DRY_RUN" = true ]; then
        echo "Would run tests in $dir"
      else
        echo "Running tests in $dir:"
        terraform -chdir="$dir" init -input=false -upgrade $flags >/dev/null
        terraform -chdir="$dir" test $flags
      fi
    fi
  done
}

dir=$(dirname "$0")
(
  cd "$dir"
  run_tests
)
