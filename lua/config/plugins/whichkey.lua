-- lua/config/plugins/which-key.lua
return {
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function()
      local wk = require 'which-key'
      local fzf = require 'fzf-lua'

      wk.setup {
        preset = 'helix',
      }
      wk.add {
        -- LSP and Code Actions
        { '<leader>c', group = 'code' },
        { '<leader>ca', vim.lsp.buf.code_action, desc = 'Code Action', mode = { 'n', 'v' } },
        { '<leader>cr', vim.lsp.buf.rename, desc = 'Rename' },

        -- File/Buffer operations
        { '<leader>f', group = 'file' },
        { '<leader>fs', fzf.lsp_document_symbols, desc = 'Document Symbols' },
        {
          '<leader>ff',
          function()
            require('conform').format { async = true, lsp_format = 'fallback' }
          end,
          desc = 'Format buffer',
        },

        -- Search operations (fzf-lua)
        { '<leader>s', group = 'search' },
        {
          '<leader>sB',
          fzf.blines,
          desc = 'Search in current buffer',
        },
        { '<leader>sb', fzf.buffers, desc = 'Search existing buffers' },
        { '<leader>sh', fzf.help_tags, desc = 'Search Help' },
        { '<leader>sk', fzf.keymaps, desc = 'Search Keymaps' },
        { '<leader>sf', fzf.files, desc = 'Search Files' },
        { '<leader>sq', fzf.quickfix, desc = 'Search Quickfix List' },
        { '<leader>st', fzf.treesitter, desc = 'Search Treesitter' },
        { '<leader>ss', fzf.builtin, desc = 'Search Select FZF' },
        { '<leader>sw', fzf.grep_cword, desc = 'Search current Word' },
        { '<leader>sg', fzf.live_grep, desc = 'Search by Grep' },
        { '<leader>sd', fzf.diagnostics_document, desc = 'Search Diagnostics' },
        {
          '<leader>s/',
          function()
            fzf.grep {
              search = '',
              rg_opts = "--hidden --no-ignore --glob '!.git/*' -g '!node_modules/*'",
              prompt = 'Grep Open Files❯ ',
            }
          end,
          desc = 'Search in Open Files',
        },
        {
          '<leader>sn',
          function()
            fzf.files { cwd = vim.fn.stdpath 'config' }
          end,
          desc = 'Search Neovim files',
        },

        -- Workspace operations
        { '<leader><leader>', group = 'workspace' },
        { '<leader><leader>s', fzf.lsp_workspace_symbols, desc = 'Workspace Symbols' },
        { '<leader><leader>x', '<cmd>source %<CR>', desc = 'Source File' },
        { '<leader><leader>l', '<cmd>:.lua<CR>', desc = 'Source Line', mode = { 'n', 'v' } },
        { '<leader><leader>q', '<cmd>:q<CR>', desc = 'Quit Buffer' },
        { '<leader><leader>w', '<cmd>:w<CR>', desc = 'Save Buffer' },
        {
          '<leader><leader>h',
          function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end,
          desc = 'Toggle Inlay Hints',
        },

        -- Terminal operations
        { '<leader>t', group = 'Terminal' },
        { '<leader>d', group = 'Debugger' },
        { '<leader>h', group = 'Harpoon' },

        -- LSP goto operations
        { 'g', group = 'goto' },
        {
          'gd',
          fzf.lsp_definitions,
          desc = 'Goto Definition',
        },
        { 'gr', fzf.lsp_references, desc = 'Goto References' },
        { 'gI', fzf.lsp_implementations, desc = 'Goto Implementation' },
        { 'gD', vim.lsp.buf.declaration, desc = 'Goto Declaration' },

        { '<leader>r', group = 'Run Tests' },
      }
    end,
  },
}
