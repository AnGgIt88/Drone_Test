#!/usr/bin/env bash

export WORK_DIR="$PWD"

curl -LSsO "https://github.com/kdrag0n/proton-clang/raw/master/bin/strip"
chmod +x "$WORK_DIR/strip"
X86_STRIP="$WORK_DIR/strip"
find "$WORK_DIR" -type f -exec file {} \; \
    | grep "x86" | grep "not strip" | grep -v "relocatable" \
	| tr ':' ' ' | awk '{print $1}' \
	| while read -r file; do $X86_STRIP "$file"; done && rm "$WORK_DIR/strip"

curl -LSsO "https://github.com/kdrag0n/proton-clang/raw/master/bin/aarch64-linux-gnu-strip"
chmod +x "$WORK_DIR/aarch64-linux-gnu-strip"
ARM64_STRIP="$WORK_DIR/aarch64-linux-gnu-strip"
find "$WORK_DIR" -type f -exec file {} \; \
    | grep "ARM" | grep "aarch64" | grep "not strip" | grep -v "relocatable" \
	| tr ':' ' ' | awk '{print $1}' \
	| while read -r file; do $ARM64_STRIP "$file"; done && rm "$WORK_DIR/aarch64-linux-gnu-strip"

curl -LSsO "https://github.com/kdrag0n/proton-clang/raw/master/bin/arm-linux-gnueabi-strip"
chmod +x "$WORK_DIR/arm-linux-gnueabi-strip"
ARM32_STRIP="$WORK_DIR/arm-linux-gnueabi-strip"
find "$WORK_DIR" -type f -exec file {} \; \
    | grep "ARM" | grep "32.bit" | grep "not strip" | grep -v "relocatable" \
	| tr ':' ' ' | awk '{print $1}' \
	| while read -r file; do $ARM32_STRIP "$file"; done && rm "$WORK_DIR/arm-linux-gnueabi-strip"
