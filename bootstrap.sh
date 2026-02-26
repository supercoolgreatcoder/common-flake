#!/usr/bin/env bash

SUDO=${SUDO:=sudo}

${SUDO} apt update
${SUDO} apt install -y --no-install-recommends curl sudo xz-utils openssh-server

# Configure SSH for root access
${SUDO} sed -i 's/^#*PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
${SUDO} sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
${SUDO} sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
# Start SSH server (container-compatible)
# Generate host keys if they don't exist
${SUDO} ssh-keygen -A

# Start SSH daemon directly (for container environments without systemd)
if [ ! -d /run/sshd ]; then
  ${SUDO} mkdir -p /run/sshd
fi
${SUDO} /usr/sbin/sshd

# Create nixbld group and build users (required even for single-user when running as root)
${SUDO} groupadd -f nixbld
for i in $(seq 1 10); do
  ${SUDO} useradd -M -N -G nixbld -s /sbin/nologin nixbld$i 2>/dev/null || true
done

# Install Nix (single-user installation)
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --no-daemon

# Source Nix profile
export PATH=${PATH}:${HOME}/.nix-profile/bin
source ${HOME}/.nix-profile/etc/profile.d/nix.sh

# Configure Nix channels
nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
nix-channel --update



nix --extra-experimental-features flakes --extra-experimental-features nix-command profile add  nixpkgs#chezmoi
chezmoi init https://supercoolgreatcoder:${GH_TOKEN}@github.com/supercoolgreatcoder/dotfiles.git
chezmoi apply --exclude=encrypted

nix profile remove chezmoi
nix profile install github:supercoolgreatcoder/common-flake#dev --no-write-lock-file --refresh

source ~/.profile
