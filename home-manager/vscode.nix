{ 
pkgs
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
      ];

      userSettings = {
        "user.colorTheme" = "Nord";
        "workbench.colorTheme" = "Nord";
        "terminal.integrated.fontFamily" = "Hack";
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";        
        "nix.serverSettings" = {
          "nil" = {
            "diagnostics"= {
              "ignored"= ["unused_binding" "unused_with"];
            };
            "formatting"= {
              "command"= ["nixpkgs-fmt"];
            };
          };
        };
      };
    };   
}
