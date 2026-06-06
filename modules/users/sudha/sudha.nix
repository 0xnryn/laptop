{ inputs, lib, config, ... }:{

  imports = [
    inputs.cosmic.flakeModules.default
  ];
    
  configurations.secrets.identities."root" = {
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJQgPPuvnBiaK6z3ADBqY5l11oB6HHwm1rtUAEusMSlx root";
    tags = [ "root" ];
  };

  configurations.secrets.identities."sudhassh" = {
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPOVwS487rUg6zfTKdeRILuaF2MAkj+0Hb+VybiY/MK sudha";
    tags = [ "sudhassh" ];
  };

  configurations.secrets.policyGroups = {
    "sudha" = {
      basePath = "modules/users/sudha/secrets";
      files = {
        "sudhassh.age" = [ "sudhalaptopssh" "sudhalaptoptpm" ];
        "sudhauserpass.age" = [ "sudhassh" "sudhalaptoptpm" ];
      };
    };
  };

  flake.nixosModules.sudha = { config, pkgs, lib, ... }: {
    
    cosmicage.secrets."sudhassh" = {
      file = "sudhassh.age";
      mode = "0600";
      owner = "sudha";
      group = "users";
      path = "/home/sudha/.ssh/id_ed25519";
    };
    
    cosmicage.secrets."sudhauserpass" = {
      file = "sudhauserpass.age";
    };
    
    users.users.sudha = {
      isNormalUser = true;
      extraGroups = [ "wheel" "dialout" ];
      hashedPasswordFile = config.age.secrets."sudhauserpass".path;
    };
  };

  flake.homeModules.sudhacli = { pkgs, osConfig, ... }:{
    nixpkgs.config.allowUnfree = true;
    home.username = "sudha";
    home.homeDirectory = "/home/sudha";
    home.stateVersion = "26.05";
    programs.home-manager.enable = true;
    home.packages = with pkgs; [
      tree
      util-linux
      wget
      curl
      git
      gptfdisk
      htop
      fastfetch
      android-tools
      sops
      pciutils
      mosquitto
      nixd
      nil
      cloudflared
      cachix
      python3
      espeak-ng
      uv
      pulseaudio 
      alsa-utils
      pipewire
      netcat-gnu
      unrar
      gh
      jq
      pwgen
    ];
    
    programs.git = {
      enable = true;
      settings.user = {
        name = "sudhanshunitinatalkar";
        email = "atalkarsudhanshu@proton.me";
      };
    };

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "*" = {
          IdentityFile = osConfig.age.secrets."sudhassh".path;
          AddKeysToAgent = "yes";
          ServerAliveInterval = 60;
        };
      };
    };
  };
  
  flake.homeModules.sudhagui = { pkgs, ... }:{
      home.packages = with pkgs; [
        zed-editor
      ];
    };
}
