{ config, pkgs, inputs, ... }:
{
  imports = [
    ./terminal
    ./containers
    ./languages
    ./ide
  ];
}
