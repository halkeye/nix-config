pkgs:
{
  enable = true;
  viAlias = true;
  vimAlias = true;
  vimdiffAlias = true;
  defaultEditor = true;
  plugins = with pkgs.vimPlugins; [
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

    # :AG
    ag-nvim # rking/ag.vim

    # COC
    coc-nvim
    coc-fzf
    coc-tailwindcss

    # themes
    wombat256
    papercolor-theme

    { plugin = vim-polyglot; config = ''let g:polyglot_disabled = ['md', 'markdown']''; }

    vim-commentary # commentary.vim: comment stuff out
    vim-eunuch # :Remove, :Rename, etc

    vim-trailing-whitespace
  ];

  coc = {
    enable = true;
    settings = ''
      {
        "languageserver": {
          "go": {
            "command": "gopls",
            "rootPatterns": [
              "go.mod"
            ],
            "trace.server": "verbose",
            "filetypes": [
              "go"
            ]
          }
        },
        "go.goplsOptions": {
          "local": "do/"
        },
        "eslint.autoFixOnSave": true,
        "eslint.format.enable": true,
        "solargraph.diagnostics": true,
        "solargraph.autoformat": true,
        "solargraph.formatting": true,
        "coc.preferences.formatOnSaveFiletypes": [
          "c",
          "go",
          "ruby",
          "python"
        ],
        "list.normalMappings": {
          "<C-c>": "do:exit"
        },
        "list.insertMappings": {
          "<C-c>": "do:exit"
        },
        "typescript.format.semicolons": "insert",
        "svelte.enable-ts-plugin": false
      }
    '';
  };

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

