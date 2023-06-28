# Getting Started

Welcome! It's great to see that you're interested in Nix and also in Ethereum.nix. These installation instructions are intended to have a basic installation of Nix on your system ready to be used alongside Ethereum.nix.

Of course, if you're a seasoned Nix user, these installation instructions can be safely skipped (as you probably know what you're doing!).

??? question "What is exactly Nix?"
    Some people might need clarification on what exactly is Nix. To clarify:

    - [Nix is a cross-platform package manager](https://zero-to-nix.com/concepts/package-management) that utilizes a purely functional deployment model where software is installed into unique directories generated through cryptographic hashes.
    - [Nix is also the name of the tool's programming language](https://zero-to-nix.com/concepts/nix-language).
    - [NixOS is a Linux distribution based on the Nix package manager](https://zero-to-nix.com/concepts/nixos).

    We recommend you have a look at the following sources to get yourself familiar with the Nix ecosystem and mechanics first before starting with Ethereum.nix:

    - [Zero to Nix](https://zero-to-nix.com/): A well-written guide with insightful information about using Nix and several important concepts.
    - [Nix Reference Manual](https://nixos.org/manual/nix/stable/): This is a more comprenhensive guide (and also more notoriosly difficult) about Nix.

## Installation

Nix, the package manager, [can be installed quite easily using the official installation script](https://nixos.org/download.html). We have left the installation instructions here for your convenience\[^1\]. Still, we recommend looking at the official source should you have more questions or want to customize the installation experience.

### On non-Nix systems (Linux, MacOS, Windows WSL2, Docker)

For some systems, there are two installation methods:

- [Multi user (always recommended)](https://nixos.org/manual/nix/stable/installation/multi-user.html).
- [Single user](https://nixos.org/manual/nix/stable/installation/single-user.html).

??? question "Which type of installation should you choose? Multi-user or Single user?"
    This depends on your requirements, but here is a short list of reasons why it's recommended the multi-user installation:

    **Pros**:

    - Better build isolation (and that is what Nix is all about).
    - Better security (a build can not write somewhere in your home).
    - Sharing builds between users.

    **Cons**:

    - Requires root to run the daemon.
    - More involved installation (creation of `nixbld*` users, installing a systemd unit, ...).
    - Harder to uninstall.

To run the installer:

=== ":simple-linux: `Linux - Multi-user installation (recommended)`"

    ```bash
    sh <(curl -L https://nixos.org/nix/install) --daemon
    ```

    !!! info
        We recommend the multi-user install if you are on Linux running [systemd](https://www.freedesktop.org/wiki/Software/systemd/), with [SELinux](https://www.redhat.com/en/topics/linux/what-is-selinux#:~:text=What%20is%20SELinux%3F-,Security%2DEnhanced%20Linux%20(SELinux)%20is%20a%20security%20architecture%20for,Article) disabled and you can authenticate with `sudo`.

=== ":simple-linux: `Linux - Single user installation`"

    ```bash
    sh <(curl -L https://nixos.org/nix/install) --no-daemon
    ```

    !!! info
        Above command will perform a single-user installation of Nix, meaning that `/nix` is owned by the invoking user. You should run this under your usual user account, not as `root`. The script will invoke sudo to create `/nix` if it doesn’t already exist.

=== ":simple-macos: `macOS`"

    ```bash
    sh <(curl -L https://nixos.org/nix/install) --daemon
    ```

=== ":simple-windows11: `Windows WSL2 - Multi-user installation`"

    ```bash
    sh <(curl -L https://nixos.org/nix/install) --daemon
    ```

    !!! info
        WSL versions 0.67.6 and above have systemd support. Follow Microsoft's systemd guide to configure it, and then install Nix using

=== ":simple-windows11: `Windows WSL2 - Single user installation`"

    ```bash
    sh <(curl -L https://nixos.org/nix/install) --no-daemon
    ```

=== ":simple-docker: `Docker`"

    Start a Docker shell with Nix:

    ```bash
    docker run -it nixos/nix
    ```

    Or start a Docker shell with Nix exposing a `workdir` directory:

    ```bash
    mkdir workdir
    docker run -it -v $(pwd)/workdir:/workdir nixos/nix
    ```

Open a new terminal session, and the nix executable should be in your `$PATH`. To verify that:

```bash
nix --version
```

This should print the version information for Nix.

### On NixOS

If you're running NixOS, you don't need to install Nix, as it's already included!

## Enable Flakes Support

Make sure [Nix Flakes](https://zero-to-nix.com/concepts/flakes) functionality is enabled to ease your operations when using Ethereum.nix.

!!! question "Are not Nix Flakes experimental?"
    Nix flakes are still in the experimental stage within Nix, and there's no defined timeline for their official launch. While we don't expect significant changes to the user interface for flakes during the experimental phase, there could still be some minor changes.s.

    We believe that enabling Flakes is the best form of learning Nix for those new to the ecosystem.

### On non-Nix systems (Linux, MacOS, Windows WSL2, Docker)

Edit (or create) either `~/.config/nix/nix.conf` or `/etc/nix/nix.conf` and add the following entry:

```txt
experimental-features = nix-command flakes
```

If the Nix installation is in multi-user mode, don’t forget to restart the `nix-daemon`.

To verify that Nix flakes are enabled just type the following on the terminal:

```bash
nix show-config | grep flakes
```

It should display what we already wrote on the config file:

```txt
experimental-features = flakes nix-command
```

### On NixOS

To do so, edit your `configuration.nix` and add the following:

=== ":octicons-file-code-16: `configuration.nix`"

```nix
{ pkgs, ... }: {
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
```

And rebuild your system closure! That's it!

## Add Ethereum.nix to your Flake registry

When dealing with Ethereum.nix, we can use of [flakes registries](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-registry.html). Flake registries are a convenience feature that allows you to refer to flakes using symbolic identifiers such as `nixpkgs`, rather than full URLs such as `git://github.com/NixOS/nixpkgs`. You can use these identifiers on the command line (e.g. when you do `nix run nixpkgs#hello`) or in flake input specifications in `flake.nix` files.

If you're curious, you can list all registries that are available in your system with the following command:

```bash
nix registry list
```

We do recommend adding Ethereum.nix to your flake registry. To do so:

```bash
nix registry add enix github:nix-community/ethereum.nix # (1)!
```

You can verify that this works by just typing the following:

```bash
nix run enix#geth -- --version
```

After a while (the first invocation, the command will take a little bit), the current version of geth should appear!

1. You can choose another alias instead of `enix`. We named it `enix` because it's short and sweet!

[^1]: Thanks to the Nix/NixOS documentation team.