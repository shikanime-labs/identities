# Identities

Nix flake modules for managing personas — git, GPG, SSH, and jj
configuration. Each identity is a separate file under
`modules/identities/`.

## Identities

- **shikanime** — Primary identity for Shikanime Studio work.
  - Git: `Shikanime Deva <william.phetsinorath@shikanime.studio>`
  - GPG: `09CA52A835C14157`
- **gouv** — Government identity.
  - Git: `William Phetsinorath <william.phetsinorath-open@interieur.gouv.fr>`
  - GPG: `0CC037FFEA0769A1`
- **operator-6o** — YoRHa operator identity.
  - Git: `Operator 6O <operator6o@shikanime.studio>`
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

Each identity (`shikanime`, `gouv`, `operator-6o`) supports:

| Option              | Type   | Description                        |
| ------------------- | ------ | ---------------------------------- |
| `enable`            | bool   | Activate this identity.            |
| `gitUserName`       | str    | Git commit author name.            |
| `gitUserEmail`      | str    | Git commit author email.           |
| `gpgSigningKey`     | str    | GPG key ID for commit signing.     |
| `sshHosts`          | attrs  | Per-host SSH configuration.        |
| `gitExtraSettings`  | attrs  | Extra git config merged on top.    |
| `jjExtraSettings`   | attrs  | Extra jj config merged on top.     |
| `pushBookmarkPrefix`| str    | jj git_push_bookmark prefix.       |

## File Structure

```
modules/identities/
├── base.nix           # Shared settings (git, jj, aliases)
├── default.nix        # Aggregator — imports all identities
├── shikanime.nix      # Primary identity
├── gouv.nix           # Government identity
└── operator-6o.nix    # YoRHa operator identity
```

## Coding Style

- Nix files: 2-space indentation, `with lib;` at top.
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
