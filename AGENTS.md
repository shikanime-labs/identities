# Identities

Nix flake modules for managing personas — name, email, and GPG key.
Each identity is a separate file under `modules/`.

## Identities

- **shikanime** — Primary identity for Shikanime Studio work.
  - Name: `Shikanime Deva`
  - Email: `william.phetsinorath@shikanime.studio`
  - GPG: `09CA52A835C14157`
- **gouv** — Government identity.
  - Name: `William Phetsinorath`
  - Email: `william.phetsinorath-open@interieur.gouv.fr`
  - GPG: `0CC037FFEA0769A1`
- **operator-6o** — YoRHa operator identity.
  - Name: `Operator 6O`
  - Email: `operator6o@shikanime.studio`
  - GPG: `5F88DB0A4256C20F`

## Usage

```nix
{
  inputs.identities.url = "github:shikanime/identities";

  outputs = { self, identities, home-manager, ... }: {
    homeConfigurations.user = home-manager.lib.homeConfiguration {
      modules = [
        identities.homeModules.shikanime
        # or identities.homeModules.gouv
        # or identities.homeModules.operator-6o
      ];
    };
  };
}
```

## Module Options

Each identity module (`shikanime`, `gouv`, `operator-6o`) exposes:

| Option   | Type   | Description                    |
| -------- | ------ | ------------------------------ |
| `enable` | bool   | Activate this identity.        |
| `name`   | str    | Full name for this identity.   |
| `email`  | str    | Email for this identity.       |
| `gpgKey` | str\|null | GPG signing key ID.         |

These options are consumed by the caller to configure `programs.git`, signing, etc.

## File Structure

```text
modules/
├── base.nix           # Shared types
├── default.nix        # Aggregator — imports all identities
├── shikanime.nix      # Primary identity options
├── gouv.nix           # Government identity options
└── operator-6o.nix    # YoRHa operator identity options
```

## Coding Style

- Nix files: 2-space indentation, `with lib;` at top.
- Commit messages: plain-text capitalized title, no conventional-commit prefix.
  Body with labels (`Design:`, `Related:`, `Closes #`).
- Run `nix fmt` before shipping.

## Stack

- 1 commit == 1 PR via ghstack.
- Amend + `ghstack` to resubmit.
- `ghstack land` on head PR to land the entire stack.
- Never `gh pr merge` (creates poisoned commits).
- Never force-push ghstack branches.

_Licensed under Apache-2.0._
