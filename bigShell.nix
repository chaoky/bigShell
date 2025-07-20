{
  pkgs,
  buildInputs ? [ ],
  shellHook ? "",
  shell ? "bash",
  ...
}@attrs:

let
  input = builtins.removeAttrs attrs [
    "pkgs"
    "buildInputs"
    "shellHook"
    "shell"
  ];
  userShell = builtins.baseNameOf (builtins.getEnv "SHELL");
  shellName = if shell == "auto" then userShell else shell;

  defaultHook = if builtins.typeOf shellHook == "string" then shellHook else shellHook.default or "";
  wrapped = pkgs.writeShellScriptBin shellName (
    {
      fishHook = ''
        INIT=/tmp/bigShellNix
        mkdir -p $INIT

        printf "%s\n" \
          '${defaultHook}' \
          '${shellHook.fish or ""}' \
        >$INIT/.fishrc

        exec fish --init-command="source $INIT/.fishrc"
      '';
      bashHook = ''
        INIT=/tmp/bigShellNix
        mkdir -p $INIT

        printf "%s\n" \
          "source $HOME/.bashrc" \
          '${defaultHook}' \
          '${shellHook.bash or ""}' \
        >$INIT/.bashrc

        exec bash --init-file $INIT/.bashrc
      '';
      zshHook = ''
        ZDOTDIR_=$ZDOTDIR
        if [[ -z "$ZDOTDIR_" ]]; then
          ZDOTDIR_=$HOME
        fi

        export ZDOTDIR=/tmp/bigShellNix
        mkdir -p $ZDOTDIR

        printf "%s\n" \
          "export ZDOTDIR=$ZDOTDIR_" \
          'source $ZDOTDIR/.zshrc' \
          '${defaultHook}' \
          '${shellHook.zsh or ""}' \
        >$ZDOTDIR/.zshrc

        exec zsh
      '';
    }
    ."${shellName}Hook"
  );
  override = {
    buildInputs = buildInputs ++ [ pkgs.${shellName} ];
    shellHook = ''
      export SHELL_NAME=${shellName}
      export SHELL=${wrapped}/bin/${shellName}
      exec $SHELL
    '';
  };
in

pkgs.mkShell (input // override)
