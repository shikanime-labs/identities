{ config, lib, ... }:

with lib;

{
  options.identities = {
    enable = mkEnableOption "all identity modules";

    autoEnable = mkEnableOption "Automatically enable all identity modules" // {
      default = true;
    };

    sops.enable = mkEnableOption "Enable SOPS encryption" // {
      default = config.sops.enable && config.identities.autoEnable;
    };
  };

  config = mkIf config.identities.enable {
    sops = mkIf config.sops.enable {
      settings.creation_rules = mkAfter [
        {
          path_regex = ".*";
          age =
            let
              telsha = "age1pwl9yz4k4255a4h8qz7lafce8wxhsul0cnqwmr8528fqgujlfshshv3z3g";
              nixtar = "age1um232l0h8wn9mtha2qf4f4mnf7ucjayvf5qxjvynatmasg8qg5mshekvjl";
            in
            [
              telsha
              nixtar
            ];
        }
      ];
    };
  };
}
