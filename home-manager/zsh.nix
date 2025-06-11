{
  config,
  lib,
  pkgs,
  ...
}:
let
  isWayland = config.custom.sessionType == "wayland";
in
{
  options.custom.sessionType = lib.mkOption {
    type = lib.types.str;
    default = "x11";
    description = "The X session type: 'wayland' or 'x11'";
  };

  config = {
    home.file."scripts/lsgpu.sh" = {
      source = ./scripts/lsgpu.sh;
      executable = true;
    };

    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      initExtra = ''
        eval "$(direnv hook zsh)"
        export GIT_CONFIG_GLOBAL="$HOME/.gitconfig"
      '';

      shellAliases = lib.mkMerge [
        {
          "vi" = "nvim";
          "vim" = "nvim";
          "ll" = "ls -l";
          "code" = "code-insiders";
          "lsgpu" = "$HOME/scripts/lsgpu.sh";
        }

        (lib.mkIf isWayland {
          "pbcopy" = "wl-copy";
          "pbpaste" = "wl-paste";
        })

        (lib.mkIf (!isWayland) {
          "pbcopy" = "xclip -selection clipboard";
          "pbpaste" = "xclip -selection clipboard -o";
        })
      ];

      oh-my-zsh = {
        enable = true;
        theme = "bureau";
        plugins = [
          "git"
          "history"
        ];
      };
    };

    home.packages = with pkgs; [ xclip ];
  };
}
