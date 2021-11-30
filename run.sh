#!/usr/bin/env bash

export WORK_DIR="$PWD"

alias gcc=gcc-10
alias g++=g++-10
git config --global user.name "${GITHUB_USER}"
git config --global user.email "${GITHUB_EMAIL}"
git clone https://"${GITHUB_USER}":"${GITHUB_TOKEN}"@github.com/"${GITHUB_USER}"/gcc-arm ../gcc-arm -b gcc-master
rm -rf ../gcc-arm/*
chmod a+x build-*.sh
curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" -d chat_id="${CHAT_ID}" -d "disable_web_page_preview=true" -d "parse_mode=html" -d text="<b>Starting Build $GCC_NAME GCC ARM (32-bit)</b>"
./build-gcc.sh -a arm
curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" -d chat_id="${CHAT_ID}" -d "disable_web_page_preview=true" -d "parse_mode=html" -d text="<b>Starting Build $GCC_NAME LLD ARM (32-bit)</b>"
sudo bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
./build-lld.sh -a arm
cd ../gcc-arm
./bin/arm-eabi-gcc -v 2>&1 | tee /tmp/gcc-arm-version
./bin/arm-eabi-ld.lld -v 2>&1 | tee /tmp/lld-arm-version
bash "$WORK_DIR/strip-binaries.sh"
echo "# $GCC_NAME GCC ARM" >> README.md
git add . -f
git commit -as -m "Release ARM GCC $(/bin/date)"  -m "Build completed on: $(/bin/date)" -m "Configuration: $(/bin/cat /tmp/gcc-arm-version)" -m "LLD: $(/bin/cat /tmp/lld-arm-version)"
git gc
git push origin gcc-master -f
export GCC_VER="$(bin/arm-eabi-gcc --version)"
export LLD_VER="$(bin/arm-eabi-ld.lld --version)"
curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" -d chat_id="${CHAT_ID}" -d "disable_web_page_preview=true" -d "parse_mode=html" -d text="<b>$GCC_NAME GCC arm: Toolchain compilation Finished</b>%0A<b>Gcc Version : </b><code>$GCC_VER</code>%0A<b>LLD Version : </b><code>$LLD_VER</code>"
curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" -d chat_id="${CHAT_ID}" -d "disable_web_page_preview=true" -d "parse_mode=html" -d text="<b>$GCC_NAME GCC arm: Toolchain pushed to : </b>https://github.com/"${GITHUB_USER}"/gcc-arm"
