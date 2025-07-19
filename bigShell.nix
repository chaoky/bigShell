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
  wrapped = pkgs.writeShellScriptBin shellName (
    {
      fishHook = "exec fish --init-command='${shellHook}'";
      bashHook = ''
        INIT=/tmp/bigShellNix
        mkdir -p $INIT

        printf "%s\n" \
          "source $HOME/.bashrc" \
          '${shellHook}' \
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
          '${shellHook}' \
        >$ZDOTDIR/.zshrc

        exec zsh
      '';
    }
    ."${shellName}Hook"
  );
  override = {
    buildInputs = buildInputs ++ [ pkgs.${shellName} ];
    shellHook = ''
      export SHELL=${wrapped}/bin/${shellName}
      exec $SHELL
    '';
  };
in

pkgs.mkShell (input // override)
