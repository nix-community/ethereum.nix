# Derivative of https://github.com/nix-community/yarn2nix/issues/143

# nix-build
# error Couldn't find any versions for "@lodestar/config" that matches "^1.7.2" in our cache (possible versions are ""). 
# This is usually caused by a missing entry in the lockfile, running Yarn without the --offline flag may help fix this issue.

{ pkgs ? import <nixpkgs> { }
, fetchFromGitHub ? pkgs.fetchFromGitHub
, mkYarnPackage ? pkgs.mkYarnPackage
, lib ? pkgs.lib
}:
let
  pname = "lodestar";
  version = "1.7.2";

  lodestarSrc = fetchFromGitHub {
    owner = "ChainSafe";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-ctJzQbmF71msj5TBj0RBoLdfsqmuh2EbkT3ZVKewRE4=";
  };

  yarnLockFixed =
    pkgs.stdenv.mkDerivation {
      name = "yarn-lock-fixed";
      src = lodestarSrc;
      buildCommand = "mkdir $out && cp ${lodestarSrc}/yarn.lock $out";
    };

  gen-lodestar = name:
    mkYarnPackage {
      name = "${name}";
      src = "${lodestarSrc}/packages/${name}";
      packageJSON = "${lodestarSrc}/packages/${name}/package.json";
      yarnLock = "${yarnLockFixed}/yarn.lock";
    };

  obj = { name = "${pname}"; version = "${version}"; };
  text = builtins.toJSON (obj // builtins.fromJSON (builtins.readFile "${lodestarSrc}/package.json"));
  packageJSON = pkgs.writeTextFile {
    name = "package.json";
    inherit text;
  };
in
mkYarnPackage {
  inherit packageJSON pname;
  src = lodestarSrc;
  name = pname;

  yarnLock = "${yarnLockFixed}/yarn.lock";
  
  workspaceDependencies = [
    (gen-lodestar "config")
    (gen-lodestar "api")
    (gen-lodestar "params")
    (gen-lodestar "types")
    (gen-lodestar "utils")
    (gen-lodestar "db")
    (gen-lodestar "fork-choice")
    (gen-lodestar "light-client")
    (gen-lodestar "reqresp")
    (gen-lodestar "state-transition")
    (gen-lodestar "validator")
    (gen-lodestar "beacon-node")
  ];

  installPhase = ''
    mkdir -p $out
    cp -r ./packages $out
    cp -r ./node_modules $out
    cp ./lodestar $out
  '';

  doDist = false;

  meta = with lib; {
    homepage = "https://lodestar.chainsafe.io/";
    description = "TypeScript Implementation of Ethereum Consensus";
    license = licenses.lgpl3;
    platforms = ["x86_64-linux"];
  };
}