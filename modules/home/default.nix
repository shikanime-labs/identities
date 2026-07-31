{ lib, pkgs, ... }:

with lib;

let
  importApplyWithLib =
    modulePath:
    modules.importApply modulePath {
      identities-lib = pkgs.callPackage ./lib.nix { };
    };
in
{
  imports = [
    ./identities.nix
    (importApplyWithLib ./gouv.nix)
    (importApplyWithLib ./operator6o.nix)
    (importApplyWithLib ./shikanime.nix)
  ];
}
