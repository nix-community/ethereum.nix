<div align="center" style="margin-top: 1em; margin-bottom: 3em;">
  <h1>ethereum.nix = Ethereum 🫶 Nix</h1>
</div>

<p align="center">
  <a href="https://ethereum.org/">
    <img src="https://img.shields.io/static/v1?label=&labelColor=1B1E36&color=1B1E36&message=ethereum%20ecosystem&style=for-the-badge&logo=data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz48c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjQwIiBoZWlnaHQ9IjQwIiB2aWV3Qm94PSIwIDAgNDAgNDAiIGZpbGw9Im5vbmUiIHZlcnNpb249IjEuMiIgYmFzZVByb2ZpbGU9InRpbnktcHMiPjx0aXRsZT5FdGhlcmV1bSBsb2dvPC90aXRsZT48cGF0aCBkPSJNOSAyMi4xMTZMMTkuOTk5OSAyOS4wNDI0VjM4LjAwMDIiIGZpbGw9IiM1M0QzRTAiPjwvcGF0aD48cGF0aCBkPSJNMzAuOTk5OSAyMi4xMTZMMjAgMjkuMDQyNFYzOC4wMDAyIiBmaWxsPSIjNUE5REVEIj48L3BhdGg+PHBhdGggZD0iTTkgMTkuODc3NUwxOS45OTk5IDEzLjY5ODVWMUw5IDE5Ljg3NzVaIiBmaWxsPSIjRkZFOTREIj48L3BhdGg+PHBhdGggZD0iTTE5Ljk5OTkgMjYuODAzOVYxMy42OTg1TDkgMTkuODc3NUwxOS45OTk5IDI2LjgwMzlaIiBmaWxsPSIjQTdERjdFIj48L3BhdGg+PHBhdGggZD0iTTIwIDFWMTMuNjk4NUwzMC45OTk5IDE5Ljg3NzVMMjAgMVoiIGZpbGw9IiNGRjlDOTIiPjwvcGF0aD48cGF0aCBkPSJNMjAgMTMuNjk4NVYyNi44MDM5TDMwLjk5OTkgMTkuODc3NUwyMCAxMy42OTg1WiIgZmlsbD0iI0Q3OTdEMSI+PC9wYXRoPjwvc3ZnPg==" alt="Ethereum Ecosystem"/>
  </a>
  <a href="https://nixos.org/">
    <img src="https://img.shields.io/static/v1?logo=nixos&logoColor=white&label=&message=Built%20with%20Nix&color=41439a&style=for-the-badge" alt="Built with nix" />
  </a>
  <a href="https://github.com/nix-community/ethereum.nix/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-MIT%20v3.0-brightgreen.svg?style=for-the-badge" alt="License" />
  </a>
</p>

This is an experimental Nix project for integrating the most interesting / important projects in the Ethereum ecosystem as Nix packages / NixOS modules.

Many of the packages found on `ethereum.nix` will be added to `nixpkgs` repository once they're stable / mature enough. But for some others, more experimental ones, they can reside here.

This project is developed entirely in [Nix Flakes](https://nixos.wiki/wiki/Flakes) (but it offers compatiblity with legacy Nix thanks to [`flake-compat`](https://github.com/nix-community/flake-compat)).

## Documentation

We recommend you [to have a look at our documentation](https://nix-community.github.io/ethereum.nix/) that shows how to use `ethereum.nix` effectively.

Any PR improving documentation is welcomed.

## Development

We are using [`devshell`](https://github.com/numtide/devshell) to have nice development environments. When prompted run `direnv allow` and you will then be met with the following prompt:

```bash
🔨 Welcome to ethereum.nix

[Docs]

  docs-build - Build docs
  docs-serve - Serve docs

[Testing]

  test       - Build and run a test

[Tools]

  fmt        - Format the source tree

[general commands]

  menu       - prints this menu

direnv: export +DEVSHELL_DIR +IN_NIX_SHELL +NIXPKGS_PATH +PRJ_DATA_DIR +PRJ_ROOT +name ~PATH ~XDG_DATA_DIRS
```

### Requirements

To make the most of this repo you should have the following installed:

- [Nix](https://nixos.org/)
- [Direnv](https://direnv.net/)

### Docs

To build the docs locally run `docs-build`. The output will be inside of `./result`.

To serve the docs locally (after building them previously) run `docs-serve`. You can edit the docs in `./docs`.

### Running tests

To run all tests you can use `check` (alias for `nix flake check`), it will build all packages and run all tests.

To execute a specific test you can use `test -h` which will provide more information.

### Formatting

You can manually format the source using the `fmt` command.

## Contribute

We welcome any kind of contribution or support to this project but before to do so:

- Make sure you have read the [contribution guide](/.github/CONTRIBUTING.md) for more details on how to submit a good PR (pull request).

In addition you can always:

- Add a [GitHub Star 🌟](https://github.com/nix-community/ethereum.nix/stargazers) to the project.
- Tweet about this project.

## Acknowledgements

This project has been inspired by the awesome work of:

- [`cosmos.nix`](https://github.com/informalsystems/cosmos.nix) by [Informal Systems](https://github.com/informalsystems) which this repository takes inspiration on it's README and several other places.

- [willruggiano](https://github.com/willruggiano) on his work done in [`eth-nix`](https://github.com/willruggiano/eth-nix) repository that served as the initial kick-start for working on this project.
