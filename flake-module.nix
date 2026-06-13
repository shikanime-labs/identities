# Flake module for shikanime/identities
{ lib, flake-parts-lib, ... }:

with lib;

let
  inherit (flake-parts-lib) importApply;
  identitiesModule = importApply ./modules/default.nix { };
in
{
  flake = {
    homeModules = {
      default = identitiesModule;
      shikanime = importApply ./modules/shikanime.nix { };
      gouv = importApply ./modules/gouv.nix { };
      "operator-6o" = importApply ./modules/operator-6o.nix { };
    };
  };
}
