{ config, pkgs, lib, ... }:

let utils = import ../utils.nix { inherit lib; };
in {
  imports = utils.getImports ./.;

  # Enable Docker
  virtualisation.docker.enable = true;

  # Add Docker and related tools to system packages
  environment.systemPackages = with pkgs; [
    docker
    docker-compose
    kubernetes-helm
    kubectl
    minikube
    kubernetes-helm
    k9s
    cloudlens
    vscode
  ];

  # Add your user to the Docker group
  users.users.cameron = { extraGroups = [ "docker" ]; };
}
