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

    nixtar.enable = mkEnableOption "Nixtar";

    telsha.enable = mkEnableOption "Telsha";
  };

  config = mkIf cfg.enable {
    sops = mkIf cfg.sops.enable {
      settings.creation_rules = mkAfter [
        (recursiveUpdate {
          path_regex = ".*";
          age =
            optionals cfg.nixtar.enable [
              "age1um232l0h8wn9mtha2qf4f4mnf7ucjayvf5qxjvynatmasg8qg5mshekvjl"
            ]
            ++ optionals cfg.telsha.enable [
              "age1eak84xcr44yfqsg843rfu2xajxsyvjwh67a630htpnd0scy7yu5szjfh8d"
            ];
        } cfg.sops.extraConfig)
      ];
    };
  };
}
