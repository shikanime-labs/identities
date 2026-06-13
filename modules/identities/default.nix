# Identity module — defines a persona with git, GPG, and SSH configuration.
#
# Usage in a consumer flake:
#   imports = [ inputs.identities.flakeModule ];
#   identities.shikanime.enable = true;
#   identities.gouv.enable = true;
#
# Each identity exposes:
#   - git user.name / user.email
#   - GPG signing key
#   - SSH extra config (Host blocks)
#   - program-specific overrides (jj, helix, etc.)

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.identities;

  # Base git settings shared across all identities
  baseGitSettings = {
    init.defaultBranch = "main";
    pull.rebase = true;
    push.autoSetupRemote = true;
    rebase = {
      autostash = true;
      updateRefs = true;
    };
    credential.helper = "manager";
    advice.skippedCherryPicks = false;
  };

  # Base jj settings shared across all identities
  baseJjSettings = {
    git.private-commits = "description(glob:'secret:*')";
    templates = {
      commit_trailers = ''
        format_signed_off_by_trailer(self)
        ++ if(!trailers.contains_key("Change-Id"), format_gerrit_change_id_trailer(self))
      '';
    };
    revset-aliases = {
      "nulls()" = "empty() & mutable()";
      "stack()" = "stack(@)";
      "stack(x)" = "stack(x, 2)";
      "stack(x, n)" = "ancestors(reachable(x, mutable()), n)";
    };
    ui.default-command = "log";
  };

  # mkIdentity helper — creates an identity option set
  mkIdentityOpts = name: {
    ${name} = {
      enable = mkEnableOption "the ${name} identity";

      gitUserName = mkOption {
        type = types.str;
        description = "Git commit author name for this identity.";
      };

      gitUserEmail = mkOption {
        type = types.str;
        description = "Git commit author email for this identity.";
      };

      gpgSigningKey = mkOption {
        type = types.str;
        description = "GPG key ID (long form) used for commit signing.";
      };

      gpgKeyFingerprint = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Full GPG key fingerprint for import (optional).";
      };

      sshHosts = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            user = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "SSH User for this host.";
            };
            forwardX11 = mkOption {
              type = types.nullOr types.bool;
              default = null;
              description = "Whether to forward X11.";
            };
            extraOptions = mkOption {
              type = types.attrsOf types.str;
              default = {};
              description = "Extra SSH config options.";
            };
          };
        });
        default = {};
        description = "SSH host-specific configuration.";
      };

      gitExtraSettings = mkOption {
        type = types.attrsOf types.anything;
        default = {};
        description = "Extra git config settings merged on top of defaults.";
      };

      jjExtraSettings = mkOption {
        type = types.attrsOf types.anything;
        default = {};
        description = "Extra jujutsu config settings merged on top of defaults.";
      };

      pushBookmarkPrefix = mkOption {
        type = types.nullOr types.str;
        defaultValue = "${name}/push-";
        description = "jj git_push_bookmark prefix; null to omit.";
      };
    };
  };
in
{
  options.identities = mkMerge (map mkIdentityOpts [
    "shikanime"
    "gouv"
    "operator6o"
  ]);

  config = mkMerge [
    (mkIf cfg.shikanime.enable {
      programs.git = {
        enable = true;
        lfs.enable = true;
        userName = cfg.shikanime.gitUserName;
        userEmail = cfg.shikanime.gitUserEmail;
        signing = {
          key = cfg.shikanime.gpgSigningKey;
          signByDefault = true;
        };
        settings = baseGitSettings // cfg.shikanime.gitExtraSettings;
        aliases = {
          adog = "log --all --decorate --oneline --graph";
          filing = "commit --amend --signoff --no-edit --reset-author";
          poi = "commit --amend --no-edit";
          pouf = "push --force-with-lease";
          refiling = "rebase --exec 'git filing'";
          tape = "push --mirror";
        };
      };

      programs.gpg.enable = true;

      programs.jujutsu = {
        enable = true;
        settings = baseJjSettings // cfg.shikanime.jjExtraSettings // {
          inherit (cfg.shikanime) pushBookmarkPrefix;
        };
      };

      programs.ssh = {
        enable = true;
        matchBlocks = mapAttrs (host: hostCfg:
          (optionalAttrs (hostCfg.user != null) { inherit (hostCfg) user; })
          // (optionalAttrs (hostCfg.forwardX11 != null) { inherit (hostCfg) forwardX11; })
          // hostCfg.extraOptions
        ) cfg.shikanime.sshHosts;
      };
    })

    (mkIf cfg.gouv.enable {
      # The gouv identity can be activated alongside shikanime.
      # It provides an alternative git/gpg context for government work.
      # Consumers should use conditional imports or overlays to select the
      # appropriate identity per-repo.
      home.file.".gitconfig-gouv".text = ''
        [user]
          name = ${cfg.gouv.gitUserName}
          email = ${cfg.gouv.gitUserEmail}
        [commit]
          gpgsign = true
        [user]
          signingKey = ${cfg.gouv.gpgSigningKey}
      '';

      home.file.".gnupg/gouv-key-id".text = cfg.gouv.gpgSigningKey;
    })

    (mkIf cfg.operator6o.enable {
      home.file.".gitconfig-operator6o".text = ''
        [user]
          name = ${cfg.operator6o.gitUserName}
          email = ${cfg.operator6o.gitUserEmail}
        [commit]
          gpgsign = true
        [user]
          signingKey = ${cfg.operator6o.gpgSigningKey}
      '';

      home.file.".gnupg/operator6o-key-id".text = cfg.operator6o.gpgSigningKey;
    })
  ];
}
