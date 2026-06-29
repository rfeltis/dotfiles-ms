{ pkgs, ... }:

{
  # Declarative tool set for Codespace pool machines.
  # Add a package here and re-run install.sh (or `hm-switch`) to roll it out.
  home.packages = with pkgs; [
    # shell / multiplexer
    tmux

    # github + vcs
    gh
    git

    # net / fetch
    curl
    wget

    # search / nav
    ripgrep
    fd
    fzf
    tree

    # data / view
    jq
    bat
    eza

    # system
    htop
    unzip
  ];

  # Declarative tmux config so the whole pool gets the same shell ergonomics
  # (mouse support, sane scrollback) with zero manual edits.
  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    historyLimit = 50000;
    escapeTime = 10;
  };

  # Let home-manager manage itself so `home-manager` is on PATH.
  programs.home-manager.enable = true;

  # Do not change after first install; pins state-format compatibility.
  home.stateVersion = "24.11";
}
