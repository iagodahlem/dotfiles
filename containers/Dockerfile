FROM ubuntu:24.04

ARG USER=dev
ARG UID=1000
ARG GID=1000
ARG DOTFILES_CONTAINER_MINIMAL=0

ENV DEBIAN_FRONTEND=noninteractive

COPY . /opt/dotfiles
RUN /opt/dotfiles/scripts/install-packages.sh

RUN set -e; \
  if getent passwd "${UID}" >/dev/null 2>&1; then \
    USERNAME="$(getent passwd "${UID}" | cut -d: -f1)"; \
  else \
    USERNAME="${USER}"; \
  fi; \
  if ! getent group "${GID}" >/dev/null 2>&1; then \
    groupadd --gid "${GID}" "${USERNAME}"; \
  fi; \
  if ! id -u "${USERNAME}" >/dev/null 2>&1; then \
    useradd --uid "${UID}" --gid "${GID}" -m -s /bin/zsh "${USERNAME}"; \
  fi; \
  mkdir -p /etc/sudoers.d; \
  echo "${USERNAME}" > /etc/dotfiles-user; \
  echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME}

RUN set -e; \
  USERNAME="$(cat /etc/dotfiles-user)"; \
  HOME_DIR="$(getent passwd "${USERNAME}" | cut -d: -f6)"; \
  mkdir -p "${HOME_DIR}"; \
  cp -a /opt/dotfiles "${HOME_DIR}/.dotfiles"; \
  chown -R "${USERNAME}:${USERNAME}" "${HOME_DIR}/.dotfiles"; \
  DOTFILES_INSTALL_MODE=container DOTFILES_CONTAINER_MINIMAL="${DOTFILES_CONTAINER_MINIMAL}" \
  DOTFILES_SKIP_PACKAGES=1 DOTFILES_SKIP_OS_DEFAULTS=1 \
    su - "${USERNAME}" -c "${HOME_DIR}/.dotfiles/scripts/install.sh"

COPY containers/entrypoint.sh /usr/local/bin/dotfiles-entrypoint
RUN chmod +x /usr/local/bin/dotfiles-entrypoint

ENTRYPOINT ["/usr/local/bin/dotfiles-entrypoint"]
