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

-- Go to next diagnostic
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
-- Go to previous diagnostic
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
-- Show diagnostic under the cursor
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
-- Open diagnostic quickfix list
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

-- [[ Luau filetype detection ]]
-- Automatically recognise .lua as luau files in a Roblox project
local cwd = assert(vim.uv.cwd())
local rojo_file_found = vim.fs.root(cwd, function(name)
  return name:match "%.project.json$"
end)

if rojo_file_found then
  vim.filetype.add {
    extension = {
      lua = function(path)
        return path:match ".nvim.lua$" and "lua" or "luau"
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

local function get_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

  -- Enable manually file watcher capability, so luau-lsp will be aware of sourcemap.json changes, this
  -- is done internally in Neovim 0.10+, but only for non Linux systems
  capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true
end

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
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
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

          -- Go to definition
          map("n", "gd", vim.lsp.buf.definition)
          -- Go to declaration
          map("n", "gD", vim.lsp.buf.declaration)
          -- Find references
          map("n", "gr", vim.lsp.buf.references)
          -- Rename symbol
          map("n", "<leader>rn", vim.lsp.buf.rename)
          -- Code action
          map("n", "<leader>ca", vim.lsp.buf.code_action)
          -- Hover
          map("n", "K", vim.lsp.buf.hover)
          -- Signature help
          map("i", "<c-s>", vim.lsp.buf.signature_help)

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if not client then
            return
          end

          -- Highlight the current word under the cursor
          if client.supports_method "textDocument/documentHighlight" then
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

      -- Setup lua-ls for your neovim config
      require("lspconfig").lua_ls.setup {
        capabilities = get_capabilities(),
      }

      -- Setup eslint for `typescript` files
      require("lspconfig").eslint.setup {
        capabilities = get_capabilities(),
      }

      -- Setup jsonls for `json` files
      require("lspconfig").jsonls.setup {
        capabilities = get_capabilities(),
        settings = {
          json = {
            -- Send custom json schemas to jsonls to provide its features when you open a json file
            schemas = get_json_schemas(),
            validate = { enable = true },
          },
        },
      }

      -- Setup vtsls for `typescript` files
      require("lspconfig").vtsls.setup {
        capabilities = get_capabilities(),
      }

      -- We don't need to call `require("lspconfig").luau_lsp.setup` because we are using luau-lsp.nvim
    end,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "b0o/SchemaStore.nvim",

      -- Configures Lua LS for your Neovim config, runtime and plugins
      -- used for completion, annotations and signatures of Neovim apis
      { "folke/neodev.nvim", opts = {} },
    },
  },

  -- Luau support
  {
    "lopi-py/luau-lsp.nvim",
    config = function()
      -- We call `require("luau-lsp").setup` instead of `require("lspconfig").luau_lsp.setup` because luau-lsp.nvim will
      -- add extra features to luau-lsp, so we don't need to call lspconfig's setup
      --
      -- See https://github.com/lopi-py/luau-lsp.nvim
      require("luau-lsp").setup {
        plugin = {
          enabled = true,
        },
        server = {
          capabilities = get_capabilities(),
          settings = {
            ["luau-lsp"] = {
              ignoreGlobs = { "**/_Index/**", "**/node_modules/**" },
              completion = {
                imports = {
                  enabled = true,
                  ignoreGlobs = { "**/_Index/**", "**/node_modules/**" },
                },
              },
            },
          },
        },
      }
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig",
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
    "hrsh7th/nvim-cmp",
    config = function()
      local cmp = require "cmp"

      cmp.setup {
        mapping = {
          -- Accept the completion
          ["<cr>"] = cmp.mapping.confirm { select = true },
          ["<tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              -- Select the next item if the completion menu is visible
              cmp.select_next_item()
            elseif vim.snippet.active { direction = 1 } then
              -- Jump to the next snippet location if possible
              vim.snippet.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<s-tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              -- Select the previous item if the completion menu is visible
              cmp.select_prev_item()
            elseif vim.snippet.active { direction = -1 } then
              -- Jump to the previous snippet location if possible
              vim.snippet.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "snippets" },
        },
      }
    end,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",

      -- Snippet loader, by default it will load snippets in `NVIM_CONFIG/snippets/*.json`
      -- See https://github.com/garymjr/nvim-snippets
      { "garymjr/nvim-snippets", opts = {} },
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
