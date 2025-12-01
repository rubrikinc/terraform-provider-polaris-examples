#!/bin/sh

set -e

show_help() {
      echo "usage: $(basename "$0") [-h|--help] [-n|--dry-run] [-v|--verbose]"
      echo
      echo "This script requires a recent version of Terraform CLI and the following environment variables:"
      echo " * TF_VAR_aws_account_id   - Account ID of the AWS account used for testing"
      echo " * TF_VAR_gcp_project_id   - Project ID of the GCP project used for testing"
      echo
      echo "In addition, Terraform requires access to each of the test accounts, including RSC."
      echo
}

# Parse command line arguments.
DRY_RUN=false
VERBOSE=false
while [ $# -gt 0 ]; do
  case "$1" in
    -n|--dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      show_help
      exit 1
      ;;
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    *)
      echo "error: unknown option: $1"
      echo
      show_help
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
if [ -z "$TF_VAR_aws_account_id" ]; then
  echo "error: the environment variable TF_VAR_aws_account_id must be set to the ID of the AWS account used for testing"
  exit 1
fi
if [ -z "$TF_VAR_gcp_project_id" ]; then
  echo "error: the environment variable TF_VAR_gcp_project_id must be set to the ID of the GCP project used for testing"
  exit 1
fi

# Set Jenkins-specific Terraform flags.
flags=""
if [ -n "${JENKINS_HOME:-}" ]; then
  flags="-no-color"
fi

run_tests() {
  verbose=""
  if [ "$VERBOSE" = true ]; then
    verbose="-verbose"
    terraform version
  fi

  for dir in $(find modules -mindepth 1 -maxdepth 1 -type d -not -path '*/\.*'); do
    if [ -d "$dir/tests" ]; then
      if [ "$DRY_RUN" = true ]; then
        echo "Would run tests in $dir"
      else
        echo
        echo "Running tests in $dir:"
        if [ "$VERBOSE" = true ]; then
          if ! terraform -chdir="$dir" init -input=false -upgrade $flags; then
            exit_code=1
          fi
        else
          if ! terraform -chdir="$dir" init -input=false -upgrade $flags >/dev/null; then
            exit_code=1
          fi
        fi
        if ! terraform -chdir="$dir" test $flags $verbose; then
          exit_code=1
        fi
      fi
    fi
  done
  echo
}

# Change directory and run tests.
dir=$(dirname "$0")
(
  cd "$dir"
  exit_code=0
  run_tests
  if [ "$exit_code" -ne 0 ]; then
    exit "$exit_code"
  fi
)
