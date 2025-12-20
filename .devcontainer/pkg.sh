#!/usr/bin/env bash
ARG=(--extra-experimental-features 'nix-command flakes')
PKGS=(nixpkgs#texliveFull nixpkgs#go nixpkgs#inkscape)
nix profile add "${ARG[@]}" "${PKGS[@]}"