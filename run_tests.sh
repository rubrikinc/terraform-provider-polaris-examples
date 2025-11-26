#!/bin/sh

set -e

show_help() {
      echo "usage: $(basename "$0") [-h|--help] [-n|--dry-run]"
      echo
      echo "This script requires a recent version of Terraform CLI and the following environment variables:"
      echo " * TF_VAR_aws_account_id   - Account ID of the AWS account used for testing"
      echo " * TF_VAR_aws_account_name - Account name of the AWS account used for testing"
      echo " * TF_VAR_gcp_project_id   - Project ID of GCP project used for testing"
      echo
      echo "In addition, Terraform requires access to each of the test accounts, including RSC."
      echo
}

# Parse command line arguments.
DRY_RUN=false
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
    *)
      echo error: unknown option: $1
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
if [ -z "$TF_VAR_aws_account_name" ]; then
  echo "error: the environment variable TF_VAR_aws_account_name must be set to the name of the AWS account used for testing"
  exit 1
fi
if [ -z "$TF_VAR_gcp_project_id" ]; then
  echo "error: the environment variable TF_VAR_gcp_project_id must be set to the ID of the GCP project used for testing"
  exit 1
fi

# Set terraform flags.
flags=""
if [ -n "$JENKINS_HOME" ]; then
  flags="-no-color"
fi

run_tests() {
  find modules -mindepth 1 -maxdepth 1 -type d -not -path '*/\.*' |  while read -r dir; do
    if [ -d "$dir/tests" ]; then
      if [ "$DRY_RUN" = true ]; then
        echo "Would run tests in $dir"
      else
        echo
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
