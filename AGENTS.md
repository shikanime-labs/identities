# Identities

Nix flake modules for managing personas. Each identity declares its own sops
secrets for PII (name, email) and, where needed, an SSH signing key, then
generates includable config fragments via sops templates.

**The identity modules do NOT enable or configure the VCS tools themselves.**
They only emit config fragments. The consumer is responsible for enabling
`programs.git`, `programs.jujutsu`, etc.

## Identities

- **shikanime** — Primary identity for Shikanime Studio work.
  - Sops secrets: `shikanime-name`, `shikanime-email`, `shikanime-gpg-key`,
    `shikanime-ssh-signing-key`, `shikanime-github-token`,
    `shikanime-gitlab-token`
  - Sops file: `secrets/shikanime.enc.yaml`
  - Output: git includes, `jj/conf.d/shikanime.toml`
- **gouv** — Government identity.
  - Sops secrets: `gouv-name`, `gouv-email`, `gouv-gpg-key`,
    `gouv-ssh-signing-key`
  - Sops file: `secrets/gouv.enc.yaml`
  - Output: git includes (scoped via `git.condition`), `jj/conf.d/gouv.conf`
- **automata** — YoRHa operator identity (`yorha-automata` GitHub login).
  - Sops secrets: `automata-name`, `automata-email`, `automata-gpg-key`,
    `automata-ssh-signing-key`
  - Sops file: `secrets/automata.enc.yaml`
  - Output: git includes (scoped via `git.condition`), `jj/conf.d/automata.toml`

## Usage and module design

Consumer wiring, options, and the file tree live in docs/identities.md —
read it before changing module options or adding an identity.

## Sops

Secrets are encrypted with age key
`age1pwl9yz4k4255a4h8qz7lafce8wxhsul0cnqwmr8528fqgujlfshshv3z3g`. Edit with:
`sops secrets/<name>.enc.yaml`

## Coding Style

- Nix files: 2-space indentation, `with lib;` at top.
- Commit messages: plain-text capitalized title, no conventional-commit prefix.
- Nix: dotted assignment (`a.b.c = v;`) for a single leaf under a shared
  parent key; a record literal once two or more keys share the parent, keys
  sorted
- Run `nix fmt` before shipping.

## Environment

This repository ships a `.envrc` for direnv. Run `direnv allow` once after
cloning; direnv then loads the Nix flake dev shell automatically on every
directory change (`.envrc` runs
`use flake . --accept-flake-config --no-pure-eval`). Without direnv, enter
the same shell manually with `nix develop`.

## PR Workflow

- Bot PRs: the reviewer takes the lead — the bot author never acts on
  review comments, so apply the verdict at review time (merge clean PRs,
  fix or close broken ones) instead of commenting and waiting.
