
package.path = package.path .. ";" .. vim.fn.stdpath('config') .. '/?.lua';
pcall(require, 'local');


---- Global Configuration Variables ----

local searchDebounceDelay = 100 -- Debounce delay for searches with telescope (ms)

-- Themes used for <leader>thl and <leader>thd keymaps
DarkThemeName = 'kanagawa-wave' -- Default dark theme
LightThemeName = 'tokyonight-day' -- Default light theme

----------------------------------------

-- [[ Setting options ]]

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
vim.o.shiftwidth = 2;
vim.o.tabstop = 2;

vim.o.scrolloff = 3;
vim.o.conceallevel = 2;

vim.o.cursorline = true;
vim.o.cursorcolumn = true;

vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

vim.o.fileformat = "unix"

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 750
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true


if vim.g.neovide then
  vim.o.guifont = "CaskaydiaCove NFM:h12"
  vim.g.neovide_title_background_color = string.format(
      "%x",
      vim.api.nvim_get_hl(0, {id=vim.api.nvim_get_hl_id_by_name("Normal")}).bg
  )
  vim.g.neovide_title_text_color = "white"
  vim.opt.linespace = 0
  vim.g.neovide_scroll_animation_length = 0.15
  vim.g.neovide_hide_mouse_when_typing = true

  vim.g.neovide_no_idle = false
  vim.g.neovide_refresh_rate = NvideRefreshRate or 50
  vim.g.neovide_refresh_rate_idle = 0 -- 1FPS when idle
  vim.g.neovide_confirm_quit = false
  vim.g.neovide_remember_window_size = true

  vim.g.neovide_position_animation_length = 0.05

  vim.g.neovide_profiler = false

  -- vim.g.neovide_cursor_animation_length = 0.1
  -- vim.g.neovide_cursor_short_animation_length = 0.04
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_cursor_short_animation_length = 0
  vim.g.neovide_cursor_trail_size = 0
  vim.g.neovide_cursor_animate_in_insert_mode = false

  vim.g.neovide_cursor_unfocused_outline_width = 0.125
end

function LoadNeorgWorkspace(workspace)
  vim.cmd('Neorg workspace ' .. workspace)
  vim.cmd('Neorg index')
  DarkThemeName = 'tokyonight-night';
  LightThemeName = 'tokyonight-day'
  vim.cmd.colorscheme(DarkThemeName)
end

-- Ouverture de fichiers binaires en mode xxd
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
  -- Language-related
  {
    'nelsyeung/twig.vim',
    event = "VeryLazy"
  },

  {
    'akinsho/flutter-tools.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    opts = {},
    ft = "dart",
  },

  -- Themes
  {
    'folke/tokyonight.nvim',
    lazy = false,
  },

  {
    'nyoom-engineering/oxocarbon.nvim',
    event = "VeryLazy",
  },

  {
    'rebelot/kanagawa.nvim',
    lazy = false,
    config = function()
      vim.cmd.colorscheme('kanagawa-wave')
    end,
  },

  -- Git related plugins
  {
    'tpope/vim-fugitive',
    event = "VeryLazy"
  },

  {
    -- (Adds git related signs to the gutter, as well as utilities for managing changes)
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

  -- AI
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
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    opts = {
      model = 'gpt-4.1',
      temperature = 0.1, -- Lower = focused, higher = creative
      window = {
        layout = 'vertical',
        width = 0.3,
      },
      auto_insert_mode = true,
      auto_fold = true, -- Automatically folds non-assistant messages
    },
    cmd = "CopilotChat",
    config = function ()
      -- Auto-command to customize chat buffer behavior
      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = 'copilot-*',
        callback = function()
          vim.opt_local.relativenumber = false
          vim.opt_local.number = false
          vim.opt_local.conceallevel = 0
        end,
      })

      require('render-markdown').setup({
        file_types = { 'markdown', 'copilot-chat' },
      })

      -- Adjust chat display settings
      require('CopilotChat').setup({
        highlight_headers = false,
        separator = '---',
        error_header = '> [!ERROR] Error',
      })
    end
  },

  -- Other plugins 
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
    cmd = "RenderMarkdown"
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

  {
    'stevearc/dressing.nvim',
    event = "VeryLazy",
    opts = {}
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
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    },
    keys = {
      { '<leader>fe', '<Cmd>NvimTreeFocus<CR>', desc = "[F]ile [E]xplorer" },
      { '<leader>ft', '<Cmd>NvimTreeToggle<CR>', desc = "[F]ile Explorer [T]oggle" },
      { '<leader>ff', '<Cmd>NvimTreeFindFile<CR>', desc = "[F]ind [F]ile" },
      { '<leader>fc', '<Cmd>NvimTreeClose<CR>', desc = "[F]ile Explorer [C]lose" },
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
          special_files = { 'Cargo.toml', 'Makefile', 'README.md', 'readme.md', '.gitignore', '.gitconfig', 'package.json', 'package-lock.json', 'go.mod' },
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
        git_use_branch_name = true,
        log_level = "error",
      });
    end,
    lazy = false,
  },

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'mason-org/mason.nvim', opts = {} },
      { 'mason-org/mason-lspconfig.nvim', opts = { } },

      -- Useful status updates for LSP
      {
        'j-hui/fidget.nvim',
        opts = {
          progress = {
            suppress_on_insert = true,
            ignore_done_already = true,
            display = {
              render_limit = 2,
              done_ttl = 0,
            }
          },
        }
      },

      {
        'folke/lazydev.nvim',
        ft = "lua",
      },
    },
    config = function ()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('config-lsp-attach', { clear = true }),
        callback = function(event)
          local nmap = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
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
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)


      vim.lsp.config('vtsls', {
        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        settings = {
          vtsls = {
            tsserver = {
              globalPlugins = {
                {
                  name = "@vue/typescript-plugin",
                  location = vim.fn.stdpath("data") .. "/mason/packages/vue-language-server/node_modules/@vue/typescript-plugin",
                  languages = { "vue" },
                  configNamespace = "typescript",
                  enableForWorkspaceTypeScriptVersions = true,
                },
              },
            },
          },
        },
      })

      require('mason').setup()
    end,
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

  'NMAC427/guess-indent.nvim',

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
    "vhyrro/luarocks.nvim",
    priority = 1000, -- Load first
    config = true, -- Calls setup()
  },
  {
    "nvim-neorg/neorg",
    dependencies = { "luarocks.nvim" },
    version = false,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "norg", "neorg" },
        callback = function()
          if pcall(vim.treesitter.start) then
            vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
      require("neorg").setup({
        load = {
          ["core.defaults"] = {}, -- Loads default behaviour
          ["core.concealer"] = {}, -- Adds pretty icons to your documents
          ["core.completion"] = {
            config = {
              engine = "nvim-cmp",
            },
          }, -- Completion
          ["core.dirman"] = DIRMAN_CONFIG,
          ['core.summary'] = {},
          ['core.export'] = {},
          ['core.esupports.metagen'] = {
            config = {
              update_date = false,
            },
          },
          -- ['external.live-pdf'] = {
          --   config = {
          --     server_port = 8025,
          --   },
          -- }
        },
      })
    end,
    keys = {
      { '<leader>ni', '<Cmd>Neorg index<CR>', desc = "[N]eorg [I]index" },
      { '<leader>nw', ':Neorg workspace ', desc = "[N]eorg [W]orkspace..." },
      { '<leader>nj', '<Cmd>Neorg journal<CR>', desc = "[N]eorg [J]ournal" },
    },
    cmd = "Neorg",
    ft = { "norg" },
  },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    tag = "v0.2.1",
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    setup = {
      extensions = {
      },
      defaults = {
        file_ignore_patterns = {
          "-lock.json$",
          "^node_modules",
          "^var$",
          "^vendor$",
          "^.cache$",
        },
      },
    }
  },

  {
    'nvim-treesitter/nvim-treesitter',
    branch = "main",
    build = ':TSUpdate',
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      folds = { enable = true },
      ensure_installed = { 'c', 'lua', 'python', 'typescript', 'javascript', 'vue', 'vimdoc', 'vim', 'php', 'go'  }
    },
    init = function ()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { '<filetype>' },
        callback = function()
          vim.treesitter.start()
        end,
      })

      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
    lazy = false,
  },
}, {
  defaults = {
    lazy = true,
  }
})

vim.keymap.set('n', '<leader>sthl', '<Cmd>lua vim.cmd.colorscheme(LightThemeName)<CR>', { desc = "[S]witch [T]heme : [L]ight"});
vim.keymap.set('n', '<leader>sthd', '<Cmd>lua vim.opt.background="dark";vim.cmd.colorscheme(DarkThemeName)<CR>', { desc = "[S]witch [T]heme : [D]ark"});

-- [[ General Keymaps ]]

-- Créer une nouvelle ligne au-dessus et l'éditer directement
vim.keymap.set("i", "<C-j>", "<C-o>O", { noremap = true, silent = true })

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
    vim.hl.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})



-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`

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



-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
-- require('luasnip.loaders.from_vscode').lazy_load()
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
