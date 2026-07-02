{ config, lib, ... }:

with lib;

{
  options.identities = {
    enable = mkEnableOption "all identity modules";

    autoEnable = mkEnableOption "automatically enable all identity modules" // {
      default = true;
    };

    sops = {
      enable = mkEnableOption "SOPS" // {
        default = config.sops.enable && config.identities.autoEnable;
      };

      extraConfig = mkOption {
        type = types.attrsOf types.raw;
        default = { };
        description = "Extra config merged into the SOPS config";
      };
    };

    nixtar.enable = mkEnableOption "Nixtar";

    telsha.enable = mkEnableOption "Telsha";
  };

  config = mkIf config.identities.enable {
    sops = mkIf config.sops.enable {
      settings.creation_rules = mkAfter [
        (recursiveUpdate {
          path_regex = ".*";
          age =
            optionals config.identities.nixtar.enable [
              "age1um232l0h8wn9mtha2qf4f4mnf7ucjayvf5qxjvynatmasg8qg5mshekvjl"
            ]
            ++ optionals config.identities.telsha.enable [
              "age1pwl9yz4k4255a4h8qz7lafce8wxhsul0cnqwmr8528fqgujlfshshv3z3g"
            ];
        } config.sops.extraConfig)
      ];
    };
  };
}
