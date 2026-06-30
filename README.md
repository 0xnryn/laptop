# laptop
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p2
sudo systemd-cryptenroll /dev/nvme0n1p2 --wipe-slot=tpm2

sudo nix run nixpkgs#age-plugin-tpm -- --generate -o /etc/laptoptpm.txt

ssh-keygen -t ed25519 -f <path> -C "name"

echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5..." | nix run nixpkgs#ssh-to-age

nix run nixpkgs#ssh-to-age -- -i /etc/ssh/ssh_host_ed25519_key.pub

echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5..." | nix run nixpkgs#ssh-to-age

nix run nixpkgs#sops -- secrets/0xnryn-laptop.yaml

nix run nixpkgs#sops -- updatekeys secrets/0xnryn-laptop.yaml

sudo EDITOR=nano SOPS_AGE_KEY_FILE=/etc/laptopboot.txt nix run nixpkgs#sops -- secrets/0xnryn-laptop.yaml

sudo EDITOR=nano SOPS_AGE_KEY_FILE=/etc/laptopboot.txt nix run nixpkgs#sops -- updatekeys secrets/0xnryn-laptop.yaml

sudo EDITOR=nano -E sops secrets/0xnryn-laptop.yaml

sudo EDITOR=nano SOPS_AGE_KEY_FILE=/etc/laptopboot.txt sops secrets/0xnryn-laptop.yaml

env -u SOPS_AGE_KEY_FILE SOPS_AGE_KEY=$(nix run nixpkgs#age -- -d secrets/sudha.age 2>/dev/null | grep AGE-SECRET-KEY) nix run nixpkgs#sops -- secrets/0xnryn-laptop.yaml


# This creates a file named 'key.txt' containing your private key
nix run nixpkgs#age-keygen -- -o keys.txt
age-keygen -o keys.txt

# This will ask you to enter a passphrase
nix run nixpkgs#age -- -p -o key.txt.age key.txt
age -p -o key.txt.age key.txt


# # Start the agent if it isn't running
# eval $(ssh-agent -s)
# # Add your password-protected root SSH key
# ssh-add secrets/root
# SOPS_AGE_SSH_PRIVATE_KEY_FILE=secrets/root sops updatekeys modules/machines/laptop/laptopsecrets.yaml
# SOPS_AGE_SSH_PRIVATE_KEY_FILE=secrets/root sops modules/machines/laptop/laptopsecrets.yaml
# echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..." | ssh-to-age\
# Generate a native age identity
# age-keygen -o ~/root.txt


Architecture A: Yggdrasil OVER Tor (Ultimate Anonymity)
In this setup, you run the Tor daemon on your laptop. You configure Yggdrasil to connect to other Yggdrasil nodes that are hosted as Tor Hidden Services (.onion addresses) via a local SOCKS5 proxy.

What you achieve: You solve the "Public Peer knows my IP" problem without needing to buy your own VPS. The public Yggdrasil peer only sees traffic emerging from a random Tor exit node. Your physical location is mathematically severed from your Yggdrasil 200:: identity.

The Cost (Extreme Latency): Tor routes your traffic through three random servers across the globe. Yggdrasil then does its own cryptographic tree-routing on top of that. If you ping an ALFIS domain, the packet might travel around the Earth three times before returning. You are looking at 1,000ms to 3,000ms (1-3 seconds) of latency per click. It is highly secure, but barely usable for web browsing.

 
# 1. Ensure the root user owns the file
sudo chown root:root /etc/serverboot.txt

# 2. Set strict read-only permissions for root (and completely block everyone else)
sudo chmod 400 /etc/serverboot.txt

