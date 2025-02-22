MESON_VERSION="0.60.2"
GO_VERSION="1.17.6"
LLVM_RELEASE="12"
GIMMIE_URL="https://raw.githubusercontent.com/travis-ci/gimme/master/gimme"

CLANG_CC="clang-${LLVM_RELEASE}"
CLANG_CXX="clang++-${LLVM_RELEASE}"
CLANG_FORMAT="clang-format-${LLVM_RELEASE}"
CLANG_TIDY="clang-tidy-${LLVM_RELEASE}"
LLD="lld-${LLVM_RELEASE}"

die() {
    echo "$@" >&2
    exit 1
}

install_go() {
    goversion="$1"
    # Gimmie outputs envrionment variables, so we need to eval them here.
    eval "$(curl -sL "${GIMMIE_URL}" | GIMME_GO_VERSION="${goversion}" bash)"
}

build_meta() {
    (cd tools/meta && GO11MODULE=on go build)
}

setup() {
    if test -n "${IN_DEBUG_MODE}"; then
        return 0
    fi
    sudo env DEBIAN_FRONTEND=noninteractive apt-get update -y && \
        sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y \
            "${CLANG_CC}" \
            "${CLANG_FORMAT}" \
            "${CLANG_TIDY}" \
            cmake \
            libmpdclient-dev \
            "${LLD}" \
            ninja-build \
            patchelf \
            python3 python3-pip python3-setuptools python3-wheel \
    || die "couldn't apt-get required packages" 
    sudo pip3 install meson=="${MESON_VERSION}" || die "couldn't install meson"
    install_go "${GO_VERSION}"
    build_meta
}
