#!/bin/bash -i

set -e

source dev-container-features-test-lib

check "venom version" venom version

reportResults
