#!/bin/bash

SCRIPT_REPO="https://github.com/Netflix/vmaf.git"
SCRIPT_COMMIT="e7258b3c269467b5ce188ccad7161f587d72d421"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" vmaf
    cd vmaf/libvmaf

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        --libdir=lib
        -Denable_avx512=true
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    elif [[ $TARGET == mac* ]]; then
        :
    else
        echo "Unknown target"
        return -1
    fi

    meson setup build "${myconf[@]}"
    ninja -vC build -j$(nproc)
    ninja -vC build install
}

ffbuild_configure() {
    echo '--enable-libvmaf --extra-libs="-lstdc++"'
}

ffbuild_unconfigure() {
    echo '--disable-libvmaf'
}