# Operator 6O identity — YoRHa operator persona.
{ config, lib, ... }:

with lib;

let
  cfg = config.identities.operator-6o;
in
{
  options.identities.operator-6o = {
    enable = mkEnableOption "the operator-6o identity";

    name = mkOption {
      type = types.str;
      default = "Operator 6O";
      description = "Git commit author name.";
    };

    email = mkOption {
      type = types.str;
      default = "operator6o@shikanime.studio";
      description = "Git commit author email.";
    };

    gpgKey = mkOption {
      type = types.nullOr types.str;
      default = "5F88DB0A4256C20F";
      description = "GPG signing key ID.";
    };
  };
}
