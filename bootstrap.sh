#!/usr/bin/env bash

# Default values
MACHINE=""
KEYS=()
GROUPS=()

usage() {
  echo "Usage: $0 --machine <name> [--keys <k1 k2...>] [--groups <g1 g2...>]"
  exit 1
}

# Parse long and short flags
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -m|--machine) MACHINE="$2"; shift ;;
    -k|--keys) 
      shift
      while [[ "$#" -gt 0 && ! "$1" =~ ^- ]]; do
        KEYS+=("$1"); shift
      done
      continue ;;
    -g|--groups) 
      shift
      while [[ "$#" -gt 0 && ! "$1" =~ ^- ]]; do
        GROUPS+=("$1"); shift
      done
      continue ;;
    *) usage ;;
  esac
  shift
done

if [[ -z "$MACHINE" ]]; then usage; fi

# 1. Generate/Verify the key file
PUBKEY=$(sudo nix run nixpkgs#age -- -y "/etc/${MACHINE}boot.txt")

# 2. Add the key definition to 'keys'
nix run nixpkgs#yq -- -i ".keys += {\"${MACHINE}boot\": \"$PUBKEY\"}" .sops.yaml

# 3. Construct the list of access targets for the YAML rule
# Convert arrays to a single string formatted as YAML list: ["*k1", "*g1", "*machineboot"]
ACCESS_LIST="[\"*${MACHINE}boot\""
for k in "${KEYS[@]}"; do ACCESS_LIST+=", \"*${k}\""; done
for g in "${GROUPS[@]}"; do ACCESS_LIST+=", \"*${g}\""; done
ACCESS_LIST+="]"

# 4. Add the unique creation rule
nix run nixpkgs#yq -- -i "select(any(.creation_rules[].path_regex; . == \"secrets/${MACHINE}ssh.yaml$\") | not) | .creation_rules += {\"path_regex\": \"secrets/${MACHINE}ssh.yaml$\", \"key_groups\": [{\"age\": ${ACCESS_LIST}}]}" .sops.yaml

echo "Initialization complete for $MACHINE. Access granted to: ${KEYS[*]} ${GROUPS[*]}"