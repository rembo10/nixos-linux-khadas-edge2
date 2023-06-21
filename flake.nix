{

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
  };

  outputs = { self, nixpkgs }: 
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        crossSystem.config = "aarch64-unknown-linux-gnu";
        overlays = [
          (self: super: {
            linuxManualConfig = super.linuxManualConfig.override {
              stdenv = super.gcc10Stdenv;
              buildPackages = super.buildPackages // {
                stdenv = super.buildPackages.gcc10Stdenv;
              };
            };
          })
        ];
      };
      linux_khadas_edges = pkgs.linuxManualConfig {
        version = "5.10.66";
        src = pkgs.fetchurl {
          url = "https://github.com/khadas/linux/archive/refs/tags/khadas-edges-linux-5.10-v1.5-release.tar.gz";
          sha256 = "0lrhl7bwg45l1l489ra4fbcvwwii645hsp7wqj9ijwhx1g05apz0";
        };
        configfile = ./config;
        kernelPatches = [
          { name = "bcmdhd-sourcetree-fix"; patch = ./patches/bcmdhd-sourcetree-fix.patch; }
        ];
        allowImportFromDerivation = true;
      };
    in {
      pkgsCross.aarch64-multiplatform.linux_khadas_edges = linux_khadas_edges;
      devShells.x86_64-linux.default = pkgs.mkShell {
        inputsFrom = [ self.pkgsCross.aarch64-multiplatform.linux_khadas_edges ];
      };
    };
}
