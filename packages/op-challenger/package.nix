{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule rec {
  pname = "op-challenger";
  version = "1.9.3";

  src = fetchFromGitHub {
    owner = "ethereum-optimism";
    repo = "optimism";
    rev = "op-challenger/v${version}";
    hash = "sha256-W/xlYV05BMZB3xneZDhFKeUWbPBbrgUUdr69vdMssM8=";
  };

  sourceRoot = "${src.name}/op-challenger";

  proxyVendor = true;
  vendorHash = "sha256-Ajh5FEVtptEJLSBWQpr+pib7XTk2bSHXC5z4bh6xQGs=";

  subPackages = [ "cmd" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/ethereum-optimism/optimism/op-challenger/version.Version=v${version}"
    "-X github.com/ethereum-optimism/optimism/op-challenger/version.Meta="
  ];

  doCheck = false;

  # The binary is named 'cmd' after the package, rename to op-challenger
  postInstall = ''
    mv $out/bin/cmd $out/bin/op-challenger
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    category = "Optimism";
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Optimism fault proof challenger service that monitors and disputes invalid claims";
    homepage = "https://github.com/ethereum-optimism/optimism/tree/develop/op-challenger";
    license = licenses.mit;
    mainProgram = "op-challenger";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.fromSource ];
  };
}
