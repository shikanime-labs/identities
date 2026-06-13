# Gouv identity — government persona.
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.identities.gouv;

  gitConfig = pkgs.writeText "git-config-gouv" ''
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
  options.identities.gouv = {
    enable = mkEnableOption "the gouv identity";

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
    xdg.configFile."git/config.d/gouv".source = gitConfig;
  };
}
