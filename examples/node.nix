{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    bigShell = "";
  };
  outputs =
    { utils, nixpkgs, bigShell, ... }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
      in
      {
        formatter = pkgs.nixfmt-tree;
        devShell = bigShell {
          inherit pkgs;
          shell = "fish";
          buildInputs = with pkgs; [
            yarn
            postgresql
            fnm
            awscli2
            direnv
            # _1password-cli  #only works with tty login
          ];
          shellHook = ''
            fnm env --use-on-cd --shell fish --corepack-enabled | source
          '';
        };
      }
    );
}
