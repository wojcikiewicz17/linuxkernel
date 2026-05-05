#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_DIR="$ROOT_DIR/android-native"
OUT_DIR="$ROOT_DIR/artifacts/android-native"
ABIS=(armeabi-v7a arm64-v8a)
GRADLE_BIN="${GRADLE_BIN:-gradle}"

usage() {
    cat <<USAGE
Usage: $0 [debug|release-unsigned|release-signed|all]

Tracks:
  debug             Build debug APKs for arm32 and arm64.
  release-unsigned  Build internal unsigned release APKs for arm32 and arm64.
  release-signed    Build official signed release APK. Requires signing env/properties.
  all               Run source selftest, debug and release-unsigned.

Signed release environment accepted by Gradle:
  ANDROID_KEYSTORE_PATH, ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS, ANDROID_KEY_PASSWORD
USAGE
}

copy_and_hash() {
    local label="$1"
    local abi="$2"
    local pattern="$3"
    local dest_dir="$OUT_DIR/$label/$abi"
    mkdir -p "$dest_dir"
    find "$ANDROID_DIR/app/build/outputs/apk" -type f -name "$pattern" -print0 |
        while IFS= read -r -d '' apk; do
            local dest="$dest_dir/$(basename "$apk")"
            cp "$apk" "$dest"
            sha256sum "$dest" > "$dest.sha256"
            echo "artifact: $dest"
            cat "$dest.sha256"
        done
}

run_gradle() {
    (cd "$ANDROID_DIR" && "$GRADLE_BIN" --no-daemon "$@")
}

build_debug() {
    local abi="$1"
    run_gradle clean :app:assembleDebug -PciAbi="$abi"
    copy_and_hash debug "$abi" "*.apk"
}

build_release_unsigned() {
    local abi="$1"
    run_gradle clean :app:assembleRelease -PciAbi="$abi"
    copy_and_hash release-unsigned "$abi" "*unsigned*.apk"
}

build_release_signed() {
    run_gradle clean :app:assembleRelease -PrequireReleaseSigning=true
    copy_and_hash release-signed universal "*.apk"
}

main() {
    local mode="${1:-all}"
    case "$mode" in
        debug)
            run_gradle :app:betaSourceSelfTest
            for abi in "${ABIS[@]}"; do build_debug "$abi"; done
            ;;
        release-unsigned)
            run_gradle :app:betaSourceSelfTest
            for abi in "${ABIS[@]}"; do build_release_unsigned "$abi"; done
            ;;
        release-signed)
            run_gradle :app:betaSourceSelfTest
            build_release_signed
            ;;
        all)
            run_gradle :app:betaSourceSelfTest
            for abi in "${ABIS[@]}"; do build_debug "$abi"; done
            for abi in "${ABIS[@]}"; do build_release_unsigned "$abi"; done
            ;;
        -h|--help|help)
            usage
            ;;
        *)
            usage >&2
            exit 2
            ;;
    esac
}

main "$@"
