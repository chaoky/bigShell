{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { nixpkgs, utils, ... }:
    let
      bigShell = attrs: import ./bigShell.nix attrs;
      dev = utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          formatter = pkgs.nixfmt-tree;
          devShell = bigShell {
            inherit pkgs;
            shell = "auto";
          };
        }
      );
    in
    dev
    // {
      mkShell = bigShell;
      templates = {
        node = {
          path = ./examples/node;
          description = "Nodejs with a version manager";
        };
      };
    };
}
