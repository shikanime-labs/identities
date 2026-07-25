{ config, lib, ... }:

with lib;

let
  cfg = config.identities;
in
{
  options.identities = {
    enable = mkEnableOption "all identity modules";

    autoEnable = mkEnableOption "automatically enable all identity modules" // {
      default = true;
    };

    sops = {
      enable = mkEnableOption "SOPS" // {
        default = config.sops.enable && cfg.autoEnable;
      };

      extraConfig = mkOption {
        type = types.attrsOf types.raw;
        default = { };
        description = "Extra config merged into the SOPS config";
      };
    };

    ishtar = {
      enable = mkEnableOption "Ishtar";
      ageKeys = mkOption {
        type = types.listOf types.str;
        description = "Age key for Ishtar";
        default = [
          "age1vn5a6cluts3ul6ssyfajewyr58htmlqlvfjryd6y9kpjsyvk93cq5p5y73"
        ];
        readOnly = true;
      };
    };

    nixtar = {
      enable = mkEnableOption "Nixtar";
      ageKeys = mkOption {
        type = types.listOf types.str;
        description = "Age key for Nixtar";
        default = [
          "age1um232l0h8wn9mtha2qf4f4mnf7ucjayvf5qxjvynatmasg8qg5mshekvjl"
        ];
        readOnly = true;
      };
    };

    telsha = {
      enable = mkEnableOption "Telsha";
      ageKeys = mkOption {
        type = types.listOf types.str;
        description = "Age key for Telsha";
        default = [
          "age1pwl9yz4k4255a4h8qz7lafce8wxhsul0cnqwmr8528fqgujlfshshv3z3g"
        ];
        readOnly = true;
      };
    };
  };

  config = mkIf cfg.enable {
    sops = mkIf cfg.sops.enable {
      settings.creation_rules = mkAfter [
        (recursiveUpdate {
          path_regex = ".*";
          age =
            optionals cfg.ishtar.enable cfg.ishtar.ageKeys
            ++ optionals cfg.nixtar.enable cfg.nixtar.ageKeys
            ++ optionals cfg.telsha.enable cfg.telsha.ageKeys;
        } cfg.sops.extraConfig)
      ];
    };
  };
}
