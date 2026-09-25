#!/usr/bin/env bash
# Adds the third-party apt repositories packages/apt.txt depends on, on Debian, Raspberry Pi OS and Ubuntu:
#   docker     docker-ce and friends  https://docs.docker.com/engine/install/debian/
#   tailscale  tailscale              https://pkgs.tailscale.com/stable/
#   eza        eza                    https://github.com/eza-community/eza/blob/main/INSTALL.md
#   azlux      docker-ctop            https://packages.azlux.fr/
# Runs as root (it re-executes itself through sudo), never prompts, and leaves a repository alone
# when its sources file already exists. Keys go into keyrings referenced by Signed-By, never apt-key.
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  exec sudo -E bash "$0" "$@"
fi

export DEBIAN_FRONTEND=noninteractive

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/utils/ui.sh"

# shellcheck disable=SC1091
. /etc/os-release

case "${ID:-}" in
  ubuntu)
    family=ubuntu
    codename="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
    azlux_suite=stable
    ;;
  debian|raspbian)
    # Raspberry Pi OS reports debian (64-bit and current 32-bit) or raspbian (older 32-bit); both use the Debian repositories
    family=debian
    codename="${VERSION_CODENAME:-}"
    azlux_suite="$codename"
    ;;
  *)
    echo "install-apt-repos.sh: unsupported distribution '${ID:-unknown}'" >&2
    exit 1
    ;;
esac

if [ -z "$codename" ]; then
  echo "install-apt-repos.sh: no release codename in /etc/os-release" >&2
  exit 1
fi

SOURCES_DIR=/etc/apt/sources.list.d
ETC_KEYRINGS=/etc/apt/keyrings
SHARE_KEYRINGS=/usr/share/keyrings

# curl and the CA bundle are needed to fetch the keys, and a bare container has neither
if ! dpkg -s ca-certificates curl >/dev/null 2>&1; then
  apt-get update
  apt-get install -y --no-install-recommends ca-certificates curl
fi
install -m 0755 -d "$ETC_KEYRINGS" "$SHARE_KEYRINGS"

# add_repo <name> <key url> <key path> <uri> <suite> <components> [architectures]
add_repo() {
  local name="$1" key_url="$2" key_path="$3" uri="$4" suite="$5" components="$6" archs="${7:-}"
  local tmp

  # a sources file written by hand or by the vendor's own script counts too, two entries for one repo make apt fail
  if [ -e "$SOURCES_DIR/$name.sources" ] || [ -e "$SOURCES_DIR/$name.list" ]; then
    echo "apt repository $name: already configured"
    return 0
  fi

  echo "apt repository $name: adding"
  tmp="$(mktemp)"
  curl -fsSL --retry 3 "$key_url" -o "$tmp" || { rm -f "$tmp"; return 1; }
  install -m 0644 "$tmp" "$key_path"
  rm -f "$tmp"

  {
    echo "Types: deb"
    echo "URIs: $uri"
    echo "Suites: $suite"
    echo "Components: $components"
    if [ -n "$archs" ]; then
      echo "Architectures: $archs"
    fi
    echo "Signed-By: $key_path"
  } > "$SOURCES_DIR/$name.sources"
  chmod 0644 "$SOURCES_DIR/$name.sources"
}

# a repository that cannot be added only costs its own packages, install_apt skips them with a warning
try_repo() {
  add_repo "$@" || report_warning "could not add the apt repository $1, its packages will be skipped"
}

# https://docs.docker.com/engine/install/debian/ (and .../ubuntu/)
try_repo docker \
  "https://download.docker.com/linux/$family/gpg" "$ETC_KEYRINGS/docker.asc" \
  "https://download.docker.com/linux/$family" "$codename" stable "$(dpkg --print-architecture)"

# https://pkgs.tailscale.com/stable/, the sources file is the deb822 form of <codename>.tailscale-keyring.list
try_repo tailscale \
  "https://pkgs.tailscale.com/stable/$family/$codename.noarmor.gpg" "$SHARE_KEYRINGS/tailscale-archive-keyring.gpg" \
  "https://pkgs.tailscale.com/stable/$family" "$codename" main

# https://github.com/eza-community/eza/blob/main/INSTALL.md, apt reads the armored key as it is, no gpg needed
try_repo gierens \
  "https://raw.githubusercontent.com/eza-community/eza/main/deb.asc" "$ETC_KEYRINGS/gierens.asc" \
  "http://deb.gierens.de" stable main

# https://packages.azlux.fr/ ("stable" is a documented alias, Ubuntu has no codename there)
try_repo azlux \
  "https://azlux.fr/repo.gpg" "$SHARE_KEYRINGS/azlux-archive-keyring.gpg" \
  "http://packages.azlux.fr/debian/" "$azlux_suite" main
