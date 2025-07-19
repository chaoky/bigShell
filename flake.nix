{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };
  outputs =
    { nixpkgs, utils, ... }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        bigShell = attrs: import ./bigShell.nix attrs;
      in
      {
        formatter = pkgs.nixfmt-tree;
        devShell = bigShell {
          inherit pkgs;
          shell = "bash";
        };
        packages = {
          inherit bigShell;
          mkShell = bigShell;
        };
      }
    );
}
