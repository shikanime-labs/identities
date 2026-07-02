{ config, lib, ... }:

with lib;

{
  options.identities = {
    enable = mkEnableOption "all identity modules";

    autoEnable = mkEnableOption "Automatically enable all identity modules" // {
      default = true;
    };

    git = {
      enable = mkEnableOption "git identity includes for all enabled identities" // {
        default = config.programs.git.enable && config.identities.autoEnable;
      };
      extraConfig = mkOption {
        type = types.attrs;
        default = config.programs.git.settings;
        description = "Extra configuration options for git identity";
      };
    };

    jj = {
      enable = mkEnableOption "Jujutsu identity configs for all enabled identities" // {
        default = config.programs.jujutsu.enable && config.identities.autoEnable;
      };
      extraConfig = mkOption {
        type = types.attrs;
        default = config.programs.jujutsu.settings;
        description = "Extra configuration options for Jujutsu identity";
      };
    };

    ghstack = {
      enable = mkEnableOption "ghstack config for all enabled identities" // {
        default = false;
      };
      extraConfig = mkOption {
        type = types.attrs;
        default = { };
        description = "Extra configuration options for ghstack identity";
      };
    };

    glab = {
      enable = mkEnableOption "glab config for all enabled identities" // {
        default = false;
      };
      extraConfig = mkOption {
        type = types.attrs;
        default = { };
        description = "Extra configuration options for glab identity";
      };
    };
  };
}
