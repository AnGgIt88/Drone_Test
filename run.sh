#!/usr/bin/env bash

alias gcc=gcc-10
alias g++=g++-10
git config --global user.name "${GITHUB_USER}"
git config --global user.email "${GITHUB_EMAIL}"
git clone https://"${GITHUB_USER}":"${GITHUB_TOKEN}"@github.com/"${GITHUB_USER}"/gcc-arm ../gcc-arm -b gcc-master
rm -rf ../gcc-arm/*
chmod a+x build-*.sh
curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" -d chat_id="${CHAT_ID}" -d "disable_web_page_preview=true" -d "parse_mode=html" -d text="<b>Starting ARM (32-bit) GCC Build</b>"
./build-gcc.sh -a arm
sudo bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
./build-lld.sh -a arm
cd ../gcc-arm
./bin/arm-eabi-gcc -v 2>&1 | tee /tmp/gcc-arm-version
./bin/arm-eabi-ld.lld -v 2>&1 | tee /tmp/lld-arm-version
git add . -f
git commit -as -m "Import ARM GCC $(/bin/date)"  -m "Build completed on: $(/bin/date)" -m "Configuration: $(/bin/cat /tmp/gcc-arm-version)" -m "LLD: $(/bin/cat /tmp/lld-arm-version)"
git gc
git push origin gcc-master -f
