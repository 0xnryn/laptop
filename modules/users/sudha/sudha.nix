{ inputs, lib, config, ... }:{

  imports = [
    inputs.cosmic.flakeModules.default
  ];

  flake.nixosModules.sudha = { config, pkgs, lib, ... }: {
    
    # Switched to native age.secrets and provided the explicit path
    age.secrets."sudhassh" = {
      file = "${inputs.self}/modules/users/sudha/secrets/sudhassh.age";
      mode = "0600";
      owner = "sudha";
      group = "users";
      path = "/home/sudha/.ssh/id_ed25519";
    };
    
    age.secrets."sudhauserpass" = {
      file = "${inputs.self}/modules/users/sudha/secrets/sudhauserpass.age";
    };
    
    users.users.sudha = {
      isNormalUser = true;
      extraGroups = [ "wheel" "dialout" ];
      # This remains exactly the same!
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
          # This continues to work flawlessly because it reads the native age config
          IdentityFile = osConfig.age.secrets."sudhassh".path;
          AddKeysToAgent = "yes";
          ServerAliveInterval = 60;
        };
      };
    };
  };
  
  flake.homeModules.sudhagui = { config, pkgs, lib, ... }:{
    home.packages = with pkgs; [
      zed-editor
      vlc
    ];
  };
}