{
  description = "Nix Package for PhotoGIMP sandboxed using NixPak";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpak,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = (import nixpkgs) {
          inherit system;
        };

        inherit (pkgs) lib gimp gimp-with-plugins;

        mkNixPak = nixpak.lib.nixpak {
          inherit pkgs lib;
        };

        photo-gimp-files =
          (pkgs.fetchFromGitHub {
            owner = "Diolinux";
            repo = "PhotoGIMP";
            rev = "62c6e3733a580b9754257ebe21d34ca5b366626d";
            sha256 = "sha256-7mqJt99O4LLyPVdyK0BGbr0GTASXogMsP1pTLLYfXsw=";
          }).outPath;

        desktopItem = pkgs.makeDesktopItem (import ./desktopFile.nix photo-gimp-files);

        g-wrapper = import ./photo-gimp-install-wrapper.nix {
          inherit
            pkgs
            lib
            gimp
            photo-gimp-files
            ;
        };

        nixpak-wrapper-g = (mkNixPak (import ./nixPak.nix g-wrapper)).config.script;

        gwp-wrapper = import ./photo-gimp-install-wrapper.nix {
          inherit
            pkgs
            lib
            photo-gimp-files
            ;
          gimp = gimp-with-plugins;
        };

        nixpak-wrapper-gwp = (mkNixPak (import ./nixPak.nix gwp-wrapper)).config.script;
      in
      {
        packages = {
          default = self.packages.${system}.photo-gimp;
          photo-gimp = import ./package.nix {
            inherit
              pkgs
              lib
              photo-gimp-files
              desktopItem
              system
              ;
            nixpak-wrapper = nixpak-wrapper-g;
          };
          photo-gimp-with-plugins = import ./package.nix {
            inherit
              pkgs
              lib
              photo-gimp-files
              desktopItem
              system
              ;
            nixpak-wrapper = nixpak-wrapper-gwp;
          };
        };
      }
    );
}
