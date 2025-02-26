{ config, pkgs, lib, ... }: {
  imports = [ ./alacritty.nix ];

  environment.systemPackages = with pkgs; [ yazi wl-clipboard ];
}
