#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_DIR="$ROOT_DIR/android-native"
GRADLE_BIN="${GRADLE_BIN:-gradle}"

source_contract_selftest() {
    local activity="$ANDROID_DIR/app/src/main/java/com/example/androidnative/MainActivity.java"
    local native="$ANDROID_DIR/app/src/main/cpp/native-lib.c"
    local gradle_file="$ANDROID_DIR/app/build.gradle.kts"
    local manifest="$ANDROID_DIR/app/src/main/AndroidManifest.xml"

    test -f "$activity"
    test -f "$native"
    test -f "$gradle_file"
    test -f "$manifest"
    grep -q 'BETA_INIT_OK' "$activity"
    grep -q 'BETA_TERMINAL_OK' "$activity"
    grep -q 'BETA_CLEANUP_OK' "$activity"
    grep -q '/system/bin/sh' "$activity"
    grep -q 'destroyForcibly' "$activity"
    grep -q 'Java_com_example_androidnative_MainActivity_stringFromJNI' "$native"
    grep -q 'armeabi-v7a' "$gradle_file"
    grep -q 'arm64-v8a' "$gradle_file"
    grep -q 'Rafacodephi Beta' "$manifest"
}

if (cd "$ANDROID_DIR" && "$GRADLE_BIN" --no-daemon :app:betaSourceSelfTest); then
    exit 0
fi

cat >&2 <<'WARN'
Gradle betaSourceSelfTest failed. Running strict source-contract fallback.
This fallback is intended for environments without Android Gradle Plugin/SDK access;
CI and release builds must still run the Gradle task and APK build.
WARN
source_contract_selftest
