# # Start the agent if it isn't running
# eval $(ssh-agent -s)
# # Add your password-protected root SSH key
# ssh-add secrets/root
# SOPS_AGE_SSH_PRIVATE_KEY_FILE=secrets/root sops updatekeys modules/machines/laptop/laptopsecrets.yaml
# SOPS_AGE_SSH_PRIVATE_KEY_FILE=secrets/root sops modules/machines/laptop/laptopsecrets.yaml
# echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..." | ssh-to-age\
# Generate a native age identity
# age-keygen -o ~/root.txt
{ pkgs, config, inputs, ... }:
{
  imports = [
    inputs.cosmic.flakeModules.default
  ];

  configurations.nixos = {
    "laptop" = {
      system = "x86_64-linux";
      module = {
        # sops.age.keyFile = "/etc/ssh/ssh_host_ed25519_key";
        # sops.secrets."git-access-tokens" = {
        #   sopsFile = "${inputs.self}/modules/machines/laptop/laptopsecrets.yaml"; 
        #   mode = "0440";
        #   owner = "root"; 
        #   group = "wheel";
        # };
        # nix.extraOptions = ''
        #   !include /run/secrets/git-access-tokens
        # '';
        imports = 
        with inputs.opinions.nixosModules; 
        with config.flake.nixosModules;    
        [ 
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

