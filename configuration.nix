# NixOS system-level configuration.
#
# This is the Linux counterpart to the macOS system-level configuration.
# On a NixOS host, import this module from your /etc/nixos/configuration.nix:
#
#   { config, pkgs, ... }:
#   {
#     imports = [ /path/to/this/repo/configuration.nix ];
#     ...
#   }
#
# For non-NixOS Linux distros (Ubuntu, Fedora, Arch, etc.), home-manager alone
# is enough — you do not need this file. The system-level settings below only
# apply when NixOS evaluates this module.

{ config, pkgs, ... }:

let
  # The one username line to change if this isn't your user.
  # This should match the `user` in flake.nix for consistency.
  user = "root";
in
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # User account. The shell is set to zsh (managed by home-manager).
  users.users.${user} = {
    isNormalUser = true;
    home = "${user}";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  # System-level packages that aren't managed by home-manager.
  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  # SSH server — remove if you don't need it.
  services.openssh.enable = true;

  # Network time sync.
  services.timesyncd.enable = true;

  # Uncomment to enable Docker:
  # virtualisation.docker.enable = true;

  # Uncomment for a graphical desktop (KDE Plasma example):
  # services.xserver.enable = true;
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  system.stateVersion = "24.11";
}
