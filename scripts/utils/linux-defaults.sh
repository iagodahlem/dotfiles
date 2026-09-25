#!/usr/bin/env bash

# The Linux defaults shared by os/arch.sh and os/ubuntu.sh. Source scripts/utils/dry-run.sh first, they go through its run().

# Switches the login shell to zsh once zsh is installed. A failure is a warning, chsh asks for a password and can be refused.
use_zsh_login_shell() {
  local zsh_path

  zsh_path="$(command -v zsh || true)"
  if [ -z "$zsh_path" ]; then
    echo "login shell: zsh is not installed, leaving it as it is"
  elif [ "$(basename "${SHELL:-}")" = "zsh" ]; then
    echo "login shell: already zsh"
  else
    run chsh -s "$zsh_path" || echo "warning: could not switch the login shell, run: chsh -s $zsh_path" >&2
  fi
}

# Adds the user to the docker group once docker has created it. A failure is a warning.
join_docker_group() {
  local user="${USER:-$(id -un)}"

  if ! getent group docker >/dev/null 2>&1; then
    echo "docker group: not present, skipping"
    return 0
  fi

  case " $(id -nG "$user") " in
    *" docker "*)
      echo "docker group: $user is already a member"
      ;;
    *)
      run sudo usermod -aG docker "$user" || echo "warning: could not add $user to the docker group, run: sudo usermod -aG docker $user" >&2
      ;;
  esac
}
