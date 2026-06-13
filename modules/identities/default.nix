# Identities module — aggregates all identity submodules.
{ config, lib, ... }:

{
  imports = [
    ./shikanime.nix
    ./gouv.nix
    ./operator-6o.nix
  ];

  options.identities = lib.mkOption {
    type = lib.types.attrs;
    default = {};
    description = "Identity configuration (git, GPG, SSH, jj).";
  };
}
