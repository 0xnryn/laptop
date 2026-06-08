{ pkgs, config, inputs, ... }:
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

  configurations.secrets.policyGroups."laptop" = {
    basePath = "modules/machines/laptop/secrets";
    files = {
      "sudhalaptoptpm.age" = [ "root" ];
      "sudhalaptopssh.age" = [ "sudhalaptoptpm" ];
      "gitaccesstokens.age" = [ "sudhalaptoptpm" "sudhalaptopssh" ];
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
        #cosmicage.secrets."git-access-tokens".file = "gitaccesstokens.age";
        imports = 
        with inputs.opinions.nixosModules; 
        with config.flake.nixosModules;    
        [ 
          inputs.agenix.nixosModules.default
          cosmicage
          #git-access-tokens
          laptop
          system
          plasma
          sudha
        ];
      }; 
    }; 
  };

  configurations.home = {
      "sudha@laptop" = {
        hostName = "laptop";
        modules = 
          with config.flake.homeModules;
          with inputs.opinions.homeModules; 
          [
            sudhacli
            sudhagui
            plasma
            helium-browser
          ];
      };
    }; 
}
