#!/bin/bash -i

set -e

source dev-container-features-test-lib

check "venom version" venom version
check "check specific version" bash -c "venom version | grep 'Version venom: v1.1.0'"

reportResults
