![hero-image](./assets/hero-image.jpeg){ loading=lazy }

## What is Ethereum.nix?

Ethereum.nix is a collection of [Nix](https://nixos.org) packages and [NixOS](https://wiki.nixos.org/wiki/NixOS_modules) modules
designed to make it easier to operate [Ethereum](https://ethereum.org) related services and infrastructure.

For the uninitiated, using Ethereum.nix will give you the following benefits:

- Access to a wide range of Ethereum applications packaged with Nix, ready to run without fuss. Nix guarantees you don't have to worry about version conflicts, missing dependencies or even what state your OS is in.
- We aim that every Ethereum application stored in the repository is constructed from its source, including all input dependencies. This approach guarantees the code's reproducibility and trustworthiness. Furthermore, with Nix, expert users can tweak and adjust the build process to any degree of detail as required.
- We develop custom NixOS modules to streamline operations with applications such as Execution and Consensus clients (including performing backups). Moreover, we aim to introduce further abstractions that simplify everyday tasks, such as running a production grade Liquid Staking deployment or even a local development environment for running consensus clients and execution clients effortlessly without needing [Docker](https://www.docker.com/) or [Kubernetes](https://kubernetes.io/).

This project is developed entirely in [Nix Flakes](https://wiki.nixos.org/wiki/Flakes) (but it offers compatibility with legacy Nix thanks to [`flake-compat`](https://github.com/nix-community/flake-compat)).

## Eager to use Ethereum.nix?

::cards::cols=2

- title: :material-information:{ .lg .middle } New to Ethereum.nix and Nix?
  content: |
    <br/>
    Get started by installing Nix on your system and how to use it with Ethereum.nix
    <br/>
    <br/>
    [Getting Started :octicons-arrow-right-24:](./getting-started.md){ .md-button }

- title: :material-apps-box:{ .lg .middle } Want to use an application now?
  content: |
    <br />
    See our list of supported applications ready to be used in seconds.
    <br />
    <br />
    [See supported Applications :octicons-arrow-right-24:](./apps.md){ .md-button }

- title: :simple-nixos:{ .lg .middle } Want to run Ethereum services on NixOS?
  content: |
    <br />
    Run Ethereum services easily with our supported NixOS modules.
    <br />
    <br />
    [Run Ethereum services on NixOS :octicons-arrow-right-24:](./nixos/installation.md){ .md-button }

- title: :material-chat-question:{ .lg .middle } Have a question or need help?
  content: |
    <br />
    Ask questions on our discussion board and get in touch with our community.
    <br />
    <br />
    [Ask a question :octicons-arrow-right-24:](https://github.com/nix-community/ethereum.nix/discussions){ .md-button }

::/cards::

## About the project

In the beginning Ethereum.nix was a playground for [Aldo Borrero](https://aldoborrero.com/) to experiment with _nix'ifying_
Ethereum related processes. Since then, the project got accepted by the [Nix Community incubator program](https://github.com/nix-community)
and it has a grown into an ever-increasing number of packages and modules targeted towards streamlining day-to-day operations across a variety of different projects.

::cards::
- title: Aldo Borrero
  content: |
    Creator of Ethereum.nix
    <br/>
    <br/>
    Full Stack freak! Blockchain passionate!
  image: https://avatars.githubusercontent.com/u/82811?v=4
  url: https://github.com/aldoborrero
- title: Brian McGee
  content: |
    Maintainer of Ethereum.nix
    <br/>
    <br/>
    Writer of software • Lover of craft beer
  image: https://avatars.githubusercontent.com/u/1173648?v=4
  url: https://github.com/brianmcgee
- title: Sergey Yakovlev
  content: |
    Maintainer of Ethereum.nix
    <br/>
    <br/>
    Love Nix, Rust, Ethereum | SRE
  image: https://avatars.githubusercontent.com/u/2993917?v=4
  url: https://github.com/selfuryon
::/cards::

## Commercial Support?

Are you seeking to use Ethereum.nix effectively within your organization for Blockchain related projects?

Below you can see the list of companies that offers support to Ethereum.nix, Nix and NixOS ecosystem:

### Numtide

![Numtide logo](https://codahosted.io/docs/6FCIMTRM0p/blobs/bl-sgSunaXYWX/077f3f9d7d76d6a228a937afa0658292584dedb5b852a8ca370b6c61dabb7872b7f617e603f1793928dc5410c74b3e77af21a89e435fa71a681a868d21fd1f599dd10a647dd855e14043979f1df7956f67c3260c0442e24b34662307204b83ea34de929d)

[Numtide](https://numtide.com) is a team of independent freelancers that love open source.
We help our customers make their project lifecycles more efficient by:

- Providing and supporting useful tools such as this one.
- Building and deploying infrastructure, and offering dedicated DevOps support.
- Building their in-house Nix skills, and integrating Nix with their workflows.
- Developing additional features and tools.
- Carrying out custom research and development.
- In the case of Blockchain building resilient systems and infrastructure to MEV services.

[Contact us](https://numtide.com/contact) if you have a project in mind, or if
you need help with any of our supported tools, including this one. We'd love to
hear from you.

