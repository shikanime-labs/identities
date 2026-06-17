# Gouv identity — government persona.
# Provides identity data and generates includable git config fragments.
# Does NOT enable or configure git itself.
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.identities.gouv;

  gitIni = pkgs.formats.gitIni { };
in
{
  options.identities.gouv = {
    enable = mkEnableOption "the gouv identity";

    name = mkOption {
      description = "Full name for this identity.";
      type = types.str;
      default = "William Phetsinorath";
    };

    email = mkOption {
      description = "Email address for this identity.";
      type = types.str;
    };

    gpgKey = mkOption {
      default = null;
      description = "GPG signing key ID.";
      type = types.nullOr types.str;
    };

    sshSigningKey = mkOption {
      default = null;
      description = "SSH signing key (public).";
      type = types.nullOr types.str;
    };

    git = {
      enable = mkEnableOption "git identity includes for gouv" // {
        default = true;
      };

      gitpath = mkOption {
        default = null;
        description = ''
          If set, emit a conditional git include scoped to this path
          (via `condition = "gitpath:<value>"`). If null, the include
          is unconditional.
        '';
        type = types.nullOr types.str;
      };

      signByDefault = mkEnableOption "commit signing by default for this identity" // {
        default = true;
      };

      gpgFormat = mkOption {
        type = types.enum [ "ssh" "gpg" "x509" "openpgp" ];
        default = "gpg";
        description = "GPG format for signing.";
      };
    };
  };

  config = mkIf cfg.enable {
    identities.git.includes = mkIf cfg.git.enable [
      (
        let
          gitConfig = gitIni.generate "config" {
            gpg.format = cfg.git.gpgFormat;
            user = {
              inherit (cfg) name email;
            } // optionalAttrs (cfg.gpgKey != null) {
              signingkey = cfg.gpgKey;
            } // optionalAttrs (cfg.sshSigningKey != null) {
              signingkey = cfg.sshSigningKey;
            };
          } // optionalAttrs cfg.git.signByDefault {
            commit.gpgsign = true;
          };

          baseEntry = {
            path = config.lib.file.mkOutOfStoreSymlink gitConfig;
          };
        in
        if cfg.git.gitpath != null
        then baseEntry // { condition = "gitpath:${cfg.git.gitpath}"; }
        else baseEntry
      )
    ];
  };
}
