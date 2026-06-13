# Shikanime identity — primary persona for Shikanime Studio work.
# GPG: 09CA52A835C14157 (expires 2027-05-26)
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.identities.shikanime;
  base = import ./base.nix { inherit lib; };
in
{
  options.identities.shikanime = {
    enable = mkEnableOption "the shikanime identity";

    gitUserName = mkOption {
      type = types.str;
      default = "Shikanime Deva";
      description = "Git commit author name.";
    };

    gitUserEmail = mkOption {
      type = types.str;
      default = "william.phetsinorath@shikanime.studio";
      description = "Git commit author email.";
    };

    gpgSigningKey = mkOption {
      type = types.str;
      default = "09CA52A835C14157";
      description = "GPG key ID for commit signing.";
    };

    sshHosts = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          user = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "SSH User for this host.";
          };
          forwardX11 = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = "Whether to forward X11.";
          };
          extraOptions = mkOption {
            type = types.attrsOf types.str;
            default = {};
            description = "Extra SSH config options.";
          };
        };
      });
      default = {};
      description = "SSH host-specific configuration.";
    };

    gitExtraSettings = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = "Extra git config merged on top of defaults.";
    };

    jjExtraSettings = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = "Extra jujutsu config merged on top of defaults.";
    };

    pushBookmarkPrefix = mkOption {
      type = types.str;
      default = "shikanime/push-";
      description = "jj git_push_bookmark prefix.";
    };
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      lfs.enable = true;
      userName = cfg.gitUserName;
      userEmail = cfg.gitUserEmail;
      signing = {
        key = cfg.gpgSigningKey;
        signByDefault = true;
      };
      settings = base.baseGitSettings // cfg.gitExtraSettings;
      aliases = base.baseGitAliases;
    };

    programs.gpg.enable = true;

    programs.jujutsu = {
      enable = true;
      settings = base.baseJjSettings // cfg.jjExtraSettings // {
        templates.git_push_bookmark = ''"${cfg.pushBookmarkPrefix}" ++ change_id.short()'';
      };
    };

    programs.ssh = {
      enable = true;
      matchBlocks = mapAttrs (host: hostCfg:
        (optionalAttrs (hostCfg.user != null) { inherit (hostCfg) user; })
        // (optionalAttrs (hostCfg.forwardX11 != null) { inherit (hostCfg) forwardX11; })
        // hostCfg.extraOptions
      ) cfg.sshHosts;
    };
  };
}
