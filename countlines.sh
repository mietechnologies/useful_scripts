#!/usr/bin/env bash

set -euo pipefail

target_dir="${1:-.}"

if ! command -v cloc >/dev/null 2>&1; then
  echo "Error: cloc is not installed." >&2
  exit 1
fi

if [[ ! -d "$target_dir" ]]; then
  echo "Error: '$target_dir' is not a directory." >&2
  exit 1
fi

target_dir="${target_dir%/}"

total_files=0
total_blank=0
total_comment=0
total_code=0
found_dirs=0

printf "Top-level directory totals for %s\n\n" "$target_dir"
printf "%-40s %10s %10s %10s %10s %10s\n" "Directory" "Files" "Blank" "Comment" "Code" "Total"

for dir in "$target_dir"/*; do
  [[ -d "$dir" ]] || continue

  found_dirs=1
  sum_line="$(cloc --quiet --csv "$dir" | awk -F, '$2 == "SUM" { print $1","$3","$4","$5 }')"

  if [[ -z "$sum_line" ]]; then
    files=0
    blank=0
    comment=0
    code=0
  else
    IFS=, read -r files blank comment code <<< "$sum_line"
  fi

  total=$((blank + comment + code))
  total_files=$((total_files + files))
  total_blank=$((total_blank + blank))
  total_comment=$((total_comment + comment))
  total_code=$((total_code + code))

  printf "%-40s %10d %10d %10d %10d %10d\n" "$(basename "$dir")" "$files" "$blank" "$comment" "$code" "$total"
done

if [[ "$found_dirs" -eq 0 ]]; then
  echo "No top-level directories found in '$target_dir'."
  exit 0
fi

grand_total=$((total_blank + total_comment + total_code))
printf "\n%-40s %10d %10d %10d %10d %10d\n" "TOTAL" "$total_files" "$total_blank" "$total_comment" "$total_code" "$grand_total"
