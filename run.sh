#!/usr/bin/env bash
set -euo pipefail
# set -x  # uncomment for debug

# Usage: ./run.sh [-s] [-r] 01 part1
USE_SAMPLE=false
USE_ROKU=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--sample)
      USE_SAMPLE=true
      shift
      ;;
    -r|--roku)
      USE_ROKU=true
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
  echo "Usage: $0 [-s|--sample] [-r|--roku] <folder> <part>"
  echo "Example: $0 01 part1"
  echo "         $0 -s 01 part1      # use input.sample"
  echo "         $0 -r 01 part1      # deploy to real Roku"
  echo "         $0 -s -r 01 part1   # sample input on real Roku"
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

# Check dependencies based on mode
if [[ "$USE_ROKU" == true ]]; then
  ENV_FILE="$SCRIPT_DIR/.env"
  if [[ ! -f "$ENV_FILE" ]]; then
    echo "ERROR: .env file not found. Create one with ROKU_IP and ROKU_PASSWORD"
    echo "Example:"
    echo "  ROKU_IP=192.168.1.100"
    echo "  ROKU_PASSWORD=your_dev_password"
    exit 1
  fi
  # shellcheck source=/dev/null
  source "$ENV_FILE"
  if [[ -z "${ROKU_IP:-}" || -z "${ROKU_PASSWORD:-}" ]]; then
    echo "ERROR: ROKU_IP and ROKU_PASSWORD must be set in .env"
    exit 1
  fi
else
  if ! command -v brs-cli >/dev/null 2>&1; then
    echo "ERROR: brs-cli not found in PATH"
    exit 1
  fi
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

if [[ "$USE_ROKU" == true ]]; then
  echo "Deploying to Roku at $ROKU_IP..."

  # Open telnet connection FIRST in the main shell
  exec 3<>/dev/tcp/"$ROKU_IP"/8085
  echo "Connected to debug console..."

  # Start background reader that processes the telnet output
  # Only look for exit AFTER we see our app compiling
  (
    SEEN_COMPILE=false
    while IFS= read -r -t 120 line <&3; do
      echo "$line"
      # Wait for our specific app to start compiling
      if [[ "$SEEN_COMPILE" == false && "$line" == *"[scrpt.cmpl] Compiling '$TITLE'"* ]]; then
        SEEN_COMPILE=true
      fi
      # Only look for exit after we've seen our app compile
      if [[ "$SEEN_COMPILE" == true && "$line" == *"bs.ndk.proc.exit"* ]]; then
        break
      fi
    done
  ) &
  READER_PID=$!

  # Now upload the package (telnet is already connected and reading)
  response=$(curl -s -w "%{http_code}" -o /dev/null --digest -u "rokudev:$ROKU_PASSWORD" \
    -F "mysubmit=Install" \
    -F "archive=@$ZIPFILE" \
    "http://$ROKU_IP/plugin_install")

  rm -f "$ZIPFILE"

  if [[ "$response" -ne 200 ]]; then
    echo "Error: Roku responded with code $response"
    kill "$READER_PID" 2>/dev/null || true
    exec 3<&-
    exit 1
  fi

  echo "Installation successful! Waiting for app to finish..."

  # Wait for reader to see the exit marker
  wait "$READER_PID" || true
  exec 3<&-
  echo "Debug console closed."
else
  time brs-cli "$ZIPFILE"
  rm -f "$ZIPFILE"
fi

echo "Done."

