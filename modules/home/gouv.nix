{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.identities;
  gitIni = pkgs.formats.gitIni { };
  toml = pkgs.formats.toml { };
in
{
  imports = [
    ./identities.nix
  ];

  options.identities.gouv = {
    enable = mkEnableOption "the gouv identity" // {
      default = false;
    };

    git = {
      enable = mkEnableOption "git identity includes for gouv" // {
        default = config.identities.git.enable;
      };

      condition = mkOption {
        default = null;
        description = ''
          Optional git include condition, such as `gitpath:<path>`.
        '';
        type = types.nullOr types.str;
      };

      extraConfig = mkOption {
        default = config.identities.git.extraConfig;
        description = ''
          Extra git config merged into the generated identity include.
          Signing settings are fixed by this module and cannot be overridden.
        '';
        type = types.attrs;
      };
    };

    jj = {
      enable = mkEnableOption "Jujutsu identity config for gouv" // {
        default = config.identities.jj.enable;
      };

      extraConfig = mkOption {
        default = config.identities.jj.extraConfig;
        description = ''
          Extra Jujutsu config merged into the generated identity include.
          Signing settings are fixed by this module and cannot be overridden.
        '';
        type = types.attrs;
      };
    };
  };

  config = mkIf (cfg.enable && cfg.gouv.enable) {
    sops = {
      secrets = {
        gouv-email.sopsFile = ./../secrets/gouv.enc.yaml;
        gouv-name.sopsFile = ./../secrets/gouv.enc.yaml;
        gouv-gpg-key.sopsFile = ./../secrets/gouv.enc.yaml;
        gouv-ssh-signing-key.sopsFile = ./../secrets/gouv.enc.yaml;
      };

      templates = {
        gouv-git-config = {
          file = gitIni.generate "config" (
            recursiveUpdate {
              user = {
                email = config.sops.placeholder.gouv-email;
                name = config.sops.placeholder.gouv-name;
                signingkey = config.sops.placeholder.gouv-ssh-signing-key;
              };
              commit.gpgsign = true;
              gpg.format = "ssh";
            } cfg.gouv.git.extraConfig
          );
        };

        gouv-jj-config = {
          file = toml.generate "config.toml" (
            recursiveUpdate {
              signing = {
                backend = "ssh";
                behavior = "own";
                key = config.sops.placeholder.gouv-ssh-signing-key;
              };
              user = {
                email = config.sops.placeholder.gouv-email;
                name = config.sops.placeholder.gouv-name;
              };
            } cfg.gouv.jj.extraConfig
          );
        };
      };
    };

    programs.git.includes = mkIf cfg.gouv.git.enable [
      (
        {
          path = config.lib.file.mkOutOfStoreSymlink config.sops.templates.gouv-git-config.path;
        }
        // optionalAttrs (cfg.gouv.git.condition != null) { condition = cfg.gouv.git.condition; }
      )
    ];

    xdg.configFile."jj/conf.d/gouv.toml" = mkIf cfg.gouv.jj.enable {
      source = config.lib.file.mkOutOfStoreSymlink config.sops.templates.gouv-jj-config.path;
    };
  };
}
