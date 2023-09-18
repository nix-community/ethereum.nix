source $stdenv/setup

buildPhase() {
    ./build.sh
}

installPhase() {
    mkdir -p $out/{include/elf,lib}
    cp libblst.a $out/lib/
    cp bindings/*.{h,hpp} $out/include/
    cp build/assembly.S $out/include/
    cp build/elf/* $out/include/elf/
    cp src/*.h $out/include/
    cp src/*.c $out/include/
}

genericBuild
