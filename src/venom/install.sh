#!/usr/bin/env bash

set -e

VENOM_VERSION="${VERSION:-"1.2.0"}"
OS="linux"
architecture="$(uname -m)"
case ${architecture} in
x86_64) architecture="amd64" ;;
aarch64 | armv8*) architecture="arm64" ;;
aarch32 | armv7* | armvhf*) architecture="arm" ;;
i?86) architecture="386" ;;
*)
	echo "(!) Architecture ${architecture} unsupported"
	exit 1
	;;
esac

# Clean up
rm -rf /var/lib/apt/lists/*


if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Ensure that login shells get the correct path if the user updated the PATH using ENV.
rm -f /etc/profile.d/00-restore-env.sh
echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh

apt_get_update() {
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

# ensure that the required packages are installed
check_packages curl gpg ca-certificates

. /etc/os-release

curl -sSfL "https://github.com/ovh/venom/releases/download/v${VENOM_VERSION}/venom.${OS}-${architecture}" > venom
chmod +x ./venom
install ./venom /usr/local/bin/venom

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
