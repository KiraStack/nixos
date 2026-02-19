# NixOS Configuration for User `archie`

PS: This setup was built for simplicity, providing just enough to be functional while staying fast and compact.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Getting Started](#getting-started)
- [Directory Structure](#directory-structure
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

A complete, lightweight dotfiles setup designed to be blazingly fast and efficient. It provides basic defaults and functionality while creating space for customization.

## Getting Started

### Quick Start (Handbook)

If you're installing NixOS from scratch, follow these steps:

#### Boot NixOS ISO

Download and boot the latest NixOS minimal ISO:
- [NixOS Downloads](https://nixos.org/download.html)

#### Partition your Disk

**Important**: Replace `/dev/nvme0n1` with your actual disk (check with `lsblk`)

**For UEFI Systems (recommended):**
```bash
# Partition scheme for desktop (separate /home partition)
sudo fdisk /dev/nvme0n1

# Create partitions:
# - 512MB EFI partition (type: EFI System)
# - Rest of disk for Btrfs root (type: Linux filesystem)
# - Optional: Separate partition for /home

# Example layout:
# /dev/nvme0n1p1 - EFI System Partition (512MB, FAT32)
# /dev/nvme0n1p2 - Root partition (Btrfs, rest of disk)
# /dev/nvme0n1p3 - Home partition (Btrfs, optional)

# Format partitions
sudo mkfs.fat -F32 /dev/nvme0n1p1
sudo mkfs.btrfs /dev/nvme0n1p2
sudo mkfs.btrfs /dev/nvme0n1p3  # Optional home partition

# Mount partitions
sudo mount /dev/nvme0n1p2 /mnt
sudo mkdir -p /mnt/home
sudo mount /dev/nvme0n1p3 /mnt/home  # If using separate home
sudo mkdir -p /mnt/boot
sudo mount /dev/nvme0n1p1 /mnt/boot
```

**For Laptops with single partition:**
```bash
# Partition scheme for laptop
sudo fdisk /dev/nvme0n1

# Create partitions:
# - 512MB EFI partition (type: EFI System)
# - Rest of disk for Btrfs root (type: Linux filesystem)

# Format partitions
sudo mkfs.fat -F32 /dev/nvme0n1p1
sudo mkfs.btrfs /dev/nvme0n1p2

# Mount partitions
sudo mount /dev/nvme0n1p2 /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/nvme0n1p1 /mnt/boot
```

#### Base NixOS System

```bash
# Generate hardware configuration
sudo nixos-generate-config --root /mnt

# Install minimal NixOS
sudo nixos-install

# Reboot into installed system
sudo reboot
```

#### Apply config

After rebooting into your newly installed NixOS:

```bash
# Run the installation script
curl -sSL https://raw.githubusercontent.com/KiraStack/nixos-config/main/install.sh | sudo bash
```

## Usage

- **Switching Configurations**: Use the `nixos-rebuild` command with flakes to switch between desktop and laptop configurations.
- **Home Manager**: Manage user environments declaratively. Changes in `hm.nix` and its modules can be applied with:

  ```bash
  home-manager switch
  ```

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests. When contributing, please follow the existing code style and structure.

## License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and distribute this software.

---

Thank you for exploring this NixOS configuration. If you have any questions or need assistance, feel free to reach out!
