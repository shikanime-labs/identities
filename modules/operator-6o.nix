# Operator 6O identity — YoRHa operator persona.
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.identities.operator-6o;

  gitConfig = pkgs.writeText "git-config-operator6o" ''
    [user]
      name = ${cfg.name}
      email = ${cfg.email}
    [commit]
      gpgsign = true
    [user]
      signingkey = ${cfg.gpgKey or ""}
  '';
in
{
  options.identities.operator-6o = {
    enable = mkEnableOption "the operator-6o identity";

    name = mkOption {
      type = types.str;
      description = "Git commit author name.";
    };

    email = mkOption {
      type = types.str;
      description = "Git commit author email.";
    };

    gpgKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "GPG signing key ID.";
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile."git/config.d/operator6o".source = gitConfig;
  };
}
