# Identities

Nix flake modules for managing personas. Each identity provides name, email,
and key material as options, then generates includable config fragments for
git (`programs.git.includes`), Jujutsu (`jj/conf.d/`), and sapling.

**The identity modules do NOT enable or configure the VCS tools themselves.**
They only emit config fragments. The consumer is responsible for enabling
`programs.git`, `programs.jujutsu`, etc.

## Identities

- **shikanime** — Primary identity for Shikanime Studio work.
  - Config: `~/.config/jj/conf.d/shikanime.toml`, `~/.config/sapling/sapling.conf`
  - Git includes: emitted via `identities.git.includes`
- **gouv** — Government identity.
  - Git includes: emitted via `identities.git.includes` (with `gitpath` condition)
- **operator-6o** — YoRHa operator identity.
  - Git includes: emitted via `identities.git.includes` (with `gitpath` condition)

## Usage

```nix
{
  inputs.identities.url = "github:x-shikanime/identities";

  outputs = { self, identities, home-manager, ... }: {
    homeConfigurations.user = home-manager.lib.homeConfiguration {
      modules = [
        identities.homeModules.default

        # Consume the generated git includes
        ({ config, ... }: {
          programs.git.includes = config.identities.git.includes;
        })
      ];
    };
  };
}
```

## Options Design

Inspired by Catppuccin/nix:

- `identities.enable` — global toggle for all identity modules
- `identities.<name>.enable` — per-identity toggle
- `identities.<name>.git.enable` / `.jj.enable` / `.sapling.enable` — per-tool output control
- `identities.<name>.git.gitpath` — when set, scopes the git include to a path via `condition`
- `identities.git.includes` — aggregated list of all git include entries from enabled identities

## File Structure

```text
modules/
├── base.nix           # Shared types
├── default.nix        # Aggregator — imports all identities
├── identities.nix     # Top-level options (global toggle, git/jj/sapling)
├── shikanime.nix      # Primary identity (git + jj + sapling)
├── gouv.nix           # Government identity (git only)
└── operator-6o.nix    # YoRHa operator identity (git only)
```

## Commit Style

- Plain-text capitalized title, no conventional-commit prefix
- Body with labels: `Design:`, `Related:`, `Closes #`
- Keep Markdown lines wrapped at 80 columns and run `nix fmt` before shipping

## Stack

- 1 commit == 1 PR via ghstack (1 commit is 1 logical atomic change)
- The commit title **is** the PR title; the commit body **is** the PR body
- Split work into stacked PRs to keep each PR small and reviewable
- To pull down an existing stack: `ghstack checkout <PR_NUMBER>`
- To update a PR: edit files, then `jj squash` (or `git commit --amend`) into
  the **target commit** of the stack — the one that PR represents; the commit
  message updates the PR title and body automatically when resubmitted
- Resubmit with `ghstack` after squashing
- `ghstack land` on the head PR to land the entire stack
- Never `gh pr merge` (creates poisoned commits)
- Never force-push ghstack branches

## Protect `main`

- Require 1 approving review
- Require linear history (no merge commits)
- Require signed commits
- Squash+rebase merge only

_Always use worktrees when making changes. Test with `nix flake check` before
submitting._
