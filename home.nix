{
  # FIXME: uncomment the next line if you want to reference your GitHub/GitLab access tokens and other secrets
  # secrets,
  config,
  pkgs,
  username,
  nix-index-database,
  lib,
  ...
}: let
  unstable-packages = with pkgs.unstable; [
    # FIXME: select your core binaries that you always want on the bleeding-edge
    bat
    bottom
    coreutils
    curl
    du-dust
    fd
    findutils
    git
    htop
    jq
    killall
    procs
    ripgrep
    sd
    silver-searcher
    tmux
    tree
    unzip
    wget
    zip

    # language servers
    ccls # c / c++
    gopls
    nodePackages.typescript-language-server
    pkgs.nodePackages.vscode-langservers-extracted # html, css, json, eslint
    nodePackages.yaml-language-server
    sumneko-lua-language-server
    nil # nix
    nodePackages.pyright
    typos-lsp
    marksman # Markdown
    terraform-lsp
    rubyPackages_3_2.ruby-lsp

    devenv
  ];

  stable-packages = with pkgs; [
    # FIXME: customize these stable packages to your liking for the languages that you use

    # key tools
    just
    lsd
    vivid
    fzy # A better fuzzy finder
    gron # Make JSON greppable!
    ctags
    typos

    wslu
    wsl-open

    # core languages
    rustup
    go
    lua
    nodejs
    python3

    # rust stuff
    cargo-cache
    cargo-expand

    # local dev stuff
    mkcert
    httpie

    # treesitter
    tree-sitter

    # docker stuff
    regctl # Docker and OCI Registry Client in Go and tooling using those libraries
    reg # Docker registry v2 command line client and repo listing generator with security checks


    # formatters and linters
    alejandra # nix
    black # python
    ruff # python
    deadnix # nix
    golangci-lint
    lua52Packages.luacheck
    nodePackages.prettier
    shellcheck
    shfmt
    statix # nix
    sqlfluff
    tflint

    #nerdfonts
    #(nerdfonts.override { fonts = [ "FiraCode" "CascadiaCode" "CascadiaMono" ]; })

    hyfetch

    # Modern encryption tool with small explicit keys
    age

    # Terminal JSON viewer
    fx

    # A tool for exploring each layer in a docker image
    dive

    # A command line tool for DigitalOcean services
    doctl

    # A package manager for kubernetes
    kubernetes-helm

    # Kubernetes CLI
    kubectl

    # Shell independent context and namespace switcher for kubectl
    kubie

    # Scans and monitors projects for security vulnerabilities
    snyk


    ###
    # Kubernetes Tools
    ###

    # Kubernetes CLI To Manage Your Clusters In Style
    k9s
    # Fast way to switch between clusters and namespaces in kubectl!
    kubectx

    kubeswitch
    # Bash script to tail Kubernetes logs from multiple pods at the same time
    kubetail
    # Multi pod and container log tailing for Kubernetes
    stern

    # Shell script analysis tool
    shellcheck

    # Dockerfile Linter JavaScript API
    hadolint

    # GitHub CLI tool
    gh

    # Text-mode interface for git
    tig


    ## Matrix
    iamb # matrix cli client
  ];
in {
  imports = [
    nix-index-database.hmModules.nix-index
  ];

  home.stateVersion = "22.11";

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";

    sessionVariables.TZ = "America/Vancouver";

    sessionVariables.EDITOR = "nvim";
    # FIXME: set your preferred $SHELL
    sessionVariables.SHELL = "/etc/profiles/per-user/${username}/bin/zsh";
  };

  home.file = lib.mkMerge [
    (lib.mkIf (builtins.pathExists "/mnt/c/Users/micro/Downloads/") { Downloads = { source = config.lib.file.mkOutOfStoreSymlink "/mnt/c/Users/micro/Downloads/"; }; } )
  ];

  home.packages =
    stable-packages
    ++ unstable-packages
    ++
    # FIXME: you can add anything else that doesn't fit into the above two lists in here
    [
      (pkgs.writeShellScriptBin "tmux-session" (builtins.readFile ./zsh/tmux-session.sh))
      # pkgs.some-package
      # pkgs.unstable.some-other-package
    ];

  services = {
    gpg-agent.enable = true;
    # gpg-agent.enableExtraSocket = withGUI;
    gpg-agent.enableSshSupport = true;
  };

  programs = {
    home-manager.enable = true;
    nix-index.enable = true;
    nix-index.enableZshIntegration = true;
    nix-index-database.comma.enable = true;

    jq = {
      enable = true;
      package = pkgs.unstable.jq;
    };

    oh-my-posh = {
      enable = true;
      useTheme = "gmay";
    };

    # FIXME: disable this if you don't want to use the starship prompt
    starship.enable = false;
    starship.settings = {
      aws.disabled = true;
      gcloud.disabled = true;
      kubernetes.disabled = false;
      git_branch.style = "242";
      directory.style = "blue";
      directory.truncate_to_repo = false;
      directory.truncation_length = 8;
      python.disabled = true;
      ruby.disabled = true;
      hostname.ssh_only = false;
      hostname.style = "bold green";
    };

    # FIXME: disable whatever you don't want
    fzf.enable = true;
    fzf.enableZshIntegration = true;
    lsd.enable = true;
    lsd.enableAliases = true;
    zoxide.enable = true;
    zoxide.enableZshIntegration = true;
    broot.enable = true;
    broot.enableZshIntegration = true;

    direnv.enable = true;
    direnv.enableZshIntegration = true;
    direnv.nix-direnv.enable = true;

    neovim = import ./vim.nix {
      inherit pkgs lib;
    };

    ssh = {
      enable = true;
      forwardAgent = true;
      extraConfig = ''
        Include ~/.ssh/config.d/*

        Host *
          User halkeye
          ForwardAgent yes
          GSSAPIAuthentication no
          RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra
      '';
    };

    git = {
      enable = true;
      package = pkgs.unstable.git;
      delta.enable = true;
      delta.options = {
        line-numbers = true;
        side-by-side = true;
        navigate = true;
      };
      aliases = {
        root = "rev-parse --show-toplevel";
      };
      userEmail = "git@gavinmogan.com";
      userName = "Gavin Mogan";
      extraConfig = {
        # FIXME: uncomment the next lines if you want to be able to clone private https repos
        # url = {
        #   "https://oauth2:${secrets.github_token}@github.com" = {
        #     insteadOf = "https://github.com";
        #   };
        #   "https://oauth2:${secrets.gitlab_token}@gitlab.com" = {
        #     insteadOf = "https://gitlab.com";
        #   };
        # };
        url = {
          "git@github.com:" = {
            insteadOf = https://github.com/;
          };
        };
        push = {
          default = "current";
          autoSetupRemote = true;
        };
        merge = {
          conflictstyle = "diff3";
        };
        diff = {
          colorMoved = "default";
        };
      };
    };

    # FIXME: This is my .zshrc - you can fiddle with it if you want
    zsh = {
      enable = true;
      autocd = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      defaultKeymap = "emacs";
      history.size = 10000;
      history.save = 10000;
      history.expireDuplicatesFirst = true;
      history.ignoreDups = true;
      history.ignoreSpace = true;
      historySubstringSearch.enable = true;

      plugins = [
        {
          name = "fast-syntax-highlighting";
          src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
        }
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "v0.5.0";
            sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
          };
        }
      ];

      shellAliases = {
        "..." = "./..";
        "...." = "././..";
        cd = "z";
        gc = "nix-collect-garbage --delete-old";
        refresh = "source ${config.home.homeDirectory}/.zshrc";
        show_path = "echo $PATH | tr ':' '\n'";

        pbcopy = "/mnt/c/Windows/System32/clip.exe";
        pbpaste = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -command 'Get-Clipboard'";
        explorer = "/mnt/c/Windows/explorer.exe";
        curl = "noglob curl --compressed --proto-default https";
        xdg-open = "wsl-open";
      };

      envExtra = ''
        export PATH=$PATH:$HOME/.local/bin
      '';

      initExtra = ''
	ulimit -S -c 0 # disable core dumps

        bindkey '^p' history-search-backward
        bindkey '^n' history-search-forward
        bindkey '^e' end-of-line
        bindkey "^[[3~" delete-char
        bindkey ";5C" forward-word
        bindkey ";5D" backward-word

        zstyle ':completion:*:*:*:*:*' menu select

        # Complete . and .. special directories
        zstyle ':completion:*' special-dirs true

        zstyle ':completion:*' list-colors ""
        zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

        # disable named-directories autocompletion
        zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

        # Use caching so that commands like apt and dpkg complete are useable
        zstyle ':completion:*' use-cache on
        zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

        # Don't complete uninteresting users
        zstyle ':completion:*:*:*:users' ignored-patterns \
                adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
                clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
                gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
                ldap lp mail mailman mailnull man messagebus  mldonkey mysql nagios \
                named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
                operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
                rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
                usbmux uucp vcsa wwwrun xfs '_*'
        # ... unless we really want to.
        zstyle '*' single-ignored complete

        # https://thevaluable.dev/zsh-completion-guide-examples/
        zstyle ':completion:*' completer _extensions _complete _approximate
        zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
        zstyle ':completion:*' group-name ""
        zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands
        zstyle ':completion:*' squeeze-slashes true
        zstyle ':completion:*' matcher-list "" 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

        WORDCHARS='*?[]~=&;!#$%^(){}<>'

        # fixes duplication of commands when using tab-completion
        export LANG=C.UTF-8

        ${builtins.readFile ./zsh/setup.zsh}
      '';
    };
  };
}
