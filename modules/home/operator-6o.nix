{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.identities;
  identitiesLib = pkgs.callPackage ./lib.nix { };
in
{
  imports = [
    ./identities.nix
  ];

  options.identities.operator-6o = {
    enable = mkEnableOption "the operator-6o identity" // {
      default = false;
    };

    git = {
      enable = mkEnableOption "git identity includes for operator-6o" // {
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
      enable = mkEnableOption "Jujutsu identity config for operator-6o" // {
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

  config = mkIf (cfg.enable && cfg.operator-6o.enable) {
    sops = {
      secrets = {
        operator6o-email.sopsFile = ../../secrets/operator6o.enc.yaml;
        operator6o-name.sopsFile = ../../secrets/operator6o.enc.yaml;
        operator6o-gpg-key.sopsFile = ./../secrets/operator6o.enc.yaml;
        operator6o-ssh-signing-key.sopsFile = ./../secrets/operator6o.enc.yaml;
      };

      templates = {
        operator6o-git-config = mkIf cfg.operator-6o.git.enable (
          identitiesLib.mkGitConfigTemplate {
            name = config.sops.placeholder.operator6o-name;
            email = config.sops.placeholder.operator6o-email;
            signingkey = config.sops.placeholder.operator6o-ssh-signing-key;
            extraConfig = cfg.operator-6o.git.extraConfig;
          }
        );

        operator6o-jj-config = mkIf cfg.operator-6o.jj.enable (
          identitiesLib.mkJujutsuConfigTemplate {
            name = config.sops.placeholder.operator6o-name;
            email = config.sops.placeholder.operator6o-email;
            signingkey = config.sops.placeholder.operator6o-ssh-signing-key;
            extraConfig = cfg.operator-6o.jj.extraConfig;
          }
        );
      };
    };

    programs.git.includes = mkIf cfg.operator-6o.git.enable [
      (
        {
          path = config.lib.file.mkOutOfStoreSymlink config.sops.templates.operator6o-git-config.path;
        }
        // optionalAttrs (cfg.operator-6o.git.condition != null) {
          condition = cfg.operator-6o.git.condition;
        }
      )
    ];

    xdg.configFile."jj/conf.d/operator6o.toml" = mkIf cfg.operator-6o.jj.enable {
      source = config.lib.file.mkOutOfStoreSymlink config.sops.templates.operator6o-jj-config.path;
    };
  };
}
