{ config, lib, ... }:

{
  imports = [
    ./base.nix
    ./identities.nix
    ./shikanime.nix
    ./gouv.nix
    ./operator-6o.nix
  ];

  options.identities = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Identity configuration.";
  };
}
