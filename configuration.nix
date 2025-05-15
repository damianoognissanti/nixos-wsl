{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    # include NixOS-WSL modules
    # <nixos-wsl/modules>
  ];
  
  ### STATE VERSION
  system.stateVersion = "24.11";

  ### WSL
  wsl.enable = true;
  wsl.defaultUser = "nixos";

  ### FLAKES SETTINGS
  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);
  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;
    nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes";
    # Deduplicate and optimize nix store
    auto-optimise-store = true;
  };

  ### PACKAGES
  environment.systemPackages = with pkgs; [
    neovim
    bc
    fzf
    git
    lazygit
  ];

  ### BASH CONFIG
  programs.bash.shellAliases = {
      ls = "ls --color=auto";
      grep = "grep --color=auto";
      vim = "nvim";
      vi = "nvim";
  };
  programs.fzf.keybindings = true;

}
