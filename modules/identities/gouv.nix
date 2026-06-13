# Gouv identity — government persona.
# GPG: 0CC037FFEA0769A1 (expires 2027-01-19)
{ config, lib, ... }:

with lib;

let
  cfg = config.identities.gouv;
  base = import ./base.nix { inherit lib; };
in
{
  options.identities.gouv = {
    enable = mkEnableOption "the gouv identity";

    gitUserName = mkOption {
      type = types.str;
      default = "William Phetsinorath";
      description = "Git commit author name.";
    };

    gitUserEmail = mkOption {
      type = types.str;
      default = "william.phetsinorath-open@interieur.gouv.fr";
      description = "Git commit author email.";
    };

    gpgSigningKey = mkOption {
      type = types.str;
      default = "0CC037FFEA0769A1";
      description = "GPG key ID for commit signing.";
    };

    gitExtraSettings = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = "Extra git config merged on top of defaults.";
    };
  };

  config = mkIf cfg.enable {
    # The gouv identity writes a separate .gitconfig fragment.
    # Consumers source this via includeIf or GIT_CONFIG_GLOBAL.
    home.file.".gitconfig-gouv".text = ''
      [user]
        name = ${cfg.gitUserName}
        email = ${cfg.gitUserEmail}
      [commit]
        gpgsign = true
      [user]
        signingKey = ${cfg.gpgSigningKey}
    '';

    home.file.".gnupg/gouv-key-id".text = cfg.gpgSigningKey;
  };
}
