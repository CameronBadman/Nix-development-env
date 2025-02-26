{ config, pkgs, lib, ... }:

with lib;

let
  isDarwin = pkgs.stdenv.isDarwin;
  getClipboardCmd = if isDarwin then
    "pbcopy"
  else if config.services.xserver.enable or false then
    "${pkgs.xclip}/bin/xclip -in -selection clipboard"
  else
    "${pkgs.wl-clipboard}/bin/wl-copy";
    
  # Common TMux configuration for both NixOS module and home-manager
  tmuxConfig = ''
    # Basic Settings
    set -g mouse on
    set -g status on
    set -g status-position top
    set -g status-keys vi
    set -ga terminal-features ',xterm-256color:RGB'
    
    # Vim-style navigation
    bind h select-pane -L
    bind j select-pane -D
    bind k select-pane -U
    bind l select-pane -R
    
    # Set prefix to Ctrl + Space
    unbind C-b
    set -g prefix C-Space
    
    # Vi copy mode
    bind-key -T copy-mode-vi v send-keys -X begin-selection
    bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "${getClipboardCmd}"
    
    # Split panes
    bind | split-window -h -c "#{pane_current_path}"
    bind - split-window -v -c "#{pane_current_path}"
    
    # tmux-continuum configuration
    set -g @continuum-restore 'on'
    
    ${optionalString isDarwin ''
      # macOS-specific settings
      set -g default-command "${pkgs.reattach-to-user-namespace}/bin/reattach-to-user-namespace -l $SHELL"
    ''}
  '';
  
  # Common plugins for both NixOS and home-manager
  tmuxPlugins = with pkgs.tmuxPlugins; [
    tmux-powerline
    continuum
    fzf-tmux-url
  ];
in {
  # Common packages for both platforms
  environment.systemPackages = with pkgs; [
    tmux
    fzf
  ] ++ (if isDarwin then [ reattach-to-user-namespace ] 
       else if config.services.xserver.enable or false then [ xclip ]
       else [ wl-clipboard ]);
  
  # NixOS-specific configuration
  programs = mkIf (!isDarwin) {
    tmux = {
      enable = true;
      baseIndex = 1;
      keyMode = "vi";
      escapeTime = 0;
      terminal = "tmux-256color";
      historyLimit = 2000;
      plugins = tmuxPlugins;
      extraConfig = tmuxConfig;
    };
  };
  
  # Home-manager integration (if available)
  home-manager.users = mkIf (config.home-manager.users != {} or false) (
    mapAttrs (username: userConfig: {
      programs.tmux = {
        enable = true;
        baseIndex = 1;
        keyMode = "vi";
        escapeTime = 0;
        terminal = "tmux-256color";
        historyLimit = 2000;
        plugins = tmuxPlugins;
        extraConfig = tmuxConfig;
      };
    }) (config.home-manager.users or {})
  );
}
