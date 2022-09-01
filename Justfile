# just is a handy way to save and run project-specific commands.
#
# https://github.com/casey/just

# list all tasks
default:
  just --list

# Format the code
fmt:
  treefmt
alias f := fmt

# Cleans any result produced by Nix or associated tools
clean:
  rm -rf result*
alias c := clean

# Build an app
nix-build APP:
  nix build .#{{APP}}