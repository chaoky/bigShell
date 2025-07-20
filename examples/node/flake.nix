{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    bigShell.url = "github:chaoky/bigShell";
  };
  outputs =
    {
      utils,
      nixpkgs,
      bigShell,
      ...
    }:
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
        devShell = bigShell.mkShell {
          inherit pkgs;
          shell = "auto"; # use "auto" to impure read from $SHELL
          buildInputs = with pkgs; [
            fnm
            direnv
          ];
          shellHook = ''
            #echo "using $SHELL_NAME"
          '';
          bashHook = ''
            eval "$(fnm env --use-on-cd --shell bash)"
          '';
          zshHook = ''
            eval "$(fnm env --use-on-cd --shell zsh)"
          '';
          fishHook = ''
            fnm env --use-on-cd --shell fish | source
          '';
        };
      }
    );
}
