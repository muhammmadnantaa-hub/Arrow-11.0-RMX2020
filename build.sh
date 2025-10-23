#!/bin/bash

# Set kernel name
BUILD_FOR="A13"
DATE="$(TZ=Asia/India date +%Y%m%d)"
KERNEL_NAME="KSU-NEXT${BUILD_FOR}-${DATE}.zip"

function compile() 
{

source ~/.bashrc && source ~/.profile
export LC_ALL=C && export USE_CCACHE=1
ccache -M 100G
export ARCH=arm64
export KBUILD_BUILD_HOST=wildmoon
export KBUILD_BUILD_USER="szyryjn"
git clone --depth=1 https://gitlab.com/sarthakroy2002/android_prebuilts_clang_host_linux-x86_clang-r437112b clang
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 los-4.9-64
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 los-4.9-32

make O=out ARCH=arm64 RMX2020_defconfig

PATH="${PWD}/clang/bin:${PATH}:${PWD}/los-4.9-32/bin:${PATH}:${PWD}/los-4.9-64/bin:${PATH}" \
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC="clang" \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE="${PWD}/los-4.9-64/bin/aarch64-linux-gnu-" \
                      CROSS_COMPILE_ARM32="${PWD}/los-4.9-32/bin/arm-linux-gnueabihf-" \
                      CONFIG_NO_ERROR_ON_MISMATCH=y
}

function zupload()
{
rm -rf AnyKernel
git clone --depth=1 -b RMX2020-KSUN https://github.com/szyryjn/AnyKernel3.git AnyKernel
cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
cd AnyKernel
(zip -r9 "$KERNEL_NAME" *)
#curl --upload-file Test-OSS-KERNEL-RMX2020-NEOLIT.zip https://transfer.sh/
curl -sL https://git.io/file-transfer | sh
./transfer wet Test-OSS-KERNEL-RMX2020-NEOLIT.zip
}

compile
zupload
