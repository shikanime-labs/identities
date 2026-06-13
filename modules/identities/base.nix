# Shared identity types and helpers used by all identity modules.
{ lib, ... }:

with lib;

{
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

  # Common git aliases
  baseGitAliases = {
    adog = "log --all --decorate --oneline --graph";
    filing = "commit --amend --signoff --no-edit --reset-author";
    poi = "commit --amend --no-edit";
    pouf = "push --force-with-lease";
    refiling = "rebase --exec 'git filing'";
    tape = "push --mirror";
  };
}
