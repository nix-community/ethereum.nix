{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
  superchainConfigsHook,
}:
buildGoModule rec {
  pname = "op-conductor";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-conductor/v${version}";
    fetchSubmodules = true;
    hash = "sha256-GVIJ77a5NehNjYuVt+IWXZLrHK32oxeTw1U1SrhGPqw=";
  };

  sourceRoot = "${src.name}/op-conductor";

  proxyVendor = true;
  vendorHash = "sha256-igCd1pje0js2MJXT/ZgX+IgURO7L/Cg5IV7UyUtFLV4=";

  nativeBuildInputs = [ superchainConfigsHook ];

  subPackages = [ "cmd" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=v${version}"
    "-X main.GitCommit="
    "-X main.GitDate="
  ];

  doCheck = false;

  # The binary is named 'cmd' after the package, rename to op-conductor
  postInstall = ''
    mv $out/bin/cmd $out/bin/op-conductor
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    category = "Optimism";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Optimism sequencer conductor for high-availability setups";
    homepage = "https://github.com/ethereum-optimism/optimism/tree/develop/op-conductor";
    changelog = "https://github.com/ethereum-optimism/optimism/releases";
    license = licenses.mit;
    mainProgram = "op-conductor";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
