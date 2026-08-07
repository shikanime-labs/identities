{
  config,
  lib,
  identities-lib,
  ...
}:

with lib;

let
  cfg = config.identities;
in
{
  imports = [
    ./identities.nix
  ];

  options.identities.gouv = {
    enable = mkEnableOption "the gouv identity";

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

      priority = mkOption {
        default = 20;
        description = ''
          Priority of the generated Jujutsu config file for gouv.
        '';
        type = types.int;
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
        username.sopsFile = ../../secrets/gouv.enc.yaml;
        email.sopsFile = ../../secrets/gouv.enc.yaml;
        name.sopsFile = ../../secrets/gouv.enc.yaml;
        gpg-key.sopsFile = ../../secrets/gouv.enc.yaml;
        ssh-signing-key.sopsFile = ../../secrets/gouv.enc.yaml;
      };

      templates = {
        gouv-git-config = mkIf cfg.gouv.git.enable (
          identities-lib.mkGitConfigTemplate {
            email = config.sops.placeholder.email;
            name = config.sops.placeholder.name;
            username = config.sops.placeholder.username;
            signingKey = config.sops.placeholder.ssh-signing-key;
            extraConfig = cfg.gouv.git.extraConfig;
          }
        );

        gouv-jj-config = mkIf cfg.gouv.jj.enable (
          identities-lib.mkJujutsuConfigTemplate {
            name = config.sops.placeholder.name;
            email = config.sops.placeholder.email;
            username = config.sops.placeholder.username;
            signingKey = config.sops.placeholder.ssh-signing-key;
            extraConfig = cfg.gouv.jj.extraConfig;
          }
        );
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

    xdg.configFile."jj/conf.d/${toString cfg.gouv.jj.priority}-gouv.toml" = mkIf cfg.gouv.jj.enable {
      source = config.lib.file.mkOutOfStoreSymlink config.sops.templates.gouv-jj-config.path;
    };
  };
}
