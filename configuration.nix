{
  config,
  pkgs,
  ... 
}: {
  imports = [
      ./hardware-configuration.nix
  ];

  # === Packages === 
  environment.systemPackages = with pkgs; let
    wine = wineWowPackages.stable;
  in [
    cachix
    cowsay cmatrix
    polkit_gnome
    firefox chromium mpv qbittorrent krita zathura
    antimicrox
    gparted
    appimage-run
    xdragon
    feh imagemagick
    libsForQt5.dolphin
    libsForQt5.qt5ct
    qt5.qtwayland
    adwaita-qt
    adwaita-qt6
    gnome-themes-extra
    adwaita-icon-theme
    glib
    vulkan-tools
    wine winetricks
    tmux neovim newsboat jq unzip
    btop duf du-dust lshw fzf ripgrep fd
    gcc clang-tools
    gradle gnumake
    go swi-prolog clojure
    # julia-bin is not in the cache yet for some reason
    #julia-bin
    julia
    rustup pixi 
    (python312.withPackages (ps: with ps; [
      numpy matplotlib scipy sympy pandas
      requests beautifulsoup4 lxml
      flask
      pytest hypothesis
    ]))
    git
    nushell carapace fish
    nixd lua-language-server gopls jdt-language-server clojure-lsp
    nodePackages.bash-language-server nodePackages.typescript-language-server
    pyright black
    pavucontrol qpwgraph
    (yabridge.override { inherit wine; }) (yabridgectl.override { inherit wine; })
    reaper carla guitarix gxplugins-lv2
    # https://github.com/NixOS/nixpkgs/issues/348871
    #distrho
    musescore
    neofetch cmatrix
    desmume mgba pcsx2
    (retroarch.override { cores = with libretro; [
      mupen64plus
    ];})
    glxinfo
    man-pages man-pages-posix tldr
    p7zip unrar-wrapper
    tlaplusToolbox coq coqPackages.coqide
    nusmv
    tigervnc
    thunderbird signal-desktop
    file-roller
    libsixel libnotify
    datefudge trealla
    tio arduino-ide hexedit
    texliveFull
    file gdb
    netcat-openbsd nmap dig
    orca at-spi2-atk
  ];

  # === Nix and Nixpkgs settings === 
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: {
    # For gamescope
    # See: https://github.com/NixOS/nixpkgs/issues/162562#issuecomment-1229444338
    steam = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        xorg.libXcursor xorg.libXi xorg.libXinerama xorg.libXScrnSaver
        libpng libpulseaudio libvorbis
        libkrb5 keyutils
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
    experimental-features = [ "nix-command" "flakes" ];
  };
  nix.registry = {
    nixpkgs.to = {
      type = "path";
      path = pkgs.path;
    };
  };

  # === Graphics ===
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
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

  # === Networking ===
  networking.hostName = "kbook";

  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 8000 5000 3000 ];
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
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };
  services.xserver.xkb.extraLayouts = {
    dvpk = {
      description = "Customized Programmer's Dvorak";
      languages = ["eng"];
      symbolsFile = builtins.toFile "dvpk" ''
        xkb_symbols "dvpk" {
          include "us(dvp)"
          key <SCLK> { [ Multi_key ] };
          key <BKSP> { [ VoidSymbol ] };
          key <CAPS> { [ Escape ] };
          key <RALT> { 
              type = "TWO_LEVEL",
              symbols = [ BackSpace, BackSpace ]
          };
        };
      '';
    };
    br-abnt2k = {
      description = "Customized br-abnt2";
      languages = ["por"];
      symbolsFile = builtins.toFile "abnt2k" ''
        xkb_symbols "abnt2k" {
          include "br(abnt2)"
          key <SCLK> { [ Multi_key ] };
          key <BKSP> { [ VoidSymbol ] };
          key <CAPS> { [ Escape ] };
          key <RALT> { 
              type = "TWO_LEVEL",
              symbols = [BackSpace, BackSpace]
          };
        };
      '';
    };
  };

  # === Users and groups ===
  users.users.kaue = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "adbusers" "dialout" "podman" ];
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
    alsa-lib pipewire
    at-spi2-atk at-spi2-core atk
    cairo pango cups fontconfig freetype
    curl zlib openssl readline
    expat fuse3
    gdk-pixbuf glib gtk3
    systemd glibc dbus stdenv.cc.cc
    libGL libappindicator-gtk3 libdrm libglvnd libnotify libpulseaudio libunwind
    libusb1 libuuid libxkbcommon libxml2
    nspr nss icu
    xorg.libX11 xorg.libXScrnSaver xorg.libXcomposite xorg.libXcursor xorg.libXdamage
    xorg.libXext xorg.libXfixes xorg.libXi xorg.libXrandr xorg.libXrender xorg.libXtst
    xorg.libxcb xorg.libxkbfile xorg.libxshmfence
    blas lapack
    vulkan-loader mesa config.boot.kernelPackages.nvidia_x11
  ];

  # === Fonts ===
  fonts.packages = with pkgs; [
    noto-fonts noto-fonts-cjk-sans noto-fonts-emoji
    nerdfonts corefonts liberation_ttf
    unifont unifont_upper
    wqy_zenhei
  ];
  fonts.fontDir.enable = true;

  # === Window management and Wayland ===
  programs.sway = {
    enable = true;
    extraOptions = ["--unsupported-gpu"];
    extraSessionCommands = ''
      export QT_QPA_PLATFORM=wayland-egl
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';
    extraPackages = with pkgs; [
      foot bemenu dunst sway-contrib.grimshot
      wlsunset waybar
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

  programs.direnv.enable = true;

  # === Flatpak ===
  services.flatpak.enable = true;

  # === Environment ===
  environment.localBinInPath = true;
  environment.sessionVariables = rec {
    VISUAL = "nvim";
    EDITOR = VISUAL;
    BROWSER = "firefox";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    GTK_THEME = "Adwaita:dark";
  };

  xdg.mime = {
    enable = true;
    defaultApplications = {
      "image/png" = "feh.desktop";
      "image/jpeg" = "feh.desktop";
    };
  };

  programs.java = {
    enable = true;
    binfmt = true;
  };
  programs.light.enable = true;
  programs.adb.enable = true;

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

  # === Swap ===
  swapDevices = [{
    device = "/swapfile";
    size = 12*1024; # 12GiB
  }];

  system.stateVersion = "23.11";
}
