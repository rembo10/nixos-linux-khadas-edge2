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
        version = "5.10.160";
        src = pkgs.fetchzip {
          url = "https://github.com/armbian/linux-rockchip/archive/99a6d693684e987cd843d6e9bf71ebcb55de51f0.zip";
          hash = "sha256-Ncw+x84AwScG/aZtMndmDueBEopHtqO4+oqYgfWNd7U=";
        };
        configfile = ./config;
        kernelPatches = [
        #  { name = "bcmdhd-sourcetree-fix"; patch = ./patches/bcmdhd-sourcetree-fix.patch; }
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
