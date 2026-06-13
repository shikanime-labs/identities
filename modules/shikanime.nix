# Shikanime identity — primary persona for Shikanime Studio work.
{ config, lib, ... }:

with lib;

let
  cfg = config.identities.shikanime;
in
{
  options.identities.shikanime = {
    enable = mkEnableOption "the shikanime identity";

    name = mkOption {
      type = types.str;
      default = "Shikanime Deva";
      description = "Git commit author name.";
    };

    email = mkOption {
      type = types.str;
      default = "william.phetsinorath@shikanime.studio";
      description = "Git commit author email.";
    };

    gpgKey = mkOption {
      type = types.nullOr types.str;
      default = "09CA52A835C14157";
      description = "GPG signing key ID.";
    };
  };
}
