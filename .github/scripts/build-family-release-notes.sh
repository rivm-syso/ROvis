#!/usr/bin/env bash
# Combines the latest NEWS.md entry from each ROvis.* family package into a
# single pkgdown article. Expects one raw NEWS.md file per package already
# downloaded into $SOURCE_DIR (see
# .github/workflows/family-release-notes.yaml), named "<package>.md".
set -euo pipefail

SOURCE_DIR="${1:-.family-release-notes}"
OUT_FILE="${2:-vignettes/articles/family-release-notes.qmd}"

PACKAGES=(ROvis.utils ROvis.ggplot2 ROvis.plotly ROvis.echarts ROvis.table ROvis.shiny)

# Prints from the first top-level ("# ...") heading up to, but excluding,
# the next one - i.e. the most recent version's entry.
extract_latest_entry() {
  awk '
    /^# / { headings++; if (headings == 2) exit }
    headings >= 1 { print }
  ' "$1"
}

# The heading line is "# <package> v<version>" - package names may contain
# dots, but the version is always the last space-separated field, so this
# stays correct regardless.
get_version() {
  head -n1 "$1" 2>/dev/null | awk '{print $NF}'
}

# The family's NEWS.md headers use GitHub-style ":shortcode:" emoji, which
# GitHub and pkgdown::build_news() render as real emoji but Quarto's default
# markdown reader (used for vignettes/articles/*.qmd) does not - it leaves
# the literal ":sparkles:" text as-is. Substituting here, once, means the
# individual family repos never need to know or care about this.
emojify() {
  sed -e 's/:sparkles:/✨/g' \
      -e 's/:hammer_and_wrench:/🛠️/g' \
      -e 's/:bug:/🐛/g' \
      -e 's/:coffin:/⚰️/g'
}

mkdir -p "$(dirname "$OUT_FILE")"

{
  echo "---"
  echo "title: \"Family release notes\""
  echo "---"
  echo
  echo "Latest release notes across the ROvis family, refreshed daily."
  echo
  echo "| Package | Latest version |"
  echo "|---|---|"
  for pkg in "${PACKAGES[@]}"; do
    version="$(get_version "$SOURCE_DIR/$pkg.md")"
    echo "| $pkg | ${version:-unknown} |"
  done

  for pkg in "${PACKAGES[@]}"; do
    echo
    entry="$(extract_latest_entry "$SOURCE_DIR/$pkg.md" 2>/dev/null || true)"
    if [ -z "$entry" ]; then
      echo "## $pkg"
      echo
      echo "No release notes yet."
    else
      # Demote the package's own "# Pkg vX" heading to "##" so it nests
      # under this page's own title instead of competing with it.
      printf '%s\n' "$entry" | sed '1s/^# /## /'
    fi
  done
} | emojify > "$OUT_FILE"
