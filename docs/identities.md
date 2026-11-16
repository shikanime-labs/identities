# Identity modules: usage, options, and file structure

Carved from the root AGENTS.md per the org progressive-disclosure standard
(https://github.com/shikanime-labs/.github — docs/progressive-disclosure.md).

## Usage

Consumer must import both `sops-nix.homeModules.default` and the identities
module:

```nix
{
  inputs.identities.url = "github:x-shikanime/identities";
  inputs.sops-nix.url = "github:mic92/sops-nix";

  outputs = { self, identities, sops-nix, home-manager, ... }: {
    homeConfigurations.user = home-manager.lib.homeConfiguration {
      modules = [
        sops-nix.homeModules.default
        identities.homeModules.default

        # Identity modules write directly to programs.git.includes
      ];
    };
  };
}
```

## Options Design

Inspired by Catppuccin/nix:

- `identities.enable` — global toggle for all identity modules
- `identities.<name>.enable` — per-identity toggle
- `identities.<name>.git.enable` / `.jj.enable` — per-tool output control
- `identities.shikanime.glab.extraConfig` — forwarded glab config merged into
  the generated config; GitLab host and token fields are fixed by the module
- `identities.homeModules.default` — option-driven home-manager module that
  exposes `identities.shikanime.enable`, `identities.gouv.enable`, and
  `identities."automata".enable`

## File Structure

```text
modules/home/
├── default.nix        # Aggregator — imports all identities
├── identities.nix     # Top-level options (global toggle, git/jj/glab)
├── shikanime.nix      # Primary identity (sops + git + jj + glab)
├── gouv.nix           # Government identity (sops + git + jj)
├── automata.nix       # YoRHa operator identity (sops + git + jj)
└── lib.nix            # sops template helpers (mkGitConfigTemplate, etc.)

secrets/
├── shikanime.enc.yaml  # Sops-encrypted PII for shikanime
├── gouv.enc.yaml       # Sops-encrypted PII for gouv
└── automata.enc.yaml # Sops-encrypted PII for automata
```

