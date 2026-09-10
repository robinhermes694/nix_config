{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  starshipTOML = "${config.xdg.configHome}/starship.toml";
in

{
  home.username = user;
  home.homeDirectory = "/${user}";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    ripgrep
    fd
    fzf
    jq
    lazygit
    neovim
    tmux
    herdr
    nerd-fonts.hack
    starship
  ];

  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  programs.git = {
    enable = true;
    settings.user = {
      name = "Robin";
      email ="robinhermes694@gmail.com";
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      bindkey '^f' autosuggest-accept
      bindkey -v
      setopt inc_append_history

      if [ -f ~/.bash_aliases ]; then
          . ~/.bash_aliases
      fi
      if [ -f ~/.zsh_history_control ]; then
          . ~/.zsh_history_control
      fi

      __conda_setup="$('/home/wenjie/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
      if [ $? -eq 0 ]; then
          eval "$__conda_setup"
      else
          if [ -f "/home/wenjie/miniconda3/etc/profile.d/conda.sh" ]; then
              . "/home/wenjie/miniconda3/etc/profile.d/conda.sh"
          else
              export PATH="/home/wenjie/miniconda3/bin:$PATH"
          fi
      fi
      unset __conda_setup

      export P4EDITOR=vim
      export GOPATH="$HOME/Documents/golang"
      export GOBIN="$GOPATH/bin"
      export PATH=$(echo "$PATH" | sed 's|/usr/local/buildtools/java/jdk/bin:||')
      export PATH=$PATH:$GOBIN:$GOPATH

      . "/root/.deno/env"
      export PATH="/root/.local/bin:$PATH"
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      ll = "ls -l";
      la = "ls -la";
      vi = "nvim";
      vim = "nvim";
      alert = "notify-send --urgency=low -i \"$([ $? = 0 ] && echo terminal || echo error)\" \"$(history|tail -n1|sed -e 's/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//')\"";
    };
  };

  programs.starship = {
    enable = true;
  };

  home.file."${starshipTOML}".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/starship.toml";
  home.file."${config.xdg.configHome}/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file."${config.xdg.configHome}/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file."${config.xdg.configHome}/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
}