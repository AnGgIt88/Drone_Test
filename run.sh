#!/usr/bin/env bash

alias gcc=gcc-10
alias g++=g++-10
git config --global user.name "${GITHUB_USER}"
git config --global user.email "${GITHUB_EMAIL}"
git clone https://"${GITHUB_USER}":"${GITHUB_TOKEN}"@github.com/"${GITHUB_USER}"/gcc-arm64 ../gcc-arm64 -b gcc-master
rm -rf ../gcc-arm64/*
chmod a+x build-*.sh
curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" -d chat_id="${CHAT_ID}" -d "disable_web_page_preview=true" -d "parse_mode=html" -d text="<b>Starting Build $GCC_NAME GCC ARM64 (64-bit)</b>"
./build-gcc.sh -a arm64
curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" -d chat_id="${CHAT_ID}" -d "disable_web_page_preview=true" -d "parse_mode=html" -d text="<b>Starting Build $GCC_NAME LLD ARM64 (64-bit)</b>"
sudo bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
./build-lld.sh -a arm64
cd ../gcc-arm64
./bin/aarch64-elf-gcc -v 2>&1 | tee /tmp/gcc-version
./bin/aarch64-elf-ld.lld -v 2>&1 | tee /tmp/lld-arm64-version
echo "# $GCC_NAME GCC ARM64" >> README.md
git add . -f
git commit -as -m "Release ARM64 GCC $(/bin/date)"  -m "Build completed on: $(/bin/date)" -m "Configuration: $(/bin/cat /tmp/gcc-version)" -m "LLD: $(/bin/cat /tmp/lld-arm64-version)"
git gc
git push origin gcc-master -f
curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" -d chat_id="${CHAT_ID}" -d "disable_web_page_preview=true" -d "parse_mode=html" -d text="$GCC_NAME GCC arm64: Toolchain compilation Finished</b>%0A<b>Gcc Version : </b><code>$(/bin/cat /tmp/gcc-version)</code>%0A<b>LLD Version : </b><code>$(/bin/cat /tmp/lld-arm64-version)</code>"
curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" -d chat_id="${CHAT_ID}" -d "disable_web_page_preview=true" -d "parse_mode=html" -d text="<b>$GCC_NAME GCC arm64: Toolchain pushed to : </b>https://github.com/"${GITHUB_USER}"/gcc-arm64"
