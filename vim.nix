{ pkgs, lib, ... }:

let
  fromGitHub = rev: ref: repo: pkgs.vimUtils.buildVimPlugin {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = ref;
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
      ref = ref;
      rev = rev;
    };
  };
in
{
  enable = true;
  package = pkgs.unstable.neovim-unwrapped;
  viAlias = true;
  vimAlias = true;
  vimdiffAlias = true;
  defaultEditor = true;
  plugins = with pkgs.vimPlugins; [
    nvim-treesitter
    editorconfig-vim
    fzf-vim
    fzfWrapper
    LanguageClient-neovim
    lightline-vim
    supertab
    tabular
    vim-better-whitespace
    vim-multiple-cursors
    vim-surround
    copilot-vim

    # :AG
    ag-nvim # rking/ag.vim


    # themes
    wombat256
    papercolor-theme
    nvim-web-devicons

    vim-commentary # commentary.vim: comment stuff out
    vim-eunuch # :Remove, :Rename, etc

    vim-trailing-whitespace

#    lspconfig doesn't have typos support, so pull from git
#    nvim-lspconfig
    (fromGitHub "aa5f4f4ee10b2688fb37fa46215672441d5cd5d9" "master" "neovim/nvim-lspconfig")

    # Coding UI
    fzf-lsp-nvim
    trouble-nvim
    lightline-lsp
    lsp-format-nvim
    telescope-nvim
    telescope-fzy-native-nvim

    # Completion
    nvim-cmp
    cmp-copilot
    cmp-cmdline
    cmp-dictionary
    cmp-emoji
    cmp-nvim-lsp
    cmp-nvim-ultisnips
    cmp-path
    cmp-buffer
    cmp-treesitter

    # Languages
    markdown-preview-nvim
    typescript-tools-nvim
    vim-go
    vim-nix
    vim-ruby
    (fromGitHub "e7acbbbfde3f09a378873a16a380f8fdb01a4d12" "main" "tekumara/typos-lsp")
#    (fromGitHub "728374ef59b11a5f5991ea2560d149a4ae33fd22" "master" "yasuhiroki/github-actions-yaml.vim")
  ];

  # coc = {
  #   enable = true;
  #   settings = ''
  #     {
  #       "languageserver": {
  #         "go": {
  #           "command": "gopls",
  #           "rootPatterns": [
  #             "go.mod"
  #           ],
  #           "trace.server": "verbose",
  #           "filetypes": [
  #             "go"
  #           ]
  #         }
  #       },
  #       "go.goplsOptions": {
  #         "local": "do/"
  #       },
  #       "eslint.autoFixOnSave": true,
  #       "eslint.format.enable": true,
  #       "solargraph.diagnostics": true,
  #       "solargraph.autoformat": true,
  #       "solargraph.formatting": true,
  #       "coc.preferences.formatOnSaveFiletypes": [
  #         "c",
  #         "go",
  #         "ruby",
  #         "python"
  #       ],
  #       "list.normalMappings": {
  #         "<C-c>": "do:exit"
  #       },
  #       "list.insertMappings": {
  #         "<C-c>": "do:exit"
  #       },
  #       "typescript.format.semicolons": "insert",
  #       "svelte.enable-ts-plugin": false
  #     }
  #   '';
  # };

  extraLuaConfig = ''
    require'lspconfig'.typos_lsp.setup{}
    require'lspconfig'.marksman.setup{}
    require'lspconfig'.ruby_lsp.setup{}
    require'lspconfig'.gopls.setup{}
    require'lspconfig'.nixd.setup{}

    local telescopeBuiltin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>ff', telescopeBuiltin.find_files, {})
    vim.keymap.set('n', '<leader>fg', telescopeBuiltin.live_grep, {})
    vim.keymap.set('n', '<leader>fb', telescopeBuiltin.buffers, {})
    vim.keymap.set('n', '<leader>fh', telescopeBuiltin.help_tags, {})
  '';
  extraPackages = with pkgs; [
    rust-analyzer
  ];

  extraConfig = ''
    set background=light
    set background=dark

    colorscheme wombat256mod
    colorscheme PaperColor

    syntax on
    filetype plugin indent on
    set splitbelow

    set shiftwidth=2
    set tabstop=2
    set number
    set expandtab
    set foldmethod=indent
    set foldnestmax=5
    set foldlevelstart=99
    set foldcolumn=0

    set list
    set listchars=tab:>-

    let g:better_whitespace_enabled=1
    let g:strip_whitespace_on_save=0

    let g:SuperTabDefaultCompletionType = '<c-x><c-o>'

    if has("gui_running")
      imap <c-space> <c-r>=SuperTabAlternateCompletion("\<lt>c-x>\<lt>c-o>")<cr>
    else " no gui
      if has("unix")
        inoremap <Nul> <c-r>=SuperTabAlternateCompletion("\<lt>c-x>\<lt>c-o>")<cr>
      endif
    endif

    " ctrl+p triggering fzf pls
    nmap <C-P> :FZF<CR>
    let g:fzf_action = {
      \ 'return': 'tabedit',
      \ }

    """ Tab stuff
    " Tab configuration
    " map <leader>tn :tabnew %<cr>
    map <leader>te :tabedit<space>
    map <leader>tm :tabmove<space>
    map <leader>tn :tabnew<space>

    " Tabular bindings
    vmap <leader>a= :Tabularize /=<CR>
    vmap <leader>a; :Tabularize /::<CR>
    vmap <leader>a- :Tabularize /-><CR>
    vmap <leader>a# :Tabularize /#<CR>

    " fzf bindings
    nnoremap <leader>r :Rg<CR>
    nnoremap <leader>b :Buffers<CR>
    nnoremap <leader>e :Files<CR>
    nnoremap <leader>l :Lines<CR>
    nnoremap <leader>L :BLines<CR>
    nnoremap <leader>c :Commits<CR>
    nnoremap <leader>C :BCommits<CR>

    " Turn backup off
    set nobackup
    set nowb
    set noswapfile

    " Set backspace
    set backspace=eol,start,indent

    " Bbackspace and cursor keys wrap to
    set whichwrap+=<,>,h,l

    " No sound on errors.
    set noerrorbells
    set novisualbell
    set t_vb=

    " show matching bracets
    set showmatch

    " disable mouse
    set mouse=

    " Copy vscode/ideajs/etc mapping for toggling comment
    let g:NERDDefaultAlign = 'left'
    nnoremap <C-_>   <Plug>Commentary
    vnoremap <C-_>   <Plug>Commentary<CR>gv
    nnoremap <C-/>   <Plug>Commentary
    vnoremap <C-/>   <Plug>Commentary<CR>gv

    let g:go_gopls_local = "do"
    let g:go_fmt_command = "gopls"

    let g:go_build_tags = 'integration'

    " automatically highlight variable your cursor is on
    let g:go_auto_sameids = 0

    let g:go_highlight_types = 1
    let g:go_highlight_fields = 1
    let g:go_highlight_functions = 1
    let g:go_highlight_function_calls = 1
    let g:go_highlight_extra_types = 1
    let g:go_highlight_operators = 1
  '';
}

