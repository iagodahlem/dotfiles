#!/usr/bin/env bash

# Entries of a list file (package lists, config/links): blank lines and comments, whole-line or trailing, are dropped.
read_list_items() {
  local list_file="$1"
  sed -E 's/[[:space:]]*#.*$//; /^[[:space:]]*$/d' "$list_file"
}

# How many entries read_list_items finds in a list file.
count_list_items() {
  read_list_items "$1" | awk 'END { print NR }'
}
