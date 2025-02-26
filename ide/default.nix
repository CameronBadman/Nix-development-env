{ config, pkgs, ... }:

{
  # Install Helix and related development tools
  environment.systemPackages = with pkgs; [
    # Editor
    helix

    # Go development tools
    go
    gopls  # Go language server
    go-tools  # Additional Go tools
    golangci-lint

    # Optional: Additional development tools
    git
    gcc
  ];

  # Optional: Create Helix configuration directory
  environment.etc."helix/config.toml".text = ''
    # Global Helix Configuration
    theme = "dracula"

    [editor]
    line-number = "relative"
    mouse = false
    color-modes = true
    cursorline = true

    [editor.cursor-shape]
    insert = "bar"
    normal = "block"
    select = "underline"

    [editor.file-picker]
    hidden = false
  '';

  # Optional: Language-specific configuration
  environment.etc."helix/languages.toml".text = ''
    # Go Language Configuration
    [[language]]
    name = "go"
    auto-format = true
    formatter = ["${pkgs.go}/bin/gofmt"]
    language-servers = ["gopls"]

    [language-server.gopls]
    command = "gopls"
    args = ["serve"]

    # Optional: Additional language configurations
    [[language]]
    name = "nix"
    auto-format = true
    formatter = ["nixpkgs-fmt"]
    language-servers = ["nil"]

    [language-server.nil]
    command = "nil"
  '';
}
