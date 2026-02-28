{
  clang,
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "c-kzg";
  version = "2.1.6";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "c-kzg-4844";
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-iSyzmtMdU2pZv+X2TVjMlN5eYoirFaP9kBvtH4tFrx4=";
  };

  nativeBuildInputs = [ clang ];

  buildPhase = ''
    set -e

    # Build blst library first
    echo "=== Building blst ==="
    cd blst
    $CC -O2 -fno-builtin -fPIC -Wall -Wextra -D__BLST_PORTABLE__ -c src/server.c -o libblst.o
    ar rcs libblst.a libblst.o
    cd ..

    # Copy blst lib to lib directory for c-kzg
    echo "=== Copying blst library ==="
    mkdir -p lib
    cp blst/libblst.a lib/

    # Compile all C files from src into object files
    echo "=== Building c-kzg ==="
    cd src
    $CC -c -O2 -I../inc -I../blst/src -I../blst/bindings -I. *.c

    # Create static library
    echo "=== Creating library ==="
    ar rcs libckzg.a *.o ../lib/libblst.a
    echo "=== Build phase complete ==="
  '';

  installPhase = ''
    mkdir -p $out/lib $out/include
    # Check what's in inc directory (go back to root first)
    cd ..
    # Copy all files from inc directory
    if [ -n "$(ls inc/)" ]; then
      cp inc/* $out/include/
    fi
    # Copy the library
    cp src/libckzg.a $out/lib/
    # Copy entire src directory for Go bindings (they need all includes)
    cp -r src $out/
  '';

  passthru = {
    category = "Libraries";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "A minimal implementation of the Polynomial Commitments API";
    homepage = "https://github.com/ethereum/c-kzg-4844";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
      "aarch64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
