{ pkgs, lib, ... }:

let
  tmux-super-fingers = pkgs.tmuxPlugins.mkTmuxPlugin
  {
    pluginName = "tmux-super-fingers";
    version = "unstable-2023-01-06";
    src = pkgs.fetchFromGitHub {
      owner = "artemave";
      repo = "tmux_super_fingers";
      rev = "2c12044984124e74e21a5a87d00f844083e4bdf7";
      sha256 = "sha256-cPZCV8xk9QpU49/7H8iGhQYK6JwWjviL29eWabuqruc=";
    };
  };
in
{
  enable = true;
  prefix = "C-a";
  shell = "${pkgs.zsh}/bin/zsh";
  terminal = "tmux-256color";
  historyLimit = 100000;
  package = pkgs.unstable.tmux;
  plugins = with pkgs; [
    {
      plugin = tmux-super-fingers;
      extraConfig = "set -g @super-fingers-key f";
    }
    tmuxPlugins.better-mouse-mode
    tmuxPlugins.yank
    tmuxPlugins.open
    tmuxPlugins.catppuccin
    tmuxPlugins.sensible
  ];
  extraConfig = ''
    set -g @super-fingers-key f
  '';
}

