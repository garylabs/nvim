return {
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      -- Useful status updates for LSP
      { 'j-hui/fidget.nvim', opts = {} },
      'saghen/blink.cmp',
      -- Adds extra capabilities to nvim-cmp
    },
    config = function()
      -- Setup LSP autocommands
      require('config.autocommands.lsp').setup()

      -- Configure language servers
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                library = vim.api.nvim_get_runtime_file('', true),
                checkThirdParty = false,
              },
              completion = {
                callSnippet = 'Replace',
              },
              diagnostics = {
                globals = { 'vim' },
                disable = { 'missing-fields' },
              },
            },
          },
        },
        cucumber_language_server = {
          settings = {
            cucumber = {
              features = { 'cypress/e2e/**/*.feature' },
              glue = { 'cypress/e2e/step-definitions/*.js' },
              parameterTypes = {},
              snippets = true,
              strictGherkin = false,
              completion = {
                enable = true,
                snippets = {
                  enable = true,
                },
              },
            },
          },
          -- Find files from the project root
          root_dir = function(fname)
            -- Using mason-lspconfig's default root detection
            local util = require 'lspconfig.util'
            return util.root_pattern('cypress.config.js', 'cypress.config.ts', 'package.json')(fname)
              or util.find_git_ancestor(fname)
              or util.path.dirname(fname)
          end,
        },
        -- Add other language servers here
        -- gopls = {},
        -- rust_analyzer = {},
        pylsp = {
          settings = {
            pylsp = {
              plugins = {
                pyflakes = { enabled = false },
                pycodestyle = { enabled = false },
                autopep8 = { enabled = false },
                yapf = { enabled = false },
                mccabe = { enabled = false },
                pylsp_mypy = { enabled = false },
                pylsp_black = { enabled = false },
                pylsp_isort = { enabled = false },
              },
            },
          },
        },
      }
      -- Ensure the servers and tools above are installed
      require('mason').setup()

      -- Ensure specific tools are installed
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      -- Setup mason-lspconfig
      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = require('blink.cmp').get_lsp_capabilities(server.capabilities)

            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },
}
