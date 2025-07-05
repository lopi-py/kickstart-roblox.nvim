-- Set <space> as the leader key
-- See `:help mapleader`
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ Settings options ]]
-- See `:help vim.opt`

-- Enable line numbers
vim.opt.number = true

-- Enable the mouse
vim.opt.mouse = "a"

-- Don't show the vim mode, since it's already in the status line
vim.opt.showmode = false

-- Make neovim use the system clipboard
vim.opt.clipboard = "unnamedplus"

-- Keep the signcolumn enabled
-- See `:help 'signcolumn'`
vim.opt.signcolumn = "yes"

-- Set the update time to a lower value
-- See `:help 'updatetime'`
vim.opt.updatetime = 300

-- Show the current line where the cursor is on
vim.opt.cursorline = true

-- [[ Basic keymaps ]]
-- See `:help vim.keymap`

-- Clear highlights on search
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")

-- Open diagnostic quickfix list
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

-- Detects if we open a Rojo project
local function rojo_project()
  return vim.fs.root(0, function(name)
    return name:match ".+%.project%.json$"
  end)
end

-- [[ Luau filetype detection ]]
-- Automatically recognise .lua as luau files in a Roblox project
if rojo_project() then
  vim.filetype.add {
    extension = {
      lua = function(path)
        return path:match "%.nvim%.lua$" and "lua" or "luau"
      end,
    },
  }
end

-- [[ Install `lazy.nvim` plugin manager ]]
-- See https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim
    .system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazypath,
    })
    :wait()
end
vim.opt.runtimepath:prepend(lazypath)

local function get_json_schemas()
  local schemas = require("schemastore").json.schemas()

  -- Add the rojo json schema for rojo project files
  table.insert(schemas, {
    fileMatch = { "*.project.json" },
    url = "https://raw.githubusercontent.com/rojo-rbx/vscode-rojo/master/schemas/project.template.schema.json",
  })

  return schemas
end

-- [[ Configure and install plugins ]]
-- See https://github.com/folke/lazy.nvim
--
-- To check the current status of your plugins, run `:Lazy`
--
-- To update your plugins, run `:Lazy update`
--
-- Here is where you install your plugins
require("lazy").setup {
  -- Tool manager for external tools like LSP's, linters, formatters, etc
  --
  -- To check the current status of your tools, run `:Mason`
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "luau-lsp",
        "stylua",
        "vtsls",
        "eslint-lsp",
        "prettierd",
        "json-lsp",
      },
    },
    dependencies = {
      {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        opts = {},
      },
    },
  },

  -- Git integration
  -- Adds git related signs to the gutter
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
    },
  },

  -- LSP configuration
  -- See https://microsoft.github.io/language-server-protocol/
  --
  -- LSP provides Neovim features like:
  -- - Go to definition
  -- - Find references
  -- - Autocompletion
  -- - and more!
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- This function will run when an LSP attaches to a particular buffer
      -- See `:help LspAttach`
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          -- Create a helper function to set the buffer specific keymaps
          local function map(mode, lhs, rhs)
            vim.keymap.set(mode, lhs, rhs, { buffer = event.buf })
          end

          -- There are already some default keymaps provided by Neovim, see:
          -- `:help lsp-defaults`
          -- `:help diagnostics-defaults`

          -- Go to definition
          map("n", "gd", vim.lsp.buf.definition)
          -- Go to declaration
          map("n", "gD", vim.lsp.buf.declaration)

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if not client then
            return
          end

          -- Highlight the current word under the cursor
          if client:supports_method "textDocument/documentHighlight" then
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      -- Configure lsp's with `vim.lsp.config`, see `:help vim.lsp.config`
      vim.lsp.config("jsonls", {
        settings = {
          json = {
            -- Send custom json schemas to jsonls to provide its features when you open a json file
            schemas = get_json_schemas(),
            validate = { enable = true },
          },
        },
      })

      -- Enable the specified lsp's, see `:help vim.lsp.enable`
      --
      -- We don't need to enable `luau_lsp` because we are using luau-lsp.nvim
      vim.lsp.enable {
        "lua_ls",
        "eslint",
        "jsonls",
        "vtsls",
      }
    end,
    dependencies = {
      "b0o/SchemaStore.nvim",

      -- Configures Lua LS for your Neovim config, runtime and plugins
      -- used for completion, annotations and signatures of Neovim apis
      {
        "folke/lazydev.nvim",
        opts = {
          library = {
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
    },
  },

  -- Luau support
  {
    "lopi-py/luau-lsp.nvim",
    config = function()
      -- Configure *server* settings
      vim.lsp.config("luau-lsp", {
        settings = {
          ["luau-lsp"] = {
            ignoreGlobs = { "**/_Index/**", "node_modules/**" },
            completion = {
              imports = {
                enabled = true,
                ignoreGlobs = { "**/_Index/**", "node_modules/**" },
              },
            },
          },
        },
      })

      -- We call `require("luau-lsp").setup` instead of `vim.lsp.enable("luau_lsp")` because luau-lsp.nvim will
      -- add extra features to luau-lsp, so we don't need to call the native lsp setup
      --
      -- See https://github.com/lopi-py/luau-lsp.nvim
      require("luau-lsp").setup {
        platform = {
          type = rojo_project() and "roblox" or "standard",
        },
        plugin = {
          enabled = true,
        },
      }
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  -- Format code on save
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    keys = {
      -- Format code
      {
        "<leader>f",
        function()
          require("conform").format { async = true }
        end,
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        luau = { "stylua" },
        typescript = { "prettierd" },
        typescriptreact = { "prettierd" },
      },
      default_format_opts = {
        lsp_format = "fallback",
      },
      format_on_save = {
        timeout_ms = 500,
      },
    },
  },

  -- Autocompletion
  {
    "Saghen/blink.cmp",
    version = "*",
    opts = {
      keymap = {
        -- 'default' (recommended) for mappings similar to built-in completions
        --   <c-y> to accept ([y]es) the completion.
        --    This will auto-import if your LSP supports it.
        --    This will expand snippets if the LSP sent a snippet.
        --
        -- For an understanding of why the 'default' preset is recommended,
        -- you will need to read `:help ins-completion`
        --
        -- For more information about presets,
        -- see https://cmp.saghen.dev/configuration/keymap.html#presets
        preset = "default",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "lazydev" },
        providers = {
          lazydev = {
            module = "lazydev.integrations.blink",
            fallbacks = { "lsp" },
          },
        },
      },
      cmdline = {
        enabled = false,
      },
    },
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- Search files
      { "<leader>sf", ":Telescope find_files<cr>" },
      -- Search by grep
      { "<leader>sg", ":Telescope live_grep<cr>" },
      -- Search buffers
      { "<leader><leader>", ":Telescope buffers<cr>" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
  },

  -- Autopair support
  {
    "windwp/nvim-autopairs",
    opts = {},
  },

  -- Set tabstop and shifwidth when opening a file
  -- See `:help 'tabstop'` and `:help 'shifwidth'`
  {
    "NMAC427/guess-indent.nvim",
    opts = {},
  },

  -- Colorscheme
  -- See https://dotfyle.com/neovim/colorscheme/top for a list of popular colorschemes!
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {},
  },

  -- Display LSP progress messages
  {
    "j-hui/fidget.nvim",
    opts = {},
  },

  -- Highlight, edit, and navigate code
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
        "lua",
        "luau",

        "typescript",
        "tsx",

        "toml",
        "yaml",
        "json",
        "jsonc",
      },
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
    },
  },

  -- Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going
  -- See https://lazy.folke.io/usage/structuring
  --
  -- { import = "custom.plugins" },
}

-- Set the colorscheme
vim.cmd.colorscheme "catppuccin-mocha"
