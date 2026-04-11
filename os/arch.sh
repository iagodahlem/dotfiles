#!/usr/bin/env bash
set -euo pipefail

echo "Configuring Arch Linux defaults..."

# Locale
if ! locale -a 2>/dev/null | grep -q "en_US.utf8"; then
  sudo sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
  sudo locale-gen
fi
if [ ! -f /etc/locale.conf ] || ! grep -q "LANG=en_US.UTF-8" /etc/locale.conf 2>/dev/null; then
  echo "LANG=en_US.UTF-8" | sudo tee /etc/locale.conf >/dev/null
fi

# Timezone
sudo ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
sudo hwclock --systohc

# Set zsh as default shell
if [ "$(basename "$SHELL")" != "zsh" ] && command -v zsh >/dev/null 2>&1; then
  chsh -s "$(which zsh)" || true
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

# UFW defaults
if command -v ufw >/dev/null 2>&1; then
  sudo ufw default deny incoming 2>/dev/null || true
  sudo ufw default allow outgoing 2>/dev/null || true
  sudo ufw --force enable 2>/dev/null || true
fi

# Liquidctl — NZXT Kraken / AIO cooler
if command -v liquidctl >/dev/null 2>&1; then
  sudo systemctl enable --now liquidctrld.service 2>/dev/null || true
fi

echo "Arch defaults configured."
