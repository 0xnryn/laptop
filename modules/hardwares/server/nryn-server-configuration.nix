{ ... }:
{
  flake.nixosModules.nryn-server-configuration = { pkgs, config, lib, ... }: 
  {
    
    nix = {
      settings = { 
        experimental-features = [ 
          "nix-command"
          "flakes"
          "pipe-operators"
        ];
      };
    };
    nixpkgs.config.allowUnfree = true;
    programs.nix-ld.enable = true;
    system.stateVersion = "26.05";
    time.timeZone = "Asia/Kolkata";
    services.timesyncd.enable = true;
    i18n.defaultLocale = "en_US.UTF-8";
    console.keyMap = "us";
    virtualisation.docker = {
      enable = true;
      # Tell Docker to live entirely inside your persistent vault
      daemon.settings = {
        data-root = "/mnt/data/docker";
      };
    };
    services = {
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
    
    environment.variables = {
      EDITOR = "nano"; VISUAL = "nano"; 
    };
    environment.systemPackages = with pkgs; [
      age age-plugin-tpm 
      bind
      cloudflared curl
      droidcam docker
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
    ];
    networking = {
      
    };

    services.yggdrasil = {
      enable = true;
      openMulticastPort = true;
      settings = {
        IfName = "ygg0";
        Listen = [ "tcp://0.0.0.0:53535" ];
        PrivateKeyPath = config.sops.secrets."yggdrasil".path; 
        NodeInfoPrivacy = true;
        Peers = [          # inputs.opinions.nixosModules.erpnext

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
            Regex = ".*";  
            Beacon = true; 
            Listen = true; 
            Port = 9001;   
          }
        ];
      };
    };
    systemd.services.cloudflared-tunnel = {
      description = "Cloudflared Remotely Managed Tunnel";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        User = "cloudflared"; Group = "cloudflared";
        ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run";
        # "TUNNEL_TOKEN=...", cloudflared will pick it up automatically
        EnvironmentFile = config.sops.secrets."cloudflare".path;
        Restart = "always";
        RestartSec = "5s";
        # Extra security hardening (optional but recommended since we removed DynamicUser)
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
      };
    };
    users.groups.cloudflared = {};
    users.users.cloudflared = {
      isSystemUser = true;
      group = "cloudflared";
    };
    networking.firewall = {
      trustedInterfaces = [ "docker0" ]; 
      allowedTCPPorts = [ 53535 9001 ];
      allowedUDPPorts = [ 53535 9001 ];
    };
  };
}

