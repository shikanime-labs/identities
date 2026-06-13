# shikanime/identities

Nix flake modules for managing personas — git, GPG, SSH, and jj
configuration. Each identity bundles a commit author, signing key, and
host-specific SSH settings.

## Identities

| Identity     | Name                         | Email                                            | GPG Key           |
| ------------ | ---------------------------- | ------------------------------------------------ | ----------------- |
| `shikanime`  | Shikanime Deva               | `william.phetsinorath@shikanime.studio`          | `09CA52A835C14157` |
| `gouv`       | William Phetsinorath         | `william.phetsinorath-open@interieur.gouv.fr`    | `0CC037FFEA0769A1` |
| `operator6o` | Operator 6O                  | `operator6o@shikanime.studio`                    | `5F88DB0A4256C20F` |

## Quick Start

```nix
{
  inputs.identities.url = "github:shikanime/identities";

  outputs = { self, identities, nixpkgs, home-manager, ... }: {
    # NixOS
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        identities.nixosModules.identities
        { identities.shikanime.enable = true; }
      ];
    };

    # home-manager
    homeConfigurations.user = home-manager.lib.homeConfiguration {
      modules = [
        identities.homeModules.identities
        {
          identities.shikanime = {
            enable = true;
            gitUserName = "Shikanime Deva";
            gitUserEmail = "william.phetsinorath@shikanime.studio";
            gpgSigningKey = "09CA52A835C14157";
          };
        }
      ];
    };
  };
}
```

## Development

```bash
direnv allow   # or: nix develop
nix fmt        # format all files
nix flake check
```

See `AGENTS.md` for module options and coding standards.
