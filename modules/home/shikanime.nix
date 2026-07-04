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

  options.identities.shikanime = {
    enable = mkEnableOption "the shikanime identity" // {
      default = false;
    };

    git = {
      enable = mkEnableOption "git identity includes for shikanime" // {
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
      enable = mkEnableOption "Jujutsu identity config for shikanime" // {
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

    ghstack = {
      enable = mkEnableOption "ghstack config for shikanime" // {
        default = config.identities.ghstack.enable;
      };

      extraConfig = mkOption {
        default = config.identities.ghstack.extraConfig;
        description = ''
          Extra ghstack config merged into the generated config.
          The GitHub identity fields are fixed by the module and cannot be
          overridden.
        '';
        type = types.attrs;
      };
    };

    glab = {
      enable = mkEnableOption "glab config for shikanime" // {
        default = config.identities.glab.enable;
      };

      extraConfig = mkOption {
        default = config.identities.glab.extraConfig;
        description = ''
          Extra glab config merged into the generated config.
          The GitLab host and token fields are fixed by the module and cannot be
          overridden.
        '';
        type = types.attrs;
      };
    };
  };

  config = mkIf (cfg.enable && cfg.shikanime.enable) {
    sops = {
      secrets = {
        shikanime-email.sopsFile = ../../secrets/shikanime.enc.yaml;
        github-token.sopsFile = ../../secrets/shikanime.enc.yaml;
        gitlab-token.sopsFile = ../../secrets/shikanime.enc.yaml;
        shikanime-gpg-key.sopsFile = ../../secrets/shikanime.enc.yaml;
        shikanime-name.sopsFile = ../../secrets/shikanime.enc.yaml;
        shikanime-ssh-signing-key.sopsFile = ../../secrets/shikanime.enc.yaml;
      };

      templates = {
        shikanime-git-config = mkIf cfg.shikanime.git.enable (
          identitiesLib.mkGitConfigTemplate {
            name = config.sops.placeholder.shikanime-name;
            email = config.sops.placeholder.shikanime-email;
            signingkey = config.sops.placeholder.shikanime-ssh-signing-key;
            extraConfig = cfg.shikanime.git.extraConfig;
          }
        );

        shikanime-jj-config = mkIf cfg.shikanime.jj.enable (
          identitiesLib.mkJujutsuConfigTemplate {
            name = config.sops.placeholder.shikanime-name;
            email = config.sops.placeholder.shikanime-email;
            signingkey = config.sops.placeholder.shikanime-ssh-signing-key;
            extraConfig = cfg.shikanime.jj.extraConfig;
          }
        );

        ghstack-config = mkIf cfg.shikanime.ghstack.enable (
          identitiesLib.mkGhstackConfigTemplate {
            name = config.sops.placeholder.shikanime-name;
            token = config.sops.placeholder.github-token;
            extraConfig = cfg.shikanime.ghstack.extraConfig;
          }
        );

        glab-cli-config = mkIf cfg.shikanime.glab.enable (
          identitiesLib.mkGlabConfigTemplate {
            name = config.sops.placeholder.shikanime-name;
            token = config.sops.placeholder.gitlab-token;
            extraConfig = cfg.shikanime.glab.extraConfig;
          }
        );
      };
    };

    programs.git.includes = mkIf cfg.shikanime.git.enable [
      (
        {
          path = config.lib.file.mkOutOfStoreSymlink config.sops.templates.shikanime-git-config.path;
        }
        // optionalAttrs (cfg.shikanime.git.condition != null) { condition = cfg.shikanime.git.condition; }
      )
    ];

    xdg.configFile."jj/conf.d/shikanime.toml" = mkIf cfg.shikanime.jj.enable {
      source = config.lib.file.mkOutOfStoreSymlink config.sops.templates.shikanime-jj-config.path;
    };

    home.sessionVariables = mkIf cfg.shikanime.ghstack.enable {
      GHSTACKRC_PATH = config.lib.file.mkOutOfStoreSymlink config.sops.templates.ghstack-config.path;
    };

    xdg.configFile."glab-cli/shikanime/config.yml" = mkIf cfg.shikanime.glab.enable {
      force = true;
      source = config.lib.file.mkOutOfStoreSymlink config.sops.templates.glab-cli-config.path;
    };
  };
}
