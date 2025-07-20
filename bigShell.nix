{
  pkgs,
  shellHook ? "",
  fishHook ? "",
  bashHook ? "",
  zshHook ? "",
  shell ? "bash",
  ...
}@attrs:

let
  input = builtins.removeAttrs attrs [
    "pkgs"
    "shellHook"
    "fishHook"
    "bashHook"
    "zshHook"
    "shell"
  ];
  shellName = if shell == "auto" then builtins.baseNameOf (builtins.getEnv "SHELL") else shell;
  wrapped = pkgs.writeShellScriptBin shellName (
    {
      fish = ''
        INIT=/tmp/bigShellNix
        mkdir -p $INIT

        printf "%s\n" \
          '${shellHook}' \
          '${fishHook}' \
        >$INIT/.fishrc

        exec ${pkgs.fish}/bin/fish --init-command="source $INIT/.fishrc"
      '';
      bash = ''
        INIT=/tmp/bigShellNix
        mkdir -p $INIT

        printf "%s\n" \
          "source $HOME/.bashrc" \
          '${shellHook}' \
          '${bashHook}' \
        >$INIT/.bashrc

        exec ${pkgs.bashInteractive}/bin/bash --init-file $INIT/.bashrc
      '';
      zsh = ''
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
          '${zshHook}' \
        >$ZDOTDIR/.zshrc

        exec ${pkgs.zsh}/bin/zsh
      '';
      "" = builtins.throw "shell not supported ${shellName}";
    }
    .${shellName}
  );
  override = {
    shellHook = ''
      export SHELL_NAME=${shellName}
      export SHELL=${wrapped}/bin/${shellName}
      exec $SHELL
    '';
  };
in

pkgs.mkShell (input // override)
