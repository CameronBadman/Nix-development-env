{ config, pkgs, lib, ... }: {
  imports = [ ./tmux.nix ./alacritty.nix ];

  environment.systemPackages = with pkgs; [ yazi wl-clipboard ];
}
