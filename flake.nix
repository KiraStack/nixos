# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NOTE: Ensure /etc/nixos is owned by root to allow flake-based rebuilds:
# doas chown -R root:root /etc/nixos
# Then rebuild with: doas nixos-rebuild switch --flake /etc/nixos/

{
  description = "None";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    aagl = {
      # url = "github:ezKEa/aagl-gtk-on-nix/release-25.11"; # deprecated.
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # for `genshin`.
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      use_nvidia = true; # Enable NVIDIA features.
      lock_false = {
        Value = false;
        Status = "locked";
      };
      lock_true = {
        Value = true;
        Status = "locked";
      };
      mkSystem =
        hostname:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            # Hardware config.
            ./hardware-configuration.nix

            # Add home manager mod.
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users = {
                  archie =
                    {
                      config,
                      lib,
                      pkgs,
                      ...
                    }:
                    {
                      # Set home vars.
                      home.username = "archie";
                      home.homeDirectory = "/home/archie";
                      home.stateVersion = "25.11";

                      # Specify user-scoped packages.
                      # Makes sense for user-specific apps that shouldn't be available system-wide.
                      home.packages = [
                        pkgs.bibata-cursors
                        pkgs.bitwarden-desktop
                      ];

                      # Map dotfiles to source directories.
                      home.file = {
                        "$HOME/.config/discord".source = ./components/discord;
                        "$HOME/.config/dunst".source = ./components/dunst;
                        "$HOME/.config/fastfetch".source = ./components/fastfetch;
                        "$HOME/.config/fish".source = ./components/fish;
                        "$HOME/.config/hypr".source = ./components/hypr;
                        "$HOME/.config/htop".source = ./components/htop;
                        "$HOME/.config/kitty".source = ./components/kitty;
                        "$HOME/.config/neofetch".source = ./components/neofetch;
                        "$HOME/.config/nvim".source = ./components/nvim;
                        "$HOME/.config/starship".source = ./components/starship;
                        "$HOME/.config/wofi".source = ./components/wofi;
                        "$HOME/.config/zshrc".source = ./components/zsh;
                        "$HOME/.scripts".source = ./scripts; # map `scripts` folder to base.
                      };

                      # Environment variables exported in user sessions.
                      home.sessionVariables = {
                        WLR_NO_HARDWARE_CURSORS = lib.mkIf use_nvidia "1"; # if your cursor becomes invis.
                        NIXOS_OZONE_WL = "1";
                      };

                      # Extra PATH entries appended to the user environment.
                      home.sessionPath = [ ];
                    };
                };
              };
            }

            # Main inline NixOS module.
            # This anonymous function returns the base system configuration for the host.
            (
              {
                config,
                lib,
                pkgs,
                ...
              }:
              {
                # Import external modules
                # (e.g. to add new system options).
                imports = [ inputs.aagl.nixosModules.default ];

                # Configure network connections.
                networking = {
                  hostName = "archie";
                  networkmanager = {
                    enable = true;
                  };
                  wireless.iwd = {
                    enable = false;
                  };
                  firewall = {
                    enable = true;
                    allowedTCPPorts = [
                      443
                      80
                    ];
                    allowedUDPPorts = [
                      443
                      80
                      44857
                    ];
                    allowPing = false;
                  };
                };

                # Define your user.
                users.users.archie = {
                  isNormalUser = true;
                  shell = pkgs.fish;
                  extraGroups = [
                    "wheel"
                    "networkmanager"
                    "audio"
                  ];
                  # For security, do not store passwords in plain text.
                  # Instead, leave it out for manual setup or use hashed passwords
                  password = ""; # Remove plain text password
                };

                # Remove unecessary preinstalled packages.
                environment.defaultPackages = [ ];

                # Allow 'unfree' packages (for specific packages).
                nixpkgs.config.allowUnfreePredicate =
                  pkg:
                  builtins.elem (lib.getName pkg) [
                    "vscode"
                    "steam-unwrapped"
                  ];

                # Manage program configurations declaratively.
                programs = {
                  hyprland = {
                    enable = true;
                    xwayland.enable = lib.mkIf use_nvidia true;
                  };
                  dconf.profiles.user.databases = [
                    {
                      settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
                    }
                  ];
                  git = {
                    enable = true;
                    # settings = {
                    #   user = {
                    #     name = "google";
                    #     email = "google@gmail.com";
                    #   };
                    #   init.defaultBranch = "main";
                    # }; # refer to `.config` instead.
                  };
                  fish = {
                    enable = true;
                    interactiveShellInit = ''
                      set fish_greeting ""
                    '';
                  };
                  starship = {
                    enable = true;
                  };
                  neovim = {
                    enable = true;
                    defaultEditor = true;
                    # plugins = with pkgs.vimPlugins; [ ]; # refer to `.config` instead.
                  };
                  firefox = {
                    enable = true;
                    languagePacks = [
                      # Available languages can be found in https://releases.mozilla.org/pub/firefox/releases/${cfg.package.version}/linux-x86_64/xpi/
                      # "ach"
                      # "af"
                      # "an"
                      # "ar"
                      # "ast"
                      # "az"
                      # "be"
                      # "bg"
                      # "bn"
                      # "br"
                      # "bs"
                      # "ca-valencia"
                      # "ca"
                      # "cak"
                      # "cs"
                      # "cy"
                      # "da"
                      # "de"
                      # "dsb"
                      # "el"
                      # "en-CA"
                      "en-GB"
                      "en-US"
                      # "eo"
                      # "es-AR"
                      # "es-CL"
                      # "es-ES"
                      # "es-MX"
                      # "et"
                      # "eu"
                      # "fa"
                      # "ff"
                      # "fi"
                      # "fr"
                      # "fur"
                      # "fy-NL"
                      # "ga-IE"
                      # "gd"
                      # "gl"
                      # "gn"
                      # "gu-IN"
                      # "he"
                      # "hi-IN"
                      # "hr"
                      # "hsb"
                      # "hu"
                      # "hy-AM"
                      # "ia"
                      # "id"
                      # "is"
                      # "it"
                      # "ja"
                      # "ka"
                      # "kab"
                      # "kk"
                      # "km"
                      # "kn"
                      # "ko"
                      # "lij"
                      # "lt"
                      # "lv"
                      # "mk"
                      # "mr"
                      # "ms"
                      # "my"
                      # "nb-NO"
                      # "ne-NP"
                      # "nl"
                      # "nn-NO"
                      # "oc"
                      # "pa-IN"
                      # "pl"
                      # "pt-BR"
                      # "pt-PT"
                      # "rm"
                      # "ro"
                      # "ru"
                      # "sat"
                      # "sc"
                      # "sco"
                      # "si"
                      # "sk"
                      # "skr"
                      # "sl"
                      # "son"
                      # "sq"
                      # "sr"
                      # "sv-SE"
                      # "szl"
                      # "ta"
                      # "te"
                      # "tg"
                      # "th"
                      # "tl"
                      # "tr"
                      # "trs"
                      # "uk"
                      # "ur"
                      # "uz"
                      # "vi"
                      # "xh"
                      # "zh-CN"
                      # "zh-TW"
                    ];
                    policies = {
                      DisableTelemetry = true;
                      DisableFirefoxStudies = true;
                      EnableTrackingProtection = {
                        Value = true;
                        Locked = true;
                        Cryptomining = true;
                        Fingerprinting = true;
                      };
                      DisablePocket = true;
                      DisableFirefoxAccounts = true;
                      DisableAccounts = true;
                      DisableFirefoxScreenshots = true;
                      OverrideFirstRunPage = "";
                      OverridePostUpdatePage = "";
                      DontCheckDefaultBrowser = true;
                      DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
                      DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
                      SearchBar = "unified"; # alternative: "separate"

                      # Check about:support for extension/add-on ID strings.
                      # Valid strings for installation_mode are "allowed", "blocked", "normal_installed" and "force_installed"
                      ExtensionSettings = {
                        "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
                        # Decentraleyes:
                        "jid1-BoFifL9Vbdl2zQ@jetpack" = {
                          install_url = "https://addons.mozilla.org/firefox/downloads/latest/decentraleyes/latest.xpi";
                          installation_mode = "force_installed";
                        };

                        # uBlock Origin:
                        "uBlock0@raymondhill.net" = {
                          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
                          installation_mode = "force_installed";
                        };

                        # ClearURLs:
                        "{74145f27-f039-47ce-a470-a662b129930a}" = {
                          install_url = "https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi";
                          installation_mode = "force_installed";
                        };

                        # SponsorBlock:
                        "sponsorBlocker@ajay.app" = {
                          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
                          installation_mode = "force_installed";
                        };

                        # Dark Reader:
                        "addon@darkreader.org" = {
                          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
                          installation_mode = "force_installed";
                        };

                        # Enhanced h264ify:
                        "enhanced-h264ify@unrelenting.technology" = {
                          install_url = "https://addons.mozilla.org/firefox/downloads/latest/enhanced-h264ify/latest.xpi";
                          installation_mode = "force_installed";
                        };

                        # DF YouTube:
                        "dfyoutube@example.com" = {
                          install_url = "https://addons.mozilla.org/firefox/downloads/latest/df-youtube/latest.xpi";
                          installation_mode = "force_installed";
                        };

                        # Bitwarden:
                        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
                          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
                          installation_mode = "force_installed";
                        };
                      };

                      # Check about:config for options.
                      Preferences = {
                        "browser.contentblocking.category" = {
                          Value = "strict";
                          Status = "locked";
                        };
                        "extensions.pocket.enabled" = lock_false;
                        "extensions.screenshots.disabled" = lock_true;
                        "browser.topsites.contile.enabled" = lock_false;
                        "browser.formfill.enable" = lock_false;
                        "browser.search.suggest.enabled" = lock_false;
                        "browser.search.suggest.enabled.private" = lock_false;
                        "browser.urlbar.suggest.searches" = lock_false;
                        "browser.urlbar.showSearchSuggestionsFirst" = lock_false;
                        "browser.newtabpage.activity-stream.feeds.section.topstories" = lock_false;
                        "browser.newtabpage.activity-stream.feeds.snippets" = lock_false;
                        "browser.newtabpage.activity-stream.section.highlights.includePocket" = lock_false;
                        "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = lock_false;
                        "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = lock_false;
                        "browser.newtabpage.activity-stream.section.highlights.includeVisited" = lock_false;
                        "browser.newtabpage.activity-stream.showSponsored" = lock_false;
                        "browser.newtabpage.activity-stream.system.showSponsored" = lock_false;
                        "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock_false;
                      };
                    };
                  };
                  anime-games-launcher = {
                    # `hoyoverse|kuro games|mrdrnose`.
                    # creates launcher and /etc/hosts rules.
                    enable = true;
                  };
                };

                # Manage service configurations declaratively.
                services = {
                  xserver = {
                    desktopManager = {
                      xterm = {
                        enable = false;
                      };
                    };
                  };
                  displayManager = {
                    ly = {
                      enable = true;
                      settings = {
                        bg = "0x00000000";
                        fg = "0x00FFFFFF";
                        border_fg = "0x00FFFFFF";
                        error_fg = "0x00FF0000";
                        clock_color = "0x00FFFFFF";
                      };
                    };
                  };
                  pulseaudio = {
                    enable = true;
                  };
                  pipewire = {
                    enable = false;
                    alsa = {
                      enable = true;
                      support32Bit = true;
                    };
                    pulse = {
                      enable = true;
                    };
                  };
                  flatpak = {
                    # to enable it,
                    # run `flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo`.
                    enable = true;
                  };
                  dunst = {
                    enable = true;
                    # settings.global = {} # refer to `.config` instead.
                  };
                  greetd = {
                    enable = false;
                  };
                };

                # Configure hardware-related configs
                hardware = {
                  bluetooth = {
                    enable = false;
                  };
                  graphics = {
                    enable = true;
                  };
                };

                # Enable sound (using `pulseaudio`).
                # sound = { enable = true; }; # deprecated.

                # List packages installed in system profile.
                # You can use https://search.nixos.org/ to find more packages (and options).
                environment.systemPackages = with pkgs; [
                  # System
                  pkgs.acpi
                  pkgs.age
                  pkgs.dunst
                  pkgs.fzf
                  pkgs.gnupg
                  pkgs.htop
                  pkgs.libnotify
                  pkgs.ripgrep
                  pkgs.unzip

                  # Display (wayland)
                  pkgs.kitty
                  pkgs.mpv
                  pkgs.neofetch
                  pkgs.hyprpaper
                  pkgs.rofi # old: pkgs.rofi-wayland
                  pkgs.vesktop
                  # pkgs.vinegar # deprecated: use `flatpak install flathub org.vinegarhq.Vinegar` instead.
                  pkgs.vscode
                  pkgs.waybar
                  (pkgs.waybar.overrideAttrs (attrs: {
                    mesonFlags = attrs.mesonFlags ++ [ "-Dexperimental=true" ];
                  }))

                  # Fonts
                  pkgs.jetbrains-mono

                  # Tools
                  pkgs.grim # screenshots
                  pkgs.slurp # area selection
                  pkgs.hyprpicker # optional: freeze screen selection
                  pkgs.wl-clipboard # wl-copy
                  pkgs.jq # JSON parsing
                  pkgs.nixfmt
                  pkgs.python3
                  pkgs.starship

                  # Extra (optional)
                  pkgs.bat # syntax-highlighting cat
                  pkgs.fd # alternative to find
                  pkgs.ripgrep # already included, but good for search
                  pkgs.unzip # already included
                  pkgs.wget
                  pkgs.curl
                  pkgs.git
                ];

                # Enable portals (how programs interact with each other).
                xdg = {
                  portal = {
                    enable = true;
                    extraPortals = with pkgs; [
                      xdg-desktop-portal-wlr
                      xdg-desktop-portal-gtk
                    ];
                    # gtkUsePortal = true; # deprecated.
                  };
                };

                # Nix configuration settings.
                nix = {
                  settings.auto-optimise-store = true;
                  settings.allowed-users = [ "archie" ];
                  gc = {
                    automatic = true;
                    dates = "weekly";
                    options = "--delete-older-than 7d";
                  };
                  extraOptions = ''
                    experimental-features = nix-command flakes
                    keep-outputs = true
                    keep-derivations = true
                  '';
                };

                # Bootloader and system startup configuration.
                boot = {
                  tmp = {
                    cleanOnBoot = true;
                  };
                  loader = {
                    systemd-boot.enable = true;
                    systemd-boot.editor = false;
                    efi.canTouchEfiVariables = true;
                    timeout = 0;
                  };
                };

                # Configure locales (timezone and keyboard layout)
                time.timeZone = "Europe/London";
                i18n.defaultLocale = "en_GB.UTF-8";
                console = {
                  font = "Lat2-Terminus16";
                  keyMap = "uk";
                };

                # System security configuration.
                security = {
                  sudo = {
                    enable = false;
                  };
                  doas = {
                    enable = true;
                    extraRules = [
                      {
                        users = [ "archie" ];
                        keepEnv = true;
                        persist = true;
                      }
                    ];
                  };
                  rtkit = {
                    enable = true;
                  };
                  protectKernelImage = true;
                };
                # Add global fonts available to all users and apps.
                fonts.packages = with pkgs; [
                  pkgs.nerd-fonts.jetbrains-mono
                ];

                # Store version for future updates
                # This option defines the first version of NixOS you have installed on this particular machine.
                system.stateVersion = "25.11";
              }
            )
          ];
        };
    in
    {
      # Generate system config by hostname
      nixosConfigurations = {
        archie = mkSystem "archie";
      };
    };
}
