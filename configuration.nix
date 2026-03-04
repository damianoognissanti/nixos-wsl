{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    # include NixOS-WSL modules
    # <nixos-wsl/modules>
  ];

  nixpkgs.overlays = [
      #(final: prev:
      # {
      # kakoune-unwrapped = prev.kakoune-unwrapped.overrideAttrs (old: {
      #         src = prev.fetchFromGitHub {
      #         owner = "mawww";
      #         repo = "kakoune";
      #         rev = "237dd3e287cf4bd3528206ba140527618e3a7c93";
      #         hash = "sha256-xI4hUEQD+eSlAQLu2UgKYSGvTd9P7V/viiVYVvwC5JA=";
      #         };
      # });
      #})
  ];

  ### WSL
  wsl.enable = true;
  wsl.defaultUser = "nixos";
  wsl.interop.includePath = false;

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
    #kakoune
    #helix
    neovim
    bc
    fzf
    git
    lazygit
    steam-run
    fastfetch
    typst
    xclip
  ];

  ### BASH CONFIG
  #programs.fzf.keybindings = true;
  #programs.bash= {
  #  blesh.enable = true;
  #  shellAliases = {
  #      vim = "kak";
  #      vi = "kak";
  #      ls = "ls --color";
  #      grep = "grep --color";
  #  };
#	promptInit = ''
#	export PS1='\[$(tput setaf 30)\]\u\[$(tput setaf 31)\]@\[$(tput setaf 32)\]\H\[$(tput setaf 33)\]:$PWD\[$(tput setaf 34)\] ($(git branch --show-current 2>/dev/null))\[$(tput sgr0)\]$ '
#    '';
#  };
  ### FISH CONFIG
  users.users.nixos.shell = pkgs.fish;
  programs.fish = {
    enable = true;
    #blesh.enable = true;
    shellAliases = {
        vim = "nvim";
        vi = "nvim";
        ls = "ls --color";
        grep = "grep --color";
    };
  };

  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;

  #services.postgresql = {
  #  enable = true;
  #  ensureDatabases = [ "mydatabase" ];
  #  authentication = pkgs.lib.mkOverride 10 ''
  #    #type database  DBuser  auth-method
  #    local all       all     trust
  #  '';
  #};
}
