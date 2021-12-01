#!/usr/bin/env bash

export WORK_DIR="$PWD"
export BOT_MSG_URL="https://api.telegram.org/bot$BOT_TOKEN/sendMessage"

# Configure gcc 10
function configure() {
	alias gcc=gcc-10
	alias g++=g++-10
}

# Clone repo
function repo() {
	git config --global user.name "${GITHUB_USER}"
	git config --global user.email "${GITHUB_EMAIL}"
	git clone https://"${GITHUB_USER}":"${GITHUB_TOKEN}"@github.com/"${GITHUB_USER}"/gcc-arm64 ../gcc-arm64 -b gcc-master
	rm -rf ../gcc-arm64/*
}

tg_post_msg() {
  curl -s -X POST "$BOT_MSG_URL" -d chat_id="$CHAT_ID" \
  -d "disable_web_page_preview=true" \
  -d "parse_mode=html" \
  -d text="$1"
}

# Fin Error
function finerr() {
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Build throw an error(s)" \
    curl -s -X POST "$BOT_MSG_URL2/sendSticker" \
        -d sticker="CAACAgIAAx0CXjGT1gACDRRhYsUKSwZJQFzmR6eKz2aP30iKqQACPgADr8ZRGiaKo_SrpcJQIQQ" \
        -d chat_id="$CHAT_ID"
    exit 1
}

# Building gcc
function gcc() {
	tg_post_msg "<b>Starting Build $GCC_NAME GCC ARM64 (64-bit)</b>"
	chmod a+x build-*.sh
	./build-gcc.sh -a arm64
}

# Building lld
function lld() {
	tg_post_msg "<b>Starting Build $GCC_NAME LLD ARM64 (64-bit)</b>"
	sudo bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
	./build-lld.sh -a arm64
}

# Push toolchain
function push() {
	cd ../gcc-arm64
	./bin/aarch64-elf-gcc -v 2>&1 | tee /tmp/gcc-version
	./bin/aarch64-elf-ld.lld -v 2>&1 | tee /tmp/lld-arm64-version
	bash "$WORK_DIR/strip-binaries.sh"
	export short_binutils_commit="$(cut -c-8 <<< "$binutils_commit")"
	export short_gcc_commit="$(cut -c-8 <<< "$gcc_commit")"
	export binutils_commit_url="https://github.com/bminor/binutils-gdb/commit/$short_binutils_commit"
	export gcc_commit_url="https://github.com/gcc-mirror/gcc/commit/$short_gcc_commit"
	echo "# $GCC_NAME GCC ARM64" >> README.md
	git add . -f
	git commit -as -m "Release ARM64 GCC $(/bin/date)"  -m "Build completed on: $(/bin/date)" -m "Gcc commit: $gcc_commit_url" -m "Binutils commit: $binutils_commit_url" -m "Configuration: $(/bin/cat /tmp/gcc-version)" -m "LLD: $(/bin/cat /tmp/lld-arm64-version)"
	git gc
	git push origin gcc-master -f
	export GCC_VER="$(bin/aarch64-elf-gcc --version)"
	export LLD_VER="$(bin/aarch64-elf-ld.lld --version)"
	tg_post_msg "<b>$GCC_NAME GCC arm64: Toolchain compilation Finished</b>%0A<b>Gcc Version : </b><code>$GCC_VER</code>%0A<b>LLD Version : </b><code>$LLD_VER</code>"
	tg_post_msg "<b>$GCC_NAME GCC arm64: Toolchain pushed to : </b>https://github.com/"${GITHUB_USER}"/gcc-arm64"
}

# Commit detection
binutils_commit() {
	cd $WORK_DIR/binutils
	git rev-parse HEAD
}
gcc_commit() {
	cd $WORK_DIR/gcc
	git rev-parse HEAD
}
configure
repo
gcc
lld
push
