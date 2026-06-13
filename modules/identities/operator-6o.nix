# Operator 6O identity — YoRHa operator persona.
# GPG: 5F88DB0A4256C20F (expires 2028-11-06)
{ config, lib, ... }:

with lib;

let
  cfg = config.identities.operator-6o;
  base = import ./base.nix { inherit lib; };
in
{
  options.identities.operator-6o = {
    enable = mkEnableOption "the operator-6o identity";

    gitUserName = mkOption {
      type = types.str;
      default = "Operator 6O";
      description = "Git commit author name.";
    };

    gitUserEmail = mkOption {
      type = types.str;
      default = "operator6o@shikanime.studio";
      description = "Git commit author email.";
    };

    gpgSigningKey = mkOption {
      type = types.str;
      default = "5F88DB0A4256C20F";
      description = "GPG key ID for commit signing.";
    };

    gitExtraSettings = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = "Extra git config merged on top of defaults.";
    };
  };

  config = mkIf cfg.enable {
    home.file.".gitconfig-operator6o".text = ''
      [user]
        name = ${cfg.gitUserName}
        email = ${cfg.gitUserEmail}
      [commit]
        gpgsign = true
      [user]
        signingKey = ${cfg.gpgSigningKey}
    '';

    home.file.".gnupg/operator6o-key-id".text = cfg.gpgSigningKey;
  };
}
