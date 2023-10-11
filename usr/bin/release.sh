#!/bin/bash

set -e

e() {
    GREEN='\033[0;32m'
    NC='\033[0m'
    echo -e "${GREEN}$1${NC}"
    eval "$1"
}

e "bundle"
e "bundle exec rspec"

if [[ $(git diff --shortstat 2> /dev/null | tail -n1) != "" ]]; then
  echo -e "\033[1;31mgit working directory not clean, please commit your changes first \033[0m"
  exit 1
fi

GEM_NAME="action_reporter"
VERSION=$(grep -Eo "VERSION\s*=\s*'.+'" lib/action_reporter.rb  | grep -Eo "[0-9.]{5,}")
GEM_FILE="$GEM_NAME-$VERSION.gem"

e "gem build $GEM_NAME.gemspec"
e "gem push $GEM_FILE"

e "git tag $VERSION && git push --tags"
