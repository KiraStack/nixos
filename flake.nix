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
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # flake-utils.url = "github:numtide/flake-utils";
    aagl = {
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
                backupFileExtension = "backup";
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
                      home.packages = with pkgs; [
                        bibata-cursors
                        bitwarden-desktop
                        # sober # deprecated: use `flatpak install flathub org.vinegarhq.Sober` instead.
                        vesktop
                        # vinegar # deprecated: use `flatpak install flathub org.vinegarhq.Vinegar` instead.
                        vscode
                      ];

                      # Deploy custom client configuration per-user.
                      home.file = {
                        # System-wide configuration.
                        "/etc/pulse" = {
                          source = ./components/pulse;
                          recursive = true;
                        };
                        "/home/archie/.scripts" = {
                          source = ./scripts;
                          recursive = true;
                        };

                        # User configuration directories.
                        "/home/archie/.config/cava" = {
                          source = ./components/cava;
                          recursive = true;
                        };
                        "/home/archie/.config/discord" = {
                          source = ./components/discord;
                          recursive = true;
                        };
                        "/home/archie/.config/dunst" = {
                          source = ./components/dunst;
                          recursive = true;
                        };
                        "/home/archie/.config/fastfetch" = {
                          source = ./components/fastfetch;
                          recursive = true;
                        };
                        "/home/archie/.config/fish" = {
                          source = ./components/fish;
                          recursive = true;
                        };
                        "/home/archie/.config/gtk-3.0" = {
                          source = ./components/gtk-3.0;
                          recursive = true;
                        };
                        "/home/archie/.config/gtk-4.0" = {
                          source = ./components/gtk-4.0;
                          recursive = true;
                        };
                        "/home/archie/.config/hypr" = {
                          source = ./components/hypr;
                          recursive = true;
                        };
                        "/home/archie/.config/htop" = {
                          source = ./components/htop;
                          recursive = true;
                        };
                        "/home/archie/.config/kitty" = {
                          source = ./components/kitty;
                          recursive = true;
                        };
                        "/home/archie/.config/neofetch" = {
                          source = ./components/neofetch;
                          recursive = true;
                        };
                        "/home/archie/.config/nvim" = {
                          source = ./components/nvim;
                          recursive = true;
                        };
                        "/home/archie/.config/ranger" = {
                          source = ./components/ranger;
                          recursive = true;
                        };
                        "/home/archie/.config/rofi" = {
                          source = ./components/rofi;
                          recursive = true;
                        };
                        "/home/archie/.config/starship" = {
                          source = ./components/starship;
                          recursive = true;
                        };
                        "/home/archie/.config/wofi" = {
                          source = ./components/wofi;
                          recursive = true;
                        };
                        "/home/archie/.config/.zshrc" = {
                          source = ./components/.zshrc;
                          recursive = true;
                        };
                        "/home/archie/.config/zsh" = {
                          source = ./components/zsh;
                          recursive = true;
                        };
                      };
                    };
                };
              };
            }

            # Main inline NixOS module.
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
                  networkmanager.enable = true;
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
                nixpkgs.config = {
                  allowUnfree = true;
                  allowUnfreePredicate =
                    pkg:
                    builtins.elem (lib.getName pkg) [
                      "vscode"
                      "steam"
                      "steam-unwrapped"
                    ];
                };

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
                  };
                  fish = {
                    enable = true;
                  };
                  neovim = {
                    enable = true;
                    defaultEditor = true;
                  };
                  firefox = {
                    enable = true;
                    languagePacks = [
                      # Available languages can be found in https://releases.mozilla.org/pub/firefox/releases/${cfg.package.version}/linux-x86_64/xpi/
                      "en-GB"
                      "en-US"
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
                        # Close up all addons except the ones specified below.
                        "*".installation_mode = "blocked";

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
                  steam = {
                    enable = true;
                    package = pkgs.steam;
                  };
                  anime-games-launcher = {
                    # creates launcher and /etc/hosts rules.
                    # `hoyoverse, kuro games, mrdrnose`.
                    enable = true;
                  };
                  obs-studio = {
                    enable = true;
                    package = (
                      pkgs.obs-studio.override {
                        cudaSupport = true;
                      }
                    );
                    plugins = with pkgs.obs-studio-plugins; [
                      wlrobs
                      obs-backgroundremoval
                      obs-pipewire-audio-capture
                      obs-vaapi # AMD hardware acceleration
                      obs-gstreamer
                      obs-vkcapture
                    ];
                  };
                };

                # Manage service configurations declaratively.
                services = {
                  xserver = {
                    desktopManager.xterm.enable = false;
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
                    enable = false;
                  };
                  pipewire = {
                    enable = true;
                    alsa = {
                      enable = true;
                      support32Bit = true;
                    };
                    pulse = {
                      enable = true;
                    };
                    extraConfig.pipewire."91-null-sinks" = {
                      "context.objects" = [
                        # https://docs.pipewire.org/page_man_pipewire_conf_5.html#pipewire_conf__context_objects
                        {
                          factory = "adapter";
                          args = {
                            "factory.name" = "support.null-audio-sink"; # "api.alsa.pcm.source"? -- also couldnt find any documentation on this
                            "node.name" = "Microphone-Proxy";
                            "node.description" = "micspam";
                            "media.class" = "Audio/Source/Virtual"; # "Audio/Source"? -- "Audio/Sink"?
                            "audio.position" = "MONO"; # "FL,FR"
                            # "priority.driver" = 8000; # sources = 1600-2000; sinks = 600-1000 -- redundant IF the only microphone
                            # "priority.session" = 8000; # sources = 1600-2000; sinks = 600-1000 -- redundant IF the only microphone
                            "node.dont-fallback" = true; # "node.autoconnect"?
                            "object.linger" = true; # keep linked even if destroyed -- DOESNT WORK BTW
                            # ...
                          };
                        }
                      ];
                    };
                  };
                  flatpak = {
                    # to enable it,
                    # run `flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo`.
                    enable = true;
                  };
                  dunst = {
                    enable = true;
                  };
                  greetd = {
                    enable = false;
                  };
                };

                # Configure hardware-related configs
                hardware = {
                  bluetooth = {
                    enable = true;
                  };
                  graphics = {
                    enable = true;
                  };
                };

                # Environment variables exported per-user in sessions.
                # For more on rec expressions see https://nix.dev/tutorials/first-steps/nix-language#recursive-attribute-set-rec
                environment.sessionVariables = rec {
                  # Programs
                  TERMINAL = "kitty";
                  BROWSER = "firefox";
                  VISUAL = "nvim";
                  EDITOR = "nvim";

                  # XDG directories
                  XDG_CACHE_HOME = "$HOME/.cache";
                  XDG_CONFIG_HOME = "$HOME/.config";
                  XDG_DATA_HOME = "$HOME/.local/share";
                  XDG_STATE_HOME = "$HOME/.local/state";
                  XDG_BIN_HOME = "$HOME/.local/bin";
                  XDG_DOCUMENTS_DIR = "$HOME/Documents";
                  XDG_MUSIC_DIR = "$HOME/Music";
                  XDG_PICTURES_DIR = "$HOME/Pictures";
                  XDG_SCREENSHOTS_DIR = "$XDG_PICTURES_DIR/Screenshots";

                  # Environment variables
                  PATH = [
                    "$HOME/.spicetify"
                    "$HOME/.scripts"
                    "$HOME/.local/bin"
                    "$HOME/.cargo/bin"
                  ];

                  # Wayland variables
                  WLR_NO_HARDWARE_CURSORS = lib.mkIf use_nvidia "1"; # if your cursor becomes invis.
                  NIXOS_OZONE_WL = "1";
                };

                # List packages installed in system profile.
                # You can use https://search.nixos.org/ to find more packages (and options).
                environment.systemPackages = with pkgs; [
                  # System
                  acpi
                  age
                  cava
                  cliphist
                  dunst
                  fzf
                  htop
                  ladspaPlugins
                  pipewire
                  ripgrep
                  unzip
                  wireplumber

                  # Display (wayland)
                  kitty
                  hyprpaper
                  mpv
                  neofetch
                  ranger
                  rofi # or: rofi-wayland
                  waybar
                  (waybar.overrideAttrs (attrs: {
                    mesonFlags = attrs.mesonFlags ++ [ "-Dexperimental=true" ];
                  }))

                  # Tools
                  git
                  grim
                  slurp
                  wl-clipboard
                  jq
                  nixfmt
                ];

                # Enable portals (how programs interact with each other).
                xdg = {
                  portal = {
                    enable = true;
                    extraPortals = with pkgs; [
                      xdg-desktop-portal-wlr
                      xdg-desktop-portal-gtk
                      xdg-desktop-portal-hyprland
                    ];
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
