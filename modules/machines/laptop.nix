flakeContext@{ inputs, ... }:
{
  imports = [
    inputs.cosmic.flakeModules.default
  ];

  configurations.nixos = {
    "laptop" = {
      system = "x86_64-linux";
      module = { pkgs, config, ... }:{
        nix.settings = { experimental-features = [ "nix-command" "flakes" "pipe-operators" ]; };
        nixpkgs.config.allowUnfree = true;
        programs.nix-ld.enable = true;
        system.stateVersion = "26.05";
        time.timeZone = "Asia/Kolkata";
        i18n.defaultLocale = "en_US.UTF-8";
        console.keyMap = "us";
        virtualisation.docker.enable = true;
        services = {
          printing.enable = true;
          openssh.enable = true;
          pipewire = {
            enable = true;
            pulse.enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            wireplumber.enable = true; 
          };
          avahi = {
            enable = true;
            nssmdns4 = true; 
          };
        };
        environment.systemPackages = with pkgs; [
          age age-plugin-tpm android-tools
          bind
          cloudflared curl
          droidcam
          git gptfdisk
          home-manager htop
          jq
          mtr
          pciutils
          sbctl sops ssh-to-age
          tcpdump tree
          util-linux unzip
          vim
          wget
          yggdrasil
          alfis-nogui
          alfis
          docker
        ];
        environment.variables = {
          EDITOR = "nano"; VISUAL = "nano"; 
          SOPS_AGE_KEY_FILE = "/etc/laptopboot.txt"; 
        };

        networking = {
          networkmanager.enable = true;
          hostName = "laptop";
          firewall = {
            enable = true;
            # 1. Allow ALFIS P2P traffic
            allowedTCPPorts = [ 4244 53535 ];
            allowedUDPPorts = [ 4244 53535 53 ];
          };
          # nameservers = [ "127.0.0.2" ];
          # networkmanager.dns = "none";
        };

        # command to generate yggdrasil key
        # nix run nixpkgs#yggdrasil -- -useconffile <(yggdrasil -genconf -json) -exportkey
        sops.secrets."yggdrasil" = {
          sopsFile = "${inputs.self}/secrets/laptop.yaml";
          format = "yaml";
          # Use the default SOPS runtime path in RAM, avoiding the physical disk entirely
        };
        services.yggdrasil = {
          enable = true;
          openMulticastPort = true;
          settings = {
            IfName = "ygg0";
            Listen = [ "tcp://0.0.0.0:53535" ];
            PrivateKeyPath = config.sops.secrets."yggdrasil".path;
            NodeInfoPrivacy = true;
            Peers = [
              #india
              "tls://ins.8px.sk:4321"
              "quic://ins.8px.sk:4321"
              #hongkong
              "tcp://ygg5.mk16.de:1337?key=0000009611ae5391dc0aceea9f3fa6a0dc1279f4306059339e84bfb8b74d2f9b"
              "tls://ygg5.mk16.de:1338?key=0000009611ae5391dc0aceea9f3fa6a0dc1279f4306059339e84bfb8b74d2f9b"
              "quic://ygg5.mk16.de:1339?key=0000009611ae5391dc0aceea9f3fa6a0dc1279f4306059339e84bfb8b74d2f9b"
              "ws://ygg5.mk16.de:1340?key=0000009611ae5391dc0aceea9f3fa6a0dc1279f4306059339e84bfb8b74d2f9b"
              #singapore
              "tls://asia.deinfra.org:15015"
              "quic://asia.deinfra.org:15015"
              "tcp://yg-sin.magicum.net:23901"
              "tls://yg-sin.magicum.net:23900"
            ];
            MulticastInterfaces = [
              {
                Regex = ".*";  # Scan all physical network cards (eth0, wlan0, etc.)
                Beacon = true; # Shout your presence to the local network
                Listen = true; # Listen for neighbors shouting back
                Port = 9001;   # Matches the port opened by openMulticastPort
              }
            ];
          };
        };

        sops.secrets."syncthing_cert" = {
          sopsFile = "${inputs.self}/secrets/laptop.yaml";
          format = "yaml";
          owner = "root"; # Syncthing runs as root now
        };
        sops.secrets."syncthing_key" = {
          sopsFile = "${inputs.self}/secrets/laptop.yaml";
          format = "yaml";
          owner = "root";
        };
        
        sops.age.keyFile = "/etc/laptopboot.txt";
        sops.secrets."ssh/ssh_host_ed25519_key" = {
          sopsFile = "${inputs.self}/secrets/laptop.yaml";
          format = "yaml";
          path = "/etc/ssh/ssh_host_ed25519_key"; # This is the symlink location
        };
        # sops.secrets."git-access-tokens" = {
        #   sopsFile = "${inputs.self}/secrets/laptop.yaml"; 
        #   mode = "0440";
        #   owner = "root"; 
        #   group = "wheel";
        # };
        # nix.extraOptions = ''
        #   !include /run/secrets/git-access-tokens
        # '';
        users.users.sudha = {
          isNormalUser = true;
          extraGroups = [ "wheel" "networkmanager" "dialout" "docker" "adbusers"];          
          # hashedPasswordFile = config.sops.secrets."sudha-login-password".path;
        };
        
        imports = 
        with inputs.opinions.nixosModules; 
        with flakeContext.config.flake.nixosModules;    
        [ 
          inputs.sops-nix.nixosModules.sops
          # cosmicnetwork
          laptop
          plasma
          ollama_cuda
        ];
      }; 
    }; 
  };

  # configurations.home = {
  #   "sudha@laptop" = {
  #     hostName = "laptop";
  #     modules = 
  #       with config.flake.homeModules;
  #       with inputs.opinions.homeModules; 
  #       [
  #         sudhacli
  #         sudhagui
  #         plasma
  #         helium-browser
  #       ];
  #   };
  # }; 
}

