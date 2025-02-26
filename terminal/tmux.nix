{ config, pkgs, lib, ... }: {
  programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    baseIndex = 1;
    keyMode = "vi";
    escapeTime = 0;
    terminal = "tmux-256color";
    historyLimit = 2000;
    plugins = with pkgs.tmuxPlugins; [
      tmux-powerline # Add tmux-powerline plugin
      continuum # Add tmux-continuum plugin
      fzf-tmux-url # Optional: For fzf integration
    ];

    extraConfig = ''
      # Basic Settings
      set -g mouse on
      set -g status on  # Ensure the status bar is enabled
      set -g status-position top
      setw -g aggressive-resize off
      setw -g clock-mode-style 12
      set -g status-keys vi
      set -ga terminal-features ',xterm-256color:RGB'

      # Vim-style navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Set prefix to Ctrl + Space
      unbind C-b
      set -g prefix C-Space
      bind C-Space send-prefix

      # Prefix + r to rename window
      bind r command-prompt -I "#W" "rename-window '%%'"

      # Vi copy mode
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "${
        if config.services.xserver.enable then
          "xclip -in -selection clipboard"
        else
          "wl-copy"
      }"

      # Split panes
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Load tmux-powerline
      run-shell ${pkgs.tmuxPlugins.tmux-powerline}/share/tmux-plugins/tmux-powerline/powerline.tmux

      # Customize tmux-powerline to show session and git branch on the left
      set -g @powerline-segments-left "session hostname git"
      set -g @powerline-segments-right "pwd date"

      # tmux-continuum configuration
      set -g @continuum-restore 'on'               # Enable automatic restore
      set -g @continuum-save-interval '15'         # Save session every 15 minutes

      # Key binding to switch between sessions in the background
      bind-key -r s choose-session
      bind-key -r C-s choose-session

      # Optional: Use fzf to switch between sessions
      bind-key -r f run-shell "tmux list-sessions | fzf --reverse | cut -d: -f1 | xargs tmux switch-client -t"
    '';
  };

  environment.systemPackages = with pkgs; [
    tmux
    coreutils # Ensure basic utilities are available
    fzf # Required for fzf-based session switching
    (if config.services.xserver.enable then xclip else wl-clipboard)
  ];
}
