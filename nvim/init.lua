
package.path = package.path .. ";" .. vim.fn.stdpath('config') .. '/?.lua';
pcall(require, 'local');


---- Global Configuration Variables ----

local searchDebounceDelay = 100 -- Debounce delay for searches with telescope (ms)

-- Themes used for <leader>thl and <leader>thd keymaps
DarkThemeName = 'github_dark_default' -- Default dark theme
LightThemeName = 'github_light' -- Default light theme

----------------------------------------




-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Default tabstop/shiftwidth
vim.opt.shiftwidth = 2;
vim.opt.tabstop = 2;

vim.opt.scrolloff = 3;
vim.opt.conceallevel = 2;

vim.opt.cursorline = true;
vim.opt.cursorcolumn = true;

function LoadNeorgWorkspace(workspace)
  vim.cmd('Neorg workspace ' .. workspace)
  vim.cmd('Neorg index')
  DarkThemeName = 'catppuccin-mocha';
  LightThemeName = 'catppuccin-latte'
  vim.cmd.colorscheme(DarkThemeName)
end

vim.cmd([[
  augroup BinaryFileAutoCommand
    autocmd!
    autocmd BufReadPre,FileReadPre *.bin,*.exe,*.wasm silent execute 'set binary'
    autocmd BufReadPost,FileReadPost *.bin,*.exe,*.wasm if &binary | silent execute '%!xxd' | endif
    autocmd BufReadPost,FileReadPost *.bin,*.exe,*.wasm if &binary | set ft=xxd  | endif
    autocmd BufWritePre *.bin,*.exe,*.wasm if &binary | silent execute '%!xxd -r' | endif
    autocmd BufWritePost *.bin,*.exe,*.wasm if &binary | silent execute 'set nomod' | endif
  augroup END
]]);

--
-- PLUGINS
--

require('lazy').setup({
  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    config = true, -- This automatically runs `require("luarocks-nvim").setup()`
  },

  {
    "rcarriga/nvim-notify",
    config = function ()
      vim.notify = require('notify') -- Override vim.notify
      require('notify').setup({
        stages = "static",
        timeout = 5000,
        render = "compact",
      })
    end,
    lazy = false,
  },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
    },
    event = "VeryLazy"
  },

  -- Git related plugins
  {
    'tpope/vim-fugitive',
    event = "VeryLazy"
  },

  -- Detect tabstop and shiftwidth automatically
  {
    'tpope/vim-sleuth',
    lazy = false
  },

  {
    'tpope/vim-surround',
    event = "VeryLazy"
  },

  {
    'nelsyeung/twig.vim',
    event = "VeryLazy"
  },

  {
    'zbirenbaum/copilot.lua',
    keys = {
      { '<leader>ce', '<Cmd>Copilot enable<CR>', desc = "[C]opilot [E]nable" },
      { '<leader>cd', '<Cmd>Copilot disable<CR>', desc = "[C]opilot [D]isable" },
    },
    cmd = "Copilot",
    config = function ()
      require('copilot').setup({
        suggestion = {
          auto_trigger = true,
          keymap = {
            accept = "<C-K>",
            dismiss = "<C-J>",
          },
        },
      });
    end
  },

  --[[ {
    'lervag/vimtex',
    lazy = false, -- NOTE: Specific requirements of Vimtex
  }, ]]

  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    },
    keys = {
      { '<leader>fe', '<Cmd>NvimTreeFocus<CR>', desc = "[F]ile [E]xplorer" },
      { '<leader>ft', '<Cmd>NvimTreeToggle<CR>', desc = "[F]ile Explorer [T]oggle" },
      { '<leader>ff', '<Cmd>NvimTreeFindFile<CR>', desc = "[F]ind [F]ile" },
      { '<leader>fc', '<Cmd>NvimTreeClose<CR>', desc = "[F]ile Explorer [C]lose" },
      { '<leader>fr', '<Cmd>NvimTreeRefresh<CR>', desc = "[F]ile Explorer [R]efresh" },
    },
    config = function (self, opts)
      require('nvim-tree').setup({
        actions = {
          open_file = {
            quit_on_open = true,
          },
        },
        sort_by="case_sensitive",
        trash = {
          cmd = "Remove-ItemSafely "
        },
        view = {
          width = {
            min = 30,
            max = 40,
            padding = 1,
          },
          signcolumn = "auto",
        },
        modified = {
          enable = true,
        },
        renderer = {
          group_empty = true,
          special_files = { 'Cargo.toml', 'Makefile', 'README.md', 'readme.md', '.gitignore', '.gitconfig', 'package.json', 'package-lock.json' },
          hidden_display = "all",
        },
        filters = {
          git_ignored = false,
        },
        filesystem_watchers = {
          ignore_dirs = { ".git", "node_modules", ".cache", "vendor", "var" },
        },
        live_filter = {
          always_show_folders = false,
        },
        git = {
          enable = false,
          -- timeout = 500,
        },
      });
    end
  },

  {
    'rmagatti/auto-session',
    config = function()
      require('auto-session').setup({
        log_level = "error",
        auto_session_use_git_branch = true,
      });
      vim.g.auto_session_pre_save_cmds = { "silent! tabdo NvimTreeClose" }
    end,
    lazy = false,
  },

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      {
        'j-hui/fidget.nvim',
        opts = {
          progress = {
            suppress_on_insert = true,
            ignore_done_already = true,
            display = {
              render_limit = 3,
              done_ttl = 0,
            }
          },
        }
      },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
    config = function ()
      vim.lsp.set_log_level("warn")
    end
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {}, event = "VeryLazy" },

  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>gp', require('gitsigns').prev_hunk, { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
        vim.keymap.set('n', '<leader>gn', require('gitsigns').next_hunk, { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
        vim.keymap.set('n', '<leader>ph', require('gitsigns').preview_hunk, { buffer = bufnr, desc = '[P]review [H]unk' })
      end,
    },
    event = "VeryLazy",
  },

  -- Theme
  {
    'projekt0n/github-nvim-theme',
    config = function()
      vim.cmd.colorscheme('github_dark_default')
    end,
    lazy = false,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    config = function ()
      -- vim.cmd.colorscheme "catppuccin-frappe"
      -- vim.cmd.colorscheme "catppuccin-macchiato" -- darker variant
      -- vim.cmd.colorscheme "catppuccin-mocha" -- darker variant
    end,
    lazy = false
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
      },
    },
    event = "VeryLazy"
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help indent_blankline.txt`
    main = "ibl",
    opts = {},
    event = "VeryLazy",
    config = function ()

      require('ibl').setup {
        indent = {
          char = '╎',
          -- char = '┆',
          highlight = "Comment",
        },
        exclude = {
          buftypes = { 'terminal' },
        },
        scope = {
          enabled = false,
        }
      }
    end,
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {}, lazy = false },

  {
    "nvim-neorg/neorg",
    config = function()
      require("neorg").setup {
        load = {
          ["core.defaults"] = {}, -- Loads default behaviour
          ["core.concealer"] = {}, -- Adds pretty icons to your documents
          ["core.completion"] = {
            config = {
              engine = "nvim-cmp",
            },
          }, -- Completion
          ["core.dirman"] = DIRMAN_CONFIG,
          ['core.summary'] = {}
        },
      }
    end,
    keys = {
      { '<leader>ni', '<Cmd>Neorg index<CR>', desc = "[N]eorg [I]index" },
      { '<leader>nw', ':Neorg workspace ', desc = "[N]eorg [W]orkspace..." },
      { '<leader>nj', '<Cmd>Neorg journal<CR>', desc = "[N]eorg [J]ournal" },
    },
    cmd = "Neorg"
  },


  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
  },

  -- Fuzzy Finder Algorithm which requires local dependencies to be built.

  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
    event = "VeryLazy",
    config = function ()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 'c', 'cpp', 'lua', 'python', 'typescript', 'vimdoc', 'vim', 'query' },
        auto_install = false,

        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<leader>ss',
            node_incremental = '<leader>si',
            scope_incremental = '<leader>sci',
            node_decremental = '<leader>scd',
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              [']m'] = '@function.outer',
              [']]'] = '@class.outer',
            },
            goto_next_end = {
              [']M'] = '@function.outer',
              [']['] = '@class.outer',
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
              ['[['] = '@class.outer',
            },
            goto_previous_end = {
              ['[M'] = '@function.outer',
              ['[]'] = '@class.outer',
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ['<leader>a'] = '@parameter.inner',
            },
            swap_previous = {
              ['<leader>A'] = '@parameter.inner',
            },
          },
        },
      }

    end,
  },
  {
      'akinsho/flutter-tools.nvim',
      dependencies = {
          'nvim-lua/plenary.nvim',
          'stevearc/dressing.nvim', -- optional for vim.ui.select
      },
      config = function (self, opts)
        require("flutter-tools").setup {} -- use defaults
      end,
      event = "VeryLazy",
  }
}, {
    defaults = {
      lazy = true,
    }
})

-- vim.keymap.set('n', '<leader>ssf', '<Cmd>syntax sync fromstart<CR>', { desc = "[S]yntax [S]ync [F]romstart"});
vim.keymap.set('n', '<leader>sthl', '<Cmd>lua vim.cmd.colorscheme(LightThemeName)<CR>', { desc = "[S]witch [T]heme : [L]ight"});
vim.keymap.set('n', '<leader>sthd', '<Cmd>lua vim.cmd.colorscheme(DarkThemeName)<CR>', { desc = "[S]witch [T]heme : [D]ark"});

-- [[ Setting options ]]

-- Set highlight on search
vim.opt.hlsearch = false

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true

-- Enable mouse mode
vim.opt.mouse = 'a'

vim.opt.fileformat = "unix"

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = 'unnamedplus'

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.opt.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.opt.termguicolors = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
-- vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup({
  extensions = {
  },
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },

    file_ignore_patterns = {
      "^node_modules",
      "^var$",
      "^vendor$",
      "^.cache$",
    },
  },
});

-- Enable telescope fzf native, if installed
--
-- pcall(require('telescope').load_extension, 'fzf')


-- Use fzf to search files and respect .gitignore rules
-- vim.env.FZF_DEFAULT_COMMAND = [=[rg --files --hidden --follow --glob "!.git/*" --glob "!.gitignore" 2>/dev/null || find * -path "*/\.*" -prune -o -type f -print -o -type l -print 2>/dev/null | sed s/^..//]=]
vim.fn.setenv("FZF_DEFAULT_COMMAND", "git ls-files --cached --others --exclude-standard | fzf")

-- Set the prefix command for fzf file search
vim.g.fzf_command_prefix = 'FzfFiles'

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

local debounceTelescope = function(func)
  return function()
    func({ debounce=searchDebounceDelay })
  end
end

vim.keymap.set('n', '<leader>gf', debounceTelescope(require('telescope.builtin').git_files), { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', debounceTelescope(require('telescope.builtin').find_files), { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', debounceTelescope(require('telescope.builtin').help_tags), { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', debounceTelescope(require('telescope.builtin').grep_string), { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', debounceTelescope(require('telescope.builtin').live_grep), { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', debounceTelescope(require('telescope.builtin').diagnostics), { desc = '[S]earch [D]iagnostics' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

vim.diagnostic.config({
  signs = true,
  update_in_insert = false,
});

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- We create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end
}

require('lspconfig').volar.setup({
  filetypes = { 'vue' },
  init_options = {
    vue = {
      hybridMode = false,
    },
  },
})

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        local selected_entry = cmp.get_selected_entry()
        if selected_entry then
          cmp.confirm({ select = true })
        else
          fallback()
        end
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
