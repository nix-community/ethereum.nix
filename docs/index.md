![hero-image](./assets/hero-image.jpeg){ loading=lazy }

## What is Ethereum.nix?

Ethereum.nix is a collection of [Nix](https://nixos.org) packages and [NixOS](https://nixos.wiki/wiki/NixOS_modules) modules
designed to make it easier to operate [Ethereum](https://ethereum.org) related services and infrastructure.

For the uninitiated, using Ethereum.nix will give you the following benefits:

- Access to a wide range of Ethereum applications packaged with Nix, ready to run without fuss. Nix guarantees you don't have to worry about version conflicts, missing dependencies or even what state your OS is in.
- We aim that every Ethereum application stored in the repository is constructed from its source, including all input dependencies. This approach guarantees the code's reproducibility and trustworthiness. Furthermore, with Nix, expert users can tweak and adjust the build process to any degree of detail as required.
- We develop custom NixOS modules to streamline operations with applications such as Execution and Consensus clients (including performing backups). Moreover, we aim to introduce further abstractions that simplify everyday tasks, such as running a production grade Liquid Staking deployment or even a local development environment for running consensus clients and execution clients effortlessly without needing [Docker](https://www.docker.com/) or [Kubernetes](https://kubernetes.io/).

This project is developed entirely in [Nix Flakes](https://nixos.wiki/wiki/Flakes) (but it offers compatibility with legacy Nix thanks to [`flake-compat`](https://github.com/nix-community/flake-compat)).

## Eager to use Ethereum.nix?

#### :material-information:{ .lg .middle } __New to Ethereum.nix and Nix?__

Get started by installing Nix on your system and how to use it with Ethereum.nix.

[Getting Started :octicons-arrow-right-24:](./getting-started/installation.md){ .md-button }

#### :material-apps-box:{ .lg .middle } __Want to use an application?__

See our list of supported applications ready to be used in seconds.

[See supported Applications :octicons-arrow-right-24:](./apps.md){ .md-button }

#### :simple-nixos:{ .lg .middle } __Want to run Ethereum services on NixOS?__

Run Ethereum services easily with our supported NixOS modules.

[Run Ethereum services on NixOS :octicons-arrow-right-24:](./nixos/installation.md){ .md-button }

#### :material-chat-question:{ .lg .middle } __Have a question or need help?__

Ask questions on our discussion board and get in touch with our community.

[Ask a question :octicons-arrow-right-24:](https://github.com/nix-community/ethereum.nix/discussions){ .md-button }

## About the project

In the beginning Ethereum.nix was a playground for [Aldo Borrero](https://aldoborrero.com/) to experiment with _nix'ifying_
Ethereum related processes. Since then, it has a grown into an ever-increasing number of packages and modules targeted towards
streamlining day-to-day operations across a variety of different projects.
