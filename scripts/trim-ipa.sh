#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 INPUT_IPA OUTPUT_IPA" >&2
  exit 2
fi

input_ipa=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
output_ipa=$(mkdir -p "$(dirname "$2")" && cd "$(dirname "$2")" && pwd)/$(basename "$2")
work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT

unzip -q "$input_ipa" -d "$work_dir/unpacked"
app_dir=$(find "$work_dir/unpacked/Payload" -maxdepth 1 -type d -name '*.app' -print -quit)
plugins_dir="$app_dir/PlugIns"

if [[ -z "$app_dir" || ! -d "$plugins_dir" ]]; then
  echo "The IPA does not contain an app with a PlugIns directory." >&2
  exit 1
fi

found_safari=0
found_share=0

while IFS= read -r -d '' extension; do
  plist="$extension/Info.plist"
  bundle_id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$plist" 2>/dev/null || true)
  case "$bundle_id" in
    com.christianselig.Apollo.Apollofari)
      found_safari=1
      echo "Keeping $(basename "$extension") ($bundle_id)"
      ;;
    com.christianselig.Apollo.OpenInUIExtension)
      found_share=1
      echo "Keeping $(basename "$extension") ($bundle_id)"
      ;;
    *)
      echo "Removing $(basename "$extension") (${bundle_id:-unknown bundle ID})"
      rm -rf "$extension"
      ;;
  esac
done < <(find "$plugins_dir" -mindepth 1 -maxdepth 1 -type d -name '*.appex' -print0)

if [[ "$found_safari" -ne 1 ]]; then
  echo "Required extension not found: com.christianselig.Apollo.Apollofari" >&2
  exit 1
fi
if [[ "$found_share" -ne 1 ]]; then
  echo "Required extension not found: com.christianselig.Apollo.OpenInUIExtension" >&2
  exit 1
fi

remaining_count=$(find "$plugins_dir" -mindepth 1 -maxdepth 1 -type d -name '*.appex' | wc -l | tr -d ' ')
if [[ "$remaining_count" -ne 2 ]]; then
  echo "Safety check failed: expected exactly 2 extensions, found $remaining_count." >&2
  exit 1
fi

(
  cd "$work_dir/unpacked"
  zip -qry -y "$output_ipa" Payload
)

echo "Created $output_ipa"
