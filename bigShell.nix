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
      "fish" = "exec fish --init-command='${shellHook}'";
      "bash" = "...";
      "zsh" = ''
        exec zsh
      '';
    }
    .${shellName}
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
