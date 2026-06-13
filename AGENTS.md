# Identities

Nix flake modules for managing personas — git, GPG, SSH, and jj
configuration. Each identity bundles a commit author, signing key, and
host-specific SSH settings.

## Identities

- **shikanime** — Primary identity for Shikanime Studio work.
  - Git: `Shikanime Deva <william.phetsinorath@shikanime.studio>`
  - GPG: `09CA52A835C14157`
- **gouv** — Government identity.
  - Git: `William Phetsinorath <william.phetsinorath-open@interieur.gouv.fr>`
  - GPG: `0CC037FFEA0769A1`
- **operator6o** — YoRHa operator identity.
  - Git: `Operator 6O <operator6o@shikanime.studio>`
  - GPG: `5F88DB0A4256C20F`

## Usage

Add to a consumer flake:

```nix
{
  inputs.identities.url = "github:shikanime/identities";

  outputs = { self, identities, ... }: {
    # As a NixOS module:
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        identities.nixosModules.identities
        {
          identities.shikanime.enable = true;
        }
      ];
    };

    # As a home-manager module:
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

## Module Options

Each identity (`shikanime`, `gouv`, `operator6o`) supports:

| Option              | Type   | Description                        |
| ------------------- | ------ | ---------------------------------- |
| `enable`            | bool   | Activate this identity.            |
| `gitUserName`       | str    | Git commit author name.            |
| `gitUserEmail`      | str    | Git commit author email.           |
| `gpgSigningKey`     | str    | GPG key ID for commit signing.     |
| `gpgKeyFingerprint` | str?   | Full fingerprint for key import.   |
| `sshHosts`          | attrs  | Per-host SSH configuration.        |
| `gitExtraSettings`  | attrs  | Extra git config merged on top.    |
| `jjExtraSettings`   | attrs  | Extra jj config merged on top.     |
| `pushBookmarkPrefix`| str?   | jj git_push_bookmark prefix.       |

## Coding Style

- Nix files: 2-space indentation, `with lib;` at top, `mkEnableOption`
  for toggles, `mkOption` with types for all inputs.
- Commit messages: plain-text capitalized title, no conventional-commit
  prefix. Body with labels (`Design:`, `Related:`, `Closes #`).
- Run `nix fmt` before shipping.

## Stack

- 1 commit == 1 PR via ghstack.
- Amend + `ghstack` to resubmit.
- `ghstack land` on head PR to land the entire stack.
- Never `gh pr merge` (creates poisoned commits).
- Never force-push ghstack branches.

_Licensed under Apache-2.0._
