# laptop
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p2
sudo systemd-cryptenroll /dev/nvme0n1p2 --wipe-slot=tpm2

sudo nix run nixpkgs#age-plugin-tpm -- --generate -o /etc/laptoptpm.txt

ssh-keygen -t ed25519 -f <path> -C "name"

echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5..." | nix run nixpkgs#ssh-to-age

nix run nixpkgs#ssh-to-age -- -i /etc/ssh/ssh_host_ed25519_key.pub

echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5..." | nix run nixpkgs#ssh-to-age

nix run nixpkgs#sops -- secrets/laptop.yaml

nix run nixpkgs#sops -- updatekeys secrets/laptop.yaml

sudo EDITOR=nano SOPS_AGE_KEY_FILE=/etc/laptoptpm.txt nix run nixpkgs#sops -- secrets/laptop.yaml

sudo EDITOR=nano SOPS_AGE_KEY_FILE=/etc/laptoptpm.txt nix run nixpkgs#sops -- updatekeys secrets/laptop.yaml

sudo -E sops secrets/laptop.yaml

env -u SOPS_AGE_KEY_FILE SOPS_AGE_KEY=$(nix run nixpkgs#age -- -d secrets/sudha.age 2>/dev/null | grep AGE-SECRET-KEY) nix run nixpkgs#sops -- secrets/laptop.yaml


# This creates a file named 'key.txt' containing your private key
nix run nixpkgs#age-keygen -o key.txt

# This will ask you to enter a passphrase
nix run nixpkgs#age -p -o key.txt.age key.txt


# # Start the agent if it isn't running
# eval $(ssh-agent -s)
# # Add your password-protected root SSH key
# ssh-add secrets/root
# SOPS_AGE_SSH_PRIVATE_KEY_FILE=secrets/root sops updatekeys modules/machines/laptop/laptopsecrets.yaml
# SOPS_AGE_SSH_PRIVATE_KEY_FILE=secrets/root sops modules/machines/laptop/laptopsecrets.yaml
# echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..." | ssh-to-age\
# Generate a native age identity
# age-keygen -o ~/root.txt
 
