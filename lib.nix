lib: rec {
  /*
  Function: mkNixpkgs
  Synopsis: Creates a custom Nixpkgs configuration.

  Parameters:
    - system (string): Target system, e.g., "x86_64-linux".
    - inputs (attrset, optional): Custom inputs for the Nixpkgs configuration.
    - overlays (list, optional): List of overlays to apply.
    - nixpkgs (path, optional): Path to the Nixpkgs repository. Defaults to inputs.nixpkgs.
    - config (attrset, optional): Additional Nixpkgs configuration settings.

  Returns:
    - A configured Nixpkgs environment suitable for importing.

  Example:
    mkNixpkgs {
      system = "x86_64-linux";
      overlays = [ myOverlay ];
    }

  Description:
    The function imports a Nixpkgs environment with the specified target system, custom inputs,
    and overlays. It also accepts additional Nixpkgs configuration settings.
  */
  mkNixpkgs = {
    system,
    nixpkgs,
    overlays ? [],
    config ? {allowUnfree = true;},
  }:
    import nixpkgs {inherit system config overlays;};

  /*
  Function: mkApp
  Synopsis: Creates an "app" type for Nix flakes.

  Parameters:
    - drv (derivation): The Nix derivation.
    - name (string, optional): Name of the application.
    - exePath (string, optional): Executable path.

  Returns:
    - An "app" type attribute with 'type' and 'program' keys.
  */
  mkApp = {
    drv,
    name ? drv.pname or drv.name,
    exePath ? drv.passthru.exePath or "/bin/${name}",
  }: {
    type = "app";
    program = "${drv}${exePath}";
  };

  /*
  Function: buildApps
  Synopsis: Constructs attribute set of applications from Nix packages and custom apps specification.

  Parameters:
    - packages (attrset): An attribute set of Nix packages.
    - apps (attrset): Custom apps specification.

  Returns:
    - An attribute set representing built applications.
  */
  buildApps = packages: apps:
    lib.listToAttrs
    (lib.collect (attrs: lib.attrNames attrs == ["name" "value"])
      (lib.mapAttrsRecursiveCond lib.isAttrs (path: v: let
        drvName = lib.head path;
        drv = packages.${drvName};
        name = lib.last (lib.init path);
        exePath = "/bin/${v}";
      in
        lib.nameValuePair name {inherit drv name exePath;})
      apps));

  /*
  Function: platformPkgs
  Synopsis: Filters Nix packages based on the target system platform.

  Parameters:
    - system (string): Target system platform (e.g., "x86_64-linux").

  Returns:
    - A filtered attribute set of Nix packages compatible with the target system.
  */
  platformPkgs = system:
    lib.filterAttrs
    (_: value: let
      platforms = lib.attrByPath ["meta" "platforms"] [] value;
    in
      lib.elem system platforms);

  /*
  Function: platformApps
  Synopsis: Filters and builds platform-specific applications.

  Parameters:
    - packages (attrset): An attribute set of Nix packages.
    - apps (attrset): Custom apps specification.

  Returns:
    - An attribute set of platform-specific applications.
  */
  platformApps = packages: apps: let
    apps' = lib.filterAttrs (name: _: lib.elem name (lib.attrNames packages)) apps;
    bapps = buildApps packages apps';
  in
    lib.mapAttrs (_: mkApp) bapps;

  /*
  Function: flattenTree
  Synopsis: Flattens a nested attribute set (tree) into a single-level attribute set.

  Parameters:
    - tree (attrset): A nested attribute set

  Returns:
    - An attribute set where keys are constructed in reverse DNS notation, based on the nesting.

  Example:
    Input: { a = { b = { c = <path>; }; }; }
    Output: { "a.b.c" = <path>; }

  Description:
    The function traverses the nested attribute set and produces a flattened attribute set.
    It uses dot-based reverse DNS notation to concatenate the nested keys.
  */
  flattenTree = {
    tree,
    separator ? ".",
  }: let
    op = sum: path: val: let
      pathStr = builtins.concatStringsSep separator path;
    in
      if builtins.isPath val
      then
        (sum
          // {
            "${pathStr}" = val;
          })
      else if builtins.isAttrs val
      then
        # recurse into that attribute set
        (recurse sum path val)
      else
        # ignore that value
        sum;

    recurse = sum: path: val:
      builtins.foldl'
      (sum: key: op sum (path ++ [key]) val.${key})
      sum
      (builtins.attrNames val);
  in
    recurse {} [] tree;

  /*
  Function: rakeLeaves
  Synopsis: Recursively collects `.nix` files from a directory into an attribute set.

  Parameters:
    - dirPath (string): The directory path to collect `.nix` files from.

  Returns:
    - An attribute set mapping filenames (without the `.nix` suffix) to their paths.
  */
  rakeLeaves = dirPath: let
    collect = file: type: {
      name = lib.removeSuffix ".nix" file;
      value = let
        path = dirPath + "/${file}";
      in
        if (type == "regular")
        then path
        else rakeLeaves path;
    };

    files = builtins.readDir dirPath;
  in
    lib.filterAttrs (_n: v: v != {}) (lib.mapAttrs' collect files);

  mkdocs = with lib; rec {
    /*
    Function: getBaseName
    Synopsis: Extracts the base name from a full module path.

    Parameters:
      - name (string): The full module path.

    Returns:
      - A string representing the base name of the module.

    Example:
      Input: "path.to.module"
      Output: "module"

    Description:
      The function splits the input string by dots and returns the last element,
      representing the base name of the module.
    */
    getBaseName = name: head (splitString "." name);

    /*
    Function: generateModuleDoc
    Synopsis: Generates documentation for a single module.

    Parameters:
      - value (attrset): The Nix module for which to generate documentation.

    Returns:
      - An attribute set representing the documentation of the module.

    Example:
      Input: <module-attrset>
      Output: <doc-attrset>

    Description:
      This function evaluates the module to extract its options, then transforms
      these options into a documentation-friendly format. It filters out non-visible
      and internal options.
    */
    generateModuleDoc = value: let
      options = evalModules {modules = [value];};
      docList = optionAttrSetToDocList options;
      visibleOpts = filter (opt: opt.visible && !opt.internal) docList;
      # Transform each option into a simpler attrset.
      transformOption = o: nameValuePair o.name (removeAttrs o ["name" "visible" "internal"]);
    in
      listToAttrs (map transformOption visibleOpts);

    /*
    Function: renderTableParameters
    Synopsis: Renders module parameters into a markdown table format.

    Parameters:
      - attrs (attrset): An attribute set containing the parameters of a module.

    Returns:
      - A string representing a markdown table of parameters.

    Example:
      Input: { type = "string"; description.text = "A simple parameter"; default.text = "default"; }
      Output: "| string | A simple parameter | default |"

    Description:
      Formats the given attribute set into a markdown table row, showing the type,
      description, and default value of a module parameter.
    */
    renderTableParameters = attrs: let
      type = attrs.type or "";
      description = attrs.description.text or "";
      default = attrs.default.text or "";
    in "| ${type} | ${description} | ${default} |";

    /*
    Function: generateMarkdownEntry
    Synopsis: Generates a markdown entry for a module documentation.

    Parameters:
      - name (string): The name of the module.
      - value (attrset): The documentation attribute set of the module.

    Returns:
      - A string representing the markdown documentation for the module.

    Example:
      Input: "moduleName", <module-doc-attrset>
      Output: <markdown-content>

    Description:
      Creates a markdown formatted documentation entry for a given module, including
      a code snippet and a parameter table.
    */
    generateMarkdownEntry = name: value: ''
      ## `${name}`

      **Snippet**

      ```nix
      ${name}
      ```

      **Parameter**

      | Type | Description | Default |
      | ---- | ----------- | ------- |
      ${renderTableParameters value}
    '';

    /*
    Function: createModuleDocumentation
    Synopsis: Creates markdown documentation for a collection of modules.

    Parameters:
      - docs (attrset): An attribute set where each key is a module name and its value is the module's documentation.

    Returns:
      - A string representing the concatenated markdown documentation of all modules.

    Example:
      Input: <modules-docs-attrset>
      Output: <markdown-documentation>

    Description:
      Concatenates the markdown entries of each module in 'docs' to produce a single markdown
      document representing the entire documentation.
    */
    createModuleDocumentation = docs:
      concatStringsSep "\n"
      (mapAttrsToList (name: value: let
          markdownContent = concatStringsSep "\n\n" (mapAttrsToList generateMarkdownEntry value);
        in ''
          path=$out/${strings.sanitizeDerivationName name}.md
          printf '%s' ${escapeShellArg markdownContent} > "$path"
        '')
        docs);

    /*
    Function: createNixosMarkdownDocs
    Synopsis: Generates markdown documentation for NixOS modules in a given path.

    Parameters:
      - modulesPath (string): The file path to the NixOS modules.

    Returns:
      - A string representing the markdown documentation for all modules in the specified path.

    Example:
      Input: "/path/to/modules"
      Output: <markdown-documentation>

    Description:
      This function rakes leaves to get all 'options.nix' files, flattens the tree, and then
      generates markdown documentation for each module found.
    */
    createNixosMarkdownDocs = {modulesPath}: let
      eachOptions = filterAttrs (_: hasSuffix "options.nix") (flattenTree {tree = rakeLeaves modulesPath;});
      docs = mapAttrs' (name: value: nameValuePair (getBaseName name) (generateModuleDoc value)) eachOptions;
    in
      createModuleDocumentation docs;
  };
}
