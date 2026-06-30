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
    historyLimit = 50000;
    escapeTime = 10;

    # Fix copy/paste when SSH'd into a mouse-enabled tmux: push selections to
    # the *local* clipboard via OSC 52. Bind in both the emacs (copy-mode) and
    # vi (copy-mode-vi) tables so the fix works regardless of keyMode.
    extraConfig = ''
      # Send tmux copies to the system clipboard via OSC 52 (works over SSH).
      set -g set-clipboard on

      # Mouse drag release: copy selection to the clipboard.
      bind -T copy-mode    MouseDragEnd1Pane send -X copy-selection-and-cancel
      bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-selection-and-cancel

      # Keyboard copy-mode yank to the system clipboard.
      bind -T copy-mode    M-w send -X copy-selection-and-cancel
      bind -T copy-mode-vi y   send -X copy-selection-and-cancel
    '';
  };

  # Let home-manager manage itself so `home-manager` is on PATH.
  programs.home-manager.enable = true;

  # Do not change after first install; pins state-format compatibility.
  home.stateVersion = "24.11";
}
