# Flake module for shikanime/identities
{ self, lib, flake-parts-lib, ... }:

with lib;

let
  inherit (flake-parts-lib) importApply;
  identitiesModule = importApply ./modules/identities/default.nix { };
in
{
  flake = {
    homeModules = {
      default = identitiesModule;
      shikanime = importApply ./modules/identities/shikanime.nix { };
      gouv = importApply ./modules/identities/gouv.nix { };
      "operator-6o" = importApply ./modules/identities/operator-6o.nix { };
    };
  };
}
