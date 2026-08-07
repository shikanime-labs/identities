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

  options.identities.automata = {
    enable = mkEnableOption "the automata identity";

    git = {
      enable = mkEnableOption "git identity includes for automata" // {
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
      enable = mkEnableOption "Jujutsu identity config for automata" // {
        default = config.identities.jj.enable;
      };

      priority = mkOption {
        default = 20;
        description = ''
          Priority of the generated Jujutsu config file for automata.
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

    ghstack = {
      enable = mkEnableOption "ghstack config for automata" // {
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
  };

  # yorha-automata is the GitHub login (automata was taken); the option and
  # docs stay on the public name automata.
  config = mkIf (cfg.enable && cfg.automata.enable) {
    sops = {
      secrets = {
        username.sopsFile = ../../secrets/automata.enc.yaml;
        email.sopsFile = ../../secrets/automata.enc.yaml;
        name.sopsFile = ../../secrets/automata.enc.yaml;
        automata-github-token.sopsFile = ../../secrets/automata.enc.yaml;
        gpg-key.sopsFile = ../../secrets/automata.enc.yaml;
        ssh-signing-key.sopsFile = ../../secrets/automata.enc.yaml;
      };

      templates = {
        "automata-git-config" = mkIf cfg.automata.git.enable (
          identities-lib.mkGitConfigTemplate {
            name = config.sops.placeholder."name";
            email = config.sops.placeholder."email";
            username = config.sops.placeholder."username";
            signingKey = config.sops.placeholder."ssh-signing-key";
            extraConfig = cfg.automata.git.extraConfig;
          }
        );

        "automata-jj-config" = mkIf cfg.automata.jj.enable (
          identities-lib.mkJujutsuConfigTemplate {
            name = config.sops.placeholder."name";
            email = config.sops.placeholder."email";
            username = config.sops.placeholder."username";
            signingKey = config.sops.placeholder."ssh-signing-key";
            extraConfig = cfg.automata.jj.extraConfig;
          }
        );

        "automata-ghstack-config" = mkIf cfg.automata.ghstack.enable (
          identities-lib.mkGhstackConfigTemplate {
            username = config.sops.placeholder."username";
            token = config.sops.placeholder."automata-github-token";
            extraConfig = cfg.automata.ghstack.extraConfig;
          }
        );
      };
    };

    programs.git.includes = mkIf cfg.automata.git.enable [
      (
        {
          path = config.lib.file.mkOutOfStoreSymlink config.sops.templates."automata-git-config".path;
        }
        // optionalAttrs (cfg.automata.git.condition != null) {
          condition = cfg.automata.git.condition;
        }
      )
    ];

    home.sessionVariables = mkIf cfg.automata.ghstack.enable {
      GHSTACKRC_PATH =
        config.lib.file.mkOutOfStoreSymlink
          config.sops.templates."automata-ghstack-config".path;
    };

    xdg.configFile."jj/conf.d/${toString cfg.automata.jj.priority}-automata.toml" =
      mkIf cfg.automata.jj.enable
        {
          source = config.lib.file.mkOutOfStoreSymlink config.sops.templates."automata-jj-config".path;
        };
  };
}
