#!/usr/bin/env bash
set -euo pipefail
# set -x  # uncomment for debug

# Usage: ./run.sh 01 part1
FOLDER="${1:-}"
PART="${2:-}"

if [[ -z "$FOLDER" || -z "$PART" ]]; then
  echo "Usage: $0 <folder> <part>"
  echo "Example: $0 01 part1"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PART_FILE="${FOLDER}/${PART}.brs"
INPUT_PATH="${FOLDER}/input"
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

# Make sure zip exists
if ! command -v zip >/dev/null 2>&1; then
  echo "ERROR: zip command not found. Install it with: sudo apt install zip"
  exit 1
fi

WORKDIR="$(mktemp -d)"
cleanup() {
  rm -rf "$WORKDIR"
}
trap cleanup EXIT

mkdir -p "$WORKDIR/source"

# Core files
cp "$PART_FILE"     "$WORKDIR/source/main.brs"
cp "$UTILS_FILE"    "$WORKDIR/source/utils.brs"
cp -r "$INPUT_PATH" "$WORKDIR/source/input"
cp "$MANIFEST_FILE" "$WORKDIR/manifest"

# Include any extra files from the FOLDER (e.g. bigint.brs),
# excluding:
#   - input
#   - all part*.brs files
for path in "$FOLDER"/*; do
  base="$(basename "$path")"

  # Skip the input file/dir
  if [[ "$base" == "$(basename "$INPUT_PATH")" ]]; then
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

