#!/usr/bin/env bash

set -euo pipefail

target_dir="${1:-.}"
mode="${2:-tracked}"

if ! command -v cloc >/dev/null 2>&1; then
  echo "Error: cloc is not installed." >&2
  exit 1
fi

if [[ ! -d "$target_dir" ]]; then
  echo "Error: '$target_dir' is not a directory." >&2
  exit 1
fi

case "$mode" in
  tracked|full)
    ;;
  *)
    echo "Error: mode must be 'tracked' or 'full'." >&2
    echo "Usage: $(basename "$0") [directory] [tracked|full]" >&2
    exit 1
    ;;
esac

target_dir="${target_dir%/}"

# Directories that commonly dominate line counts but are not useful source metrics.
exclude_dirs="node_modules,.next,.next_stale_20260323_0945,.next_stale_20260323_1010,.next_stale_20260323_1030,.venv,venv,data,volumes,__pycache__,.pytest_cache,dist,build"

run_cloc() {
  local dir="$1"

  if [[ "$mode" == "tracked" ]]; then
    cloc --vcs=git --quiet --csv "$dir"
  else
    cloc --quiet --csv --exclude-dir="$exclude_dirs" "$dir"
  fi
}

total_files=0
total_blank=0
total_comment=0
total_code=0
found_dirs=0

printf "Top-level directory totals for %s (%s mode)\n\n" "$target_dir" "$mode"
printf "%-40s %10s %10s %10s %10s %10s\n" "Directory" "Files" "Blank" "Comment" "Code" "Total"

for dir in "$target_dir"/*; do
  [[ -d "$dir" ]] || continue

  found_dirs=1
  sum_line="$(run_cloc "$dir" | awk -F, '$2 == "SUM" { print $1","$3","$4","$5 }')"

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
