#!/usr/bin/env bash
# Runs the installer as a dry run in a scratch home, on the host and without Docker, and checks that every step reports and that
# nothing lands in the home. Nothing is installed, so it is safe on a machine that is already set up.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STEPS="private packages dotfiles shell mise ai-clis nvim os-defaults host"

fail() {
  echo "dry-run: $*" >&2
  exit 1
}

# the machine this runs on would change which overlay the steps find, and the checks below set what they need
unset DOTFILES_HOST DOTFILES_PRIVATE

# a scratch home laid out like a machine that cloned the checkout to ~/.dotfiles
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
ln -s "$ROOT_DIR" "$scratch/.dotfiles"

# a private overlay for the host "example", which also has an overlay in the checkout, so the checks below can tell which one is picked
private="$scratch/.machines/example/dotfiles"
mkdir -p "$private/git"
cat > "$private/install.sh" <<'HOOK'
#!/usr/bin/env bash
if [ "${DOTFILES_DRY_RUN:-0}" = 1 ]; then
  echo "private hook: dry run"
fi
HOOK
chmod +x "$private/install.sh"
printf '%s\n' '[credential]' '  helper = store' > "$private/git/config"
# with a package list of each kind, which the packages step installs after the shared list
mkdir -p "$private/packages"
printf '%s\n' '# host packages' 'host-pacman-pkg  # with a comment' > "$private/packages/pacman.txt"
printf '%s\n' 'host-apt-pkg' > "$private/packages/apt.txt"
# and one directory that looks like a checkout of the private repo
mkdir -p "$scratch/checkout/.git"

# the XDG variables and DOTFILES would point the steps at the real home, so they are dropped
installer() {
  env -u XDG_CONFIG_HOME -u XDG_DATA_HOME -u XDG_STATE_HOME -u XDG_CACHE_HOME -u DOTFILES \
    HOME="$scratch" "$ROOT_DIR/scripts/install.sh" "$@"
}

before="$(find "$scratch" -mindepth 1 | sort)"

help="$(installer --help)"
for step in $STEPS; do
  grep -q "^  $step " <<<"$help" || fail "--help does not list the $step step"
done

output="$(installer --dry-run 2>&1)" || { echo "$output"; fail "install.sh --dry-run failed"; }
echo "$output"
for step in $STEPS; do
  grep -qxF "== $step ==" <<<"$output" || fail "no '== $step ==' header in the dry run"
done

only="$(installer --only dotfiles --dry-run 2>&1)" || { echo "$only"; fail "install.sh --only dotfiles --dry-run failed"; }
if [ "$(grep -c '^== ' <<<"$only")" != 1 ] || ! grep -qxF "== dotfiles ==" <<<"$only"; then
  fail "--only dotfiles did not run just the dotfiles step"
fi

# the private step clones the repo named by DOTFILES_PRIVATE_REPO, pulls a checkout, leaves a directory somebody filled by hand alone, and is off without a repo
repo="git@example.invalid:me/overlays.git"
out="$(DOTFILES_PRIVATE="$scratch/none" installer --only private --dry-run 2>&1)" || { echo "$out"; fail "install.sh --only private --dry-run failed"; }
grep -q '^private overlays are off' <<<"$out" || { echo "$out"; fail "the private step did not say it is off without DOTFILES_PRIVATE_REPO"; }
out="$(DOTFILES_PRIVATE="$scratch/none" DOTFILES_PRIVATE_REPO="$repo" installer --only private --dry-run 2>&1)" || { echo "$out"; fail "the private step failed with DOTFILES_PRIVATE_REPO set"; }
grep -qxF "would run: git clone --depth 1 $repo $scratch/none" <<<"$out" || { echo "$out"; fail "the private step would not clone DOTFILES_PRIVATE_REPO"; }
out="$(DOTFILES_PRIVATE="$scratch/checkout" DOTFILES_PRIVATE_REPO="$repo" installer --only private --dry-run 2>&1)" || { echo "$out"; fail "the private step failed on a checkout"; }
grep -q 'would run git pull --ff-only' <<<"$out" || { echo "$out"; fail "the private step would not pull an existing checkout"; }
out="$(DOTFILES_PRIVATE_REPO="$repo" installer --only private --dry-run 2>&1)" || { echo "$out"; fail "the private step failed on a directory that is not a checkout"; }
grep -q 'not a git checkout, using it as it is' <<<"$out" || { echo "$out"; fail "the private step did not leave a directory that is not a checkout alone"; }

# the private overlay wins over the one in the checkout, and its hook has to see the dry run
host="$(DOTFILES_HOST=example installer --only host --dry-run 2>&1)" || { echo "$host"; fail "install.sh --only host --dry-run failed"; }
grep -qxF "running $private/install.sh" <<<"$host" || { echo "$host"; fail "the host step did not run the private overlay's hook"; }
grep -qxF "private hook: dry run" <<<"$host" || { echo "$host"; fail "the private overlay's hook did not see the dry run"; }

# without a private overlay it falls back to the one in the checkout
host="$(DOTFILES_HOST=example DOTFILES_PRIVATE="$scratch/none" installer --only host --dry-run 2>&1)" || { echo "$host"; fail "the host step failed on the overlay in the checkout"; }
grep -qxF "running overlays/host/example/install.sh" <<<"$host" || { echo "$host"; fail "the host step did not fall back to overlays/host/example"; }

# and a host with no overlay at all is only reported
host="$(DOTFILES_HOST=nowhere installer --only host --dry-run 2>&1)" || { echo "$host"; fail "the host step failed for a host with no overlay"; }
grep -q '^no install.sh in the host overlay of nowhere' <<<"$host" || { echo "$host"; fail "the host step did not report a host with no overlay"; }

# the host package lists come after the shared ones, on the Arch and Debian paths alike (DOTFILES_OS_ID picks the path on any runner)
pkgs="$(DOTFILES_OS_ID=arch DOTFILES_HOST=example installer --only packages --dry-run 2>&1)" || { echo "$pkgs"; fail "the packages step failed on the Arch path"; }
grep -q '^~/.machines/example/dotfiles/packages/pacman.txt: 1 entry$' <<<"$pkgs" || { echo "$pkgs"; fail "the packages step did not read the host pacman list"; }
grep -q 'pacman -S --needed --noconfirm host-pacman-pkg$' <<<"$pkgs" || { echo "$pkgs"; fail "the packages step would not install the host pacman list"; }
pkgs="$(DOTFILES_OS_ID=debian DOTFILES_HOST=example installer --only packages --dry-run 2>&1)" || { echo "$pkgs"; fail "the packages step failed on the Debian path"; }
grep -q '^~/.machines/example/dotfiles/packages/apt.txt: 1 entry$' <<<"$pkgs" || { echo "$pkgs"; fail "the packages step did not read the host apt list"; }
grep -q 'apt-get install -y --no-install-recommends host-apt-pkg$' <<<"$pkgs" || { echo "$pkgs"; fail "the packages step would not install the host apt list"; }

# a host with no list is only reported, and the example overlay in the checkout has lists with no entries
pkgs="$(DOTFILES_OS_ID=arch DOTFILES_HOST=nowhere installer --only packages --dry-run 2>&1)" || { echo "$pkgs"; fail "the packages step failed for a host with no overlay"; }
grep -q "^No host pacman list for 'nowhere'" <<<"$pkgs" || { echo "$pkgs"; fail "the packages step did not report a host with no pacman list"; }
pkgs="$(DOTFILES_OS_ID=debian DOTFILES_HOST=example DOTFILES_PRIVATE="$scratch/none" installer --only packages --dry-run 2>&1)" || { echo "$pkgs"; fail "the packages step failed on the overlay in the checkout"; }
grep -qxF "Host apt list for 'example' has no entries." <<<"$pkgs" || { echo "$pkgs"; fail "the packages step did not skip the empty apt list of overlays/host/example"; }

# the git config of the private overlay is what config/git/host would link to
links="$(DOTFILES_HOST=example installer --only dotfiles --dry-run 2>&1)" || { echo "$links"; fail "install.sh --only dotfiles --dry-run failed"; }
grep -q "config/git/host -> .*/.machines/example/dotfiles/git/config" <<<"$links" || { echo "$links"; fail "the dotfiles step would not link the private overlay's git config"; }

after="$(find "$scratch" -mindepth 1 | sort)"
[ "$before" = "$after" ] || fail "the dry run changed the home directory"

echo "dry-run ok"
