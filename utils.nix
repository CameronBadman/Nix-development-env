{ lib }:
rec {
  getImports = dir:
    let
      files = builtins.attrNames (builtins.readDir dir);
      nixFiles = builtins.filter (x: x != "default.nix" && lib.hasSuffix ".nix" x) files;
    in
    map (x: dir + "/${x}") nixFiles;
}

