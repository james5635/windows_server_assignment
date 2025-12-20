#!/env bash
ARG="--experimental-features 'nix-command flakes'"
nix profile install $ARG nixpkgs#texliveFull 