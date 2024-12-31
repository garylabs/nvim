return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-neotest/neotest-python',
      'thenbe/neotest-playwright',
    },
    config = function()
      -- Set up keymaps
      require('neotest').setup {
        adapters = {
          require 'neotest-python',
          require 'neotest-playwright',
        },
      }
      local map = vim.keymap.set

      -- Test running
      map('n', '<leader>rt', function()
        require('neotest').run.run()
      end, { desc = '[R]un: nearest [T]est' })
      map('n', '<leader>rf', function()
        require('neotest').run.run(vim.fn.expand '%')
      end, { desc = '[R]un: current [F]ile' })
      map('n', '<leader>ra', function()
        require('neotest').run.run(vim.fn.getcwd())
      end, { desc = '[R]un: [A]ll tests' })
      map('n', '<leader>rs', function()
        require('neotest').summary.toggle()
      end, { desc = '[R]un: Toggle [S]ummary' })
      map('n', '<leader>ro', function()
        require('neotest').output.open { enter = true }
      end, { desc = '[R]un: Open [O]utput' })
      map('n', '<leader>rp', function()
        require('neotest').output_panel.toggle()
      end, { desc = '[R]un: Toggle output [P]anel' })
      map('n', '<leader>rw', function()
        require('neotest').watch.toggle()
      end, { desc = '[R]un: Toggle [W]atch mode' })

      -- Test navigation
      map('n', '[t', function()
        require('neotest').jump.prev { status = 'failed' }
      end, { desc = 'Jump to previous failed test' })
      map('n', ']t', function()
        require('neotest').jump.next { status = 'failed' }
      end, { desc = 'Jump to next failed test' })
    end,
  },
}
