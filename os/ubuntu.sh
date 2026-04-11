#!/usr/bin/env bash
set -euo pipefail

echo "Configuring Ubuntu defaults..."

# Locale
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8

# Timezone
sudo timedatectl set-timezone America/Sao_Paulo 2>/dev/null || \
  sudo ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

# Set zsh as default shell
if [ "$(basename "$SHELL")" != "zsh" ]; then
  chsh -s "$(which zsh)"
fi

# Docker group
if getent group docker >/dev/null 2>&1; then
  sudo usermod -aG docker "$USER"
fi

# Enable systemd services (idempotent)
for svc in docker tailscaled; do
  if systemctl list-unit-files "$svc.service" >/dev/null 2>&1; then
    sudo systemctl enable --now "$svc.service" 2>/dev/null || true
  fi
done

echo "Ubuntu defaults configured."
