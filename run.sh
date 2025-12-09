#!/usr/bin/env bash
set -euo pipefail
# set -x  # uncomment for debug

# Usage: ./run.sh [-s] 01 part1
USE_SAMPLE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--sample)
      USE_SAMPLE=true
      shift
      ;;
    *)
      break
      ;;
  esac
done

FOLDER="${1:-}"
PART="${2:-}"

if [[ -z "$FOLDER" || -z "$PART" ]]; then
  echo "Usage: $0 [-s|--sample] <folder> <part>"
  echo "Example: $0 01 part1"
  echo "         $0 -s 01 part1  # use input.sample"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PART_FILE="${FOLDER}/${PART}.brs"
if [[ "$USE_SAMPLE" == true ]]; then
  INPUT_PATH="${FOLDER}/input.sample"
else
  INPUT_PATH="${FOLDER}/input"
fi
UTILS_FILE="common/utils.brs"
MANIFEST_FILE="common/manifest"

[[ -f "$PART_FILE" ]]     || { echo "Missing part file: $PART_FILE"; exit 1; }
[[ -e "$INPUT_PATH" ]]    || { echo "Missing input: $INPUT_PATH"; exit 1; }
[[ -f "$UTILS_FILE" ]]    || { echo "Missing utils file: $UTILS_FILE"; exit 1; }
[[ -f "$MANIFEST_FILE" ]] || { echo "Missing manifest file: $MANIFEST_FILE"; exit 1; }

# Make sure brs-cli exists
if ! command -v brs-cli >/dev/null 2>&1; then
  echo "ERROR: brs-cli not found in PATH"
  exit 1
fi

WORKDIR="$(mktemp -d)"
cleanup() {
  rm -rf "$WORKDIR"
}
trap cleanup EXIT

mkdir -p "$WORKDIR/source"

# Build dynamic title
DAY_NUM=$((10#${FOLDER}))  # Strip leading zero: "01" -> "1"
PART_NUM="${PART#part}"    # Extract number from "part1" -> "1"
TITLE="Advent of Code 2025 - Day ${DAY_NUM}, Part ${PART_NUM}"
if [[ "$USE_SAMPLE" == true ]]; then
  TITLE="${TITLE} (Sample Input)"
fi

# Core files
cp "$PART_FILE"     "$WORKDIR/source/main.brs"
cp "$UTILS_FILE"    "$WORKDIR/source/utils.brs"
cp -r "$INPUT_PATH" "$WORKDIR/source/input"

# Generate manifest with dynamic title
sed "s/^title=.*/title=${TITLE}/" "$MANIFEST_FILE" > "$WORKDIR/manifest"

# Include any extra files from the FOLDER (e.g. bigint.brs),
# excluding:
#   - input and input.sample
#   - all part*.brs files
for path in "$FOLDER"/*; do
  base="$(basename "$path")"

  # Skip the input files
  if [[ "$base" == "input" || "$base" == "input.sample" ]]; then
    continue
  fi

  # Skip all part*.brs files (special)
  if [[ "$base" == part*.brs ]]; then
    continue
  fi

  # Copy anything else (file or dir) into source/
  cp -r "$path" "$WORKDIR/source/"
done

# Get a unique name but DON'T create the file yet
ZIPFILE="$(mktemp -u /tmp/brs-package-XXXXXX).zip"

(
  cd "$WORKDIR"
  zip -r "$ZIPFILE" .
)

echo "Created zip at: $ZIPFILE"

time brs-cli "$ZIPFILE"

rm -f "$ZIPFILE"
echo "Done."

