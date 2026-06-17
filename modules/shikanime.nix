# Shikanime identity — primary persona for Shikanime Studio work.
# Provides identity data (name, email, keys) and generates includable config
# fragments for git, Jujutsu, and sapling. Does NOT enable or configure
# the tools themselves — the consumer must enable them.
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.identities.shikanime;

  gitIni = pkgs.formats.gitIni { };
  toml = pkgs.formats.toml { };
in
{
  options.identities.shikanime = {
    enable = mkEnableOption "the shikanime identity";

    name = mkOption {
      description = "Full name for this identity.";
      type = types.str;
      default = "William Phetsinorath";
    };

    email = mkOption {
      description = "Email address for this identity.";
      type = types.str;
      default = "william.phetsinorath@shikanime.studio";
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
      enable = mkEnableOption "git identity includes for shikanime" // {
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
        default = "ssh";
        description = "GPG format for signing.";
      };
    };

    jj = {
      enable = mkEnableOption "Jujutsu identity config for shikanime" // {
        default = true;
      };

      repositories = mkOption {
        default = [ ];
        description = ''
          If non-empty, scope this identity to these repository paths
          via `[--when.repositories]`. If empty, the config is global.
        '';
        type = types.listOf types.str;
      };

      signingBackend = mkOption {
        type = types.enum [ "ssh" "gpg" ];
        default = "ssh";
        description = "Signing backend for Jujutsu.";
      };

      signingBehavior = mkOption {
        type = types.enum [ "own" "force" ];
        default = "own";
        description = "Signing behavior for Jujutsu.";
      };
    };

    sapling = {
      enable = mkEnableOption "sapling identity config for shikanime" // {
        default = true;
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

    xdg.configFile."jj/conf.d/shikanime.toml" = mkIf cfg.jj.enable {
      source =
        let
          jjConfig = toml.generate "config.toml" (
            {
              user = {
                inherit (cfg) name email;
              };
            }
            // optionalAttrs (cfg.sshSigningKey != null) {
              signing = {
                backend = cfg.jj.signingBackend;
                behavior = cfg.jj.signingBehavior;
                key = cfg.sshSigningKey;
              };
            }
            // optionalAttrs (cfg.jj.repositories != [ ]) {
              "--when.repositories" = cfg.jj.repositories;
            }
          );
        in
        config.lib.file.mkOutOfStoreSymlink jjConfig;
    };

    xdg.configFile."sapling/sapling.conf" = mkIf cfg.sapling.enable {
      source =
        let
          slConfig = (pkgs.formats.ini { }).generate "sapling.conf" {
            ui = {
              username = "${cfg.name} <${cfg.email}>";
            };
          } // optionalAttrs (cfg.gpgKey != null) {
            gpg.key = cfg.gpgKey;
          };
        in
        config.lib.file.mkOutOfStoreSymlink slConfig;
    };
  };
}
