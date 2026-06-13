# Shikanime identity — primary persona for Shikanime Studio work.
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.identities.shikanime;

  gitConfig = pkgs.writeText "git-config-shikanime" ''
    [user]
      name = ${config.sops.placeholder.shikanime-name}
      email = ${config.sops.placeholder.shikanime-email}
    [commit]
      gpgsign = true
    [user]
      signingkey = ${config.sops.placeholder.shikanime-ssh-signing-key}
  '';

  jjConfig = pkgs.writeText "jj-config-shikanime.toml" ''
    [user]
    name = "${config.sops.placeholder.shikanime-name}"
    email = "${config.sops.placeholder.shikanime-email}"

    [signing]
    backend = "ssh"
    behavior = "own"
    key = "${config.sops.placeholder.shikanime-ssh-signing-key}
  '';
in
{
  options.identities.shikanime = {
    enable = mkEnableOption "the shikanime identity";
  };

  config = mkIf cfg.enable {
    sops = {
      age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
      defaultSopsFile = ./../secrets/identities.yaml;
      defaultSopsFormat = "yaml";
      secrets = {
        shikanime-name = { };
        shikanime-email = { };
        shikanime-gpg-key = { };
        shikanime-ssh-signing-key = { };
      };
    };

    xdg.configFile."git/config.d/shikanime".source = gitConfig;
    xdg.configFile."jj/conf.d/shikanime.toml".source = jjConfig;
  };
}
