# BigShell

Bring your shell of choice to `mkShell` with a simple wrapper

## Basic Example

Edit `flake.nix`

```nix
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
}
```

Enter the shell

```bash
nix develop --impure
```

## Advanced Example

```nix
...
{
  devShell = bigShell.mkShell {
    inherit pkgs;
    shell = "fish";
    buildInputs = with pkgs; [ fnm ];
    shellHook = ''
      echo "using $SHELL_NAME"
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
```

### why not [use flake from direnv](https://direnv.net/man/direnv-stdlib.1.html#codeuse-flake-ltinstallablegtcode)

`direnv` only exports and clears environment variables,
it'll not work for more advanced shell features like in the example above,
I still use `direnv` to manage my secrets and environment variables

### auto enter shell

Add something similar to this `zsh` script to your shell init file
to automatically enter the development environment

```sh
# auto nix develop
nix_flake_cd() {
  if [[ -f "flake.nix" && -z "$NIX_SHELL_LEVEL" ]]; then
    export NIX_SHELL_LEVEL=1
    nix develop --impure
    export NIX_SHELL_LEVEL=
  fi
}

autoload -U add-zsh-hook
add-zsh-hook chpwd nix_flake_cd && nix_flake_cd
```
