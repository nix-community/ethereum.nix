source $stdenv/setup

buildPhase() {
    ./build.sh
}

installPhase() {
    mkdir -p $out/{include,lib}
    cp libblst.a $out/lib/
    cp bindings/*.{h,hpp} $out/include/
    cp src/*.h $out/include/
    cp src/*.c $out/include/
}

genericBuild