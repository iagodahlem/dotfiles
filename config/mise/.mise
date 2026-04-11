if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"

  # Add GOPATH/bin for Go tools installed via `go install`
  if command -v go >/dev/null 2>&1; then
    export PATH=$PATH:$(go env GOPATH)/bin
  fi
fi
