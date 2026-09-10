{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/${user}";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    neovim
    tmux
    herdr     # agent multiplexer that lives in your terminal
    # the font everything renders in
    nerd-fonts.hack
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
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    oh-my-zsh = {
      enable = true;
      theme = "powerlevel10k/powerlevel10k";
      plugins = [ "git" "zsh-autosuggestions" "zsh-syntax-highlighting" "vi-mode" ];
    };
    initContent = ''
      bindkey '^f' autosuggest-accept
      bindkey -v
      setopt inc_append_history

      # Source bash aliases and history control
      if [ -f ~/.bash_aliases ]; then
          . ~/.bash_aliases
      fi
      if [ -f ~/.zsh_history_control ]; then
          . ~/.zsh_history_control
      fi

      # >>> conda initialize >>>
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
      # <<< conda initialize <<<

      # using vim for p4editor
      export P4EDITOR=vim

      # set GOPATH
      export GOPATH="$HOME/Documents/golang"
      export GOBIN="$GOPATH/bin"

      # remove JDK /usr/local/buildtools/java/jdk/bin from PATH
      export PATH=$(echo "$PATH" | sed 's|/usr/local/buildtools/java/jdk/bin:||')
      export PATH=$PATH:$GOBIN:$GOPATH

      # .deno env
      . "/root/.deno/env"

      # hermes commands
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
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
      cmd_duration.min_time = 3;
      directory.truncation_length = 80;
      directory.truncate_to_repo = true;
      directory.style = "cyan";
      git_branch.style = "magenta";
      git_branch.symbol = "branch:";
      git_status.style = "red";
      status.style = "red";
      jobs.style = "cyan";
      jobs.symbol = "parallel_lines ";
      python.symbol = "🐍 ";
      python.style = "yellow";
      conda.symbol = "🧪 ";
      conda.style = "green";
      time.format = "%H:%M";
      time.style = "blue";
      nix_shell.symbol = "⌘ ";
      nix_shell.style = "cyan";
      direnv.symbol = "⌘ ";
      direnv.style = "yellow";
      aws.symbol = "☁️ ";
      aws.style = "yellow";
      context.symbol = "✈️ ";
      context.style = "cyan";
    };
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

  # Keep Pi's credential and runtime state local, linking only authored files.
  home.file.".pi/agent/themes".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/themes";
  home.file.".pi/agent/extensions".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/extensions";
  home.file.".pi/agent/models.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/models.json";
  home.file.".pi/agent/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/settings.json";

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
}
