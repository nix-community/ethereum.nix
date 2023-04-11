# Derivative of https://github.com/NixOS/nixpkgs/issues/203708

# nix-build
# builds main package.json successfully but binaries not found
# for example ./result/node_modules/beacon-node/bin is missing

{ pkgs ? import <nixpkgs> { }
, fetchFromGitHub ? pkgs.fetchFromGitHub
, mkYarnPackage ? pkgs.mkYarnPackage
, fetchYarnDeps ? pkgs.fetchYarnDeps
, fixup_yarn_lock ? pkgs.fixup_yarn_lock
, lib ? pkgs.lib
}:

let
  pname = "lodestar";
  version = "1.7.2";
  src = fetchFromGitHub {
    owner = "ChainSafe";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-ctJzQbmF71msj5TBj0RBoLdfsqmuh2EbkT3ZVKewRE4=";
  };
in
mkYarnPackage {
  inherit pname version src;
  name = pname;

  offlineCache = fetchYarnDeps {
    yarnLock = src + "/yarn.lock";
    sha256 = "sha256-oGgLg8iiugCef+bE2R2WNHmgSYGrD5b/CLqIfP0WRHs=";
  };

  nativeBuildInputs = [ 
    pkgs.fixup_yarn_lock
    pkgs.nodePackages.lerna
  ];

  configurePhase = ''
    export HOME=$NIX_BUILD_TOP
    yarn config --offline set yarn-offline-mirror $offlineCache
    fixup_yarn_lock yarn.lock
    yarn install --offline --ignore-optional --frozen-lockfile --ignore-scripts --no-progress --non-interactive
    patchShebangs node_modules/
  '';

  postBuild = "yarn --offline build";

  installPhase = ''
    mkdir -p $out
    cp -r ./packages $out
    cp -r ./node_modules $out
    cp ./lodestar $out
  '';

  doDist = false;

  meta = with lib; {
    homepage = "https://lodestar.chainsafe.io/";
    description = "TypeScript Implementation of Ethereum Consensus ";
    license = licenses.lgpl3;
    platforms = ["x86_64-linux"];
  };
}