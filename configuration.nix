{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./cachix.nix
  ];

  # === Packages and programs ===
  environment.systemPackages =
    with pkgs;
    [
      # Desktop
      polkit_gnome
      libnotify
      glib
      firefox
      chromium
      mpv
      qbittorrent
      zathura
      thunderbird
      feh
      imv
      imagemagick
      krita
      file-roller
      kdePackages.dolphin
      signal-desktop
    ]
    ++ [
      # Programming languages
      erlang
      gcc
      clang
      rustup
      zig
      go
      swi-prolog
      trealla
      clojure
      gforth
      squeak
      guile
      (julia-bin.overrideAttrs { installCheckPhase = ""; })
      (python313.withPackages (
        ps: with ps; [
          numpy
          matplotlib
          scipy
          sympy
          pandas
          requests
          beautifulsoup4
          lxml
          flask
          pytest
          hypothesis
        ]
      ))
      wasm-pack
      wasm-tools
      binaryen
      valgrind
      wasmtime
      typst
      sqlite
    ]
    ++ [
      # Programming tools, linters and LSPs
      pixi
      gradle
      leiningen
      libllvm
      tree-sitter
      gnumake
      clang-tools
      zls
      gdb
      nixd
      nixfmt-rfc-style
      lua-language-server
      gopls
      jdt-language-server
      clojure-lsp
      cljfmt
      tinymist
      nodePackages.bash-language-server
      nodePackages.typescript-language-server
      pyright
      black
      meld
      vscode
    ]
    ++ [
      # Audio and music
      pavucontrol
      qpwgraph
      yabridge
      yabridgectl
      reaper
      #carla
      guitarix
      gxplugins-lv2
      distrho-ports
      musescore
      obs-studio
    ]
    ++ [
      # CLI
      cowsay
      cmatrix
      hyfetch
      dragon-drop
      tmux
      zellij
      neovim
      helix
      newsboat
      jq
      unzip
      atool
      btop
      duf
      dust
      lshw
      usbutils
      fzf
      ripgrep
      fd
      bat
      git
      jujutsu
      nushell
      carapace
      fish
      p7zip
      unrar-wrapper
      libsixel
      file
      tokei
      btrfs-progs
      pciutils
      lsof
      compsize
      ghostscript
      nvd
      tree
      bash-env-json
      wl-clipboard
      perf
      rlwrap
      tailscale
      delta
      broot
      zoxide
    ]
    ++ [
      godot
      desmume
      mgba
      pcsx2
      mupen64plus
    ]
    ++ [
      # Graphics and Wayland
      qt5.qtwayland
      vulkan-tools
      mesa-demos
    ]
    ++ [
      # Formal methods
      tlaplusToolbox
      tlaplus18
      coq
      nusmv
    ]
    ++ [
      # Themes
      gnome-themes-extra
      adwaita-icon-theme
      adwaita-qt
      adwaita-qt6
      libsForQt5.qt5ct
    ]
    ++ [
      # Networking
      netcat-openbsd
      nmap
      dig
    ]
    ++ [
      # Wine and gaming
      wineWowPackages.stable
      winetricks
      prismlauncher
      protontricks
      (import inputs.nixpkgs-df { system = "x86_64-linux"; config.allowUnfree = true; }).dfhack
      openmw
    ]
    ++ [
      # Documentation
      man-pages
      man-pages-posix
      tldr
    ]
    ++ [
      # Embedded
      tio
      arduino-ide
      hexedit
    ]
    ++ [
      # Misc
      cachix
      antimicrox
      gparted
      datefudge
      wev
      keyd
      distrobox
      graphviz
      hledger
      hledger-ui
      hledger-web
    ];

  programs.java = {
    enable = true;
    binfmt = true;
  };
  programs.light.enable = true;
  programs.adb.enable = true;

  # === Nix and Nixpkgs settings ===
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: {
    # For gamescope
    # See: https://github.com/NixOS/nixpkgs/issues/162562#issuecomment-1229444338
    steam = pkgs.steam.override {
      extraPkgs =
        pkgs: with pkgs; [
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
          libpng
          libpulseaudio
          libvorbis
          libkrb5
          keyutils
          stdenv.cc.cc.lib
        ];
    };
    # Sixel support in mpv
    mpv-unwrapped = pkgs.mpv-unwrapped.override {
      sixelSupport = true;
    };
  };

  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  nix.registry = {
    nixpkgs.flake = inputs.nixpkgs;
  };
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  # === Graphics ===
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    #powerManagement.enable = true;
    #powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    forceFullCompositionPipeline = true;
    #package = config.boot.kernelPackages.nvidiaPackages.latest;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
    };
  };

  # === Boot and kernel ===
  boot.supportedFilesystems = [ "ntfs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;

  # === Filesystems ===
  boot.tmp.useTmpfs = true;
  fileSystems = {
    "/nix".options = [ "noatime" ];
  };

  # === Networking ===
  networking.hostName = "kbook";

  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      8000
      5000
      5900
      3000
    ];
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      conf-dir = "/etc/dnsmasq-conf.d";
    };
  };

  # === Locale and keyboard ===
  time.timeZone = "America/Sao_Paulo";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
  };
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-rime
      fcitx5-gtk
    ];
  };

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            # This was getting very annoying
            #capslock = "overload(caps_layer, esc)";
            capslock = "esc";
            rightalt = "backspace";
            backspace = "compose";
            #backspace = "noop";
            #"102nd" = "overload(102nd_layer, compose)";
          };
        };
      };
    };
  };

  # === Users and groups ===
  users.users.kaue = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "adbusers"
      "dialout"
      "podman"
      "libvirtd"
    ];
  };

  # === Authentication ===
  security.polkit.enable = true;
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    user.targets.sway-session = {
      wants = [ "graphical-session.target" ];
    };
  };

  # === Audio ===
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    wireplumber.enable = true;
  };
  musnix.enable = true;

  # === Documentation ===
  documentation.dev.enable = true;
  documentation.man = {
    enable = true;
    generateCaches = true;
  };

  # === Dynamic linking and nix-ld ===
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    alsa-lib
    pipewire
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    pango
    cups
    fontconfig
    freetype
    curl
    zlib
    openssl
    readline
    expat
    fuse3
    gdk-pixbuf
    glib
    gtk3
    systemd
    glibc
    dbus
    stdenv.cc.cc
    libGL
    libappindicator-gtk3
    libdrm
    libglvnd
    libnotify
    libpulseaudio
    libunwind
    libusb1
    libuuid
    libxkbcommon
    libxml2
    nspr
    nss
    icu
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libxcb
    xorg.libxkbfile
    xorg.libxshmfence
    blas
    lapack
    vulkan-loader
    mesa
    SDL2
    SDL2_image
    #config.boot.kernelPackages.nvidia_x11
    config.hardware.nvidia.package
  ];

  # === Fonts ===
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.fira-code
    corefonts
    liberation_ttf
    unifont
    unifont_upper
    wqy_zenhei
  ];
  fonts.fontDir.enable = true;

  # === Window management and Wayland ===
  programs.sway = {
    enable = true;
    extraOptions = [ "--unsupported-gpu" ];
    extraSessionCommands = ''
      export QT_QPA_PLATFORM=wayland-egl
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';
    extraPackages = with pkgs; [
      foot
      bemenu
      dunst
      sway-contrib.grimshot
      wlsunset
      waybar
    ];
  };
  programs.xwayland.enable = true;

  # === XDG Portals ===
  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  xdg.portal.wlr.enable = true;

  # === Gaming ===
  programs.steam.enable = true;
  programs.gamescope.enable = true;

  # === Environment ===
  environment.localBinInPath = true;
  environment.sessionVariables = rec {
    VISUAL = "hx";
    EDITOR = VISUAL;
    BROWSER = "firefox";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    GTK_THEME = "Adwaita:dark";
    GTK_A11Y = "atspi";
  };

  xdg.mime = {
    enable = true;
    defaultApplications = {
      "image/png" = "feh.desktop";
      "image/jpeg" = "feh.desktop";
    };
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  services.flatpak.enable = true;
  programs.direnv.enable = true;

  # === Accessibility ===
  services.gnome.at-spi2-core.enable = true;
  services.orca.enable = true;

  # === Containers ===
  hardware.nvidia-container-toolkit.enable = true;
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # === Tailscale ===
  services.tailscale.enable = true;

  # === Virtualization ===
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # === Swap ===
  zramSwap.enable = true;

  system.stateVersion = "23.11";

  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';
}
