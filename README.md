# BigShell

Bring your shell of choice to `mkShell` with a simple wrapper

## Basic Example

````nix
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
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShell = bigShell.mkShell {
          inherit pkgs;
          # supports bash, zsh and fish
          # use "auto" to impure read from $SHELL
          shell = "fish";
          shellHook = ''
            echo "using $SHELL_NAME"
          };
        };
      }
    );
}```
````

## Advanced Example

```nix
...
{
  devShell = bigShell.mkShell {
    inherit pkgs;
    shell = "fish";
    buildInputs = with pkgs; [ fnm ];
    shellHook = {
      default = ''
        if [ $SHELL_NAME == "fish" ]; then
          echo "using fish"
        fi
      '';
      bash = ''
        eval "$(fnm env --use-on-cd --shell bash)"
      '';
      zsh = ''
        eval "$(fnm env --use-on-cd --shell zsh)"
      '';
      fish = ''
        fnm env --use-on-cd --shell fish | source
      '';
    };
  };
}
```
