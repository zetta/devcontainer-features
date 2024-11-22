#!/bin/bash -i

set -e

source dev-container-features-test-lib

check "scalr --version" scalr --version
check "check specific version" bash -c "scalr --version | grep '0.14.5'"

reportResults
