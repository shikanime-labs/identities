# Flake module for shikanime/identities
#
# Add to your flake.nix:
#   inputs.identities.url = "github:shikanime/identities";
#
# Then import the module and configure identities:
#   imports = [ inputs.identities.flakeModule ];
#   identities.shikanime = {
#     enable = true;
#     gitUserName = "Shikanime Deva";
#     gitUserEmail = "william.phetsinorath@shikanime.studio";
#     gpgSigningKey = "09CA52A835C14157";
#   };

{ self, lib, flake-parts-lib, ... }:

with lib;

let
  inherit (flake-parts-lib) importApply;
in
{
  options = {
    identities = mkOption {
      type = types.submodule {
        imports = [ ./default.nix ];
      };
      default = {};
      description = "Identity configuration (git, GPG, SSH, jj).";
    };
  };

  config = {
    flake = {
      # Export the identities module for direct import
      nixosModules.identities = importApply ./modules/identities/default.nix { };
      homeModules.identities = importApply ./modules/identities/default.nix { };
    };
  };
}
