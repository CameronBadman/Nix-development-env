{ config, pkgs, lib, ... }:

let 
  utils = import ../utils.nix { inherit lib; };
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  
  # Common packages for both platforms
  commonPackages = with pkgs; [
    docker
    docker-compose
    kubernetes-helm
    kubectl
    minikube
    k9s
    vscode
  ];
  
  # Linux-specific packages
  linuxPackages = with pkgs; [
    cloudlens
    # Add other Linux-only packages here
  ];
in {
  imports = utils.getImports ./.;
  
  # Add packages to the system
  environment.systemPackages = commonPackages 
    ++ lib.optionals isLinux linuxPackages;
  
  # Linux-specific configurations
  virtualisation = lib.mkIf isLinux {
    docker.enable = true;
  };
  
  # User configurations (Linux-only)
  users.users = lib.mkIf (isLinux && config.users.users ? cameron) {
    cameron.extraGroups = [ "docker" ];
  };
}
