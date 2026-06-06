{ pkgs, config, inputs, ... }:
let
  mkUser = hostname: modules: {
    pkgs = inputs.nixpkgs.legacyPackages.${config.configurations.nixos.${hostname}.system};
    module = { imports = modules; };
    osConfig = config.flake.nixosConfigurations.${hostname}.config;
  };
in
{
  
  imports = [
    inputs.cosmic.flakeModules.default
  ];

  configurations.secrets.identities."sudhalaptoptpm" = {
    publicKey = "age1tag1qv37tamvtdydm3m3zg9g6k8st3m5nvggacy2h6wkha44sqgl944cyw3mek9";
    tags = [ "sudhalaptoptpm"  ]; 
  };

  configurations.secrets.identities."sudhalaptopssh" = {
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDOJRuZDBhEn9Q37C0qZ8jMo6EMrTe7bzTT4hKcBMBN9 sudhalaptop";
    tags = [ "sudhalaptopssh" ]; 
  };

  configurations.secrets.policyGroups = {
    "sudhalaptopssh" = {
      basePath = "modules/machines/laptop/secrets";
      files = {
        "sudhalaptoptpm.age" = [ "root" ];
        "sudhalaptopssh.age" = [ "sudhalaptoptpm" ];
      };
    };
  };
  
  configurations.nixos = {
    "laptop" = {
      system = "x86_64-linux";
      module = {
        age.identityPaths = [ 
          "/etc/sudhalaptoptpm"
        ];
        cosmicage.secrets."sudhalaptopssh" = {
          file = "sudhalaptopssh.age";
          path = "/etc/ssh/ssh_host_ed25519_key"; 
          mode = "0600";
          owner = "root";
        };
        imports = with config.flake.nixosModules; [ 
          inputs.agenix.nixosModules.default
          cosmicage
          laptop
          system
          plasma
          sudha
        ];
      }; 
    }; 
  };

  configurations.home = {
    "sudha@laptop" = with config.flake.homeModules; mkUser "laptop" [
      sudhacli
      sudhagui
      zen-browser
    ];
  };  
}
