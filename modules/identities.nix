# Top-level identities module.
{ lib, ... }:

with lib;

{
  options.identities.enable = mkEnableOption "all identity modules";
}
