{ pkgs
, ...
}:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions = with pkgs.vscode-extensions; [
      eamodio.gitlens
      bbenoist.nix
      jnoortheen.nix-ide
      arcticicestudio.nord-visual-studio-code
      pinage404.nix-extension-pack
      
    ];

    userSettings = {
      "extensions.autoCheckUpdates" = false;
      "update.mode" = "none";
      "telemetry.telemetryLevel" = "off";
      "gitlens.telemetry.enabled" = false;
      "workbench.colorTheme" = "Nord";
      "terminal.integrated.fontFamily" = "Hack";
      "nix.formatterPath" = "nixpkgs-fmt";
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nil";
      "nix.serverSettings" = {
        "nil" = {
          "diagnostics" = {
            "ignored" = [ "unused_binding" "unused_with" ];
          };
          "formatting" = {
            "command" = [ "nixpkgs-fmt" ];
          };
        };
      };
    };
  };
}
