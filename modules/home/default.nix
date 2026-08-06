{ lib, pkgs, ... }:

with lib;

let
  identities-lib = pkgs.callPackage ./lib.nix { };
in
{
  imports = [
    ./identities.nix
    ./gouv.nix
    ./automata.nix
    ./shikanime.nix
  ];

  _module.args.identities-lib = identities-lib;
}
