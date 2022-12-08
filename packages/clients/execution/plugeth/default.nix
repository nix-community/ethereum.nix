{
  lib,
  makeWrapper,
  mkGeth,
  plugeth-plugins,
  runtimeShell,
  stdenv,
}: let
  inherit
    (lib)
    appendToName
    attrValues
    catAttrs
    filter
    flatten
    isDerivation
    makeBinPath
    unique
    ;

  pluggable = plugeth: let
    withPlugins = plugins: let
      actualPlugins = plugins plugeth.plugins;

      # Wrap PATH of plugins propagatedBuildInputs, plugins may have runtime dependencies on external binaries
      wrapperInputs = unique (flatten
        (catAttrs "propagatedBuildInputs"
          (builtins.filter (x: x != null) actualPlugins)));

      passthru = {
        withPlugins = newplugins:
          withPlugins (x: newplugins x ++ actualPlugins);

        full = withPlugins (p: filter isDerivation (attrValues p.actualProviders));

        # Expose wrappers around the override* functions of the plugeth
        # derivation.
        #
        # Note that this does not behave as anyone would expect if plugins
        # are specified. The overrides are not on the user-visible wrapper
        # derivation but instead on the function application that eventually
        # generates the wrapper. This means:
        #
        # 1. When using overrideAttrs, only `passthru` attributes will
        #    become visible on the wrapper derivation. Other overrides that
        #    modify the derivation *may* still have an effect, but it can be
        #    difficult to follow.
        #
        # 2. Other overrides may work if they modify the plugeth
        #    derivation, or they may have no effect, depending on what
        #    exactly is being changed.
        #
        # 3. Specifying overrides on the wrapper is unsupported.
        #
        # See nixpkgs#158620 for details.
        overrideDerivation = f:
          (pluggable (plugeth.overrideDerivation f)).withPlugins plugins;

        overrideAttrs = f:
          (pluggable (plugeth.overrideAttrs f)).withPlugins plugins;

        override = x:
          (pluggable (plugeth.override x)).withPlugins plugins;
      };
      # Don't bother wrapping unless we actually have plugins, since the wrapper will stop automatic downloading
      # of plugins, which might be counterintuitive if someone just wants a vanilla Terraform.
    in
      if actualPlugins == []
      then
        plugeth.overrideAttrs
        (orig: {passthru = orig.passthru // passthru;})
      else
        appendToName "with-plugins" (stdenv.mkDerivation {
          inherit (plugeth) name meta;

          nativeBuildInputs = [makeWrapper];

          # Expose the passthru set with the override functions
          # defined above, as well as any passthru values already
          # set on `plugeth` at this point (relevant in case a
          # user overrides attributes).
          passthru = plugeth.passthru // passthru;

          buildCommand = ''
            # TODO: This is real for Terraform provider, need to double check in plugeth

            # Create wrappers for terraform plugins because Terraform only
            # walks inside of a tree of files.
            # for providerDir in ${toString actualPlugins}
            # do
            #   for file in $(find $providerDir/plugin -type f)
            #   do
            #     relFile=''${file#$providerDir/}
            #     mkdir -p $out/$(dirname $relFile)
            #     cat <<WRAPPER > $out/$relFile
            # #!${runtimeShell}
            # exec "$file" "$@"
            # WRAPPER
            #     chmod +x $out/$relFile
            #   done
            # done

            # Create a wrapper for plugeth to point it to the plugins dir.
            mkdir -p $out/{bin,plugins}
            makeWrapper "${plugeth}/bin/geth" "$out/bin/geth" \
              --set PLUGETH_PLUGIN_DIR $out/plugins \
              --prefix PATH : "${makeBinPath wrapperInputs}"
          '';
        });
  in
    withPlugins (_: []);

  plugins = removeAttrs plugeth-plugins [
    "override"
    "overrideDerivation"
    "recurseForDerivations"
  ];
in rec {
  mkPlugeth = attrs: pluggable (mkGeth attrs);

  plugeth = mkPlugeth {
    name = "plugeth";
    version = "1.10.25.0.0";
    owner = "openrelayxyz";
    repo = "plugeth";
    sha256 = "sha256-sibt+rud2eNskC4TXbWUOCmvzpwUEdTSi/WQiu4Mwpc=";
    vendorSha256 = "sha256-xP4jbaQUB3VvyD8sktfFpTDUZVEKtskqkVb/GkTYp54=";
    bins = ["geth"];
    subPackages = ["cmd/geth"];
    patches = [./001-Load-Plugins-From-Env-Var.patch];
    passthru = {
      inherit plugins;
    };
  };
}
