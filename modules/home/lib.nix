{ lib, pkgs, ... }:

with lib;

let
  gitIni = pkgs.formats.gitIni { };
  ini = pkgs.formats.ini { };
  toml = pkgs.formats.toml { };
  yaml = pkgs.formats.yaml { };
in
{
  mkGitConfigTemplate =
    {
      name,
      email,
      signingKey,
      extraConfig,
    }:
    {
      file = gitIni.generate "${name}-gitconfig" (
        recursiveUpdate {
          user = {
            inherit email name;
            signingkey = signingKey;
          };
          commit.gpgsign = true;
          gpg.format = "ssh";
        } extraConfig
      );
    };

  mkJujutsuConfigTemplate =
    {
      name,
      email,
      signingKey,
      extraConfig,
    }:
    {
      file = toml.generate "${name}-jujutsu-config" (
        recursiveUpdate {
          git.sign-on-push = true;
          signing = {
            backend = "ssh";
            behavior = "own";
            key = signingKey;
          };
          user = {
            inherit email name;
          };
        } extraConfig
      );
    };

  mkGhstackConfigTemplate =
    {
      name,
      token,
      extraConfig,
    }:
    {
      file = ini.generate "${name}-ghstackrc" (
        recursiveUpdate {
          ghstack = {
            github_oauth = token;
            github_url = "github.com";
            github_username = name;
          };
        } extraConfig
      );
      mode = "0640";
    };

  mkGlabConfigTemplate =
    {
      name,
      token,
      extraConfig,
    }:
    {
      file = yaml.generate "${name}-glabrc" (
        recursiveUpdate {
          git_protocol = "https";
          hosts.gitlab.com = {
            api_host = "gitlab.com";
            api_protocol = "https";
            inherit token;
          };
        } extraConfig
      );
    };
}
