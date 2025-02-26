{
  description = "Development Environment Flake";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, darwin, home-manager, ... }@inputs:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      
      # Configure nixpkgs with allowUnfree
      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      });
    in {
      # Export the development module for both NixOS and Darwin
      nixosModules.default = { config, lib, pkgs, ... }: {
        imports = [
          ./terminal
          ./containers
          ./languages
          ./ide
        ];
      };
      
      darwinModules.default = self.nixosModules.default;
      
      # Standalone NixOS configuration for testing
      nixosConfigurations.dev = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Import the development module
          self.nixosModules.default
          
          # Basic configuration for testing
          ({ pkgs, ... }: {
            # Use nixpkgs with allowUnfree
            nixpkgs.config.allowUnfree = true;
            
            system.stateVersion = "23.11";
            boot.isContainer = true;
            users.users.cameron = {
              isNormalUser = true;
              home = "/home/cameron";
            };
          })
          
          # Home Manager
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.cameron = { ... }: {
              home.stateVersion = "23.11";
            };
          }
        ];
        specialArgs = { inherit inputs; };
      };
      
      # Standalone Darwin configuration for testing
      darwinConfigurations.dev = darwin.lib.darwinSystem {
        system = "x86_64-darwin"; # Change to aarch64-darwin for Apple Silicon
        modules = [
          # Import the development module
          self.darwinModules.default
          
          # Basic configuration for testing
          ({ pkgs, ... }: {
            # Use nixpkgs with allowUnfree
            nixpkgs.config.allowUnfree = true;
            
            users.users.cameron = {
              home = "/Users/cameron";
              shell = pkgs.zsh;
            };
            services.nix-daemon.enable = true;
            system.stateVersion = 4;
          })
          
          # Home Manager
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.cameron = { ... }: {
              home.stateVersion = "23.11";
            };
          }
        ];
        specialArgs = { inherit inputs; };
      };
      
      # Development shells for each system
      devShells = forAllSystems (system: {
        default = nixpkgsFor.${system}.mkShell {
          buildInputs = with nixpkgsFor.${system}; [
            nixfmt-classic
            nixpkgs-fmt
            nil # Modern Nix language server (replacement for rnix-lsp)
          ];
        };
      });
    };
}
