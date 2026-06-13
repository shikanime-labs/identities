# Gouv identity — government persona.
{ config, lib, ... }:

with lib;

let
  cfg = config.identities.gouv;
in
{
  options.identities.gouv = {
    enable = mkEnableOption "the gouv identity";

    name = mkOption {
      type = types.str;
      default = "William Phetsinorath";
      description = "Git commit author name.";
    };

    email = mkOption {
      type = types.str;
      default = "william.phetsinorath-open@interieur.gouv.fr";
      description = "Git commit author email.";
    };

    gpgKey = mkOption {
      type = types.nullOr types.str;
      default = "0CC037FFEA0769A1";
      description = "GPG signing key ID.";
    };
  };
}
