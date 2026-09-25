#!/usr/bin/env bash

# Entries of a list file (package lists, config/links): blank lines and comments, whole-line or trailing, are dropped.
read_list_items() {
  local list_file="$1"
  sed -E 's/[[:space:]]*#.*$//; /^[[:space:]]*$/d' "$list_file"
}
